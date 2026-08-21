import duckdb

con = duckdb.connect("collections_analysis.duckdb")

with open("sql/03_cleaning.sql", "r", encoding="utf-8") as f:
    sql = f.read()

statements = [s.strip() for s in sql.split(";") if s.strip()]

for i, statement in enumerate(statements, 1):
    print(f"\n========== QUERY {i} ==========\n")

    try:
        result = con.execute(statement)

        if con.description:
            columns = [col[0] for col in con.description]
            print(columns)

            rows = result.fetchall()

            for row in rows:
                print(row)

    except Exception as e:
        print("ERROR:", e)