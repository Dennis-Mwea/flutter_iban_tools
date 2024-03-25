import 'package:equatable/equatable.dart';

/// Interface for ComposeIBAN parameteres
class ComposeIBANParams extends Equatable {
  final String? countryCode;
  final String? bban;

  const ComposeIBANParams({this.countryCode, this.bban});

  @override
  List<Object?> get props => <Object?>[countryCode, bban];
}
