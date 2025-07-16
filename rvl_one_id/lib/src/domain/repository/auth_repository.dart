import 'package:rvl_one_id/src/domain/entities/one_id_config.dart';

abstract class AuthRepository {
  Future<bool> login({required OneIdConfig config});

  Future<bool> refreshToken({required OneIdConfig config});

  Future<bool> logout({required OneIdConfig config});
}
