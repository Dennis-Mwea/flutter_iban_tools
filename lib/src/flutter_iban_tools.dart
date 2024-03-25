import 'package:flutter_iban_tools/src/models/_country_specs.dart';
import 'package:flutter_iban_tools/src/models/compose_iban_params.dart';
import 'package:flutter_iban_tools/src/models/country_spec.dart';
import 'package:flutter_iban_tools/src/models/extract_bic_result.dart';
import 'package:flutter_iban_tools/src/models/extract_iban_result.dart';
import 'package:flutter_iban_tools/src/models/validate_bic_result.dart';
import 'package:flutter_iban_tools/src/models/validate_iban_options.dart';
import 'package:flutter_iban_tools/src/models/validate_iban_result.dart';
import 'package:flutter_iban_tools/src/types/validation_errors_bic.dart';
import 'package:flutter_iban_tools/src/types/validation_errors_iban.dart';

/// Validate IBAN
/// ```
/// // returns true
/// ibantools.isValidIBAN("NL91ABNA0417164300");
/// ```
/// ```
/// // returns false
/// ibantools.isValidIBAN("NL92ABNA0517164300");
/// ```
/// ```
/// // returns true
/// ibantools.isValidIBAN('CH4431999123000889012');
/// ```
/// ```
/// // returns false
/// ibantools.isValidIBAN('CH4431999123000889012', { allowQRIBAN: false });
/// ```
bool isValidIBAN(String iban,
    {ValidateIBANOptions options = const ValidateIBANOptions()}) {
  if (iban.isEmpty) {
    return false;
  }

  final RegExp reg = RegExp(r'^[0-9]{2}$');
  final String countryCode = iban.substring(0, 2);
  final CountrySpec? spec = countrySpecs[countryCode];

  if (spec == null || spec.bbanRegexp == null || spec.chars == null) {
    return false;
  }

  return (spec.chars == iban.length &&
      reg.hasMatch(iban.substring(2, 4)) &&
      isValidBBAN(iban.substring(4), countryCode) &&
      isValidIBANChecksum(iban) &&
      (options.allowQRIBAN || !isQRIBAN(iban)));
}

/// validateIBAN
/// ```
/// // returns {errorCodes: [], valid: true}
/// barstools.validateIBAN("NL91ABNA0417164300");
/// ```
/// ```
/// ```
/// // returns {errorCodes: [], valid: true}
/// ibantools.validateIBAN('CH4431999123000889012');
/// ```
/// ```
/// // returns {errorCodes: [7], valid: false}
/// ibantools.validateIBAN('CH4431999123000889012', { allowQRIBAN: false });
/// ```
ValidateIBANResult validateIBAN(String? iban,
    {ValidateIBANOptions validationOptions = const ValidateIBANOptions()}) {
  ValidateIBANResult result = const ValidateIBANResult(
      errorCodes: <ValidationErrorsIBAN>[], valid: true);
  if (iban != null && iban.isNotEmpty) {
    final CountrySpec? spec = countrySpecs[iban.substring(0, 2)];
    if (spec == null || !(spec.bbanRegexp != null || spec.chars != null)) {
      result = result.copyWith(
          valid: false,
          errorCodes: List<ValidationErrorsIBAN>.of(
              result.errorCodes..add(ValidationErrorsIBAN.noIBANCountry)));
      return result;
    }

    if (spec.chars != null && spec.chars != iban.length) {
      result = result.copyWith(
          valid: false,
          errorCodes: List<ValidationErrorsIBAN>.of(
              result.errorCodes..add(ValidationErrorsIBAN.wrongBBANLength)));
    }

    if (spec.bbanRegexp != null &&
        !_checkFormatBBAN(iban.substring(4), spec.bbanRegexp!)) {
      result = result.copyWith(
          valid: false,
          errorCodes: List<ValidationErrorsIBAN>.of(
              result.errorCodes..add(ValidationErrorsIBAN.wrongBBANFormat)));
    }

    if (spec.bbanValidationFunc != null &&
        !spec.bbanValidationFunc!(iban.substring(4))) {
      result = result.copyWith(
          valid: false,
          errorCodes: List<ValidationErrorsIBAN>.of(result.errorCodes
            ..add(ValidationErrorsIBAN.wrongAccountBankBranchChecksum)));
    }

    final RegExp reg = RegExp(r'^[0-9]{2}$');
    if (!reg.hasMatch(iban.substring(2, 4))) {
      result = result.copyWith(
          valid: false,
          errorCodes: List<ValidationErrorsIBAN>.of(
              result.errorCodes..add(ValidationErrorsIBAN.checksumNotNumber)));
    }

    if (result.errorCodes.contains(ValidationErrorsIBAN.wrongBBANFormat) ||
        !isValidIBANChecksum(iban)) {
      result = result.copyWith(
          valid: false,
          errorCodes: List<ValidationErrorsIBAN>.of(
              result.errorCodes..add(ValidationErrorsIBAN.wrongIBANChecksum)));
    }

    if (!validationOptions.allowQRIBAN && isQRIBAN(iban)) {
      result = result.copyWith(
          valid: false,
          errorCodes: List<ValidationErrorsIBAN>.of(
              result.errorCodes..add(ValidationErrorsIBAN.qRIBANNotAllowed)));
    }
  } else {
    result = result.copyWith(
        valid: false,
        errorCodes: List<ValidationErrorsIBAN>.of(
            result.errorCodes..add(ValidationErrorsIBAN.noIBANProvided)));
  }

  return result;
}

