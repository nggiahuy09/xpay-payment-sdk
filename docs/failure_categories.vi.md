# XPAY Payment SDK — Phân nhóm lỗi thanh toán

Tài liệu nghiệp vụ cho các trường hợp **thanh toán không thành công**: lỗi thuộc nhóm nào, do phía nào gây ra, và tài xế, app đối tác cần xử lý thế nào, đặc biệt khi phát sinh tranh
chấp giữa khách hàng và tài xế (ví dụ thẻ không đủ số dư và khách không muốn trả tiền mặt).

Áp dụng từ phiên bản SDK phát hành sau 3.1120.1, cho cả Flutter, Android native và iOS native.

## Mục lục

1. [Tổng quan](#1-tổng-quan)
2. [Các nhóm lỗi](#2-các-nhóm-lỗi)
3. [Danh sách mã theo nhóm](#3-danh-sách-mã-theo-nhóm)
4. [Quy tắc chung](#4-quy-tắc-chung)
5. [Tình huống tranh chấp thường gặp](#5-tình-huống-tranh-chấp-thường-gặp)

## 1. Tổng quan

`XPayPaymentResult` có thêm trường `failureCategory`, cho biết lỗi thuộc nhóm nào. App đối tác chỉ cần rẽ nhánh theo trường này, không cần đọc từng mã lỗi.

| Trường            | Kiểu                   | Ý nghĩa                                                                         |
| ----------------- | ---------------------- | ------------------------------------------------------------------------------- |
| `status`          | `XPayPaymentStatus`    | Kết quả thanh toán (không đổi)                                                  |
| `failureCategory` | `XPayFailureCategory?` | **Mới.** Nhóm lỗi, xem [mục 2](#2-các-nhóm-lỗi)                                 |
| `declineCode`     | `String?`              | Mã từ chối thô từ XPAY, khi `declined` (không đổi). Dùng để tra cứu và đối soát |
| `errorCode`       | `String?`              | Mã lỗi thô, khi `failed` (không đổi). Dùng để tra cứu và đối soát               |
| `message`         | `String?`              | Câu thông báo đã dịch, hiển thị được cho tài xế (không đổi)                     |
| `authId`          | `String?`              | Mã giao dịch XPAY, nếu thanh toán đã tới bước authorize (không đổi)             |

`failureCategory` có giá trị khi `status` là `declined`, `failed` hoặc `duplicate`. Với các trạng thái còn lại, trường này là `null`:

1. `approved`, `captured`: thanh toán thành công.
2. `cancelled`: tài xế chủ động thoát.
3. `expired`: hết thời gian xác thực OTP/PIN, tạo thanh toán mới.
4. `unsupported`: thiết bị không chạy được phương thức này, ẩn phương thức và chọn phương thức khác.

Cách xử lý trong tài liệu này là **quy định của XPAY**. Đầu mối hỗ trợ là **tổng đài XPAY**: khi cần thanh toán hộ, kiểm tra thẻ hoặc làm việc với doanh nghiệp sở hữu thẻ, tài xế
hoặc khách liên hệ tổng đài XPAY. SDK chỉ phân loại lỗi; việc hiển thị lựa chọn tiền mặt trên app do app đối tác thực hiện theo quy định này.

Tên giá trị theo nền tảng:

| Nhóm                | Flutter / iOS (Swift) | Android (Kotlin)    |
| ------------------- | --------------------- | ------------------- |
| Lỗi hệ thống        | `system`              | `SYSTEM`            |
| Lỗi kết nối         | `network`             | `NETWORK`           |
| Thử lại cùng thẻ    | `cardholderRetry`     | `CARDHOLDER_RETRY`  |
| Đổi thẻ/phương thức | `cardholderChange`    | `CARDHOLDER_CHANGE` |
| Chính sách DN       | `corporatePolicy`     | `CORPORATE_POLICY`  |
| Phiên/đơn hàng      | `session`             | `SESSION`           |
| Chưa xác định       | `unknown`             | `UNKNOWN`           |

## 2. Các nhóm lỗi

| Nhóm               | Phía gây ra                                    | Thử lại cùng thẻ | Cách xử lý                                                                                                                                                                                             |
| ------------------ | ---------------------------------------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `system`           | XPAY, SDK hoặc cấu hình merchant               | Có               | Cho thử lại. Nếu vẫn lỗi, **không thu tiền mặt của khách**: tài xế liên hệ tổng đài XPAY để được thanh toán hộ. Khách hàng và tài xế không có lỗi                                                      |
| `network`          | Kết nối mạng của thiết bị tài xế               | Có               | Tài xế khôi phục kết nối rồi thử lại. Nếu vẫn lỗi sau nhiều lần, **không thu tiền mặt của khách**: tài xế liên hệ tổng đài XPAY để được thanh toán hộ. Xem [mục 3.2](#32-network--lỗi-kết-nối)         |
| `cardholderRetry`  | Khách hàng: quét, chạm hoặc nhập thẻ chưa đúng | Có               | Cho khách quét, chạm hoặc nhập lại thẻ. Nếu thử lại vẫn lỗi, xử lý như `cardholderChange`                                                                                                              |
| `cardholderChange` | Khách hàng: thẻ không dùng được cho giao dịch  | Không            | Khách dùng thẻ hoặc phương thức khác, hoặc liên hệ tổng đài XPAY để kiểm tra thẻ. Nếu tổng đài xử lý được, tổng đài thanh toán hộ; nếu không, khách trả tiền mặt theo xác nhận của tổng đài            |
| `corporatePolicy`  | Quy định của doanh nghiệp sở hữu thẻ           | Không            | Liên hệ tổng đài XPAY, tổng đài làm việc với doanh nghiệp. Nếu doanh nghiệp không điều chỉnh, khách trả tiền mặt. Khách xuống xe khi tổng đài xác nhận đã thanh toán hộ hoặc khách đồng ý trả tiền mặt |
| `session`          | Phiên thanh toán, đơn hàng hoặc tích hợp       | Không            | **Không thu tiền bằng phương thức khác trước khi kiểm tra backend.** Mở phiên mới hoặc kiểm tra trạng thái chuyến/giao dịch                                                                            |
| `unknown`          | Chưa xác định                                  | —                | Xử lý như `system`, báo kèm `declineCode`/`errorCode` cho tổng đài XPAY                                                                                                                                |

## 3. Danh sách mã theo nhóm

Cột "Nguồn" cho biết mã nằm ở trường nào: `declineCode` (khi `declined`) hoặc `errorCode` (khi `failed`).

### 3.1. `system` — lỗi hệ thống

| Mã                                | Nguồn         | Nguyên nhân                                                   |
| --------------------------------- | ------------- | ------------------------------------------------------------- |
| `service_payment_failed`          | `declineCode` | Tài khoản doanh nghiệp không hoàn tất được giao dịch          |
| `service_payment_unavailable`     | `declineCode` | Dịch vụ tài khoản doanh nghiệp tạm thời gián đoạn             |
| `service_payment_auth_failed`     | `declineCode` | Không xác thực được giao dịch với tài khoản doanh nghiệp      |
| `service_payment_invalid_request` | `declineCode` | Tài khoản doanh nghiệp không xử lý được yêu cầu               |
| `employee_policy_unavailable`     | `declineCode` | Tạm thời chưa kiểm tra được chính sách chi tiêu               |
| `merchant_not_allowed`            | `declineCode` | Cấu hình merchant không cho phép thẻ này                      |
| `mcc_not_allowed`                 | `declineCode` | Cấu hình merchant không cho phép loại thẻ/merchant này        |
| `otp_delivery_failed`             | `errorCode`   | Không gửi được OTP tới số điện thoại của chủ thẻ              |
| `sdk_unexpected_response`         | `errorCode`   | XPAY trả trạng thái hoặc dữ liệu chip mà SDK không xử lý được |

`merchant_not_allowed` và `mcc_not_allowed` là lỗi do cấu hình merchant, không phải do khách hàng hay doanh nghiệp sở hữu thẻ, nên được xử lý như lỗi hệ thống.

Với Android native và iOS native, `sdk_unexpected_response` còn được trả khi kênh giữa app và màn hình SDK bị lỗi trước khi SDK kịp trả kết quả. Khi đó thanh toán có thể đã hoàn
tất, nên kết quả thuộc nhóm `session` thay vì `system` (xem [mục 3.6](#36-session--phiên-thanh-toán-đơn-hàng-tích-hợp)).

### 3.2. `network` — lỗi kết nối

| Mã              | Nguồn       | Nguyên nhân                                                            |
| --------------- | ----------- | ---------------------------------------------------------------------- |
| `no_connection` | `errorCode` | Thiết bị không có kết nối mạng (tắt Wi-Fi/dữ liệu di động, mất sóng)   |
| `no_host`       | `errorCode` | Không kết nối được tới server (lỗi DNS, mạng chặn, lỗi chứng chỉ)      |
| `timeout`       | `errorCode` | Server không phản hồi trong 30 giây. Giao dịch có thể đã được ghi nhận |

Nhóm này xử lý giống `system` (không thu tiền mặt, tổng đài thanh toán hộ) nhưng được tách riêng vì nguyên nhân thường nằm ở thiết bị của tài xế, không phải ở XPAY. Việc tách nhóm giúp
phân biệt hai loại lỗi khi đối soát và báo cáo.

1. Hiển thị `message` và yêu cầu tài xế khôi phục kết nối, rồi thử lại.
2. Thử lại với cùng phiên và cùng thẻ là an toàn: SDK dùng lại idempotency key nên khách không bị trừ tiền hai lần, kể cả khi yêu cầu trước đã tới XPAY trước lúc mất mạng.
3. Với `timeout`, backend đối tác kiểm tra giao dịch trước khi liên hệ tổng đài (xem [mục 4](#4-quy-tắc-chung)).

### 3.3. `cardholderRetry` — thử lại với cùng thẻ

| Mã                           | Nguồn         | Nguyên nhân                                                   | Cách xử lý                   |
| ---------------------------- | ------------- | ------------------------------------------------------------- | ---------------------------- |
| `verification_code_required` | `declineCode` | Giao dịch cần mã xác thực                                     | Thanh toán lại và nhập mã    |
| `token_invalid_or_expired`   | `declineCode` | Mã thanh toán (QR) không hợp lệ hoặc hết hạn                  | Khách mở mã mới rồi quét lại |
| `chip_nonce_replayed`        | `declineCode` | Lượt chạm thẻ đã được dùng cho giao dịch trước                | Chạm thẻ lại                 |
| `not_found`                  | `errorCode`   | Không tìm thấy thẻ hoặc mã thanh toán đã quét, chạm hoặc nhập | Quét, chạm hoặc nhập lại thẻ |

`not_found` gộp chung hai trường hợp mà XPAY không phân biệt được: quét hoặc nhập sai, và thẻ không tồn tại trong hệ thống. Mã được xếp vào nhóm này vì quét hoặc nhập sai là
trường hợp thường gặp. Nếu thử lại vẫn nhận `not_found`, xử lý như `cardholderChange`.

Nhập OTP/PIN được xử lý ngay trong màn hình của SDK, app đối tác không cần làm gì:

1. Nhập sai mã: khách nhập lại trên cùng màn hình. Số lần được nhập do XPAY quyết định. Nhập sai hết số lần thì thẻ bị khoá tạm thời và SDK trả `declined` thuộc nhóm
   `cardholderChange` ([mục 3.4](#34-cardholderchange--đổi-thẻ-hoặc-phương-thức)).
2. Mã hết hạn: khách yêu cầu mã mới trên cùng màn hình. Việc gửi lại có thời gian chờ giữa hai lần và giới hạn số lần cho mỗi giao dịch.
3. Hết thời gian xác thực của giao dịch: SDK trả status `expired` (`failureCategory` là `null`). Tạo thanh toán mới.

### 3.4. `cardholderChange` — đổi thẻ hoặc phương thức

| Mã                              | Nguồn         | Nguyên nhân                                                    | Cách xử lý                                            |
| ------------------------------- | ------------- | -------------------------------------------------------------- | ----------------------------------------------------- |
| `insufficient_funds`            | `declineCode` | Thẻ không đủ số dư (hạn mức còn lại của thẻ)                   | Dùng thẻ/phương thức khác, hoặc liên hệ tổng đài XPAY |
| `card_inactive`                 | `declineCode` | Thẻ chưa được kích hoạt                                        | Dùng thẻ/phương thức khác, hoặc liên hệ tổng đài XPAY |
| `card_blocked`                  | `declineCode` | Thẻ đã bị khoá                                                 | Dùng thẻ/phương thức khác, hoặc liên hệ tổng đài XPAY |
| `card_expired`                  | `declineCode` | Thẻ đã hết hạn                                                 | Dùng thẻ/phương thức khác, hoặc trả tiền mặt          |
| `card_outside_validity_window`  | `declineCode` | Thẻ không dùng được vào thời điểm này trong ngày               | Dùng thẻ/phương thức khác, hoặc liên hệ tổng đài XPAY |
| `card_link_inactive`            | `declineCode` | Người dùng không có quyền thanh toán bằng thẻ này              | Dùng thẻ/phương thức khác, hoặc liên hệ tổng đài XPAY |
| `card_locked_too_many_attempts` | `declineCode` | Thẻ tạm khoá do nhập sai mã PIN nhiều lần                      | Dùng thẻ/phương thức khác, hoặc liên hệ tổng đài XPAY |
| `verification_code_invalid`     | `declineCode` | Nhập sai OTP/PIN hết số lần cho phép, thẻ bị khoá tạm thời     | Dùng thẻ/phương thức khác, hoặc liên hệ tổng đài XPAY |
| `velocity_limit_exceeded`       | `declineCode` | Quá nhiều giao dịch trên thẻ trong thời gian ngắn, thẻ bị khoá | Dùng thẻ/phương thức khác, hoặc liên hệ tổng đài XPAY |
| `channel_not_allowed`           | `declineCode` | Thẻ không hỗ trợ cách nhập đang dùng                           | Dùng thẻ hoặc phương thức khác                        |
| `chip_cryptogram_invalid`       | `declineCode` | Không xác thực được thẻ qua NFC                                | Đổi cách nhập thẻ (quét QR, nhập số thẻ)              |
| `chip_counter_replay`           | `declineCode` | Tính năng NFC của thẻ cần kích hoạt lại                        | Đổi cách nhập thẻ (quét QR, nhập số thẻ)              |
| `chip_credential_revoked`       | `declineCode` | Thẻ đã bị vô hiệu hoá                                          | Dùng thẻ/phương thức khác, hoặc liên hệ tổng đài XPAY |
| `chip_credential_not_active`    | `declineCode` | Thẻ chưa hoàn tất thiết lập                                    | Dùng thẻ/phương thức khác, hoặc liên hệ tổng đài XPAY |
| `no_registered_phone`           | `errorCode`   | Thẻ không có số điện thoại để gửi OTP                          | Dùng thẻ/phương thức khác, hoặc liên hệ tổng đài XPAY |
| `static_code_unavailable`       | `errorCode`   | Thẻ chưa thiết lập mã PIN                                      | Dùng thẻ/phương thức khác, hoặc liên hệ tổng đài XPAY |

Khi khách liên hệ tổng đài XPAY, tổng đài kiểm tra thẻ với doanh nghiệp sở hữu thẻ (kích hoạt, mở khoá, cấp quyền, cập nhật thông tin) rồi thanh toán hộ. Nếu không xử lý được, khách
dùng phương thức khác hoặc trả tiền mặt theo xác nhận của tổng đài.

### 3.5. `corporatePolicy` — chính sách doanh nghiệp

| Mã                                     | Nguồn         | Nguyên nhân                                            |
| -------------------------------------- | ------------- | ------------------------------------------------------ |
| `per_transaction_limit_exceeded`       | `declineCode` | Vượt hạn mức mỗi giao dịch của thẻ                     |
| `daily_limit_exceeded`                 | `declineCode` | Thẻ đã đạt hạn mức trong ngày                          |
| `monthly_limit_exceeded`               | `declineCode` | Thẻ đã đạt hạn mức trong tháng                         |
| `corporate_monthly_limit_exceeded`     | `declineCode` | Hạn mức hằng tháng của doanh nghiệp không đủ           |
| `trip_budget_exceeded`                 | `declineCode` | Vượt ngân sách cho phép của chuyến đi                  |
| `policy_violation`                     | `declineCode` | Không được phép theo chính sách chi tiêu               |
| `employee_policy_violation`            | `declineCode` | Không được phép theo chính sách chi tiêu của nhân viên |
| `service_payment_insufficient_funds`   | `declineCode` | Tài khoản doanh nghiệp không đủ số dư                  |
| `service_payment_declined`             | `declineCode` | Tài khoản doanh nghiệp từ chối giao dịch               |
| `service_payment_user_invalid`         | `declineCode` | Tài khoản chủ thẻ không hợp lệ cho giao dịch           |
| — (ví doanh nghiệp, status `declined`) | —             | Ví doanh nghiệp từ chối khoản thanh toán qua mã QR     |

Các mã này được ghi nhận để đối soát với doanh nghiệp. Kết quả `declined` của thanh toán bằng ví doanh nghiệp không có `declineCode`.

### 3.6. `session` — phiên thanh toán, đơn hàng, tích hợp

| Mã                                | Nguồn         | Nguyên nhân                                                                                   | Cách xử lý                                                           |
| --------------------------------- | ------------- | --------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| `service_payment_in_flight`       | `declineCode` | Một giao dịch cho đơn hàng này đang được xử lý                                                | Kiểm tra giao dịch trên backend. Không thu lại khi chưa có kết quả   |
| `service_payment_duplicate_order` | `declineCode` | Đơn hàng đã được ghi nhận thanh toán trước đó                                                 | Kiểm tra giao dịch trên backend trước khi thu lại                    |
| `ride_already_paid`               | `errorCode`   | Chuyến đi đã có giao dịch thanh toán                                                          | Xác nhận chuyến đã thanh toán. Không thu thêm                        |
| `ride_card_not_found`             | `errorCode`   | Chuyến không còn giao cho tài xế hoặc không còn thanh toán được                               | Kiểm tra chuyến đi trên backend                                      |
| `ride_not_found`                  | `errorCode`   | Ví doanh nghiệp: chuyến đã đóng hoặc không còn mở để thanh toán                               | Kiểm tra trạng thái chuyến trước khi thu lại                         |
| `ride_not_on_corporate_wallet`    | `errorCode`   | Ví doanh nghiệp: chuyến không được đặt bằng ví doanh nghiệp                                   | Kiểm tra phương thức thanh toán của chuyến                           |
| `token_expired`                   | `errorCode`   | Mã phiên đã hết hạn                                                                           | Xin mã phiên mới rồi thanh toán lại                                  |
| `token_not_found`                 | `errorCode`   | XPAY không tìm thấy mã phiên                                                                  | Xin mã phiên mới rồi thanh toán lại                                  |
| `ride_payment_session_revoked`    | `errorCode`   | Backend đã mở phiên mới cho cùng chuyến                                                       | Dùng mã phiên mới nhất                                               |
| `amount_locked`                   | `errorCode`   | Số tiền khác số tiền đã khoá trong phiên                                                      | Truyền đúng số tiền của phiên, hoặc xin phiên mới                    |
| `sdk_invalid_request`             | `errorCode`   | Dữ liệu phiên truyền vào SDK không hợp lệ                                                     | Sửa dữ liệu truyền vào                                               |
| `sdk_not_initialized`             | `errorCode`   | Gọi thanh toán trước khi `initialize` xong                                                    | Chờ `initialize` xong rồi gọi lại                                    |
| `sdk_busy`                        | `errorCode`   | Đang có một thanh toán khác chưa trả kết quả                                                  | Chờ thanh toán trước trả kết quả. Không mở thanh toán song song      |
| `sdk_result_lost`                 | `errorCode`   | Chỉ Android: màn hình SDK được mở lại sau khi app bị hệ điều hành đóng, SDK không còn kết quả | Kiểm tra giao dịch trên backend bằng `externalRef` trước khi thu lại |
| `sdk_presentation_failed`         | `errorCode`   | Chỉ iOS: không mở được màn hình SDK do màn hình gọi SDK chưa hiển thị                         | Sửa luồng gọi SDK. SDK chưa gửi gì tới XPAY                          |
| `sdk_unexpected_response`         | `errorCode`   | Chỉ Android native và iOS native: kênh giữa app và màn hình SDK bị lỗi, SDK không trả được kết quả | Kiểm tra giao dịch trên backend bằng `externalRef` trước khi thu lại |
| — (status `duplicate`)            | —             | XPAY đang giữ một request khác dưới cùng idempotency key                                      | Kiểm tra giao dịch trên backend trước khi thu lại                    |

### 3.7. `unknown`

Mọi mã chưa có trong các bảng trên. `message` của các mã này kết thúc bằng dòng `Mã lỗi:` để tổng đài tra cứu. Khi XPAY bổ sung mã mới, SDK sẽ xếp mã đó vào nhóm phù hợp ở phiên
bản sau; app đối tác không cần sửa code nếu đã xử lý theo `failureCategory`.

## 4. Quy tắc chung

1. **Có `authId` thì phải kiểm tra backend trước.** Giao dịch có thể đã được XPAY ghi nhận dù app nhận kết quả lỗi (ví dụ mất mạng sau khi gửi yêu cầu). Thu thêm tiền lúc này có
   thể khiến khách bị thu hai lần.
2. **Nhóm `session` không được chuyển thẳng sang phương thức khác.** Phần lớn mã trong nhóm này cho biết đơn hàng có thể đã hoặc đang được thanh toán.
3. **Lưu lại kết quả lỗi** (`failureCategory`, `declineCode` hoặc `errorCode`, `authId`, thời điểm) cùng chuyến đi trên backend đối tác. Đây là căn cứ khi xử lý khiếu nại và đối soát.
4. **Thanh toán hộ dùng chung `externalRef` của chuyến.** Khi tổng đài XPAY thanh toán hộ, backend đối tác xác nhận chuyến đã được thanh toán bằng `externalRef`, giống cách xác nhận một
   thanh toán qua SDK (mục "Xác nhận thanh toán từ backend" trong tài liệu tích hợp). Tài xế không cần thanh toán lại trên app.

## 5. Tình huống tranh chấp thường gặp

| Tình huống                                                             | Nhóm               | Phía gây ra         | Cách xử lý                                                                                                                                                                             |
| ---------------------------------------------------------------------- | ------------------ | ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| XPAY gián đoạn, không gửi được OTP                                     | `system`           | Hệ thống            | Không thu tiền mặt. Tài xế liên hệ tổng đài XPAY để thanh toán hộ, sau khi kiểm tra `authId` (nếu có). Không quy lỗi cho khách hoặc tài xế                                             |
| Thẻ không được dùng với merchant hoặc loại merchant này                | `system`           | Cấu hình merchant   | Không thu tiền mặt. Tài xế liên hệ tổng đài XPAY để thanh toán hộ. Không quy lỗi cho khách                                                                                             |
| Thiết bị tài xế mất mạng hoặc tài xế tắt mạng                          | `network`          | Tài xế (thường gặp) | Tài xế khôi phục kết nối và thử lại. Nếu vẫn lỗi sau nhiều lần, tài xế liên hệ tổng đài XPAY để thanh toán hộ. Không yêu cầu khách trả tiền mặt vì lỗi này                             |
| Quét sai mã, chạm thẻ chưa đúng                                        | `cardholderRetry`  | Khách hàng          | Cho thử lại. Nếu khách không hoàn tất được, xử lý như dòng dưới                                                                                                                        |
| Thẻ không đủ số dư, bị khoá, hết hạn; khách không chịu trả tiền mặt    | `cardholderChange` | Khách hàng          | Khách dùng thẻ/phương thức khác, hoặc liên hệ tổng đài XPAY. Tổng đài kiểm tra với doanh nghiệp rồi thanh toán hộ; nếu không xử lý được, khách trả tiền mặt theo xác nhận của tổng đài |
| Khách nhập sai OTP/PIN hết số lần                                      | `cardholderChange` | Khách hàng          | Thẻ bị khoá tạm thời. Xử lý như dòng trên                                                                                                                                              |
| Thẻ không hỗ trợ cách nhập đang dùng                                   | `cardholderChange` | Khách hàng          | Dùng thẻ hoặc phương thức khác                                                                                                                                                         |
| Vượt hạn mức, sai chính sách chi tiêu, tài khoản doanh nghiệp hết tiền | `corporatePolicy`  | Doanh nghiệp        | Tổng đài XPAY làm việc với doanh nghiệp. Nếu doanh nghiệp không điều chỉnh, khách trả tiền mặt. Ghi nhận để đối soát                                                                   |
| Chuyến đã được thanh toán, giao dịch đang xử lý                        | `session`          | —                   | Không thu thêm. Kiểm tra trạng thái giao dịch trên backend                                                                                                                             |
