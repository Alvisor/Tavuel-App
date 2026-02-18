import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/availability_slot.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/entities/onboarding_status.dart';
import '../../domain/entities/provider_document.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/repositories/provider_onboarding_repository.dart';
import '../datasources/provider_onboarding_remote_datasource.dart';
import '../models/availability_model.dart';
import '../models/bank_account_model.dart';

class ProviderOnboardingRepositoryImpl implements ProviderOnboardingRepository {
  final ProviderOnboardingRemoteDatasource _datasource;

  ProviderOnboardingRepositoryImpl(this._datasource);

  @override
  Future<Result<Map<String, dynamic>?>> getMyProfile() async {
    try {
      final profile = await _datasource.getMyProfile();
      return Result.success(profile);
    } on UnauthorizedException {
      return Result.failure(
        const AuthFailure(message: 'Sesión expirada.'),
      );
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> createProfile({
    required String bio,
    required String address,
    required double latitude,
    required double longitude,
    required List<String> categoryIds,
  }) async {
    try {
      await _datasource.createProfile(
        bio: bio,
        address: address,
        latitude: latitude,
        longitude: longitude,
        categoryIds: categoryIds,
      );
      return Result.success(null);
    } on UnauthorizedException {
      return Result.failure(
        const AuthFailure(message: 'Sesión expirada.'),
      );
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<OnboardingStatus>> getOnboardingStatus() async {
    try {
      final status = await _datasource.getOnboardingStatus();
      return Result.success(status);
    } on UnauthorizedException {
      return Result.failure(
        const AuthFailure(message: 'Sesión expirada.'),
      );
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> updateProfile({
    String? bio,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? categoryIds,
  }) async {
    try {
      await _datasource.updateProfile(
        bio: bio,
        address: address,
        latitude: latitude,
        longitude: longitude,
        categoryIds: categoryIds,
      );
      return Result.success(null);
    } on UnauthorizedException {
      return Result.failure(
        const AuthFailure(message: 'Sesión expirada.'),
      );
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<ProviderDocument>> uploadDocument({
    required String filePath,
    required String documentType,
  }) async {
    try {
      final document = await _datasource.uploadDocument(
        filePath: filePath,
        documentType: documentType,
      );
      return Result.success(document);
    } on UnauthorizedException {
      return Result.failure(
        const AuthFailure(message: 'Sesión expirada.'),
      );
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<ProviderDocument>>> getDocuments() async {
    try {
      final documents = await _datasource.getDocuments();
      return Result.success(documents);
    } on UnauthorizedException {
      return Result.failure(
        const AuthFailure(message: 'Sesión expirada.'),
      );
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<BankAccount>> setBankAccount({
    required BankAccount bankAccount,
  }) async {
    try {
      final model = BankAccountModel(
        id: bankAccount.id,
        accountType: bankAccount.accountType,
        bankName: bankAccount.bankName,
        accountNumber: bankAccount.accountNumber,
        accountHolder: bankAccount.accountHolder,
        documentType: bankAccount.documentType,
        documentNumber: bankAccount.documentNumber,
        isVerified: bankAccount.isVerified,
      );
      final result = await _datasource.setBankAccount(bankAccount: model);
      return Result.success(result);
    } on UnauthorizedException {
      return Result.failure(
        const AuthFailure(message: 'Sesión expirada.'),
      );
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<BankAccount>> getBankAccount() async {
    try {
      final bankAccount = await _datasource.getBankAccount();
      return Result.success(bankAccount);
    } on UnauthorizedException {
      return Result.failure(
        const AuthFailure(message: 'Sesión expirada.'),
      );
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> setAvailability({
    required List<AvailabilitySlot> slots,
  }) async {
    try {
      final models = slots
          .map((s) => AvailabilitySlotModel(
                dayOfWeek: s.dayOfWeek,
                startTime: s.startTime,
                endTime: s.endTime,
              ))
          .toList();
      await _datasource.setAvailability(slots: models);
      return Result.success(null);
    } on UnauthorizedException {
      return Result.failure(
        const AuthFailure(message: 'Sesión expirada.'),
      );
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<AvailabilitySlot>>> getAvailability() async {
    try {
      final slots = await _datasource.getAvailability();
      return Result.success(slots);
    } on UnauthorizedException {
      return Result.failure(
        const AuthFailure(message: 'Sesión expirada.'),
      );
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> submitForVerification() async {
    try {
      await _datasource.submitForVerification();
      return Result.success(null);
    } on UnauthorizedException {
      return Result.failure(
        const AuthFailure(message: 'Sesión expirada.'),
      );
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<ServiceCategory>>> getCategories() async {
    try {
      final categories = await _datasource.getCategories();
      return Result.success(categories);
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }
}
