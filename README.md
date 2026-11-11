# Enterprise Sales Analytics: 32M Rows Optimization

## 📌 Executive Summary
Engineered an end-to-end data pipeline to process and analyze **32+ million sales records** and **3 million total orders**. Implemented a "Shift-Left" architecture by pushing heavy data transformations to PostgreSQL, resulting in a highly optimized, production-ready Power BI executive dashboard.

## 🛠️ Tech Stack
* **Database & ETL:** PostgreSQL, pgAdmin4
* **Business Intelligence:** Power BI
* **Key Techniques:** Shift-Left Architecture, SQL Window Functions, Data Modeling, DAX, Executive Formatting

## 🚀 Architecture & Performance Optimization (Shift-Left)
To ensure the dashboard loads instantly without power query bottlenecks, all heavy lifting was done at the database level:
* **Data Cleansing:** Consolidated ambiguous categories ('missing' and 'other') into a unified 'Misc' segment using SQL Views.
* **Backend Performance:** Complex aggregations of 32 million rows were optimized to execute rapidly using targeted Indexing (`CREATE INDEX`) and `ANALYSE`.
* **Ultra-Light BI File:** Because all heavy data transformations were processed in the SQL backend, the final interactive Power BI `.pbix` file is incredibly lightweight (**only 760 KB!**).

## 📊 Dashboard Visuals

### 1. Executive Master View (Dark Teal Theme)
*(Reordered percentage highlights and seamless cross-filtering)*
![Master View](Sales_dashboard_1.png)

### 2. Department-Level Slicer (Active Selection)
*(Demonstrating dynamic cross-filtering with drop-down active)*
![Slicer Open](Sales_dashboard_2.png)

### 3. Department-Level Slicer (Clean View)
*(Clean executive view after filter application)*
![Slicer Closed](Sales_dashboard_3.png)

## 📂 Project Files
* **SQL Scripts:** Check `purchase_analytics.sql` in this repository for the advanced table structures, views, and index creations.
* **Power BI Dashboard:** The highly optimized **760 KB** `Sales Dashboard.pbix` file is uploaded directly in this repository. Feel free to download and interact with the data model!
