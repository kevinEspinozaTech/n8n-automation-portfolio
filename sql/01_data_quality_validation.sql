/*
===============================================================================
PROJECT 01 — AI-Powered Marketing Decision & Content Automation System
===============================================================================

FILE:
01_data_quality_validation.sql

STAGE:
Stage 2 — Data Preparation & Analytical Validation

PURPOSE:
Validate the structural integrity, business-status consistency, and temporal
quality of the TheLook eCommerce dataset before performing financial and
business analysis.

SOURCE DATASET:
bigquery-public-data.thelook_ecommerce

VALIDATION AREAS:
1. Referential integrity
2. Order item count consistency
3. Status and date consistency
4. Chronological consistency

IMPORTANT:
TheLook is a synthetic and dynamic public dataset.
Validation results may change between executions.

These queries are diagnostic only.
They do not modify, delete, or correct the source data.
===============================================================================
*/


-- =============================================================================
-- 1. REFERENTIAL INTEGRITY
-- =============================================================================
-- Purpose:
-- Verify that foreign-key-like relationships used in the analysis are complete
-- and internally consistent.
--
-- Expected result for each validation: 0 inconsistent records.
-- =============================================================================


-- 1.1 Validate order_items → orders
-- Check for order_items without a matching order.

SELECT
    COUNT(*) AS orphan_order_items
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

LEFT JOIN `bigquery-public-data.thelook_ecommerce.orders` AS o
    ON oi.order_id = o.order_id

WHERE o.order_id IS NULL;


-- 1.2 Validate order_items → products
-- Check for order_items without a matching product.

SELECT
    COUNT(*) AS orphan_order_items_products
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
    ON oi.product_id = p.id

WHERE p.id IS NULL;


-- 1.3 Validate order_items → inventory_items
-- This relationship is important because inventory_items.cost
-- is later used as the COGS source.

SELECT
    COUNT(*) AS orphan_order_items_inventory
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

LEFT JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
    ON oi.inventory_item_id = ii.id

WHERE ii.id IS NULL;


-- 1.4 Validate order_items → users
-- Check for order_items without a matching user.

SELECT
    COUNT(*) AS orphan_order_items_users
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

LEFT JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
    ON oi.user_id = u.id

WHERE u.id IS NULL;


-- 1.5 Validate user consistency between orders and order_items
-- The user associated with an order_item should match
-- the user associated with its parent order.

SELECT
    COUNT(*) AS inconsistent_user_ids
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

INNER JOIN `bigquery-public-data.thelook_ecommerce.orders` AS o
    ON oi.order_id = o.order_id

WHERE oi.user_id != o.user_id;


-- =============================================================================
-- 2. ORDER ITEM COUNT CONSISTENCY
-- =============================================================================
-- Purpose:
-- Validate that orders.num_of_item matches the actual number of records
-- associated with each order in order_items.
--
-- Expected result: 0 inconsistent orders.
-- =============================================================================

SELECT
    COUNT(*) AS inconsistent_order_item_counts
FROM (
    SELECT
        o.order_id,
        o.num_of_item,
        COUNT(oi.id) AS actual_item_count
    FROM `bigquery-public-data.thelook_ecommerce.orders` AS o

    LEFT JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.order_id,
        o.num_of_item

    HAVING o.num_of_item != COUNT(oi.id)
);


-- =============================================================================
-- 3. STATUS AND DATE CONSISTENCY
-- =============================================================================
-- Purpose:
-- Validate that lifecycle timestamps are consistent with the current
-- status of each order item.
--
-- Expected result for each validation: 0 inconsistent records.
-- =============================================================================


-- 3.1 Processing
-- Processing items should not have shipped, delivered,
-- or returned timestamps.

SELECT
    COUNT(*) AS inconsistent_processing_records
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status = 'Processing'
  AND (
      shipped_at IS NOT NULL
      OR delivered_at IS NOT NULL
      OR returned_at IS NOT NULL
  );


-- 3.2 Cancelled
-- Cancelled items should not have shipped, delivered,
-- or returned timestamps.

SELECT
    COUNT(*) AS inconsistent_cancelled_records
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status = 'Cancelled'
  AND (
      shipped_at IS NOT NULL
      OR delivered_at IS NOT NULL
      OR returned_at IS NOT NULL
  );


-- 3.3 Shipped
-- Shipped items should have a shipped timestamp,
-- but should not have delivered or returned timestamps.

SELECT
    COUNT(*) AS inconsistent_shipped_records
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status = 'Shipped'
  AND (
      shipped_at IS NULL
      OR delivered_at IS NOT NULL
      OR returned_at IS NOT NULL
  );


-- 3.4 Complete
-- Complete items should have shipped and delivered timestamps,
-- but should not have a returned timestamp.

SELECT
    COUNT(*) AS inconsistent_complete_records
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status = 'Complete'
  AND (
      shipped_at IS NULL
      OR delivered_at IS NULL
      OR returned_at IS NOT NULL
  );


-- 3.5 Returned
-- Returned items should have shipped, delivered,
-- and returned timestamps.

SELECT
    COUNT(*) AS inconsistent_returned_records
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status = 'Returned'
  AND (
      shipped_at IS NULL
      OR delivered_at IS NULL
      OR returned_at IS NULL
  );


  -- =============================================================================
-- 4. CHRONOLOGICAL VALIDATION
-- =============================================================================
-- Purpose:
-- Validate the chronological order of lifecycle timestamps.
--
-- Known finding:
-- The dataset contains a systematic anomaly where some records have
-- shipped_at earlier than created_at.
--
-- This anomaly is documented rather than corrected in the source data.
-- =============================================================================


-- 4.1 Validate created_at → shipped_at chronology
-- Known dataset anomaly: inconsistent records are expected.
-- Do not use this timestamp relationship for creation-to-shipping
-- logistics KPIs without additional treatment.

SELECT
    COUNT(*) AS shipped_before_created
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE shipped_at IS NOT NULL
  AND shipped_at < created_at;


-- 4.2 Validate shipped_at → delivered_at chronology
-- Expected result: 0 inconsistent records.

SELECT
    COUNT(*) AS delivered_before_shipped
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE delivered_at IS NOT NULL
  AND shipped_at IS NOT NULL
  AND delivered_at < shipped_at;


-- 4.3 Validate delivered_at → returned_at chronology
-- Expected result: 0 inconsistent records.

SELECT
    COUNT(*) AS returned_before_delivered
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE returned_at IS NOT NULL
  AND delivered_at IS NOT NULL
  AND returned_at < delivered_at;