import streamlit as st
import pandas as pd
import plotly.express as px

st.set_page_config(
    page_title="Collections Recovery Dashboard",
    page_icon="",
    layout="wide"
)

# --------------------------------------------------
# LOAD DATA
# --------------------------------------------------

@st.cache_data
def load_data():
    df = pd.read_csv("golden_account_month.csv")

    df["month"] = pd.to_datetime(df["month"])

    return df


df = load_data()

# --------------------------------------------------
# CALCULATED METRICS
# --------------------------------------------------

total_recovered = df["recovered_amount"].sum()
total_outstanding = df["outstanding_amount"].sum()

recovery_rate = (
    total_recovered / total_outstanding
    if total_outstanding != 0
    else 0
)

successful_payments = df["successful_payments"].sum()
accounts_analyzed = df["account_id"].nunique()

# --------------------------------------------------
# TITLE
# --------------------------------------------------

st.title("Collections Recovery Performance Dashboard")

st.caption(
    "September 2025 – August 2026 | "
    "SQL + DuckDB + Python Analysis"
)

st.divider()

# --------------------------------------------------
# FILTERS
# --------------------------------------------------

st.sidebar.header("Filters")

months = sorted(df["month"].dropna().unique())

selected_months = st.sidebar.multiselect(
    "Month",
    months,
    default=months
)

clients = sorted(df["client"].dropna().unique())

selected_clients = st.sidebar.multiselect(
    "Client",
    clients,
    default=clients
)

segments = sorted(df["borrower_segment"].dropna().unique())

selected_segments = st.sidebar.multiselect(
    "Borrower Segment",
    segments,
    default=segments
)

filtered_df = df[
    df["month"].isin(selected_months)
    & df["client"].isin(selected_clients)
    & df["borrower_segment"].isin(selected_segments)
].copy()

# --------------------------------------------------
# FILTERED KPIs
# --------------------------------------------------

filtered_recovered = filtered_df["recovered_amount"].sum()
filtered_outstanding = filtered_df["outstanding_amount"].sum()

filtered_recovery_rate = (
    filtered_recovered / filtered_outstanding
    if filtered_outstanding != 0
    else 0
)

filtered_successful_payments = (
    filtered_df["successful_payments"].sum()
)

filtered_accounts = filtered_df["account_id"].nunique()

# --------------------------------------------------
# KPI CARDS
# --------------------------------------------------

col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric(
        "Recovery Rate",
        f"{filtered_recovery_rate:.2%}"
    )

with col2:
    st.metric(
        "Total Recovered",
        f"₹{filtered_recovered:,.0f}"
    )

with col3:
    st.metric(
        "Successful Payments",
        f"{filtered_successful_payments:,.0f}"
    )

with col4:
    st.metric(
        "Accounts Analyzed",
        f"{filtered_accounts:,.0f}"
    )

st.divider()

# --------------------------------------------------
# BUSINESS FINDING
# --------------------------------------------------

st.subheader("Business Finding")

st.info(
    "The reported 11% month-on-month recovery improvement "
    "is not sustained. Recovery increased from 6.75% in "
    "January 2026 to 7.49% in February 2026 (+10.99%), "
    "but declined in subsequent months. NEW_TARGETING "
    "was introduced in March 2026, after the February "
    "increase."
)

# --------------------------------------------------
# MONTHLY RECOVERY RATE
# --------------------------------------------------

st.subheader("Monthly Recovery Rate")

monthly = (
    filtered_df
    .groupby("month", as_index=False)
    .agg(
        recovered=("recovered_amount", "sum"),
        outstanding=("outstanding_amount", "sum")
    )
)

monthly["recovery_rate"] = (
    monthly["recovered"] /
    monthly["outstanding"]
)

fig_monthly = px.line(
    monthly,
    x="month",
    y="recovery_rate",
    markers=True,
    labels={
        "month": "Month",
        "recovery_rate": "Recovery Rate"
    }
)

fig_monthly.update_yaxes(tickformat=".2%")

fig_monthly.update_layout(
    height=400,
    hovermode="x unified"
)

st.plotly_chart(
    fig_monthly,
    use_container_width=True
)

# --------------------------------------------------
# DPD ANALYSIS
# --------------------------------------------------

