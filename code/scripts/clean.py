import pandas as pd
import os

RAW_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "data", "gapminder.csv")
OUT_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "data", "gapminder_clean.csv")


def load(path: str) -> pd.DataFrame:
    return pd.read_csv(path)


def clean(df: pd.DataFrame) -> pd.DataFrame:
    # 결측치 제거
    df = df.dropna()

    # 중복 행 제거
    df = df.drop_duplicates()

    # 컬럼명 소문자 통일
    df.columns = df.columns.str.lower().str.strip()

    # year를 정수형으로
    df["year"] = df["year"].astype(int)

    # pop을 정수형으로
    df["pop"] = df["pop"].astype(int)

    # gdppercap, lifeexp 소수점 2자리로 반올림
    df["gdppercap"] = df["gdppercap"].round(2)
    df["lifeexp"] = df["lifeexp"].round(2)

    # continent 카테고리형으로
    df["continent"] = df["continent"].astype("category")

    df = df.reset_index(drop=True)
    return df


def report(original: pd.DataFrame, cleaned: pd.DataFrame) -> None:
    print("=== 전처리 리포트 ===")
    print(f"원본 행 수      : {len(original):,}")
    print(f"전처리 후 행 수 : {len(cleaned):,}")
    print(f"제거된 행       : {len(original) - len(cleaned):,}")
    print(f"결측치 (원본)   : {original.isnull().sum().sum()}")
    print(f"중복 행 (원본)  : {original.duplicated().sum()}")
    print()
    print("=== 컬럼 타입 ===")
    print(cleaned.dtypes)
    print()
    print("=== 미리보기 ===")
    print(cleaned.head())


if __name__ == "__main__":
    df_raw = load(RAW_PATH)
    df_clean = clean(df_raw)
    report(df_raw, df_clean)
    df_clean.to_csv(OUT_PATH, index=False)
    print(f"\n저장 완료 → {os.path.abspath(OUT_PATH)}")
