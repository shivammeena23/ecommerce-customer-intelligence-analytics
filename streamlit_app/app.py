"""
E-Commerce Customer Intelligence & Business Analytics — Streamlit Dashboard
Reuses the processed analytical outputs from the SQL + Python pipeline
(data/processed/*.csv) to render an interactive, deployable version of the
Power BI dashboard.

Run locally:
    streamlit run app.py

Deploy free on Streamlit Community Cloud by pointing it at this file.
"""

import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st
from pathlib import Path

# ------------------------------------------------------------------
# Page config
# ------------------------------------------------------------------
st.set_page_config(
    page_title="E-Commerce Customer Intelligence & Business Analytics",
    page_icon="📦",
    layout="wide",
)

DATA_DIR = Path(__file__).parent / "data"

# ------------------------------------------------------------------
# Data loading (cached so the app stays fast)
# ------------------------------------------------------------------
@st.cache_data
def load_data():
    kpi = pd.read_csv(DATA_DIR / "kpi_summary.csv")
    monthly_sales = pd.read_csv(DATA_DIR / "monthly_sales.csv")
    category = pd.read_csv(DATA_DIR / "category_summary.csv")
    delivery = pd.read_csv(DATA_DIR / "delivery_review_summary.csv")
    payment = pd.read_csv(DATA_DIR / "payment_summary.csv")
    rfm = pd.read_csv(DATA_DIR / "rfm_segment_summary.csv")
    new_customers = pd.read_csv(DATA_DIR / "new_customers_monthly.csv")
    sellers = pd.read_csv(DATA_DIR / "seller_summary.csv")
    return kpi, monthly_sales, category, delivery, payment, rfm, new_customers, sellers


kpi, monthly_sales, category, delivery, payment, rfm, new_customers, sellers = load_data()
kpi_dict = dict(zip(kpi["Metric"], kpi["Value"]))

# ------------------------------------------------------------------
# Sidebar
# ------------------------------------------------------------------
st.sidebar.title("📦 E-Commerce Analytics")
st.sidebar.markdown(
    "Interactive dashboard built on the **Olist Brazilian E-Commerce** "
    "dataset — 96K+ orders, 93K+ customers, 3K+ sellers."
)
page = st.sidebar.radio(
    "Navigate",
    [
        "Executive Overview",
        "Customer Intelligence (RFM)",
        "Sales & Product Analysis",
        "Operations & Delivery",
    ],
)
st.sidebar.markdown("---")
st.sidebar.markdown(
    "**Pipeline:** MySQL → Python (EDA + K-Means) → Power BI / Streamlit\n\n"
    "[GitHub Repo](https://github.com/) &nbsp;•&nbsp; "
    "[Full README](https://github.com/)"
)

# ------------------------------------------------------------------
# Shared KPI row (shown on every page for context)
# ------------------------------------------------------------------
def kpi_row():
    c1, c2, c3, c4, c5 = st.columns(5)
    c1.metric("Total Revenue", f"R$ {kpi_dict['Total Revenue']/1e6:.2f}M")
    c2.metric("Total Orders", f"{kpi_dict['Total Orders']:,.0f}")
    c3.metric("Total Customers", f"{kpi_dict['Total Customers']:,.0f}")
    c4.metric("Avg Order Value", f"R$ {kpi_dict['Average Order Value']:.2f}")
    c5.metric("Avg Review Score", f"{kpi_dict['Average Review Score']:.2f} / 5")


# ------------------------------------------------------------------
# PAGE 1 — Executive Overview
# ------------------------------------------------------------------
if page == "Executive Overview":
    st.title("Executive Overview")
    st.caption("Sales, customers & operations at a glance")
    kpi_row()
    st.markdown("---")

    col1, col2 = st.columns(2)

    with col1:
        st.subheader("Revenue Trend")
        fig = px.line(
            monthly_sales, x="order_month", y="revenue",
            markers=True, labels={"order_month": "Month", "revenue": "Revenue (R$)"},
        )
        fig.update_layout(height=380)
        st.plotly_chart(fig, use_container_width=True)

    with col2:
        st.subheader("Revenue by Product Category (Top 10)")
        top_cat = category.sort_values("revenue", ascending=False).head(10)
        fig = px.bar(
            top_cat.sort_values("revenue"), x="revenue", y="product_category_name_english",
            orientation="h", labels={"revenue": "Revenue (R$)", "product_category_name_english": ""},
        )
        fig.update_layout(height=380)
        st.plotly_chart(fig, use_container_width=True)

    col3, col4 = st.columns(2)
    with col3:
        st.subheader("Delivery Performance")
        fig = px.pie(
            delivery, names="delivery_status", values="orders", hole=0.5,
        )
        fig.update_layout(height=350)
        st.plotly_chart(fig, use_container_width=True)

    with col4:
        st.subheader("New Customer Acquisition")
        fig = px.bar(
            new_customers, x="first_purchase_month", y="new_customers",
            labels={"first_purchase_month": "Month", "new_customers": "New Customers"},
        )
        fig.update_layout(height=350)
        st.plotly_chart(fig, use_container_width=True)

    st.markdown("---")
    st.info(
        "💡 **Key insight:** Repeat customer rate is only "
        f"**{kpi_dict['Repeat Customer Rate']:.1f}%**, despite steady new-customer "
        "acquisition — pointing to a retention gap rather than an acquisition gap."
    )

