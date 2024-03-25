import 'package:equatable/equatable.dart';
import 'package:flutter_iban_tools/src/types/validation_errors_iban.dart';

class ValidateIBANResult extends Equatable {
  final List<ValidationErrorsIBAN> errorCodes;
  final bool valid;

  const ValidateIBANResult({required this.errorCodes, required this.valid});

  ValidateIBANResult copyWith(
          {List<ValidationErrorsIBAN>? errorCodes, bool? valid}) =>
      ValidateIBANResult(
          errorCodes: errorCodes ?? this.errorCodes,
          valid: valid ?? this.valid);

  @override
  List<Object?> get props => <Object?>[errorCodes, valid];
}
