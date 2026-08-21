import duckdb

con = duckdb.connect("collections_analysis.duckdb")

# Create cleaned tables
with open("sql/03_cleaning.sql", "r", encoding="utf-8") as f:
    cleaning_sql = f.read()

for statement in cleaning_sql.split(";"):
    statement = statement.strip()
    if statement:
        con.execute(statement)

print("Cleaning tables created.")

# Create the Golden Dataset
with open("sql/04_golden_dataset.sql", "r", encoding="utf-8") as f:
    golden_sql = f.read()

statements = [
    s.strip()
    for s in golden_sql.split(";")
    if s.strip()
]

# Execute all Golden Dataset SQL statements.
# The first statement creates golden_account_month.
for statement in statements:
    con.execute(statement)

# Export the actual Golden Dataset table
df = con.execute("""
    SELECT *
    FROM golden_account_month
""").fetchdf()

df.to_csv("golden_account_month.csv", index=False)

print("Golden Dataset exported successfully.")
print("Rows:", len(df))
print("Columns:", len(df.columns))
print("File: golden_account_month.csv")

con.close()