/// Validate BBAN
///
/// ```
/// // returns true
/// ibantools.isValidBBAN("ABNA0417164300", "NL");
/// ```
/// ```
/// // returns false
/// ibantools.isValidBBAN("A7NA0517164300", "NL");
/// ```
bool isValidBBAN(String? bban, String countryCode) {
  if (bban == null || bban.isEmpty || countryCode.isEmpty) {
    return false;
  }

  final CountrySpec? spec = countrySpecs[countryCode];

  if (spec == null ||
      spec == CountrySpec.empty ||
      spec.bbanRegexp == null ||
      spec.chars == null) {
    return false;
  }

  if (spec.chars! - 4 == bban.length &&
      _checkFormatBBAN(bban, spec.bbanRegexp!)) {
    if (spec.bbanValidationFunc != null) {
      return spec.bbanValidationFunc!(bban.replaceAll(RegExp(r'[\s.]+'), ''));
    }
    return true;
  }

  return false;
}

/// Validate if country code is from a SEPA country
/// ```
/// // returns true
/// ibantools.isSEPACountry("NL");
/// ```
/// ```
/// // returns false
/// ibantools.isSEPACountry("PK");
/// ```
bool isSEPACountry(String countryCode) {
  if (countryCode.isNotEmpty) {
    final CountrySpec? spec = countrySpecs[countryCode];
    if (spec != null) {
      return spec.sepa != null ? spec.sepa! : false;
    }
  }

  return false;
}

/// Check if IBAN is QR-IBAN
/// ```
/// // returns true
/// ibantools.isQRIBAN("CH4431999123000889012");
/// ```
/// ```
/// // returns false
/// barstools.isQRIBAN("NL92ABNA0517164300");
/// ```
bool isQRIBAN(String? iban) {
  if (iban == null || iban.isEmpty) {
    return false;
  }

  final String countryCode = iban.substring(0, 2);
  final List<String> qRIBANCountries = <String>['LI', 'CH'];
  if (!qRIBANCountries.contains(countryCode)) {
    return false;
  }

  final RegExp reg = RegExp(r'^3[0-1]{1}[0-9]{3}$');

  return reg.hasMatch(iban.substring(4, 9));
}

/// composeIBAN
///
/// ```
/// // returns NL91ABNA0417164300
/// ibantools.composeIBAN({ countryCode: "NL", bban: "ABNA0417164300" });
/// ```
String? composeIBAN(ComposeIBANParams params) {
  final String? formattedBban = electronicFormatIBAN(params.bban);
  if (params.countryCode == null || params.countryCode!.isEmpty) {
    return null;
  }

  final CountrySpec? spec = countrySpecs[params.countryCode];
  if (formattedBban != null &&
      formattedBban.isNotEmpty &&
      spec != null &&
      spec.chars != null &&
      spec.chars == formattedBban.length + 4 &&
      spec.bbanRegexp != null &&
      _checkFormatBBAN(formattedBban, spec.bbanRegexp!)) {
    final int checksum = mod9710Iban('${params.countryCode!}00$formattedBban');

    return '${params.countryCode!}${('0${(98 - checksum)}').substring(-2)}$formattedBban';
  }

  return null;
}