# ------------------------------------------------------------------
# PAGE 2 — Customer Intelligence (RFM)
# ------------------------------------------------------------------
elif page == "Customer Intelligence (RFM)":
    st.title("Customer Intelligence & Segmentation")
    st.caption("RFM-based customer segments, value distribution and engagement insights")
    kpi_row()
    st.markdown("---")

    col1, col2 = st.columns([1, 1.2])

    with col1:
        st.subheader("Customers by Segment")
        fig = px.bar(
            rfm.sort_values("customers", ascending=False),
            x="customer_segment", y="customers",
            text="customer_percentage",
            labels={"customer_segment": "", "customers": "Customers"},
        )
        fig.update_traces(texttemplate="%{text:.1f}%", textposition="outside")
        fig.update_layout(height=420, xaxis_tickangle=-20)
        st.plotly_chart(fig, use_container_width=True)

    with col2:
        st.subheader("Revenue Contribution by Segment")
        fig = px.pie(
            rfm, names="customer_segment", values="total_monetary", hole=0.45,
        )
        fig.update_layout(height=420)
        st.plotly_chart(fig, use_container_width=True)

    st.subheader("RFM Profile by Segment")
    display_rfm = rfm.rename(columns={
        "customer_segment": "Segment",
        "customers": "Customers",
        "avg_recency": "Avg Recency (days)",
        "avg_frequency": "Avg Frequency",
        "avg_monetary": "Avg Monetary (R$)",
        "total_monetary": "Total Revenue (R$)",
        "customer_percentage": "% of Customers",
    })
    st.dataframe(
        display_rfm.style.format({
            "Avg Recency (days)": "{:.1f}",
            "Avg Frequency": "{:.2f}",
            "Avg Monetary (R$)": "R$ {:.2f}",
            "Total Revenue (R$)": "R$ {:,.0f}",
            "% of Customers": "{:.2f}%",
        }),
        use_container_width=True,
        hide_index=True,
    )

    st.markdown("---")
    low_value_pct = rfm.loc[rfm["customer_segment"].str.contains("Low-Value"), "customer_percentage"].values[0]
    st.warning(
        f"⚠️ **{low_value_pct:.1f}% of customers** fall into the Low-Value / Inactive "
        "segment — the single largest group by count, but the lowest by value. "
        "This is the highest-leverage target for a reactivation campaign."
    )

