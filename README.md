# Gapminder EDA 프로젝트

Hans Rosling의 Gapminder 데이터를 활용한 탐색적 데이터 분석(EDA) 및 인터랙티브 대시보드 프로젝트입니다.

🔗 **[대시보드 바로가기](https://anyc0414.github.io/myfirst_test/)**

---

## 개요

- **데이터**: 142개국, 1952~2007년 (5년 간격)
- **주요 변수**: 기대수명, 인구, 1인당 GDP
- **분석 도구**: Python, Quarto

---

## 파일 구조

```
gapminder/
├── gapminder.csv            # 원본 데이터
├── gapminder_clean.csv      # 전처리 완료 데이터
├── eda_report.qmd           # EDA 분석 보고서 (Quarto)
├── eda_report.html          # EDA 보고서 렌더링 결과
├── dashboard.qmd            # 인터랙티브 대시보드 (Quarto)
├── index.html               # 대시보드 렌더링 결과 (GitHub Pages)
├── cleaning_report.md       # 전처리 결과 리포트
├── scripts/
│   ├── clean.py             # 데이터 전처리 스크립트
│   └── generate_report.py   # 전처리 리포트 생성 스크립트
└── eda_outputs/             # EDA 분석 결과물 (차트, CSV)
```

---

## 주요 분석 내용

| 분석 항목 | 내용 |
|-----------|------|
| 데이터 전처리 | 결측치·중복 제거, 타입 변환, 소수점 정리 |
| 변수 분포 | 기대수명·GDP·인구 히스토그램, 로그 변환 |
| 대륙별 비교 | 기대수명·GDP 격차 시각화 |
| 시계열 추세 | 1952~2007 대륙별 변화 추이 |
| 변수 간 관계 | GDP-기대수명 버블차트, 상관관계 히트맵 |

---

## 주요 발견

- **모든 대륙**에서 기대수명이 꾸준히 증가
- **Africa**는 1990년대 HIV/AIDS 영향으로 증가세 일시 둔화
- **1인당 GDP와 기대수명**은 강한 양의 상관관계 (로그 스케일에서 선형)
- **중국·인도**의 인구 집중으로 전체 평균 인구가 크게 높아짐

---

## 실행 방법

```bash
# 1. 데이터 전처리
python3 scripts/clean.py

# 2. 전처리 리포트 생성
python3 scripts/generate_report.py

# 3. EDA 보고서 렌더링
quarto render eda_report.qmd --to html

# 4. 대시보드 렌더링
quarto render dashboard.qmd --to dashboard
```

---

## 사용 라이브러리

`pandas` `matplotlib` `seaborn` `plotly` `quarto`