/// extractIBAN
/// ```
/// // returns {iban: "NL91ABNA0417164300", bban: "ABNA0417164300", countryCode: "NL", valid: true, accountNumber: '0417164300', bankIdentifier: 'ABNA'}
/// ibantools.extractIBAN("NL91 ABNA 0417 1643 00");
/// ```
ExtractIBANResult extractIBAN(String iban) {
  ExtractIBANResult result = ExtractIBANResult(iban: iban);
  final String? eFormatIBAN = electronicFormatIBAN(iban);
  result = result.copyWith(iban: eFormatIBAN ?? iban);
  if (eFormatIBAN != null && isValidIBAN(eFormatIBAN)) {
    result = result.copyWith(
        bban: eFormatIBAN.substring(4),
        countryCode: eFormatIBAN.substring(0, 2),
        valid: true);
    final CountrySpec? spec = countrySpecs[result.countryCode];
    if (spec?.accountIdentifier != null) {
      final List<String> ac = spec!.accountIdentifier!.split('-');
      final int starting = int.parse(ac[0]);
      final int ending = int.parse(ac[1]);
      result = result.copyWith(
          accountNumber: result.iban.substring(starting, ending + 1));
    }

    if (spec?.bankIdentifier != null) {
      final List<String> ac = spec!.bankIdentifier!.split('-');
      final int starting = int.parse(ac[0]);
      final int ending = int.parse(ac[1]);
      result = result.copyWith(
          bankIdentifier: result.bban!.substring(starting, ending + 1));
    }

    if (spec?.branchIdentifier != null) {
      final List<String> ac = spec!.branchIdentifier!.split('-');
      final int starting = int.parse(ac[0]);
      final int ending = int.parse(ac[1]);
      result = result.copyWith(
          branchIdentifier: result.bban!.substring(starting, ending + 1));
    }
  } else {
    result = result.copyWith(valid: false);
  }

  return result;
}

/// Check BBAN format
///
/// @ignore
bool _checkFormatBBAN(String bban, RegExp bFormat) => bFormat.hasMatch(bban);

/// Get IBAN in electronic format (no spaces)
/// IBAN validation is not performed.
/// When non-string value for IBAN is provided, returns null.
/// ```
/// // returns "NL91ABNA0417164300"
/// ibantools.electronicFormatIBAN("NL91 ABNA 0417 1643 00");
/// ```
String? electronicFormatIBAN(String? iban) {
  if (iban is! String) {
    return null;
  }

  return iban.replaceAll(' ', '').toUpperCase();
}

/// Get IBAN in friendly format (separated after every 4 characters)
/// IBAN validation is not performed.
/// When non-string value for IBAN is provided, returns null.
/// ```
/// // returns "NL91 ABNA 0417 1643 00"
/// barstools.friendlyFormatIBAN("NL91ABNA0417164300");
/// ```
/// ```
/// // returns "NL91-ABNA-0417-1643-00"
/// ibantools.friendlyFormatIBAN("NL91ABNA0417164300","-");
/// ```
String? friendlyFormatIBAN(String? iban, String? separator) {
  separator ??= ' ';
  final String? electronicIban = electronicFormatIBAN(iban);
  if (electronicIban == null) {
    return null;
  }
  return electronicIban.replaceAll(RegExp(r'(.{4})(?!$)'), '1$separator');
}

