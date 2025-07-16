import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:rvl_one_id/src/data/data_source/secure_storage_manager/token_manager.dart';
import 'package:rvl_one_id/src/data/repository/auth_repository_impl.dart';
import 'package:rvl_one_id/src/di/di_module.dart';
import 'package:rvl_one_id/src/domain/repository/auth_repository.dart';
import 'package:rvl_one_id/src/domain/use_cases/login_use_case.dart';
import 'package:rvl_one_id/src/domain/use_cases/logout_use_case.dart';
import 'package:rvl_one_id/src/domain/use_cases/refresh_token_use_case.dart';

class DataModule {
  DataModule._internal();

  static final DataModule _instance = DataModule._internal();

  factory DataModule() => _instance;

  final DiModule _diModule = DiModule();

  Future<void> injectDependencies() async {
    await injectServices();
    await injectLocalDataSources();
    await injectRepositories();
    await injectUseCases();
  }

  Future<void> removeDependencies() async {
    await removeServices();
    await removeLocalDataSources();
    await removeRepositories();
    await removeUseCases();
  }

  Future<void> injectServices() async {
    await _diModule.registerSingleton<FlutterAppAuth>(FlutterAppAuth());
  }

  Future<void> removeServices() async {
    await _diModule.unregisterSingleton<FlutterAppAuth>();
  }

  Future<void> injectLocalDataSources() async {
    await _diModule.registerSingleton<TokenManger>(TokenManger());
  }

  Future<void> removeLocalDataSources() async {
    await _diModule.unregisterSingleton<TokenManger>();
  }

  Future<void> injectRepositories() async {
    final appAuth = await _diModule.resolve<FlutterAppAuth>();

    final tokenManager = await _diModule.resolve<TokenManger>();

    await _diModule.registerSingleton<AuthRepository>(AuthRepositoryImpl(
      appAuth: appAuth,
      tokenManger: tokenManager,
    ));
  }

  Future<void> removeRepositories() async {
    await _diModule.unregisterSingleton<AuthRepository>();
  }

  Future<void> injectUseCases() async {
    final authRepository = await _diModule.resolve<AuthRepository>();

    await _diModule.registerSingleton<LoginUseCae>(LoginUseCae(
      authRepository: authRepository,
    ));

    await _diModule.registerSingleton<RefreshTokenUseCase>(RefreshTokenUseCase(
      authRepository: authRepository,
    ));

    await _diModule.registerSingleton<LogoutUseCase>(LogoutUseCase(
      authRepository: authRepository,
    ));
  }

  Future<void> removeUseCases() async {
    await _diModule.unregisterSingleton<LoginUseCae>();
    await _diModule.unregisterSingleton<RefreshTokenUseCase>();
    await _diModule.unregisterSingleton<LogoutUseCase>();
  }
}
