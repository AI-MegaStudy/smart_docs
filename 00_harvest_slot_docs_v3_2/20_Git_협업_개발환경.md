# Git 협업 및 개발환경

## 1. 저장소 구조

```text
harvest-slot/
  backend/
  frontend_user_web/
  frontend_owner_app/
  ml/
  dl/
  docs/
  database/
    schema.sql
    seed.sql
```

## 2. 브랜치 전략

| 브랜치 | 용도 |
|---|---|
| `main` | 최종 제출 버전 |
| `develop` | 통합 개발 브랜치 |
| `feature/backend-auth` | 인증 기능 |
| `feature/backend-reservation` | 예약/주문/결제 |
| `feature/backend-procurement` | 발주/배송/반품 |
| `feature/user-web` | 사용자 웹 |
| `feature/owner-app` | 점주 앱 |
| `feature/ml` | ML |
| `feature/dl` | DL |

## 3. 커밋 메시지 규칙

```text
feat: 기능 추가
fix: 버그 수정
docs: 문서 수정
refactor: 구조 개선
test: 테스트 추가
chore: 설정/환경 작업
```

예시:

```text
feat: 예약 생성 트랜잭션 구현
fix: 수확 슬롯 예약 가능 수량 계산 오류 수정
docs: API 설계서 상태값 정리
```

## 4. 개발 환경

### Backend

```text
Python 3.11+
FastAPI
SQLAlchemy
Pydantic
MySQL 8.x
Uvicorn
```

### Frontend

```text
Flutter 3.x
Dart 3.x
go_router
http 또는 dio
provider 또는 riverpod
```

### ML/DL

```text
Python
scikit-learn
PyTorch
torchvision
OpenCV
pandas
numpy
```

## 5. 환경 변수 예시

```env
DATABASE_URL=mysql+pymysql://user:password@localhost:3306/harvest_slot
JWT_SECRET_KEY=change-me
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=120
MODEL_PATH=./models
UPLOAD_DIR=./uploads
```

## 6. PR 규칙

1. PR 제목에 기능 범위를 명확히 적는다.
2. API 변경 시 `09_API_설계서.md`를 함께 수정한다.
3. DB 변경 시 DBML, DDL, 어트리뷰트 사전을 함께 수정한다.
4. 화면 변경 시 화면 설계서를 함께 수정한다.
5. `develop`에 통합 전 최소 1명 이상 확인한다.