# --------------------------------------------------
# DPD ANALYSIS
# --------------------------------------------------

st.subheader("Recovery Rate by DPD Bucket")

def dpd_bucket(dpd):
    if pd.isna(dpd):
        return "Unknown"
    elif dpd <= 30:
        return "01-30"
    elif dpd <= 60:
        return "31-60"
    elif dpd <= 90:
        return "61-90"
    elif dpd <= 120:
        return "91-120"
    elif dpd <= 180:
        return "121-180"
    else:
        return "180+"

filtered_df["dpd_bucket"] = filtered_df["dpd"].apply(dpd_bucket)

dpd_order = [
    "01-30",
    "31-60",
    "61-90",
    "91-120",
    "121-180",
    "180+",
    "Unknown"
]

dpd = (
    filtered_df
    .groupby("dpd_bucket", as_index=False)
    .agg(
        recovered=("recovered_amount", "sum"),
        outstanding=("outstanding_amount", "sum")
    )
)

dpd["recovery_rate"] = (
    dpd["recovered"] / dpd["outstanding"]
)

dpd["dpd_bucket"] = pd.Categorical(
    dpd["dpd_bucket"],
    categories=dpd_order,
    ordered=True
)

dpd = dpd.sort_values("dpd_bucket")

fig_dpd = px.bar(
    dpd,
    x="dpd_bucket",
    y="recovery_rate",
    text_auto=".2%",
    labels={
        "dpd_bucket": "DPD Bucket",
        "recovery_rate": "Recovery Rate"
    }
)

fig_dpd.update_yaxes(tickformat=".2%")

fig_dpd.update_layout(
    height=400
)

st.plotly_chart(
    fig_dpd,
    use_container_width=True
)
# --------------------------------------------------
# BORROWER SEGMENT
# --------------------------------------------------

st.subheader("Recovery Rate by Borrower Segment")

segment = (
    filtered_df
    .groupby("borrower_segment", as_index=False)
    .agg(
        recovered=("recovered_amount", "sum"),
        outstanding=("outstanding_amount", "sum")
    )
)

segment["recovery_rate"] = (
    segment["recovered"] /
    segment["outstanding"]
)

fig_segment = px.bar(
    segment,
    x="borrower_segment",
    y="recovery_rate",
    labels={
        "borrower_segment": "Borrower Segment",
        "recovery_rate": "Recovery Rate"
    },
    text_auto=".2%"
)

fig_segment.update_yaxes(tickformat=".2%")

st.plotly_chart(
    fig_segment,
    use_container_width=True
)

# --------------------------------------------------
# CLIENT PERFORMANCE
# --------------------------------------------------

st.subheader("Recovery Rate by Client")

client = (
    filtered_df
    .groupby("client", as_index=False)
    .agg(
        recovered=("recovered_amount", "sum"),
        outstanding=("outstanding_amount", "sum")
    )
)

client["recovery_rate"] = (
    client["recovered"] /
    client["outstanding"]
)

fig_client = px.bar(
    client,
    x="client",
    y="recovery_rate",
    labels={
        "client": "Client",
        "recovery_rate": "Recovery Rate"
    },
    text_auto=".2%"
)

fig_client.update_yaxes(tickformat=".2%")

st.plotly_chart(
    fig_client,
    use_container_width=True
)

# --------------------------------------------------
# SUMMARY TABLE
# --------------------------------------------------

st.subheader("Monthly Performance")

summary = monthly.copy()

summary["recovery_rate"] = (
    summary["recovery_rate"] * 100
).round(2)

summary["recovered"] = summary["recovered"].round(2)

summary["outstanding"] = summary["outstanding"].round(2)

summary = summary.rename(
    columns={
        "month": "Month",
        "recovered": "Recovered Amount",
        "outstanding": "Outstanding Amount",
        "recovery_rate": "Recovery Rate (%)"
    }
)

st.dataframe(
    summary,
    use_container_width=True,
    hide_index=True
)

# --------------------------------------------------
# FOOTER
# --------------------------------------------------

st.divider()

st.caption(
    "Collections Recovery Analysis | "
    "Data processed using DuckDB and SQL | "
    "Dashboard built using Python, Streamlit and Plotly"
)