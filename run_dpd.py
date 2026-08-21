import duckdb

con = duckdb.connect("collections_analysis.duckdb")

with open("sql/08_dpd_analysis.sql", "r", encoding="utf-8") as f:
    sql = f.read()

result = con.execute(sql)

print([col[0] for col in result.description])

for row in result.fetchall():
    print(row)