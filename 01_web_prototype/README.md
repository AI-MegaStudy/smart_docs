# Harvest Slot 웹 프로토타입

고객 예약웹 프로토타입 모음입니다. 고객 화면에는 백엔드/API/DB/개발자용 상태 코드가 노출되지 않도록 정리했습니다.

## 실행 방법

VS Code 확장 프로그램 **Live Server**로 실행합니다.

확장 링크: https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer


## Live Server 설치

### VS Code 화면에서 설치

1. VS Code를 실행합니다.
2. 왼쪽 사이드바에서 Extensions 아이콘을 누릅니다.
3. 검색창에 `Live Server`를 입력합니다.
4. 제작자가 `Ritwick Dey`인 확장 프로그램을 선택합니다.
5. `Install`을 누릅니다.

### 명령어로 설치

VS Code 명령어 도구가 설정되어 있다면 터미널에서 아래 명령어를 실행합니다.

```bash
code --install-extension ritwickdey.LiveServer
```

## 사용법

1. VS Code에서 이 README가 들어 있는 폴더 또는 상위 프로젝트 폴더를 엽니다.
2. 아래 실행 파일 중 하나를 엽니다.
3. HTML 편집 화면에서 우클릭합니다.
4. `Open with Live Server`를 선택합니다.
5. 브라우저가 자동으로 열리면 화면을 확인합니다.

Live Server 기본 주소는 보통 아래 형식입니다.

```text
http://127.0.0.1:5500/...
```

포트가 이미 사용 중이면 Live Server가 다른 포트를 사용할 수 있습니다. 브라우저에 열린 주소를 그대로 사용하면 됩니다.

## 바로 열어볼 파일

전체 시안 보기:

```text
prototype_user_web/index.html
```

페이지별 분리 시안 시작 화면:

```text
prototype_user_web_m3/index.html
```

이 프로토타입은 정적 HTML입니다. 별도 백엔드 실행이나 데이터베이스 연결은 필요하지 않습니다.

## 프로토타입 구성

### 1. 전체 시안 보기

파일: `prototype_user_web/index.html`

한 페이지에서 고객 예약웹 전체 시안을 한눈에 확인하는 버전입니다. 상단 토글로 데스크톱과 모바일 레이아웃을 비교할 수 있습니다.

포함 화면:

- 홈: 추천 예약 상품과 수확 예정 상품 진입
- 상품 목록: 품종과 수확 예정 범위 확인
- 상품 상세: 수확 슬롯과 박스 수량 선택
- 예약함: 담은 상품과 예상 합계 확인
- 회원가입: 고객 계정 생성
- 이메일 인증: 인증 코드 입력
- 로그인: 예약 내역 연결
- 예약 확인: 예약 가능 여부 최종 확인
- 주문서 작성: 배송지와 결제 전 확인
- 결제: 카드 결제 승인
- 주문 완료: 결제 완료와 농가 확인 안내
- 내 주문: 최근 예약 주문 목록
- 주문 상세: 결제, 선별, 배송 진행 상태
- 반품 신청: 반품 사유와 증빙 등록

### 2. 페이지별 분리 시안

시작 파일: `prototype_user_web_m3/index.html`

각 고객 화면을 개별 HTML 파일로 분리한 버전입니다. 특정 화면을 단독으로 확인하거나 발표 자료에 연결하기 좋습니다.

페이지 파일:

- `pages/home.html`: 홈
- `pages/product-list.html`: 상품 목록
- `pages/product-detail.html`: 상품 상세
- `pages/local-basket.html`: 예약함
- `pages/signup.html`: 회원가입
- `pages/email-verify.html`: 이메일 인증
- `pages/login.html`: 로그인
- `pages/reservation-confirm.html`: 예약 확인
- `pages/checkout.html`: 주문서 작성
- `pages/mock-payment.html`: 결제
- `pages/order-complete.html`: 주문 완료
- `pages/my-orders.html`: 내 주문
- `pages/order-detail.html`: 주문 상세
- `pages/return-request.html`: 반품 신청

