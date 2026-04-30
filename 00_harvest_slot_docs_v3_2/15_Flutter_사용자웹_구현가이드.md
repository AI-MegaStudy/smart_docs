# Flutter 사용자 웹 구현 가이드

## 1. 폴더 구조

```text
frontend_user_web/
  lib/
    main.dart
    core/
      router.dart
      api_client.dart
      auth_store.dart
      local_basket_store.dart
      theme.dart
    models/
      product_model.dart
      harvest_slot_model.dart
      reservation_model.dart
      order_model.dart
      payment_model.dart
      return_model.dart
    pages/
      home_page.dart
      product_list_page.dart
      product_detail_page.dart
      local_basket_page.dart
      signup_page.dart
      email_verify_page.dart
      login_page.dart
      reservation_confirm_page.dart
      checkout_page.dart
      mock_payment_page.dart
      order_complete_page.dart
      my_orders_page.dart
      order_detail_page.dart
      return_request_page.dart
    widgets/
      product_card.dart
      harvest_slot_card.dart
      status_badge.dart
      price_text.dart
      notice_box.dart
```

## 2. 라우팅

| Route | Page |
|---|---|
| `/` | HomePage |
| `/products` | ProductListPage |
| `/products/:id` | ProductDetailPage |
| `/basket` | LocalBasketPage |
| `/signup` | SignupPage |
| `/verify-email` | EmailVerifyPage |
| `/login` | LoginPage |
| `/reservation/confirm` | ReservationConfirmPage |
| `/checkout/:reservationId` | CheckoutPage |
| `/payment/:orderId` | MockPaymentPage |
| `/orders/complete/:orderId` | OrderCompletePage |
| `/me/orders` | MyOrdersPage |
| `/me/orders/:orderId` | OrderDetailPage |
| `/me/orders/:orderId/return` | ReturnRequestPage |

## 3. 로컬 예약함 모델

서버 저장 전 사용자가 선택한 상품과 슬롯을 임시로 저장한다.

```dart
class LocalBasketItem {
  final int slotId;
  final int productId;
  final String productName;
  final String farmName;
  final DateTime harvestStart;
  final DateTime harvestEnd;
  final double packageUnitKg;
  final int unitPrice;
  int packageCount;

  double get reservedKg => packageUnitKg * packageCount;
  int get subtotalAmount => unitPrice * packageCount;
}
```

## 4. 예약 생성 흐름

```text
ProductDetailPage
→ LocalBasketStore.addItem()
→ LocalBasketPage
→ ReservationConfirmPage
→ POST /reservations
→ CheckoutPage
```

예약 생성 성공 후 서버가 반환하는 `reservation_id`를 기준으로 주문서 작성 화면으로 이동한다.

## 5. 상태 표시 컴포넌트

`StatusBadge`는 주문 상태를 한국어로 변환한다.

| 상태 | 표시 |
|---|---|
| `PAYMENT_PENDING` | 결제 대기 |
| `PROCUREMENT_REQUESTED` | 농가 확인 중 |
| `QUALITY_CHECKING` | 선별 중 |
| `READY_TO_SHIP` | 발송 준비 |
| `SHIPPED` | 배송 중 |
| `DELIVERED` | 배송 완료 |

## 6. 화면 개발 우선순위

1. 로그인/회원가입/이메일 인증
2. 상품 목록/상세
3. 로컬 예약함
4. 예약 확인/주문서 작성
5. Mock 결제/주문 완료
6. 마이페이지/주문 상세
7. 반품 신청