/// Calculate checksum of IBAN and compares it with checksum provided in IBAN Registry
///
/// @ignore
bool isValidIBANChecksum(String iban) {
  final String countryCode = iban.substring(0, 2);
  final int providedChecksum = int.parse(iban.substring(2, 4), radix: 10);
  final String bban = iban.substring(4);

  // Wikipedia[validating_iban] says there are a specif way to check if a IBAN is valid but
  // it. It says 'If the remainder is 1, the check digit test is passed and the
  // IBAN might be valid.'. might, MIGHT!
  // We don't want might but want yes or no. Since every BBAN is IBAN from the fifth
  // (slice(4)) we can generate the IBAN from BBAN and country code(two first characters)
  // from in the IBAN.
  // To generate the (generate the iban check digits)[generating-iban-check]
  //   Move the country code to the end
  //   remove the checksum from the begging
  //   Add "00" to the end
  //   modulo 97 on the amount
  //   subtract remainder from 98, (98 - remainder)
  //   Add a leading 0 if the remainder is less then 10 (padStart(2, "0")) (we skip this
  //     since we compare int, not string)
  //
  // [validating_iban][https://en.wikipedia.org/wiki/International_Bank_Account_Number#Validating_the_IBAN]
  // [generating-iban-check][https://en.wikipedia.org/wiki/International_Bank_Account_Number#Generating_IBAN_check_digits]

  final String validationString =
      replaceCharacterWithCode('$bban${countryCode}00');
  final int rest = mod9710(validationString);

  return 98 - rest == providedChecksum;
}

/// Iban contain characters and should be converted to integer by 55 subtracted
/// from there ascii value
///
/// @ignore
String replaceCharacterWithCode(String str) {
  // It is slower but a lot more readable
  // https://jsbench.me/ttkzgsekae/1
  return str.split('').map((String c) {
    final int code = c.codeUnitAt(0);

    return code >= 65 ? (code - 55).toString() : c;
  }).join('');
}

/// MOD-97-10
///
/// @ignore
int mod9710Iban(String iban) =>
    mod9710(replaceCharacterWithCode(iban.substring(4) + iban.substring(0, 4)));

/// Returns specifications for all countries, even those who are not
/// members of IBAN registry. `IBANRegistry` field indicates if country
/// is member of not.
///
/// ```
/// // Validating IBAN form field after user selects his country
/// // <select id="countries">
/// //   ...
/// //   <option value="NL">Netherlands</option>
/// //   ...
/// // </select>
/// $("#countries").select(function() {
///   // Find country
///   let country = ibantools.getCountrySpecifications()[$(this).val()];
///   // Add country code letters to IBAN form field
///   $("input#iban").value($(this).val());
///   // Add New value to "pattern" attribute to #iban input text field
///   $("input#iban").attr("pattern", $(this).val() + "[0-9]{2}" + country.bban_regexp.slice(1).replace("$",""));
/// });
/// ```
Map<String, CountrySpec> getCountrySpecifications() {
  Map<String, CountrySpec> countyMap = const <String, CountrySpec>{};
  countrySpecs.forEach((String key, CountrySpec value) {
    final CountrySpec? county = countrySpecs[key];
    countyMap[key] = CountrySpec(
        chars: county?.chars,
        bbanRegexp: county?.bbanRegexp,
        ibanRegistry: county?.ibanRegistry ?? false,
        sepa: county?.sepa ?? false);
  });

  return countyMap;
}

/// Validate BIC/SWIFT
///
/// ```
/// // returns true
/// ibantools.isValidBIC("ABNANL2A");
///
/// // returns true
/// ibantools.isValidBIC("NEDSZAJJXXX");
///
/// // returns false
/// ibantools.isValidBIC("ABN4NL2A");
///
/// // returns false
/// ibantools.isValidBIC("ABNA NL 2A");
/// ```
bool isValidBIC(String? bic) {
  if (bic == null) {
    return false;
  }
  final RegExp reg = RegExp(r'^[a-zA-Z]{6}[a-zA-Z0-9]{2}([a-zA-Z0-9]{3})?$');
  final CountrySpec? spec = countrySpecs[bic.toUpperCase().substring(4, 6)];

  return reg.hasMatch(bic) && spec != null;
}

