# Flutter IBANTools

![License](https://img.shields.io/badge/License-MIT-blue)

![GitHub last commit](https://img.shields.io/github/last-commit/Dennis-Mwea/flutter_iban_tools)
![GitHub contributors](https://img.shields.io/github/contributors/Dennis-Mwea/flutter_iban_tools)
![GitHub issues](https://img.shields.io/github/issues/Dennis-Mwea/flutter_iban_tools)
![GitHub closed issues](https://img.shields.io/github/issues-closed-raw/Dennis-Mwea/flutter_iban_tools)
![GitHub pull requests](https://img.shields.io/github/issues-pr/Dennis-Mwea/flutter_iban_tools)
![GitHub closed pull requests](https://img.shields.io/github/issues-pr-closed/Dennis-Mwea/flutter_iban_tools)

![No deps](https://img.shields.io/badge/dependencies-0-brightgreen)

## About

Flutter IBANTools is Flutter/Dart library for validation, creation and extraction of IBAN, BBAN and BIC/SWIFT numbers. Inspired by [ibantools](https://github.com/Simplify/ibantools)

For more information about IBAN/BBAN see [wikipedia page](https://en.wikipedia.org/wiki/International_Bank_Account_Number) and
[IBAN registry](https://www.swift.com/resource/iban-registry-pdf).

For more information about BIC/SWIFT see [this wikipedia page](https://en.wikipedia.org/wiki/ISO_9362).

## Installation

### Flutter/Dart

```
$ flutter pub add flutter_iban_tools
```

## Usage

See [full documentation](https://pub.dev/documentation/flutter_iban_tools/latest/) with examples on Github pages.

### Flutter/Dart

```dart
import 'package:flutter_iban_tools/flutter_iban_tools.dart' as ibantools;

void main() {
  final String? iban = electronicFormatIBAN('NL91 ABNA 0417 1643 00'); // 'NL91ABNA0517164300'
  ibantools.isValidIBAN(iban);
  
  // If you want to know reason why IBAN is invalid
  ibantools.validateIBAN('NL91ABNA0517164300'); 
  // Returns { valid: false, errorCodes: [iban.ValidationErrorsIBAN.WrongIBANChecksum] }

  // Validate BIC
  ibantools.isValidBIC('ABNANL2A');
}
```

### Extension

Country specifications can be extended with national BBAN validations by calling `setCountryBBANValidation`.

Example implementation coming soon

## Contributing

This project adheres to the Contributor Covenant [code of conduct](https://github.com/dennis-mwea/ibantools/blob/master/.github/CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code.

For contribution details, please read [this document](https://github.com/dennis-mwea/ibantools/blob/master/CONTRIBUTING.md).

## License

This work is dual-licensed under MIT and MPL-2.0.
You can choose between one of them if you use this work.

`SPDX-License-Identifier: MIT OR MPL-2.0`
