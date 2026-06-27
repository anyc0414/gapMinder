import pandas as pd
import os

RAW_PATH = os.path.join(os.path.dirname(__file__), "..", "gapminder.csv")
CLEAN_PATH = os.path.join(os.path.dirname(__file__), "..", "gapminder_clean.csv")
OUT_PATH = os.path.join(os.path.dirname(__file__), "..", "cleaning_report.md")


def generate_report(raw: pd.DataFrame, clean: pd.DataFrame) -> str:
    removed = len(raw) - len(clean)
    missing_raw = int(raw.isnull().sum().sum())
    dup_raw = int(raw.duplicated().sum())

    dtype_rows = "\n".join(
        f"| `{col}` | `{str(dtype)}` |"
        for col, dtype in clean.dtypes.items()
    )

    continent_rows = "\n".join(
        f"| {continent} | {count} |"
        for continent, count in clean.groupby("continent")["country"].nunique().items()
    )

    stats = clean[["lifeexp", "pop", "gdppercap"]].describe().round(2)
    stat_rows = "\n".join(
        f"| {idx} | {stats.loc[idx, 'lifeexp']} | {stats.loc[idx, 'pop']:,.0f} | {stats.loc[idx, 'gdppercap']} |"
        for idx in stats.index
    )

    preview = clean.head(5).to_markdown(index=False)

    md = f"""# Gapminder 데이터 전처리 리포트

## 1. 개요

| 항목 | 값 |
|------|----|
| 원본 행 수 | {len(raw):,} |
| 전처리 후 행 수 | {len(clean):,} |
| 제거된 행 | {removed:,} |
| 원본 결측치 수 | {missing_raw:,} |
| 원본 중복 행 수 | {dup_raw:,} |
| 총 국가 수 | {clean['country'].nunique()} |
| 연도 범위 | {clean['year'].min()} ~ {clean['year'].max()} (5년 간격) |

---

## 2. 전처리 항목

| # | 처리 내용 | 설명 |
|---|-----------|------|
| 1 | 결측치 제거 | `dropna()` 적용 |
| 2 | 중복 행 제거 | `drop_duplicates()` 적용 |
| 3 | 컬럼명 정규화 | 소문자 변환 + 공백 제거 |
| 4 | 타입 변환 | `year`, `pop` → `int` / `continent` → `category` |
| 5 | 소수점 정리 | `gdppercap`, `lifeexp` → 소수점 2자리 |

---

## 3. 컬럼 타입

| 컬럼 | 타입 |
|------|------|
{dtype_rows}

---

## 4. 대륙별 국가 수

| 대륙 | 국가 수 |
|------|--------|
{continent_rows}

---

## 5. 주요 통계

| 통계 | lifeexp (기대수명) | pop (인구) | gdppercap (1인당 GDP) |
|------|-------------------|------------|----------------------|
{stat_rows}

---

## 6. 데이터 미리보기 (상위 5행)

{preview}
"""
    return md


if __name__ == "__main__":
    raw = pd.read_csv(RAW_PATH)
    clean = pd.read_csv(CLEAN_PATH)

    report = generate_report(raw, clean)

    with open(OUT_PATH, "w", encoding="utf-8") as f:
        f.write(report)

    print(f"리포트 저장 완료 → {os.path.abspath(OUT_PATH)}")