/// validateBIC
/// ```
/// // returns {errorCodes: [], valid: true}
/// ibantools.validateBIC("NEDSZAJJXXX");
/// ```
ValidateBICResult validateBIC(String? bic) {
  ValidateBICResult result =
      const ValidateBICResult(errorCodes: <ValidationErrorsBIC>[], valid: true);
  if (bic != null && bic.isNotEmpty) {
    final CountrySpec? spec = countrySpecs[bic.toUpperCase().substring(4, 6)];
    if (spec == null) {
      result = result.copyWith(
          valid: false,
          errorCodes: List<ValidationErrorsBIC>.of(
              result.errorCodes..add(ValidationErrorsBIC.noBICCountry)));
    } else {
      final RegExp reg =
          RegExp(r'^[a-zA-Z]{6}[a-zA-Z0-9]{2}([a-zA-Z0-9]{3})?$');
      if (!reg.hasMatch(bic)) {
        result = result.copyWith(
            valid: false,
            errorCodes: List<ValidationErrorsBIC>.of(
                result.errorCodes..add(ValidationErrorsBIC.wrongBICFormat)));
      }
    }
  } else {
    result = result.copyWith(
        valid: false,
        errorCodes: List<ValidationErrorsBIC>.of(
            result.errorCodes..add(ValidationErrorsBIC.noBICProvided)));
  }
  return result;
}

/// extractBIC
/// ```
/// // returns {bankCode: "ABNA", countryCode: "NL", locationCode: "2A", branchCode: null, testBIC: false, valid: true}
/// ibantools.extractBIC("ABNANL2A");
/// ```
ExtractBICResult extractBIC(String inputBic) {
  ExtractBICResult result =
      const ExtractBICResult(bankCode: '', testBIC: false, valid: false);
  final String bic = inputBic.toUpperCase();
  if (isValidBIC(bic)) {
    result = result.copyWith(
        bankCode: bic.substring(0, 4),
        countryCode: bic.substring(4, 6),
        locationCode: bic.substring(6, 8),
        testBIC: result.locationCode![1] == '0' ? true : false,
        branchCode: bic.length > 8 ? bic.substring(8) : null,
        valid: true);
  } else {
    result = result.copyWith(valid: false);
  }
  return result;
}

/// Used for Norway BBAN check
///
/// @ignore
bool checkNorwayBBAN(String bban) {
  const List<int> weights = <int>[5, 4, 3, 2, 7, 6, 5, 4, 3, 2];
  final String bbanWithoutSpacesAndPeriods =
      bban.replaceAll(RegExp(r'[\s.]+'), '');
  final int controlDigit =
      int.parse(bbanWithoutSpacesAndPeriods[10], radix: 10);
  final String bbanWithoutControlDigit =
      bbanWithoutSpacesAndPeriods.substring(0, 10);
  int sum = 0;
  for (int index = 0; index < 10; index++) {
    sum +=
        int.parse(bbanWithoutControlDigit[index], radix: 10) * weights[index];
  }
  final int remainder = sum % 11;

  return controlDigit == (remainder == 0 ? 0 : 11 - remainder);
}

/// Used for Belgian BBAN check
///
/// @ignore
bool checkBelgianBBAN(String bban) {
  final String stripped = bban.replaceAll(RegExp(r'[\s.]+'), '');
  final int checkingPart =
      int.parse(stripped.substring(0, stripped.length - 2), radix: 10);
  final int checksum = int.parse(
      stripped.substring(stripped.length - 2, stripped.length),
      radix: 10);
  final int remainder = checkingPart % 97 == 0 ? 97 : checkingPart % 97;

  return remainder == checksum;
}

/// Mod 97/10 calculation
///
/// @ignore
int mod9710(String validationString) {
  while (validationString.length > 2) {
    // > Any computer programming language or software package that is used to compute D
    // > mod 97 directly must have the ability to handle integers of more than 30 digits.
    // > In practice, this can only be done by software that either supports
    // > arbitrary-precision arithmetic or that can handle 219-bit (unsigned) integers
    // https://en.wikipedia.org/wiki/International_Bank_Account_Number#Modulo_operation_on_IBAN
    late final String part;
    try {
      part = validationString.substring(0, 6);
    } on RangeError catch (_) {
      part = validationString;
    }

    final int partInt = int.parse(part, radix: 10);
    validationString =
        '${(partInt % 97)}${validationString.substring(part.length)}';
  }
  return int.parse(validationString, radix: 10) % 97;
}

