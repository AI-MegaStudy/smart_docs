# Harvest Slot 문서 패키지 v3.1

이 패키지는 과수농가 직배송 예약 서비스 **Harvest Slot**의 최종 MVP 기준 문서다. 모든 기획서, 화면 설계서, API, DB/ERD, ML/DL, 테스트, 일정 문서는 아래 19개 테이블 구조를 기준으로 동기화되어 있다.

## 개발 기준

- 사용자용 예약 웹: Flutter Web
- 점주용 관리 앱: Flutter Android App
- 백엔드: FastAPI
- DB: MySQL
- ML: 수확 시기·수확량·추천가 보조 예측
- DL: PyTorch 기반 신선도 판별 보조
- 외부 데이터: 가격/환경/통계 Open API 수집 후 ML 입력 피처로 활용
- 결제: Mock 결제 승인 흐름
- 배송: 송장번호와 배송 상태를 앱에서 관리
- 반품/환불: 반품 요청, 점주 승인, Mock 환불 완료 흐름

## 최종 DB 테이블 19개

```text
accounts
customer_profiles
owner_profiles
email_verifications
farms
products
ml_predictions
harvest_slots
reservations
reservation_items
orders
order_items
payments
procurements
procurement_items
quality_inspections
shipments
return_requests
refunds
```

## 문서 목록

| 번호 | 문서 |
|---:|---|
| 01 | 프로젝트 정의서 GCSE |
| 02 | 서비스 범위 확정서 |
| 03 | 업무 흐름 및 상태 전이 |
| 04 | 요구사항 정의서 |
| 05 | 사용자 예약 웹 기획서 |
| 06 | 사용자 예약 웹 화면 설계 및 기능 정의서 |
| 07 | 점주 관리 앱 기획서 |
| 08 | 점주 관리 앱 화면 설계 및 기능 정의서 |
| 09 | API 설계서 |
| 10 | DB/ERD 설계서 |
| 11 | ML 수확 예측 기획서 |
| 12 | DL 신선도 판별 기획서 |
| 13 | 데이터 수집 및 Open API 계획서 |
| 14 | FastAPI 구현 가이드 |
| 15 | Flutter 사용자 웹 구현 가이드 |
| 16 | Flutter 점주 앱 구현 가이드 |
| 17 | 디자인 시스템 및 UIUX 가이드 |
| 18 | 테스트 및 QA 시나리오 |
| 19 | WBS 및 역할 분담 2주 |
| 20 | Git 협업 및 개발환경 |
| 21 | 발표 및 데모 시나리오 |
| 22 | 리스크 관리 |
| 23 | 최종 제출 체크리스트 |
| 24 | 리서치 참고자료 |

## ERD 관련 핵심 파일

```text
assets/10_harvest_slot_final_19tables.dbml
assets/10_harvest_slot_final_19tables.mmd
assets/10_관계_카디널리티_전체.md
assets/10_어트리뷰트_사전_19테이블.md
assets/10_schema_mysql.sql
```

## 작업 기준

개발자는 이 패키지의 문서만 기준으로 작업한다. 화면, API, DB, 테스트, 발표 흐름은 모두 같은 업무 흐름을 따른다.

```text
상품 등록
→ ML 예측 보조
→ 점주 수확 슬롯 확정
→ 고객 로컬 예약함 구성
→ 서버 예약 생성
→ 주문 생성
→ Mock 결제 승인
→ 발주 생성
→ 점주 발주 승인/부분승인/거절
→ DL 신선도 검사
→ 배송 등록
→ 반품 요청
→ Mock 환불 처리
```


---

## v3.1 보강 사항

이 버전은 ERD를 Miro에서 직접 재작성할 수 있도록 `10_관계_카디널리티_전체.md`와 `10_어트리뷰트_사전_19테이블.md`를 보강한 버전이다.

- 19개 테이블 분류와 Miro 박스 작성 규칙 추가
- 모든 관계 카드에 Miro 선 표기, FK 컬럼, 참조 대상, UNIQUE/NULL 규칙 추가
- `return_requests`는 주문 단위 반품으로 확정하여 `orders 1 -> return_requests 0..1`로 수정
- `refunds.payment_id`도 Mock 환불 범위에 맞춰 UNIQUE로 정리
- `accounts`와 고객/점주 프로필의 배타 생성 규칙을 문서화
