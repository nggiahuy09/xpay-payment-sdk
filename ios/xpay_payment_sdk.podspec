#
# iOS part of the XPay payment SDK: the native Swift API (`XPayPayment`) for hosts without Flutter.
# The payment logic itself is the Dart code in lib/.
#
Pod::Spec.new do |s|
  s.name             = 'xpay_payment_sdk'
  s.version          = '0.0.1'
  s.summary          = 'XPay payment SDK: native iOS API.'
  s.description      = <<-DESC
Collect a payment with an XPay card (QR scan or manual entry) from a native iOS app.
                       DESC
  s.homepage         = 'https://github.com/nggiahuy09/xpay-payment-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'XPERISE'
  s.source           = { :path => '.' }
  s.source_files     = 'xpay_payment_sdk/Sources/xpay_payment_sdk/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
