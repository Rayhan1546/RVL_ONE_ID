import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:rvl_one_id/src/data/data_source/secure_storage_manager/token_manager.dart';
import 'package:rvl_one_id/src/data/model/auth_tokens.dart';
import 'package:rvl_one_id/src/domain/entities/one_id_config.dart';
import 'package:rvl_one_id/src/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required FlutterAppAuth appAuth,
    required TokenManger tokenManger,
  })  : _appAuth = appAuth,
        _tokenManger = tokenManger;

  final FlutterAppAuth _appAuth;
  final TokenManger _tokenManger;

  @override
  Future<bool> login({required OneIdConfig config}) async {
    try {
      final AuthorizationTokenResponse result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          config.clientId,
          config.redirectUri,
          issuer: config.issuer,
          scopes: config.scopes,
          clientSecret: config.clientSecret,
        ),
      );

      await _tokenManger.saveAuthTokens(
        tokens: AuthTokens(
          accessToken: result.accessToken ?? "",
          refreshToken: result.refreshToken ?? "",
          appIdToken: result.idToken ?? "",
        ),
      );

      return true;
    } catch (e) {
      await _tokenManger.delete();
      return false;
    }
  }

  @override
  Future<bool> refreshToken({required OneIdConfig config}) async {
    try {
      final tokens = await _tokenManger.getAuthTokens();

      if (tokens == null) return false;

      final TokenResponse result = await _appAuth.token(
        TokenRequest(
          config.clientId,
          config.redirectUri,
          issuer: config.issuer,
          refreshToken: tokens.refreshToken,
          scopes: config.scopes,
        ),
      );

      await _tokenManger.saveAuthTokens(
        tokens: AuthTokens(
          accessToken: result.accessToken ?? "",
          refreshToken: result.refreshToken ?? "",
          appIdToken: result.idToken ?? "",
        ),
      );

      return true;
    } catch (e) {
      await logout(config: config);
      return false;
    }
  }

  @override
  Future<bool> logout({required OneIdConfig config}) async {
    try {
      final tokens = await _tokenManger.getAuthTokens();

      if (tokens != null) {
        await _appAuth.endSession(
          EndSessionRequest(
            idTokenHint: tokens.appIdToken,
            issuer: config.issuer,
            postLogoutRedirectUrl: config.redirectUri,
          ),
        );
      }
    } catch (e) {
      throw Exception("Failed to logout: $e");
    } finally {
      await _tokenManger.deleteAll();
    }
    return true;
  }
}
