import 'package:equatable/equatable.dart';
import 'package:flutter_iban_tools/src/types/validation_errors_bic.dart';

/// Interface for ValidateBIC result
class ValidateBICResult extends Equatable {
  final List<ValidationErrorsBIC> errorCodes;
  final bool valid;

  const ValidateBICResult({required this.errorCodes, required this.valid});

  ValidateBICResult copyWith(
          {List<ValidationErrorsBIC>? errorCodes, bool? valid}) =>
      ValidateBICResult(
          errorCodes: errorCodes ?? this.errorCodes,
          valid: valid ?? this.valid);

  @override
  List<Object?> get props => <Object>[errorCodes, valid];
}