/// Check BBAN based on Mod97/10 calculation for countries that support it:
/// BA, ME, MK, PT, RS, SI
///
/// @ignore
bool checkMod9710BBAN(String bban) {
  final String stripped = bban.replaceAll(RegExp(r'[\s.]+'), '');
  final int reminder = mod9710(stripped);

  return reminder == 1;
}

/// Used for Poland BBAN check
///
/// @ignore
bool checkPolandBBAN(String bban) {
  const List<int> weights = <int>[3, 9, 7, 1, 3, 9, 7];
  final int controlDigit = int.parse(bban[7], radix: 10);
  final String toCheck = bban.substring(0, 7);
  int sum = 0;
  for (int index = 0; index < 7; index++) {
    sum += int.parse(toCheck[index], radix: 10) * weights[index];
  }
  final int remainder = sum % 10;

  return controlDigit == (remainder == 0 ? 0 : 10 - remainder);
}

/// Spain (ES) BBAN check
///
/// @ignore
bool checkSpainBBAN(String bban) {
  const List<int> weightsBankBranch = <int>[4, 8, 5, 10, 9, 7, 3, 6];
  const List<int> weightsAccount = <int>[1, 2, 4, 8, 5, 10, 9, 7, 3, 6];
  final int controlBankBranch = int.parse(bban[8], radix: 10);
  final int controlAccount = int.parse(bban[9], radix: 10);
  final String bankBranch = bban.substring(0, 8);
  final String account = bban.substring(10, 20);
  int sum = 0;
  for (int index = 0; index < 8; index++) {
    sum += int.parse(bankBranch[index], radix: 10) * weightsBankBranch[index];
  }
  int remainder = sum % 11;
  if (controlBankBranch !=
      (remainder == 0
          ? 0
          : remainder == 1
              ? 1
              : 11 - remainder)) {
    return false;
  }
  sum = 0;
  for (int index = 0; index < 10; index++) {
    sum += int.parse(account[index], radix: 10) * weightsAccount[index];
  }
  remainder = sum % 11;
  return controlAccount ==
      (remainder == 0
          ? 0
          : remainder == 1
              ? 1
              : 11 - remainder);
}

/// Mod 11/10 check
///
/// @ignore
bool checkMod1110(String toCheck, num control) {
  int nr = 10;
  for (int index = 0; index < toCheck.length; index++) {
    nr += int.parse(toCheck[index], radix: 10);
    if (nr % 10 != 0) {
      nr = nr % 10;
    }
    nr = nr * 2;
    nr = nr % 11;
  }
  return control == (11 - nr == 10 ? 0 : 11 - nr);
}

/// Croatian (HR) BBAN check
///
/// @ignore
bool checkCroatianBBAN(String bban) {
  final int controlBankBranch = int.parse(bban[6], radix: 10);
  final int controlAccount = int.parse(bban[16], radix: 10);
  final String bankBranch = bban.substring(0, 6);
  final String account = bban.substring(7, 16);

  return checkMod1110(bankBranch, controlBankBranch) &&
      checkMod1110(account, controlAccount);
}

/// Czech (CZ) and Slowak (SK) BBAN check
///
/// @ignore
bool checkCzechAndSlovakBBAN(String bban) {
  const List<int> weightsPrefix = <int>[10, 5, 8, 4, 2, 1];
  const List<int> weightsSuffix = <int>[6, 3, 7, 9, 10, 5, 8, 4, 2, 1];
  final int controlPrefix = int.parse(bban[9], radix: 10);
  final int controlSuffix = int.parse(bban[19], radix: 10);
  final String prefix = bban.substring(4, 9);
  final String suffix = bban.substring(10, 19);
  int sum = 0;
  for (int index = 0; index < prefix.length; index++) {
    sum += int.parse(prefix[index], radix: 10) * weightsPrefix[index];
  }
  int remainder = sum % 11;
  if (controlPrefix !=
      (remainder == 0
          ? 0
          : remainder == 1
              ? 1
              : 11 - remainder)) {
    return false;
  }
  sum = 0;
  for (int index = 0; index < suffix.length; index++) {
    sum += int.parse(suffix[index], radix: 10) * weightsSuffix[index];
  }
  remainder = sum % 11;
  return controlSuffix ==
      (remainder == 0
          ? 0
          : remainder == 1
              ? 1
              : 11 - remainder);
}

