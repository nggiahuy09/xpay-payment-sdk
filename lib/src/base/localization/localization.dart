import 'locale/locale_base/locale_base.dart';
import 'locale/locale_en/locale_en.dart';
import 'locale/locale_vi/locale_vi.dart';

export 'locale/locale_base/locale_base.dart';

final class XPLocalization {
  XPLocalization._();

  static final XPLocalization instance = XPLocalization._();

  XPLocaleBase get locale => _selectedLocale;
  XPLocaleBase _selectedLocale = const XPLocaleVI();

  String get localeId => _localeEnum.localeId;

  XPLocale get localeEnum => _localeEnum;
  XPLocale _localeEnum = XPLocale.vi;

  void changeLocale(XPLocale localeEnum) {
    _localeEnum = localeEnum;
    _selectedLocale = switch (localeEnum) {
      XPLocale.en => const XPLocaleEN(),
      XPLocale.vi => const XPLocaleVI(),
    };
  }
}

enum XPLocale {
  en('en'),
  vi('vi');

  const XPLocale(this.localeId);

  final String localeId;
}
