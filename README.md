#  NYC Yellow Taxi Enterprise Data Warehouse & Visual Analytics Platform

An end-to-end Data Engineering and Analytics solution designed to process, clean, structure, and visualize the **NYC Yellow Taxi Dataset (January 2024)**. 

This project demonstrates a complete data pipeline lifecycle—from raw Parquet ingestion and automated error auditing via Python, to modeling a relational Data Warehouse in SQL Server, and delivering interactive business insights through a 3-page Power BI dashboard.

---

##  Project Architecture & Workflow
[ Raw Dataset (.parquet) ] ──► (Download via Cloudfront Link)
│
▼
[ Python ETL Pipeline ] ──(Isolate Invalid Records)──► [ Audit_TaxiErrors Table ]
│ (Clean & Transform)
▼
[ SQL Server Data Warehouse ] ──(Fact & Dimension Star Schema)
│
▼
[ Analytical SQL Views ] ──(Performance Aggregations)
│
▼
[ Power BI Interactive Dashboard ] ──► (Financial, Peak-Time & Location Insights)
---

## 🛠️ Tech Stack & Tools

* **Programming Language:** Python 3.x
* **Data Manipulation & ETL:** Pandas, NumPy, SQLAlchemy, PyODBC
* **Database Management System:** SQL Server Management Studio (SSMS)
* **Data Warehouse Schema:** Relational Star Schema (Fact & Dimension Tables)
* **Visual Analytics & Business Intelligence:** Power BI Desktop, DAX
* **Direct Dataset URL:** [Download NYC Yellow Taxi Jan 2024 Dataset](https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-01.parquet)

---

## 🧹 1. Data Cleaning & Automated Audit System

Raw data often contains anomalies, hardware glitches, and missing entries. The Python ETL pipeline applies **10 strict validation rules**. Any non-compliant record is extracted, tagged with an `error_reason`, and routed to a dedicated audit logging table (`Audit_TaxiErrors`).

### Validation Rules Applied:
1. **Passenger Count:** Imputed missing values to `1`; isolated counts `< 1` or `> 6`.
2. **Payment Type:** Standardized implicit nulls (`0` to `5` - Unknown); isolated voided trips (`6`).
3. **Rate Code:** Imputed missing entries to `1` (Standard Rate); isolated codes `> 6` (e.g., code `99`).
4. **Financial Sanity:** Isolated negative or zero values in `fare_amount` and `total_amount`.
5. **Logical Timestamps:** Isolated trips where `tpep_dropoff_datetime <= tpep_pickup_datetime`.
6. **Trip Distance:** Isolated non-positive trip distances (`trip_distance <= 0`).
7. **Date Range Scope:** Isolated pickup timestamps outside January 2024.
8. **Null Imputation:** Imputed missing pickup/dropoff locations with `265` (Unknown Location).
9. **Surcharge/Fee Integrity:** Filtered negative values across extra charges, MTA tax, tips, tolls, and surcharges.
10. **Outliers & Glitches:** Isolated extreme fares (`> $5,000`) and ultra-short trips (`< 10 seconds`).

---

## 🏗️ 2. Data Warehouse Architecture (Star Schema)
The cleaned data is loaded into `NYC_Taxi_DW` structured as a **Star Schema** to optimize query performance and reduce storage redundancy.

              ┌──────────────┐
              │   Dim_Date   │
              └──────┬───────┘
                     │
┌──────────────┐         │         ┌──────────────────┐
│  Dim_Vendor  ├─────────┼─────────┤ Dim_PaymentType  │
└──────────────┘         │         └──────────────────┘
▼
┌────────────────┐
│ Fact_TaxiTrips │
└────────────────┘
▲
┌──────────────┐         │         ┌──────────────────┐
│ Dim_Ratecode ├─────────┼─────────┤   Dim_Location   │
└──────────────┘         │         └──────────────────┘
│
┌──────────────┐
│   Dim_Time   │
└──────────────┘


### Key Dimensions:
* **`Dim_Date`:** Calendar dimension covering all 2024 dates (`DateKey`, `Year`, `Quarter`, `Month`, `DayOfWeek`, `IsWeekend`).
* **`Dim_Time`:** Second-by-second dimension (86,400 rows) with engineered **`TimeBucket`** intervals (*Morning, Afternoon, Evening, Night*).
* **`Dim_Vendor` / `Dim_PaymentType` / `Dim_Ratecode` / `Dim_Location`:** Lookup seed dimensions for entity mapping.

---

## ⚡ 3. SQL Database Views for Performance Optimization

To prevent performance bottlenecks during Power BI refreshes, aggregations were offloaded to SQL Server using pre-calculated views:
* **`vw_FinancialBreakdown`:** Aggregates base fares, tips, tolls, and airport surcharges.
* **`vw_TimeDemandAnalysis`:** Pre-aggregates trip volumes and revenue by hour, weekday, and `TimeBucket`.
* **`vw_AirportAndDistanceAnalysis`:** Calculates distance metrics, trip duration, and average speeds ($\text{mph}$).

---

## 📊 4. Interactive Power BI Dashboard

The dashboard consists of **3 key analytical pages**:

### 1️⃣ Executive Overview
Focuses on macro-level business performance, total revenue growth, and trip distribution across payment types.
> *(Add screenshot link here: `![Executive Overview](images/executive_overview.png)`)*

### 2️⃣ Demand & Time Analytics
Features a **Matrix Heatmap** (Hours $\times$ Weekdays) to highlight operational peak hours and passenger demand trends.
> *(Add screenshot link here: `![Time Analytics](images/time_analytics.png)`)*

### 3️⃣ Location & Trip Insights
Analyzes Top 10 revenue-generating pickup zones, speed/distance ratios, and airport trip efficiency (JFK/Newark).
> *(Add screenshot link here: `![Location Insights](images/location_insights.png)`)*

---

## 💡 Key Business Insights

1. **Peak Demand Windows:** Maximum ride volume and revenue peak between **5:00 PM and 7:00 PM** on weekdays (Monday–Friday).
2. **Payment Preferences:** Credit cards account for over **80%** of total revenue and consistently yield higher tip percentages compared to cash.
3. **Airport Trip Economics:** Although airport trips (JFK & Newark) account for a smaller volume percentage, they generate the **highest average revenue per trip**.

---

## 🚀 How to Run the Project

1. **Download Dataset:** Download the dataset directly from [Cloudfront Direct Link](https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-01.parquet) and place it in your project root directory.
2. **Database Setup:** Open SQL Server Management Studio (SSMS) and create database `NYC_Taxi_DW`.
3. **Run Pipeline:** Execute the Python script to clean the data and automatically populate tables:
   ```bash
   python main_pipeline.py
4. **View Analytics:** Open NYC_Taxi_Analytics.pbix in Power BI Desktop to explore the dashboard.
