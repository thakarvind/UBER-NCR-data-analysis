# Uber NCR Ride Bookings — Data Analysis & Dashboard

**Author:** THAK ARAVIND   
**Dataset:** NCR (National Capital Region) Uber Ride Bookings · Jan–Dec 2024  
**Stack:** MySQL · Python · power bi

---

## Project Description

SQL-powered data cleaning and EDA on 150,000 Uber NCR ride bookings with an interactive analytics dashboard. Cleaned raw data using MySQL — removing 1,233 duplicate records — then performed full exploratory data analysis covering ride status, revenue trends, vehicle performance, peak demand hours, cancellation patterns, and payment behaviour. Findings are presented in a fully interactive dark-mode dashboard built with HTML, CSS, and Chart.js.

---

## Files

| File | Description |
|------|-------------|
| `ncr_ride_bookings.csv` | Raw dataset · 150,000 rows · 21 columns |
| `mysql_analysis.sql` | Full MySQL cleaning + EDA (15 queries) |
| `uber_ncr_dashboard.` | Interactive analytics dashboard |

---

## Data Cleaning — MySQL

| Step | Action | Result |
|------|--------|--------|
| Load | Import CSV into MySQL table | 150,000 rows |
| Inspect | CHECK NULL counts, preview data | — |
| Find duplicates | GROUP BY booking_id HAVING COUNT > 1 | 1,233 found |
| Remove duplicates | DELETE with self-join keeping MIN(id) | 1,233 removed |
| Lock | ADD UNIQUE INDEX on booking_id | Future-proof |
| **Final dataset** | **148,767 rows × 21 columns** | ✓ Clean |

---

## Key Findings

### Overview
| Metric | Value |
|--------|-------|
| Total Rides | 148,767 |
| Total Revenue | ₹4.69 Crore |
| Completion Rate | 62.01% |
| Average Distance | 26.0 km |
| Avg Driver Rating | 4.23 / 5.0 |
| Avg Customer Rating | 4.40 / 5.0 |

### Booking Status
| Status | Rides | % |
|--------|-------|---|
| Completed | 92,248 | 62.01% |
| Cancelled by Driver | 26,789 | 18.01% |
| Cancelled by Customer | 10,402 | 6.99% |
| No Driver Found | 10,401 | 6.99% |
| Incomplete | 8,927 | 6.00% |

### Revenue by Vehicle
| Vehicle | Completed Rides | Revenue |
|---------|----------------|---------|
| Auto | 22,970 | ₹1.16 Cr |
| Go Mini | 18,404 | ₹93.4 L |
| Go Sedan | 16,550 | ₹84.7 L |
| Bike | 13,921 | ₹70.8 L |
| Premier Sedan | 11,158 | ₹56.9 L |

### Payment Methods
| Method | Rides | % |
|--------|-------|---|
| UPI | 41,500 | 45.0% |
| Cash | 22,922 | 24.8% |
| Uber Wallet | 11,116 | 12.1% |
| Credit Card | 9,240 | 10.0% |
| Debit Card | 7,470 | 8.1% |

### Peak Demand
- **Morning peak:** 10 AM — 9,490 rides
- **Evening peak:** 6 PM — 12,298 rides *(highest of the day)*
- **Lowest demand:** 4 AM — 1,311 rides

---

## How to Run

```bash
# 1. Create database and import data
mysql -u root -p < mysql_analysis.sql

```

---

## GitHub Topics
`data-analysis` `mysql` `python` `eda` `dashboard` `uber` `data-cleaning` `chartjs` `data-visualization` `ncr` `ride-analytics` `sql`
