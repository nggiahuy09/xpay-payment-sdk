import '../../../../../../base/gateway/api/api.dart';
import '../models/corporate_wallet_recipient_model.dart';

final class CorporateWalletRecipientsResource extends XPResource<List<CorporateWalletRecipientModel>> {
  const CorporateWalletRecipientsResource() : super(description: 'Get corporate wallet OTP recipients');

  @override
  XPHttpMethod get method => XPHttpMethod.get;

  @override
  String get path => '/merchant/wallet-payments/recipients';

  @override
  List<CorporateWalletRecipientModel> parse(Object? data) => (data as List<dynamic>).map((json) => CorporateWalletRecipientModel.fromJson(json as Map<String, dynamic>)).toList();
}