# ------------------------------------------------------------------
# PAGE 3 — Sales & Product Analysis
# ------------------------------------------------------------------
elif page == "Sales & Product Analysis":
    st.title("Sales & Product Analysis")
    st.caption("Revenue trends, product categories, and seller performance")
    kpi_row()
    st.markdown("---")

    col1, col2 = st.columns(2)
    with col1:
        st.subheader("Revenue vs. Items Sold by Category")
        top_cat = category.sort_values("revenue", ascending=False).head(10)
        fig = go.Figure()
        fig.add_bar(x=top_cat["product_category_name_english"], y=top_cat["revenue"], name="Revenue (R$)")
        fig.add_scatter(
            x=top_cat["product_category_name_english"], y=top_cat["items_sold"],
            name="Items Sold", yaxis="y2", mode="lines+markers",
        )
        fig.update_layout(
            height=420,
            yaxis=dict(title="Revenue (R$)"),
            yaxis2=dict(title="Items Sold", overlaying="y", side="right"),
            xaxis_tickangle=-30,
            legend=dict(orientation="h", y=1.1),
        )
        st.plotly_chart(fig, use_container_width=True)

    with col2:
        st.subheader("Top 10 Sellers by Revenue")
        top_sellers = sellers.sort_values("revenue", ascending=False).head(10).copy()
        top_sellers["seller_id_short"] = top_sellers["seller_id"].str[:8] + "…"
        fig = px.bar(
            top_sellers.sort_values("revenue"), x="revenue", y="seller_id_short",
            orientation="h", labels={"revenue": "Revenue (R$)", "seller_id_short": ""},
        )
        fig.update_layout(height=420)
        st.plotly_chart(fig, use_container_width=True)

    st.markdown("---")
    st.subheader("Seller Revenue Concentration")
    sellers_sorted = sellers.sort_values("revenue", ascending=False).reset_index(drop=True)
    total_rev = sellers_sorted["revenue"].sum()
    top10pct_n = max(1, int(len(sellers_sorted) * 0.10))
    top10pct_rev = sellers_sorted.head(top10pct_n)["revenue"].sum()
    share = top10pct_rev / total_rev * 100

    c1, c2 = st.columns([1, 2])
    c1.metric("Top 10% of Sellers → Revenue Share", f"{share:.1f}%")
    with c2:
        sellers_sorted["cum_revenue_pct"] = sellers_sorted["revenue"].cumsum() / total_rev * 100
        sellers_sorted["seller_rank_pct"] = (sellers_sorted.index + 1) / len(sellers_sorted) * 100
        fig = px.line(
            sellers_sorted, x="seller_rank_pct", y="cum_revenue_pct",
            labels={"seller_rank_pct": "% of Sellers (ranked by revenue)", "cum_revenue_pct": "Cumulative % of Revenue"},
        )
        fig.add_vline(x=10, line_dash="dash", line_color="orange")
        fig.update_layout(height=280)
        st.plotly_chart(fig, use_container_width=True)

    st.error(
        f"🚩 **Revenue concentration risk:** the top 10% of sellers "
        f"(~{top10pct_n:,} sellers) generate **{share:.0f}%** of total marketplace "
        "revenue — a significant dependency on a small seller base."
    )

# ------------------------------------------------------------------
# PAGE 4 — Operations & Delivery
# ------------------------------------------------------------------
elif page == "Operations & Delivery":
    st.title("Operations & Customer Experience")
    st.caption("Delivery performance, payment behaviour, and order fulfilment")
    kpi_row()
    st.markdown("---")

    col1, col2 = st.columns(2)
    with col1:
        st.subheader("Delivery Status vs. Review Score")
        fig = px.bar(
            delivery, x="delivery_status", y="average_review", color="delivery_status",
            text="average_review",
            labels={"delivery_status": "", "average_review": "Avg Review Score"},
        )
        fig.update_traces(texttemplate="%{text:.2f}", textposition="outside")
        fig.update_layout(height=400, showlegend=False, yaxis_range=[0, 5])
        st.plotly_chart(fig, use_container_width=True)

    with col2:
        st.subheader("Payment Value by Method")
        fig = px.pie(payment, names="payment_type", values="payment_value", hole=0.45)
        fig.update_layout(height=400)
        st.plotly_chart(fig, use_container_width=True)

    st.subheader("Delivery Summary")
    display_delivery = delivery.rename(columns={
        "delivery_status": "Delivery Status",
        "orders": "Orders",
        "average_review": "Avg Review Score",
        "average_delivery_days": "Avg Delivery Days",
    })
    st.dataframe(
        display_delivery.style.format({
            "Orders": "{:,.0f}",
            "Avg Review Score": "{:.2f}",
            "Avg Delivery Days": "{:.1f}",
        }),
        use_container_width=True,
        hide_index=True,
    )

    st.markdown("---")
    late = delivery.loc[delivery["delivery_status"] == "Late"].iloc[0]
    on_time = delivery.loc[delivery["delivery_status"] == "On Time"].iloc[0]
    gap = on_time["average_review"] - late["average_review"]
    st.error(
        f"🚚 **Late deliveries ({kpi_dict['Late Delivery Rate']:.1f}% of orders)** average "
        f"**{late['average_delivery_days']:.1f} days** to arrive vs. "
        f"**{on_time['average_delivery_days']:.1f} days** for on-time orders — and score "
        f"**{gap:.2f} points lower** on customer reviews ({late['average_review']:.2f} vs. "
        f"{on_time['average_review']:.2f} / 5). Logistics reliability is directly tied to satisfaction."
    )

# ------------------------------------------------------------------
# Footer
# ------------------------------------------------------------------
st.sidebar.markdown("---")
st.sidebar.caption(
    "Built with Streamlit • Data: Olist Brazilian E-Commerce Public Dataset • "
    "Full analysis: MySQL + Python (Pandas, Scikit-learn) + Power BI"
)
