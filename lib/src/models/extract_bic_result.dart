import 'package:equatable/equatable.dart';

/// Interface for ExtractBIC result
class ExtractBICResult extends Equatable {
  final String? bankCode;
  final String? countryCode;
  final String? locationCode;
  final String? branchCode;
  final bool testBIC;
  final bool valid;

  const ExtractBICResult(
      {this.bankCode,
      this.countryCode,
      this.locationCode,
      this.branchCode,
      required this.testBIC,
      required this.valid});

  ExtractBICResult copyWith(
          {String? bankCode,
          String? countryCode,
          String? locationCode,
          String? branchCode,
          bool? testBIC,
          bool? valid}) =>
      ExtractBICResult(
          bankCode: bankCode ?? this.bankCode,
          countryCode: countryCode ?? this.countryCode,
          locationCode: locationCode ?? this.locationCode,
          branchCode: branchCode ?? this.branchCode,
          testBIC: testBIC ?? this.testBIC,
          valid: valid ?? this.valid);

  @override
  List<Object?> get props => <Object?>[
        bankCode,
        countryCode,
        locationCode,
        branchCode,
        testBIC,
        valid
      ];
}
