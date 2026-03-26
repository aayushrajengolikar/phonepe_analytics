import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

st.set_page_config(layout="wide")

st.title("📊 PhonePe Analytics Dashboard")

# ================= LOAD DATA =================
@st.cache_data
def load_data():
    return (
        pd.read_csv("aggregated_transaction.csv"),
        pd.read_csv("aggregated_user.csv"),
        pd.read_csv("aggregated_insurance.csv")
    )

df_trans, df_user, df_ins = load_data()

# ================= KPI CARDS =================
col1, col2, col3 = st.columns(3)

col1.metric("💰 Total Transactions", f"{df_trans['transaction_amount'].sum():,.0f}")
col2.metric("👥 Total Users", f"{df_user['registered_users'].sum():,.0f}")
col3.metric("🛡 Insurance Amount", f"{df_ins['insurance_amount'].sum():,.0f}")

st.markdown("---")

# ================= FILTER =================
state = st.selectbox("Select State", df_trans["state"].unique())

# ================= TABS =================
tab1, tab2, tab3 = st.tabs(["💰 Transactions", "👥 Users", "🛡 Insurance"])

# ================= TRANSACTION TAB =================
with tab1:

    st.subheader("Transaction Analysis")

    filtered = df_trans[df_trans["state"] == state]

    col1, col2 = st.columns(2)

    # Year trend
    with col1:
        year_data = filtered.groupby("year")["transaction_amount"].sum()
        fig, ax = plt.subplots()
        year_data.plot(marker='o', ax=ax)
        st.pyplot(fig)

    # Transaction types
    with col2:
        type_data = filtered.groupby("transaction_type")["transaction_amount"].sum()
        fig, ax = plt.subplots()
        type_data.plot(kind="bar", ax=ax)
        st.pyplot(fig)

    # Top states
    st.subheader("Top States")
    top_states = df_trans.groupby("state")["transaction_amount"].sum().sort_values(ascending=False).head(10)
    st.bar_chart(top_states)

    st.info("Insight: Few states dominate the majority of transactions.")

# ================= USER TAB =================
with tab2:

    st.subheader("User Analysis")

    filtered = df_user[df_user["state"] == state]

    col1, col2 = st.columns(2)

    # User growth
    with col1:
        year_data = filtered.groupby("year")["registered_users"].sum()
        fig, ax = plt.subplots()
        year_data.plot(marker='o', ax=ax)
        st.pyplot(fig)

    # App opens
    with col2:
        year_data = filtered.groupby("year")["app_opens"].sum()
        fig, ax = plt.subplots()
        year_data.plot(marker='o', ax=ax)
        st.pyplot(fig)

    # Engagement
    st.subheader("Engagement Ratio")
    eng = df_user.groupby("state").agg({
        "registered_users": "sum",
        "app_opens": "sum"
    })
    eng["ratio"] = eng["app_opens"] / eng["registered_users"]
    st.bar_chart(eng["ratio"].sort_values(ascending=False).head(10))

    st.info("Insight: Some states have higher engagement despite fewer users.")

# ================= INSURANCE TAB =================
with tab3:

    st.subheader("Insurance Analysis")

    filtered = df_ins[df_ins["state"] == state]

    col1, col2 = st.columns(2)

    # Growth
    with col1:
        year_data = filtered.groupby("year")["insurance_amount"].sum()
        fig, ax = plt.subplots()
        year_data.plot(marker='o', ax=ax)
        st.pyplot(fig)

    # Type distribution
    with col2:
        type_data = filtered.groupby("insurance_type")["insurance_amount"].sum()
        fig, ax = plt.subplots()
        type_data.plot(kind="pie", autopct='%1.1f%%', ax=ax)
        st.pyplot(fig)

    # Top states
    st.subheader("Top States")
    top_states = df_ins.groupby("state")["insurance_amount"].sum().sort_values(ascending=False).head(10)
    st.bar_chart(top_states)

    st.info("Insight: Insurance adoption is growing steadily across states.")

# ================= FOOTER =================
st.markdown("---")
st.markdown("🚀 Built by Aayush | PhonePe Data Project")