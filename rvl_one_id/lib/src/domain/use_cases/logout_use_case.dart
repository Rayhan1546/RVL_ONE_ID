import 'package:rvl_one_id/src/domain/entities/one_id_config.dart';
import 'package:rvl_one_id/src/domain/repository/auth_repository.dart';

class LogoutUseCase {
  LogoutUseCase({required this.authRepository});

  final AuthRepository authRepository;

  Future<bool> execute({required OneIdConfig config}) async {
    return await authRepository.logout(config: config);
  }
}
