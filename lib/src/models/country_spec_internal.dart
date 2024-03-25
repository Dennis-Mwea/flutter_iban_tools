import 'package:equatable/equatable.dart';

/// Interface for IBAN Country Specification
class CountrySpecInternal extends Equatable {
  final num? chars;
  final RegExp? bbanRegexp;
  final bool Function(String)? bbanValidationFunc;
  final bool? iBANRegistry; // Is country part of official IBAN registry
  final bool? sepa; // Is county part of SEPA initiative
  final String? branchIdentifier;
  final String? bankIdentifier;
  final String? accountIdentifier;

  const CountrySpecInternal(
      {this.chars,
      this.bbanRegexp,
      this.bbanValidationFunc,
      this.iBANRegistry,
      this.sepa,
      this.branchIdentifier,
      this.bankIdentifier,
      this.accountIdentifier});

  @override
  List<Object?> get props => [
        chars,
        bbanRegexp,
        bbanValidationFunc,
        iBANRegistry,
        sepa,
        branchIdentifier,
        bankIdentifier,
        accountIdentifier,
      ];
}
