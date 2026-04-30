# 데이터 수집 및 Open API 계획서

## 1. 목적

ML/DL 기능 구현에 필요한 공개 데이터와 Open API 데이터를 확보하고, FastAPI 서버에서 예측 입력 피처로 활용한다.

## 2. 데이터 소스

| 데이터 | 활용 목적 |
|---|---|
| AI-Hub 농산물 품질(QC) 이미지 | DL 품질 등급 분류 |
| AI-Hub 전북 장수 사과 당도 품질 데이터 | 사과 품질/당도 학습 보조 |
| AI-Hub 고품질 과수작물 통합 데이터 | 과수 이미지/환경 데이터 보조 |
| 농촌진흥청 스마트팜 우수농가 공개용 데이터 | 환경/생육/생산량 피처 예시 |
| KAMIS 가격 정보 | 추천 가격 기준가 |
| 경기데이터드림 과실생산량 조사결과 | 지역 생산량 참고 |
| 서울시 과실류 생산량 통계 | 생산량 통계 참고 |
| 농림축산식품부 과실 출하약정 상세현황 | 출하/수급 참고 |

## 3. Open API 활용 방식

Open API 수집 결과는 별도 운영 테이블이 아니라 ML 예측 실행 시점의 스냅샷으로 저장한다.

저장 위치:

```text
ml_predictions.open_api_snapshot_json
```

예시:

```json
{
  "price": {
    "source": "KAMIS",
    "item": "apple",
    "unit": "5kg",
    "price": 35000,
    "collected_at": "2026-04-28T10:00:00"
  },
  "weather": {
    "source": "public_open_api",
    "avg_temperature": 23.4,
    "rainfall": 12.0
  }
}
```

## 4. 데이터 전처리

| 단계 | 작업 |
|---|---|
| 이미지 정리 | 품목/등급별 폴더 분리 |
| 이미지 리사이즈 | 224x224 기준 |
| 라벨 정리 | A/B/C 또는 PASS/REVIEW/HOLD 매핑 |
| 수치 데이터 정리 | 결측치 처리, 단위 통일 |
| 가격 데이터 정리 | kg 또는 포장 단위 기준 환산 |
| 학습/검증 분리 | train/valid/test 분리 |

## 5. 데이터 산출물

```text
data/raw/
data/processed/
data/sample/
ml/features_sample.csv
dl/image_dataset_sample/
```

## 6. 발표용 데이터 준비

시연 안정성을 위해 발표용으로 다음 샘플 데이터를 미리 구성한다.

| 샘플 | 수량 |
|---|---:|
| 점주 계정 | 1 |
| 고객 계정 | 1 |
| 농장 | 1 |
| 상품 | 2 |
| ML 예측 결과 | 2 |
| 수확 슬롯 | 3 |
| 주문 시나리오 | 1 |
| 반품 시나리오 | 1 |
