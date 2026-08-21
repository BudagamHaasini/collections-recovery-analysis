import duckdb

con = duckdb.connect("collections_analysis.duckdb")

with open("sql/09_final_analysis.sql", "r", encoding="utf-8") as f:
    sql = f.read()

statements = [s.strip() for s in sql.split(";") if s.strip()]

for i, statement in enumerate(statements, 1):

    print("\n========================================")
    print(f"ANALYSIS {i}")
    print("========================================")

    try:
        result = con.execute(statement)

        if con.description:
            print([col[0] for col in con.description])

            for row in result.fetchall():
                print(row)

    except Exception as e:
        print("ERROR:", e)