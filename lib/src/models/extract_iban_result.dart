import 'package:equatable/equatable.dart';

/// Interface for ExtractIBAN result
class ExtractIBANResult extends Equatable {
  final String iban;
  final String? bban;
  final String? countryCode;
  final String? accountNumber;
  final String? branchIdentifier;
  final String? bankIdentifier;
  final bool valid;

  const ExtractIBANResult({
    required this.iban,
    this.bban,
    this.countryCode,
    this.accountNumber,
    this.branchIdentifier,
    this.bankIdentifier,
    this.valid = false,
  });

  @override
  List<Object?> get props => <Object?>[
        iban,
        bban,
        countryCode,
        accountNumber,
        branchIdentifier,
        bankIdentifier,
        valid
      ];

  ExtractIBANResult copyWith(
          {String? iban,
          String? bban,
          String? countryCode,
          String? accountNumber,
          String? branchIdentifier,
          String? bankIdentifier,
          bool? valid}) =>
      ExtractIBANResult(
          iban: iban ?? this.iban,
          bban: bban ?? this.bban,
          countryCode: countryCode ?? this.countryCode,
          accountNumber: accountNumber ?? this.accountNumber,
          branchIdentifier: branchIdentifier ?? this.branchIdentifier,
          bankIdentifier: bankIdentifier ?? this.bankIdentifier,
          valid: valid ?? this.valid);
}