/// Estonian (EE) BBAN check
///
/// @ignore
bool checkEstonianBBAN(String bban) {
  const List<int> weights = <int>[7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7];
  final int controlDigit = int.parse(bban[15], radix: 10);
  final String toCheck = bban.substring(2, 15);
  int sum = 0;
  for (int index = 0; index < toCheck.length; index++) {
    sum += int.parse(toCheck[index], radix: 10) * weights[index];
  }
  final int remainder = sum % 10;

  return controlDigit == (remainder == 0 ? 0 : 10 - remainder);
}

/// Check French (FR) BBAN
/// Also for Monaco (MC)
///
/// @ignore
bool checkFrenchBBAN(String bban) {
  final String stripped = bban.replaceAll(RegExp(r'[\s.]+'), '');
  final List<String> normalized = stripped.split('');
  for (int index = 0; index < stripped.length; index++) {
    final int c = normalized[index].codeUnitAt(0);
    if (c >= 65) {
      switch (c) {
        case 65:
        case 74:
          normalized[index] = '1';
          break;
        case 66:
        case 75:
        case 83:
          normalized[index] = '2';
          break;
        case 67:
        case 76:
        case 84:
          normalized[index] = '3';
          break;
        case 68:
        case 77:
        case 85:
          normalized[index] = '4';
          break;
        case 69:
        case 78:
        case 86:
          normalized[index] = '5';
          break;
        case 70:
        case 79:
        case 87:
          normalized[index] = '6';
          break;
        case 71:
        case 80:
        case 88:
          normalized[index] = '7';
          break;
        case 72:
        case 81:
        case 89:
          normalized[index] = '8';
          break;
        case 73:
        case 82:
        case 90:
          normalized[index] = '9';
          break;
      }
    }
  }
  final int remainder = mod9710(normalized.join(''));
  return remainder == 0;
}

/// Hungarian (HU) BBAN check
///
/// @ignore
bool checkHungarianBBAN(String bban) {
  const List<int> weights = <int>[9, 7, 3, 1, 9, 7, 3, 1, 9, 7, 3, 1, 9, 7, 3];
  final int controlDigitBankBranch = int.parse(bban[7], radix: 10);
  final String toCheckBankBranch = bban.substring(0, 7);
  int sum = 0;
  for (int index = 0; index < toCheckBankBranch.length; index++) {
    sum += int.parse(toCheckBankBranch[index], radix: 10) * weights[index];
  }
  int remainder = sum % 10;
  if (controlDigitBankBranch != (remainder == 0 ? 0 : 10 - remainder)) {
    return false;
  }
  sum = 0;
  if (bban.endsWith('00000000')) {
    final String toCheckAccount = bban.substring(8, 15);
    final int controlDigitAccount = int.parse(bban[15], radix: 10);
    for (int index = 0; index < toCheckAccount.length; index++) {
      sum += int.parse(toCheckAccount[index], radix: 10) * weights[index];
    }
    int remainder = sum % 10;
    return controlDigitAccount == (remainder == 0 ? 0 : 10 - remainder);
  } else {
    final String toCheckAccount = bban.substring(8, 23);
    final int controlDigitAccount = int.parse(bban[23], radix: 10);
    for (int index = 0; index < toCheckAccount.length; index++) {
      sum += int.parse(toCheckAccount[index], radix: 10) * weights[index];
    }
    int remainder = sum % 10;
    return controlDigitAccount == (remainder == 0 ? 0 : 10 - remainder);
  }
}

/// Set custom BBAN validation function for country.
///
/// If `bban_validation_func` already exists for the corresponding country,
/// it will be overwritten.
bool setCountryBBANValidation(String country, bool Function(String) func) {
  if (countrySpecs[country] == null) {
    return false;
  }

  countrySpecs.update(
      country, (CountrySpec value) => value.copyWith(bbanValidationFunc: func));

  return true;
}
