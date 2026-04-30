# API 설계서

## 1. 공통 규칙

Base URL:

```text
/api/v1
```

응답 기본 구조:

```json
{
  "data": {},
  "message": "success",
  "error": null
}
```

인증이 필요한 API는 `Authorization: Bearer <access_token>` 헤더를 사용한다.

## 2. 인증 API

| Method | Endpoint | 설명 | 관련 테이블 |
|---|---|---|---|
| POST | `/auth/customers/signup` | 고객 회원가입 | `accounts`, `customer_profiles`, `email_verifications` |
| POST | `/auth/owners/signup` | 점주 회원가입 | `accounts`, `owner_profiles`, `email_verifications` |
| POST | `/auth/email/resend` | 인증 코드 재발송 | `email_verifications` |
| POST | `/auth/email/verify` | 이메일 인증 완료 | `email_verifications`, `accounts` |
| POST | `/auth/login` | 로그인 | `accounts` |
| GET | `/me` | 내 계정 정보 | `accounts`, `customer_profiles`, `owner_profiles` |

회원가입 Request 예시:

```json
{
  "email": "customer@test.com",
  "password": "pass1234!",
  "name": "홍길동",
  "phone": "010-1111-2222"
}
```

## 3. 상품/농장 API

| Method | Endpoint | 설명 | 권한 | 관련 테이블 |
|---|---|---|---|---|
| GET | `/farms/{farm_id}` | 농장 정보 조회 | 공개 | `farms` |
| GET | `/products` | 상품 목록 조회 | 공개 | `products`, `farms`, `harvest_slots` |
| GET | `/products/{product_id}` | 상품 상세 조회 | 공개 | `products`, `farms`, `harvest_slots` |
| GET | `/products/{product_id}/slots` | 상품 수확 슬롯 조회 | 공개 | `harvest_slots` |
| GET | `/owner/farms/me` | 점주 농장 조회 | 점주 | `farms` |
| PUT | `/owner/farms/{farm_id}` | 농장 수정 | 점주 | `farms` |
| GET | `/owner/products` | 점주 상품 목록 | 점주 | `products` |
| POST | `/owner/products` | 상품 등록 | 점주 | `products` |
| PUT | `/owner/products/{product_id}` | 상품 수정 | 점주 | `products` |
| PATCH | `/owner/products/{product_id}/status` | 상품 상태 변경 | 점주 | `products` |

## 4. ML 예측 API

| Method | Endpoint | 설명 | 관련 테이블 |
|---|---|---|---|
| POST | `/owner/ml/predictions` | 수확 예측 실행 및 저장 | `ml_predictions` |
| GET | `/owner/ml/predictions` | 예측 이력 조회 | `ml_predictions` |
| GET | `/owner/ml/predictions/{prediction_id}` | 예측 상세 조회 | `ml_predictions` |

Request:

```json
{
  "farm_id": 1,
  "product_id": 3,
  "features": {
    "farm_area": 1200,
    "tree_count": 180,
    "past_yield_kg": 900,
    "avg_temperature": 23.5,
    "avg_humidity": 68.0,
    "rainfall": 12.0
  }
}
```

Response:

```json
{
  "prediction_id": 10,
  "predicted_harvest_start": "2026-10-12",
  "predicted_harvest_end": "2026-10-18",
  "estimated_yield_kg": 420.0,
  "suggested_reservable_min_kg": 260.0,
  "suggested_reservable_max_kg": 320.0,
  "recommended_price": 39000,
  "confidence": 0.78,
  "safety_factor": 0.7,
  "warning_message": "기상과 생육 상황에 따라 점주 확정값을 조정하세요."
}
```

## 5. 수확 슬롯 API

| Method | Endpoint | 설명 | 관련 테이블 |
|---|---|---|---|
| GET | `/owner/harvest-slots` | 점주 슬롯 목록 | `harvest_slots` |
| POST | `/owner/harvest-slots` | 수확 슬롯 생성 | `harvest_slots` |
| PUT | `/owner/harvest-slots/{slot_id}` | 수확 슬롯 수정 | `harvest_slots` |
| PATCH | `/owner/harvest-slots/{slot_id}/status` | 슬롯 상태 변경 | `harvest_slots` |

POST Request:

```json
{
  "farm_id": 1,
  "product_id": 3,
  "prediction_id": 10,
  "confirmed_harvest_start": "2026-10-12",
  "confirmed_harvest_end": "2026-10-18",
  "confirmed_reservable_kg": 300.0,
  "confirmed_price": 39000,
  "customer_notice": "수확 예정 범위는 기상 상황에 따라 조정될 수 있습니다.",
  "slot_status": "OPEN"
}
```

## 6. 예약 API

