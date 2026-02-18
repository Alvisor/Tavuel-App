class BankAccount {
  final String? id;
  final String accountType;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String documentType;
  final String documentNumber;
  final bool isVerified;

  const BankAccount({
    this.id,
    required this.accountType,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    required this.documentType,
    required this.documentNumber,
    this.isVerified = false,
  });
}
