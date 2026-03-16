-- ============================================================
-- Uber NCR Ride Bookings 2024 — SQL Data Cleaning & EDA
-- Author: THAK ARAVIND
-- Dataset: ncr_ride_bookings.csv (150,000 raw records)
-- ============================================================

-- STEP 1: View raw data structure
SELECT * FROM rides LIMIT 5;

-- STEP 2: Count total raw records
SELECT COUNT(*) AS total_raw FROM rides;
-- Result: 150,000

-- STEP 3: Find duplicate Booking IDs
SELECT "Booking ID", COUNT(*) AS occurrences
FROM rides
GROUP BY "Booking ID"
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;
-- Found: 1,233 duplicate booking IDs

-- STEP 4: Remove duplicates (keep first occurrence)
-- In SQLite: Create clean table
CREATE TABLE rides_clean AS
SELECT * FROM rides
WHERE rowid IN (
  SELECT MIN(rowid)
  FROM rides
  GROUP BY "Booking ID"
);
-- Clean dataset: 148,767 records

-- STEP 5: Total rides after cleaning
SELECT COUNT(*) AS total_rides FROM rides_clean;

-- STEP 6: Booking status breakdown
SELECT
  "Booking Status",
  COUNT(*) AS total,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM rides_clean
GROUP BY "Booking Status"
ORDER BY total DESC;

-- STEP 7: Monthly ride and revenue trend
SELECT
  strftime('%Y-%m', Date) AS month,
  COUNT(*) AS total_rides,
  SUM(CASE WHEN "Booking Status" = 'Completed' THEN 1 ELSE 0 END) AS completed_rides,
  ROUND(SUM("Booking Value"), 2) AS total_revenue,
  ROUND(AVG("Booking Value"), 2) AS avg_fare
FROM rides_clean
GROUP BY month
ORDER BY month;

-- STEP 8: Revenue and rides by vehicle type (completed only)
SELECT
  "Vehicle Type",
  COUNT(*) AS rides,
  ROUND(SUM("Booking Value"), 0) AS total_revenue,
  ROUND(AVG("Booking Value"), 2) AS avg_fare,
  ROUND(AVG("Ride Distance"), 2) AS avg_distance_km
FROM rides_clean
WHERE "Booking Status" = 'Completed'
GROUP BY "Vehicle Type"
ORDER BY total_revenue DESC;

-- STEP 9: Payment method distribution
SELECT
  "Payment Method",
  COUNT(*) AS rides,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM rides_clean
WHERE "Booking Status" = 'Completed'
  AND "Payment Method" IS NOT NULL
GROUP BY "Payment Method"
ORDER BY rides DESC;

-- STEP 10: Peak hours (demand analysis)
SELECT
  CAST(substr(Time, 1, 2) AS INTEGER) AS hour_of_day,
  COUNT(*) AS total_rides
FROM rides_clean
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- STEP 11: Customer cancellation reasons
SELECT
  "Reason for cancelling by Customer" AS reason,
  COUNT(*) AS frequency
FROM rides_clean
WHERE "Reason for cancelling by Customer" IS NOT NULL
GROUP BY reason
ORDER BY frequency DESC;

-- STEP 12: Driver cancellation reasons
SELECT
  "Driver Cancellation Reason" AS reason,
  COUNT(*) AS frequency
FROM rides_clean
WHERE "Driver Cancellation Reason" IS NOT NULL
GROUP BY reason
ORDER BY frequency DESC;

-- STEP 13: Average ratings (completed rides only)
SELECT
  ROUND(AVG("Driver Ratings"), 2) AS avg_driver_rating,
  ROUND(AVG("Customer Rating"), 2) AS avg_customer_rating,
  COUNT(*) AS rated_rides
FROM rides_clean
WHERE "Booking Status" = 'Completed'
  AND "Driver Ratings" IS NOT NULL;

-- STEP 14: Top 10 pickup locations by completed rides
SELECT
  "Pickup Location",
  COUNT(*) AS completed_rides
FROM rides_clean
WHERE "Booking Status" = 'Completed'
GROUP BY "Pickup Location"
ORDER BY completed_rides DESC
LIMIT 10;

-- STEP 15: Incomplete rides reasons
SELECT
  "Incomplete Rides Reason",
  COUNT(*) AS frequency
FROM rides_clean
WHERE "Incomplete Rides Reason" IS NOT NULL
GROUP BY "Incomplete Rides Reason"
ORDER BY frequency DESC;

-- STEP 16: Overall summary statistics
SELECT
  COUNT(*) AS total_clean_rides,
  SUM(CASE WHEN "Booking Status" = 'Completed' THEN 1 ELSE 0 END) AS completed,
  ROUND(SUM(CASE WHEN "Booking Status" = 'Completed' THEN "Booking Value" ELSE 0 END), 0) AS total_revenue,
  ROUND(AVG(CASE WHEN "Booking Status" = 'Completed' THEN "Ride Distance" END), 2) AS avg_km,
  ROUND(AVG(CASE WHEN "Booking Status" = 'Completed' THEN "Driver Ratings" END), 2) AS avg_driver_rating,
  ROUND(AVG(CASE WHEN "Booking Status" = 'Completed' THEN "Customer Rating" END), 2) AS avg_customer_rating
FROM rides_clean;
