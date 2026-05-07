# Harvest Slot 워크플로우 다이어그램

Harvest Slot 서비스의 주요 유저플로우와 상태 전이를 확인하기 위한 정적 HTML 다이어그램 페이지입니다.

`index.html`은 PPT 삽입용 PNG/SVG 산출물만 한글 제목, 설명, 미리보기와 함께 보여줍니다.

## 실행 방법

이 폴더의 `index.html`을 브라우저에서 열면 됩니다. 정적 HTML이므로 별도 백엔드나 데이터베이스 연결은 필요하지 않습니다.

VS Code에서 확인할 경우 Live Server를 사용할 수 있습니다.

1. VS Code에서 이 폴더 또는 상위 프로젝트 폴더를 엽니다.
2. `03_workflow_diagrams/index.html` 파일을 엽니다.
3. HTML 편집 화면에서 우클릭합니다.
4. `Open with Live Server`를 선택합니다.

Live Server 확장 링크: https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer

## 화면 구성

완성된 대형 PNG/SVG 다이어그램을 아래 3개 묶음으로 구분해 표시합니다.

### 01. 전체 흐름 다이어그램

서비스 전체 흐름을 개요 설명용으로 분리한 다이어그램입니다.

- `01_overview_end_to_end_1_slot_reservation.png` / `.svg`: 전체 서비스 흐름 1 - 슬롯 예약
- `01_overview_end_to_end_2_order_fulfillment_return.png` / `.svg`: 전체 서비스 흐름 2 - 주문·발주·배송·반품

### 02-06. 업무 처리 다이어그램

고객과 점주가 실제 화면에서 수행하는 핵심 업무 흐름입니다.

- `02_owner_supply_slot_setup.png` / `.svg`: 점주 수확 슬롯 설정
- `03_customer_reservation.png` / `.svg`: 고객 예약 생성
- `04_order_payment_procurement.png` / `.svg`: 주문·결제·발주 요청
- `05_owner_fulfillment_quality_shipping.png` / `.svg`: 점주 발주·품질·배송 처리
- `06_return_refund.png` / `.svg`: 반품·환불 처리

### 07. 상태 생명주기 다이어그램

주문, 출고, 반품·환불 상태값이 어떻게 전이되는지 정리한 상태 중심 다이어그램입니다. PPT에 넣기 쉽도록 3개 파트로 분리했습니다.

- `07_state_lifecycle_1_order_procurement.png` / `.svg`: 상태 생명주기 1 - 예약·주문·발주
- `07_state_lifecycle_2_fulfillment_shipping.png` / `.svg`: 상태 생명주기 2 - 출고·배송
- `07_state_lifecycle_3_return_refund.png` / `.svg`: 상태 생명주기 3 - 반품·환불

## 도형 기준

대형 PNG/SVG 다이어그램은 표준 플로우차트 관례를 기준으로 작성했습니다.

- 시작/종료: 둥근 사각형
- 처리: 사각형
- 판단: 마름모
- 입출력: 평행사변형
- 데이터 저장소: 원통형

글자와 선, 도형이 겹치지 않도록 SVG에서 직접 배치했으며, PNG 변환 시 화살표 머리가 사라지지 않도록 marker 대신 실제 삼각형 도형을 사용했습니다.
