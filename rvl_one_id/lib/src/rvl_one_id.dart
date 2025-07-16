import 'package:flutter/material.dart';
import 'package:rvl_one_id/src/core/di/data_module.dart';
import 'package:rvl_one_id/src/data/data_source/secure_storage_manager/token_manager.dart';
import 'package:rvl_one_id/src/di/di_module.dart';
import 'package:rvl_one_id/src/domain/entities/one_id_config.dart';
import 'package:rvl_one_id/src/domain/use_cases/login_use_case.dart';
import 'package:rvl_one_id/src/domain/use_cases/logout_use_case.dart';
import 'package:rvl_one_id/src/domain/use_cases/refresh_token_use_case.dart';
import 'package:rvl_one_id/src/feature/registration_web_view.dart';

class RvlOneId {
  static final RvlOneId _singleton = RvlOneId._internal();
  factory RvlOneId() => _singleton;
  RvlOneId._internal();

  final DataModule _dataModule = DataModule();
  final DiModule _diModule = DiModule();

  late LoginUseCae _loginUseCae;
  late RefreshTokenUseCase _refreshTokenUseCase;
  late LogoutUseCase _logoutUseCase;

  late TokenManger _tokenManger;

  OneIdConfig? _config;
  bool _isInitialized = false;

  Future<void> initialize({required OneIdConfig config}) async {
    config.validate();

    _config = config;
    _isInitialized = true;
    await _dataModule.injectDependencies();

    _loginUseCae = await _diModule.resolve<LoginUseCae>();
    _refreshTokenUseCase = await _diModule.resolve<RefreshTokenUseCase>();
    _logoutUseCase = await _diModule.resolve<LogoutUseCase>();

    _tokenManger = await _diModule.resolve<TokenManger>();

    final tokens = await _tokenManger.getAuthTokens();

    if (tokens != null) {
      await _refreshTokenUseCase.execute(config: config);
    }
  }

  Future<bool> login() async {
    _ensureInitialized();

    return await _loginUseCae.execute(config: _config!);
  }

  Future<void> registration({required BuildContext context}) async {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => RegistrationWebView(
        initialUrl: "https://d1bowc4dzkfcje.cloudfront.net/",
        targetUrlHostName: "https://d1bowc4dzkfcje.cloudfront.net/login",
        onSuccess: (String? accessToken) async {
          Navigator.pop(context);
        },
      ),
    );

    await Navigator.push(context, route);
  }

  Future<bool> refreshAccessToken() async {
    _ensureInitialized();

    return await _refreshTokenUseCase.execute(config: _config!);
  }

  Future<bool> logout() async {
    _ensureInitialized();

    return await _logoutUseCase.execute(config: _config!);
  }

  Future<String?> getAccessToken() async {
    final tokens = await _tokenManger.getAuthTokens();

    return tokens?.accessToken ?? "";
  }

  Future<bool> isUserLoggedIn() async {
    final tokens = await _tokenManger.getAuthTokens();

    return tokens != null;
  }

  void _ensureInitialized() {
    if (!_isInitialized || _config == null) {
      throw StateError('OneId must be initialized before use');
    }
  }
}