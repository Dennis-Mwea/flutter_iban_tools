/// Interface for ValidateIBAN result
enum ValidationErrorsIBAN {
  noIBANProvided,
  noIBANCountry,
  wrongBBANLength,
  wrongBBANFormat,
  checksumNotNumber,
  wrongIBANChecksum,
  wrongAccountBankBranchChecksum,
  qRIBANNotAllowed
}
