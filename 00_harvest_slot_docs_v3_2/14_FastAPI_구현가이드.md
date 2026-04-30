# FastAPI 구현 가이드

## 1. 서버 폴더 구조

```text
backend/
  app/
    main.py
    core/
      config.py
      security.py
      database.py
      transaction.py
    models/
      account.py
      farm.py
      product.py
      ml_prediction.py
      harvest_slot.py
      reservation.py
      order.py
      payment.py
      procurement.py
      quality_inspection.py
      shipment.py
      return_refund.py
    schemas/
      auth_schema.py
      product_schema.py
      reservation_schema.py
      order_schema.py
      payment_schema.py
      procurement_schema.py
      quality_schema.py
      shipment_schema.py
      return_schema.py
    routers/
      auth_router.py
      product_router.py
      owner_router.py
      reservation_router.py
      order_router.py
      payment_router.py
      procurement_router.py
      quality_router.py
      shipment_router.py
      return_router.py
    services/
      auth_service.py
      reservation_service.py
      order_service.py
      payment_service.py
      procurement_service.py
      ml_service.py
      dl_service.py
    repositories/
      harvest_slot_repo.py
      reservation_repo.py
      order_repo.py
```

## 2. DB 모델 기준

SQLAlchemy 모델은 `assets/10_schema_mysql.sql`의 테이블과 동일해야 한다.

핵심 모델 그룹:

| 그룹 | 모델 |
|---|---|
| 계정 | `Account`, `CustomerProfile`, `OwnerProfile`, `EmailVerification` |
| 상품 | `Farm`, `Product`, `MLPrediction`, `HarvestSlot` |
| 예약/주문 | `Reservation`, `ReservationItem`, `Order`, `OrderItem` |
| 결제/발주 | `Payment`, `Procurement`, `ProcurementItem` |
| 검사/배송 | `QualityInspection`, `Shipment` |
| 반품/환불 | `ReturnRequest`, `Refund` |

## 3. 트랜잭션 서비스

### 예약 생성

`reservation_service.create_reservation()`에서 처리한다.

```python
with session.begin():
    slots = repo.lock_slots(slot_ids)
    validate_available_qty(slots, request.items)
    reservation = create_reservation_header()
    create_reservation_items()
    increase_reserved_kg()
```

`lock_slots()`는 다음과 같은 쿼리를 사용한다.

```sql
SELECT * FROM harvest_slots
WHERE slot_id IN (...)
FOR UPDATE;
```

### 결제 승인

`payment_service.mock_approve()`에서 처리한다.

```python
with session.begin():
    order = lock_order(order_id)
    create_payment()
    update_order_paid()
    move_reserved_to_sold()
    create_procurement()
    create_procurement_items()
```

## 4. 권한 처리

| 권한 | 접근 가능 기능 |
|---|---|
| CUSTOMER | 상품 조회, 예약, 주문, 결제, 반품 |
| OWNER | 농장/상품 관리, ML, 수확 슬롯, 발주, 신선도 검사, 배송, 반품 처리 |

권한 체크 예시:

```python
def require_owner(current_user: Account):
    if current_user.role != "OWNER":
        raise HTTPException(status_code=403, detail="OWNER 권한이 필요합니다.")
```

## 5. API 구현 우선순위

1. Auth API
2. Product/Farm API
3. Harvest Slot API
4. Reservation API
5. Order API
6. Payment API
7. Procurement API
8. Quality Inspection API
9. Shipment API
10. Return/Refund API

## 6. Swagger 관리

FastAPI의 자동 문서화를 활용하되, Markdown API 설계서와 엔드포인트 이름이 일치해야 한다.

```text
GET /docs
GET /redoc
```