| Method | Endpoint | 설명 | 관련 테이블 |
|---|---|---|---|
| POST | `/reservations/preview` | 예약 전 금액/수량 검증 | `harvest_slots` |
| POST | `/reservations` | 예약 생성 | `reservations`, `reservation_items`, `harvest_slots` |
| GET | `/me/reservations` | 내 예약 목록 | `reservations` |
| GET | `/owner/reservations` | 점주 예약 목록 | `reservations`, `reservation_items` |

POST `/reservations` Request:

```json
{
  "items": [
    {
      "slot_id": 12,
      "package_count": 2
    }
  ]
}
```

처리 규칙:

```text
1. 각 slot_id의 harvest_slots 행을 잠근다.
2. available_kg를 계산한다.
3. package_count * package_unit_kg가 available_kg 이하인지 검증한다.
4. reservations, reservation_items를 생성한다.
5. harvest_slots.reserved_kg를 증가시킨다.
```

## 7. 주문 API

| Method | Endpoint | 설명 | 관련 테이블 |
|---|---|---|---|
| POST | `/orders/from-reservation` | 예약을 주문으로 전환 | `orders`, `order_items`, `reservations` |
| GET | `/me/orders` | 내 주문 목록 | `orders`, `payments`, `shipments` |
| GET | `/me/orders/{order_id}` | 내 주문 상세 | `orders`, `order_items`, `payments`, `procurements`, `shipments`, `return_requests` |
| GET | `/owner/orders` | 점주 주문 목록 | `orders`, `order_items` |

POST Request:

```json
{
  "reservation_id": 5,
  "receiver_name": "홍길동",
  "receiver_phone": "010-1111-2222",
  "shipping_address": "서울시 강남구 ...",
  "delivery_memo": "문 앞에 놓아주세요"
}
```

## 8. 결제 API

| Method | Endpoint | 설명 | 관련 테이블 |
|---|---|---|---|
| POST | `/payments/mock-approve` | Mock 결제 승인 | `payments`, `orders`, `harvest_slots`, `procurements`, `procurement_items` |
| GET | `/me/orders/{order_id}/payments` | 주문 결제 목록 | `payments` |

POST Request:

```json
{
  "order_id": 8,
  "idempotency_key": "order-8-pay-001"
}
```

## 9. 발주 API

| Method | Endpoint | 설명 | 관련 테이블 |
|---|---|---|---|
| GET | `/owner/procurements` | 발주 목록 | `procurements` |
| GET | `/owner/procurements/{procurement_id}` | 발주 상세 | `procurements`, `procurement_items` |
| PATCH | `/owner/procurements/{procurement_id}/decision` | 발주 승인/부분승인/거절 | `procurements`, `procurement_items`, `orders`, `order_items` |

PATCH Request:

```json
{
  "decision": "APPROVED",
  "items": [
    {
      "procurement_item_id": 20,
      "approved_package_count": 2,
      "approved_kg": 10.0,
      "owner_memo": "정상 승인"
    }
  ],
  "rejected_reason": null
}
```

## 10. 신선도 검사 API

| Method | Endpoint | 설명 | 관련 테이블 |
|---|---|---|---|
| POST | `/owner/quality-inspections` | 이미지 업로드 및 DL 검사 저장 | `quality_inspections` |
| GET | `/owner/quality-inspections` | 검사 이력 목록 | `quality_inspections` |

Response:

```json
{
  "quality_inspection_id": 31,
  "model_grade": "A",
  "freshness_score": 91.2,
  "color_score": 88.0,
  "roundness_score": 93.5,
  "bruise_probability": 0.06,
  "model_decision": "PASS"
}
```

## 11. 배송 API

| Method | Endpoint | 설명 | 관련 테이블 |
|---|---|---|---|
| POST | `/owner/shipments` | 배송 등록 | `shipments`, `orders` |
| PATCH | `/owner/shipments/{shipment_id}/status` | 배송 상태 변경 | `shipments`, `orders` |
| GET | `/me/orders/{order_id}/shipment` | 내 주문 배송 정보 | `shipments` |

## 12. 반품/환불 API

| Method | Endpoint | 설명 | 관련 테이블 |
|---|---|---|---|
| POST | `/returns` | 고객 반품 요청 | `return_requests`, `orders` |
| GET | `/owner/returns` | 점주 반품 목록 | `return_requests` |
| PATCH | `/owner/returns/{return_request_id}/decision` | 반품 승인/거절 및 환불 처리 | `return_requests`, `refunds`, `payments`, `orders` |
| GET | `/me/returns` | 내 반품 목록 | `return_requests`, `refunds` |

PATCH Request:

```json
{
  "decision": "APPROVED",
  "approved_amount": 39000,
  "decision_reason": "배송 중 파손 확인"
}
```
