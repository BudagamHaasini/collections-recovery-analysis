import duckdb

con = duckdb.connect("collections_analysis.duckdb")

files = [
    "daily_targeting.csv",
    "promises_to_pay.csv",
    "calls.csv",
    "call_dispositions.csv"
]

for file in files:
    print("\n==============================")
    print(file)
    print("==============================")

    result = con.execute(
        f"DESCRIBE SELECT * FROM read_csv_auto('raw/{file}')"
    ).fetchall()

    for row in result:
        print(row)