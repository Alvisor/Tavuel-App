import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository _repository;

  RegisterUsecase(this._repository);

  Future<Result<User>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    bool wantsToBeProvider = false,
  }) {
    return _repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      wantsToBeProvider: wantsToBeProvider,
    );
  }
}
