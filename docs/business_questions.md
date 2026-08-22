# Business Questions

## Olist E-Commerce Analytics Project

This document defines the core business questions that will guide the SQL analysis and Power BI dashboard for the Olist E-Commerce Analytics project.

The analysis focuses on sales performance, customer behavior, seller performance, logistics, payments, customer satisfaction, and freight costs.

---

# 1. Sales & Revenue Analysis

## Q1. How is the overall sales performance of the business?

Analyze the overall health of the business using:

- Total Revenue
- Total Orders
- Average Order Value (AOV)
- Revenue by Order Status
- Total Freight

---

## Q2. How has revenue and order volume changed over time?

Analyze business growth and trends using:

- Monthly Revenue
- Monthly Order Volume
- Monthly Average Order Value
- Month-over-Month (MoM) Revenue Growth

---

## Q3. Which product categories and products drive the most sales?

Identify the strongest-performing products and categories using:

- Revenue by Category
- Quantity Sold by Category
- Revenue Contribution by Category
- Top Products by Revenue
- Top Products by Quantity Sold

---

# 2. Customer Analysis

## Q4. Who are our customers and where are they located?

Understand the customer base geographically using:

- Customers by State
- Customers by City
- Orders by Location
- Revenue by State

---

## Q5. How loyal are our customers?

Analyze customer purchasing behavior using:

- One-Time vs Repeat Customers
- Repeat Customer Rate
- Orders per Customer
- Customer Order Frequency

---

## Q6. Which customers generate the most value?

Identify high-value customers using:

- Customer Revenue
- Average Customer Spend
- Top Customers by Revenue
- Revenue Contribution by Customer

---

# 3. Seller Analysis

## Q7. Which sellers are driving the business?

Evaluate seller performance using:

- Seller Revenue
- Orders per Seller
- Quantity Sold
- Seller Average Order Value
- Top Sellers by Revenue

---

## Q8. How concentrated is marketplace revenue among sellers?

Understand the dependence of marketplace revenue on high-performing sellers using:

- Seller Revenue Share
- Top 10% Seller Revenue Contribution
- Cumulative Revenue Contribution
- Seller Revenue Distribution

---

# 4. Delivery & Logistics Analysis

## Q9. How well is the company performing in terms of delivery?

Measure overall delivery performance using:

- Average Delivery Time
- On-Time Delivery Rate
- Late Delivery Rate
- Average Delivery Delay
- Estimated vs Actual Delivery Time

---

## Q10. Where are the major logistics problems?

Identify geographical and seller-level delivery bottlenecks using:

- Delivery Performance by State
- States with Highest Delivery Time
- States with Highest Late Delivery Rate
- Sellers with Poor Delivery Performance

---

## Q11. How has delivery performance changed over time?

Analyze delivery trends using:

- Monthly Average Delivery Time
- Monthly Late Delivery Rate
- Monthly On-Time Delivery Rate
- Changes in Estimated vs Actual Delivery Time

---

# 5. Payment Analysis

## Q12. How do customers pay and what is the value of each payment method?

Understand customer payment behavior using:

- Payment Method Popularity
- Orders by Payment Method
- Revenue by Payment Method
- Average Transaction Value
- Payment Installment Behavior

---

# 6. Customer Satisfaction

## Q13. How satisfied are customers?

Measure overall customer satisfaction using:

- Average Review Score
- Review Score Distribution
- Reviews by Product Category
- Average Review Score by Category

---

## Q14. Does delivery performance affect customer satisfaction?

Analyze the relationship between logistics and customer experience using:

- Delivery Time vs Review Score
- Late Delivery vs Review Score
- Average Review Score for On-Time Orders
- Average Review Score for Late Orders

---

# 7. Freight & Cost Analysis

## Q15. How significant are freight costs to the business?

Analyze the impact of shipping costs using:

- Total Freight Cost
- Average Freight per Order
- Freight as a Percentage of Product Value
- Freight Cost by Product Category
- Freight Cost by Customer Location

---

# 8. Overall Business Insights

## Q16. What are the biggest business opportunities and problems?

Combine the findings from the complete analysis to identify actionable business insights, such as:

- High-revenue but low-rated categories
- High-revenue sellers with poor delivery performance
- High-freight categories or locations
- High-value customers with low repeat-purchase behavior
- Revenue concentration among a small number of sellers
- Poor-performing geographic markets
- Strong-performing product categories
- Areas with potential for improving customer satisfaction

---

# Analysis Framework

The 16 core business questions are organized into the following analytical areas:

1. Sales & Revenue Analysis
2. Customer Analysis
3. Seller Analysis
4. Delivery & Logistics Analysis
5. Payment Analysis
6. Customer Satisfaction
7. Freight & Cost Analysis
8. Overall Business Insights

These business questions will serve as the foundation for:

- SQL analytical queries
- Reusable SQL views
- Key Performance Indicators (KPIs)
- Power BI visualizations
- Business insights and recommendations