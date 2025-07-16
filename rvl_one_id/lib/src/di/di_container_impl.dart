import 'dart:async';

import 'package:rvl_one_id/src/di/di_container.dart';

class DiContainerImpl extends DiContainer {
  static final DiContainerImpl _instance = DiContainerImpl._internal();

  factory DiContainerImpl() => _instance;

  final Map<String, List<dynamic>> _dependencies = {};
  final Map<String, dynamic> _singletons = {};

  // Using AsyncLock ensures thread safety when accessing shared resources in an
  // asynchronous environment. In Dart, operations such as registering and
  // resolving dependencies might happen concurrently, leading to race conditions
  // and data inconsistencies. The AsyncLock class helps synchronize these operations,
  // ensuring that only one operation can modify the shared resources at a time.
  final _lock = AsyncLock();

  DiContainerImpl._internal();

  @override
  Future<void> register<T>(T instance) async {
    final key = T.toString();
    await _lock.synchronized(() {
      if (!_dependencies.containsKey(key)) {
        _dependencies[key] = [];
      }
      _dependencies[key]!.add(instance);
    });
  }

  @override
  Future<void> registerSingleton<T>(T instance) async {
    final key = T.toString();
    await _lock.synchronized(() {
      if (_singletons.containsKey(key)) {
        throw DependencyError.alreadyRegistered;
      }
      _singletons[key] = instance;
    });
  }

  @override
  Future<T> resolve<T>() async {
    final key = T.toString();
    return await _lock.synchronized<T>(() {
      if (_singletons.containsKey(key)) {
        return _singletons[key] as T;
      } else if (_dependencies.containsKey(key) &&
          _dependencies[key]!.isNotEmpty) {
        return _dependencies[key]!.last as T;
      } else {
        throw DependencyError.notRegistered;
      }
    });
  }

  @override
  Future<bool> isRegistered<T>() async {
    final key = T.toString();
    return await _lock.synchronized(() {
      return (_dependencies.containsKey(key) &&
              _dependencies[key]!.isNotEmpty) ||
          _singletons.containsKey(key);
    });
  }

  @override
  Future<void> unregister<T>() async {
    final key = T.toString();
    if (!(await isRegistered<T>())) {
      throw DependencyError.notRegistered;
    }
    await _lock.synchronized(() {
      _dependencies[key]?.removeLast();
    });
  }

  @override
  Future<void> unregisterSingleton<T>() async {
    final key = T.toString();
    if (!(await isRegistered<T>())) {
      throw DependencyError.notRegistered;
    }
    await _lock.synchronized(() {
      _singletons.remove(key);
    });
  }
}

enum DependencyError implements Exception {
  alreadyRegistered,
  notRegistered,
}

// Example Scenario
//
// Let’s consider an example where this mechanism is important. Assume two asynchronous operations register and resolve are called nearly at the same time.
//
// Without a lock:
//
// •	register could start modifying the _dependencies map.
// •	Meanwhile, resolve could be trying to read from the same map concurrently.
// •	This concurrent access may lead to race conditions and inconsistent state (e.g., the map could be read while being modified).
//
// With the lock:
//
// •	The first operation (say register) creates a lock (Completer<void>()) and starts.
// •	The second operation (say resolve) checks the lock (await _completer!.future) and waits until the first operation finishes.
// •	Once register completes and the lock is released (_completer!.complete()), the second operation can proceed safely, knowing that the map is in a consistent state.

class AsyncLock {
  Completer<void>? _completer;

  Future<T> synchronized<T>(FutureOr<T> Function() action) async {
    // Wait for any ongoing operation
    if (_completer != null) {
      await _completer!.future;
    }

    // Create a new lock
    final lock = Completer<void>();
    _completer = lock;

    try {
      return await action();
    } finally {
      // Safely complete the lock and reset it
      lock.complete();
      _completer = null;
    }
  }
}
