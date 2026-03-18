# Uber NCR Ride Bookings — Data Analysis Project

**Author:** THAK ARAVIND
**GitHub:** [github.com/thakarvind/UBER-NCR-data-analysis](https://github.com/thakarvind/UBER-NCR-data-analysis)

> End-to-end data analysis of 150,000 Uber ride bookings across the National Capital Region (2024) — from raw data cleaning in MySQL, exploratory analysis in Python, to an interactive dashboard built in Power BI.

---

## Dashboard Preview

---

## Tools Used

| Tool | Purpose |
|------|---------|
| **MySQL** | Data ingestion, cleaning, duplicate removal, and SQL-based aggregations |
| **Python** | Exploratory data analysis, statistical summaries, and data validation |
| **Power BI** | Interactive dashboard with visuals, slicers, and KPI cards |

---

## Project Workflow

```
Raw CSV (150,000 rows)
       │
       ▼
  1. MySQL ── Clean data, remove duplicates, run queries
       │
       ▼
  2. Python ── EDA, statistical analysis, validate findings
       │
       ▼
  3. Power BI ── Build interactive dashboard, publish visuals
```

---

## 1. MySQL — Data Cleaning & Querying

The raw dataset contained **150,000 rows** with duplicate booking IDs that needed to be removed before any analysis could begin.

**Duplicate Removal**
```sql
-- Find duplicate booking IDs
SELECT booking_id, COUNT(*) AS occurrences
FROM rides
GROUP BY booking_id
HAVING COUNT(*) > 1;

-- Remove duplicates — keep the first occurrence of each booking
DELETE r1
FROM rides r1
INNER JOIN rides r2
  ON r1.booking_id = r2.booking_id
  AND r1.id > r2.id;

-- Result: 1,233 rows removed → 148,767 clean records
```

**Key SQL Queries Run**
```sql
-- Booking status breakdown with percentage
SELECT
  booking_status,
  COUNT(*) AS total,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM rides
GROUP BY booking_status
ORDER BY total DESC;

-- Monthly revenue trend
SELECT
  DATE_FORMAT(ride_date, '%Y-%m') AS month,
  COUNT(*) AS total_rides,
  ROUND(SUM(booking_value), 2) AS revenue
FROM rides
WHERE booking_status = 'Completed'
GROUP BY month
ORDER BY month;

-- Revenue by vehicle type
SELECT
  vehicle_type,
  COUNT(*) AS completed_rides,
  ROUND(SUM(booking_value), 0) AS total_revenue,
  ROUND(AVG(booking_value), 2) AS avg_fare
FROM rides
WHERE booking_status = 'Completed'
GROUP BY vehicle_type
ORDER BY total_revenue DESC;

-- Peak demand by hour
SELECT
  HOUR(ride_time) AS hour_of_day,
  COUNT(*) AS total_rides
FROM rides
GROUP BY hour_of_day
ORDER BY total_rides DESC;
```

**Cleaning Summary**

| Step | Detail |
|------|--------|
| Raw records | 150,000 |
| Duplicate booking IDs found | 1,233 |
| Rows removed | 1,233 |
| Clean records | 148,767 |
| Unique index added | Yes — on `booking_id` |

---

## 2. Python — Exploratory Data Analysis

Python was used to validate the SQL findings, compute statistics, and explore patterns across the dataset.

**Libraries Used**
```python
import pandas as pd
import numpy as np
import sqlite3
import matplotlib.pyplot as plt
import seaborn as sns
```

**EDA Steps Performed**
```python
# Load and inspect
df = pd.read_csv('ncr_ride_bookings.csv')
print(df.shape)           # (150000, 21)
print(df.dtypes)
print(df.isnull().sum())

# Clean string columns — remove extra quotes
for col in df.select_dtypes(include='object').columns:
    df[col] = df[col].str.replace('"""', '').str.strip()
    df[col] = df[col].replace({'nan': None, 'null': None})

# Remove duplicates
df.drop_duplicates(subset=['Booking ID'], keep='first', inplace=True)
print(df.shape)           # (148767, 21)

# Convert numeric columns
numeric_cols = ['Booking Value', 'Ride Distance', 'Driver Ratings',
                'Customer Rating', 'Avg VTAT', 'Avg CTAT']
for col in numeric_cols:
    df[col] = pd.to_numeric(df[col], errors='coerce')

# Summary statistics
print(df[numeric_cols].describe())

# Completion rate
completion_rate = df[df['Booking Status'] == 'Completed'].shape[0] / df.shape[0] * 100
print(f"Completion Rate: {completion_rate:.2f}%")   # 62.01%

# Peak hour analysis
df['Hour'] = pd.to_datetime(df['Time'], format='%H:%M:%S').dt.hour
peak = df.groupby('Hour').size()
print(f"Peak Hour: {peak.idxmax()}:00 with {peak.max():,} rides")
```

**Key Findings from EDA**

| Metric | Value |
|--------|-------|
| Total clean rides | 148,767 |
| Completed rides | 92,248 |
| Completion rate | 62.01% |
| Total revenue | ₹4.69 Crore |
| Average ride distance | 26.0 km |
| Average driver rating | 4.23 / 5.0 |
| Average customer rating | 4.40 / 5.0 |
| Peak demand hour | 6 PM — 12,298 rides |
| Lowest demand hour | 4 AM — 1,311 rides |

---

## 3. Power BI — Interactive Dashboard

The cleaned data was loaded into Power BI Desktop to build an interactive dashboard with slicers, KPI cards, and multiple visualisations.

**Dashboard Sections**

| Section | Visual Type | Metric |
|---------|-------------|--------|
| Key Metrics | KPI Cards | Total Rides, Revenue, Completion Rate, Avg Distance |
| Monthly Trend | Line + Bar combo | Rides and Revenue Jan–Dec 2024 |
| Booking Status | Donut Chart | Completed, Cancelled, Incomplete, No Driver |
| Vehicle Revenue | Horizontal Bar | Revenue per vehicle type |
| Payment Methods | Donut Chart | UPI, Cash, Uber Wallet, Credit Card, Debit Card |
| Hourly Demand | Area Chart | Ride volume by hour of day |
| Ratings | Bar Chart | Driver vs Customer average ratings |
| Cancellation Reasons | Bar Chart | Customer and Driver cancellation breakdowns |
| Top Locations | Table | Top 10 pickup locations by ride count |
| Vehicle Completion | Grouped Bar | Total vs Completed rides per vehicle |

**DAX Measures Used**
```dax
Total Rides = COUNT(rides[Booking ID])

Completed Rides = 
  CALCULATE(COUNT(rides[Booking ID]), rides[Booking Status] = "Completed")

Completion Rate = 
  DIVIDE([Completed Rides], [Total Rides], 0)

Total Revenue = 
  CALCULATE(SUM(rides[Booking Value]), rides[Booking Status] = "Completed")

Avg Driver Rating = 
  CALCULATE(AVERAGE(rides[Driver Ratings]), rides[Booking Status] = "Completed")

Avg Customer Rating = 
  CALCULATE(AVERAGE(rides[Customer Rating]), rides[Booking Status] = "Completed")
```

---

## Key Findings Summary

**Booking Status**
| Status | Rides | Share |
|--------|-------|-------|
| Completed | 92,248 | 62.01% |
| Cancelled by Driver | 26,789 | 18.01% |
| Cancelled by Customer | 10,402 | 6.99% |
| No Driver Found | 10,401 | 6.99% |
| Incomplete | 8,927 | 6.00% |

**Revenue by Vehicle**
| Vehicle | Completed Rides | Revenue |
|---------|----------------|---------|
| Auto | 22,970 | ₹1.16 Cr |
| Go Mini | 18,404 | ₹93.4 L |
| Go Sedan | 16,550 | ₹84.7 L |
| Bike | 13,921 | ₹70.8 L |
| Premier Sedan | 11,158 | ₹56.9 L |

**Payment Methods**
| Method | Rides | Share |
|--------|-------|-------|
| UPI | 41,500 | 45.0% |
| Cash | 22,922 | 24.8% |
| Uber Wallet | 11,116 | 12.1% |
| Credit Card | 9,240 | 10.0% |
| Debit Card | 7,470 | 8.1% |

---

## How to Run

```bash
# Step 1 — MySQL: create database and clean data
mysql -u root -p < mysql_analysis.sql

# Step 2 — Python: run EDA
pip install pandas numpy matplotlib seaborn
python3 eda_analysis.py

# Step 3 — Power BI: open dashboard
# Open uber_ncr_dashboard.pbix in Power BI Desktop
# Or open uber_ncr_dashboard.html in any browser
```

---

## Repository Structure

```
UBER-NCR-data-analysis/
├── ncr_ride_bookings.csv       ← Raw dataset (150,000 rows)
├── mysql_analysis.sql          ← MySQL cleaning + 15 EDA queries
├── eda_analysis.py             ← Python EDA script
├── uber_ncr_dashboard.html     ← Interactive HTML dashboard
├── assets/
│   ├── preview_1_overview.png
│   ├── preview_2_charts.png
│   └── preview_3_analysis.png
└── README.md
```

---

## Topics
`mysql` `python` `power-bi` `data-analysis` `eda` `data-cleaning` `sql` `pandas` `dashboard` `data-visualization` `uber` `ncr` `ride-analytics`
