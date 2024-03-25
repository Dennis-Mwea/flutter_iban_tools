/// Interface for IBAN Country Specification
class CountrySpec {
  final bool? sepa;
  final int? chars;
  final bool? ibanRegistry;
  final String? bankIdentifier;
  final RegExp? bbanRegexp;
  final String? branchIdentifier;
  final String? accountIdentifier;
  final bool Function(String)? bbanValidationFunc;

  const CountrySpec(
      {this.sepa,
      this.chars,
      this.ibanRegistry,
      this.bankIdentifier,
      this.bbanRegexp,
      this.branchIdentifier,
      this.accountIdentifier,
      this.bbanValidationFunc});

  static const CountrySpec empty = CountrySpec();

  CountrySpec copyWith(
          {bool? sepa,
          int? chars,
          bool? ibanRegistry,
          String? bankIdentifier,
          RegExp? bbanRegexp,
          String? branchIdentifier,
          String? accountIdentifier,
          bool Function(String)? bbanValidationFunc}) =>
      CountrySpec(
          sepa: sepa ?? this.sepa,
          chars: chars ?? this.chars,
          ibanRegistry: ibanRegistry ?? this.ibanRegistry,
          bankIdentifier: bankIdentifier ?? this.bankIdentifier,
          bbanRegexp: bbanRegexp ?? this.bbanRegexp,
          branchIdentifier: branchIdentifier ?? this.branchIdentifier,
          accountIdentifier: accountIdentifier ?? this.accountIdentifier,
          bbanValidationFunc: bbanValidationFunc ?? this.bbanValidationFunc);
}
