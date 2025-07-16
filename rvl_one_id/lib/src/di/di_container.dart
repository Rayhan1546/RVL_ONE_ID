import 'dart:async';

abstract class DiContainer {
  Future<void> register<T>(T instance);

  Future<void> registerSingleton<T>(T instance);

  Future<T> resolve<T>();

  Future<bool> isRegistered<T>();

  Future<void> unregister<T>();

  Future<void> unregisterSingleton<T>();
}
