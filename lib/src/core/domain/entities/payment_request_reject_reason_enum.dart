enum PaymentRequestRejectReason {
  invalidSessionJson('invalid_session_json'),
  malformedSession('malformed_session'),
  missingSessionToken('missing_session_token'),
  missingEntryModes('missing_entry_modes'),
  invalidAmount('invalid_amount'),
  amountBelowMinimum('amount_below_minimum'),
  missingCurrency('missing_currency'),
  invalidExternalRef('invalid_external_ref');

  const PaymentRequestRejectReason(this.code);

  final String code;
}
