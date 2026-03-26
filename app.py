import streamlit as st
import pandas as pd
import plotly.express as px
import os

st.set_page_config(layout="wide")

st.title("📊 PhonePe Analytics Dashboard")

# ================= LOAD DATA =================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "csv_created")

@st.cache_data
def load_data():
    df_trans = pd.read_csv(os.path.join(DATA_DIR, "aggregated_transaction.csv"))
    df_user = pd.read_csv(os.path.join(DATA_DIR, "aggregated_user.csv"))
    df_ins = pd.read_csv(os.path.join(DATA_DIR, "aggregated_insurance.csv"))
    return df_trans, df_user, df_ins

with st.spinner("Loading data..."):
    df_trans, df_user, df_ins = load_data()

# ================= SIDEBAR =================
st.sidebar.title("🔍 Filters")

state = st.sidebar.selectbox("Select State", sorted(df_trans["state"].unique()))
year = st.sidebar.selectbox("Select Year", sorted(df_trans["year"].unique()))
quarter = st.sidebar.selectbox("Select Quarter", sorted(df_trans["quarter"].unique()))

section = st.sidebar.radio("Navigate", ["Transactions", "Users", "Insurance"])

# ================= FILTERED DATA =================
filtered_trans = df_trans[
    (df_trans["state"] == state) &
    (df_trans["year"] == year) &
    (df_trans["quarter"] == quarter)
]

filtered_user = df_user[
    (df_user["state"] == state) &
    (df_user["year"] == year) &
    (df_user["quarter"] == quarter)
]

filtered_ins = df_ins[
    (df_ins["state"] == state) &
    (df_ins["year"] == year) &
    (df_ins["quarter"] == quarter)
]

# ================= KPI CARDS =================
col1, col2, col3 = st.columns(3)

col1.metric("💰 Transactions", f"{filtered_trans['transaction_amount'].sum():,.0f}")
col2.metric("👥 Users", f"{filtered_user['registered_users'].sum():,.0f}")
col3.metric("🛡 Insurance", f"{filtered_ins['insurance_amount'].sum():,.0f}")

st.markdown("---")

# ================= TRANSACTIONS =================
if section == "Transactions":

    st.subheader("💰 Transaction Analysis")

    # Year Trend
    year_data = df_trans.groupby("year")["transaction_amount"].sum().reset_index()
    fig = px.line(year_data, x="year", y="transaction_amount", title="Year-wise Growth")
    st.plotly_chart(fig, use_container_width=True)

    # Transaction Type
    type_data = filtered_trans.groupby("transaction_type")["transaction_amount"].sum().reset_index()
    fig = px.bar(type_data, x="transaction_type", y="transaction_amount", title="Transaction Types")
    st.plotly_chart(fig, use_container_width=True)

    # Top vs Bottom
    order = st.radio("Select View", ["Top States", "Bottom States"])

    state_data = df_trans.groupby("state")["transaction_amount"].sum().reset_index()

    if order == "Top States":
        state_data = state_data.sort_values(by="transaction_amount", ascending=False).head(10)
    else:
        state_data = state_data.sort_values(by="transaction_amount").head(10)

    fig = px.bar(state_data, x="state", y="transaction_amount", title=order)
    st.plotly_chart(fig, use_container_width=True)

    st.info("Insight: Digital transactions are highly concentrated in a few states.")

    st.download_button("Download Data", data=filtered_trans.to_csv(index=False), file_name="transactions.csv")

# ================= USERS =================
elif section == "Users":

    st.subheader("👥 User Analysis")

    # Growth
    year_data = df_user.groupby("year")["registered_users"].sum().reset_index()
    fig = px.line(year_data, x="year", y="registered_users", title="User Growth")
    st.plotly_chart(fig, use_container_width=True)

    # App Opens
    opens_data = df_user.groupby("year")["app_opens"].sum().reset_index()
    fig = px.line(opens_data, x="year", y="app_opens", title="App Opens Trend")
    st.plotly_chart(fig, use_container_width=True)

    # Engagement
    eng = df_user.groupby("state").agg({
        "registered_users": "sum",
        "app_opens": "sum"
    }).reset_index()

    eng["ratio"] = eng["app_opens"] / eng["registered_users"]

    fig = px.bar(eng.sort_values(by="ratio", ascending=False).head(10),
                 x="state", y="ratio", title="Top Engagement States")
    st.plotly_chart(fig, use_container_width=True)

    st.info("Insight: Some states show high engagement despite lower user base.")

    st.download_button("Download Data", data=filtered_user.to_csv(index=False), file_name="users.csv")

# ================= INSURANCE =================
elif section == "Insurance":

    st.subheader("🛡 Insurance Analysis")

    # Growth
    year_data = df_ins.groupby("year")["insurance_amount"].sum().reset_index()
    fig = px.line(year_data, x="year", y="insurance_amount", title="Insurance Growth")
    st.plotly_chart(fig, use_container_width=True)

    # Type Distribution
    type_data = filtered_ins.groupby("insurance_type")["insurance_amount"].sum().reset_index()
    fig = px.pie(type_data, names="insurance_type", values="insurance_amount", title="Insurance Types")
    st.plotly_chart(fig, use_container_width=True)

    # Top States
    state_data = df_ins.groupby("state")["insurance_amount"].sum().reset_index()
    state_data = state_data.sort_values(by="insurance_amount", ascending=False).head(10)

    fig = px.bar(state_data, x="state", y="insurance_amount", title="Top States")
    st.plotly_chart(fig, use_container_width=True)

    st.info("Insight: Insurance adoption is increasing steadily across regions.")

    st.download_button("Download Data", data=filtered_ins.to_csv(index=False), file_name="insurance.csv")

# ================= FOOTER =================
st.markdown("---")
st.markdown("🚀 Built by Aayush | PhonePe Data Project")