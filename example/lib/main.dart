import 'package:flutter/material.dart';
import 'package:flutter_iban_tools/flutter_iban_tools.dart' as ibantools;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool bic = ibantools.isValidIBAN('DE64 5001 0517 9423 8144 35');
  debugPrint('Iban is valid: ${bic}'); // result: INGDDEFFXXX
}
