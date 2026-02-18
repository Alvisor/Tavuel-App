import '../../domain/entities/bank_account.dart';

class BankAccountModel extends BankAccount {
  const BankAccountModel({
    super.id,
    required super.accountType,
    required super.bankName,
    required super.accountNumber,
    required super.accountHolder,
    required super.documentType,
    required super.documentNumber,
    super.isVerified,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] as String?,
      accountType: json['accountType'] as String,
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      accountHolder: json['accountHolder'] as String,
      documentType: json['documentType'] as String,
      documentNumber: json['documentNumber'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountType': accountType,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolder': accountHolder,
      'documentType': documentType,
      'documentNumber': documentNumber,
    };
  }
}
