import 'package:equatable/equatable.dart';

/// Interface for validation options
class ValidateIBANOptions extends Equatable {
  final bool allowQRIBAN;

  const ValidateIBANOptions({this.allowQRIBAN = true});

  @override
  List<Object?> get props => <Object?>[allowQRIBAN];
}
