/*
===============================================================================
PROJECT 01 — AI-Powered Marketing Decision & Content Automation System
===============================================================================

FILE:
02_financial_validation.sql

STAGE:
Stage 2 — Data Preparation & Analytical Validation

PURPOSE:
Validate the financial fields and business rules used to calculate revenue,
COGS, gross profit, and gross margin from the TheLook eCommerce dataset.

SOURCE DATASET:
bigquery-public-data.thelook_ecommerce

VALIDATION AREAS:
1. Sale price validation
2. Inventory cost validation
3. Product and inventory consistency
4. Sale price versus cost validation
5. Financial recognition rules
6. Financial baseline

IMPORTANT:
TheLook is a synthetic and dynamic public dataset.
Validation results may change between executions.

Financial assumptions used in this project are analytical business rules and
should not be interpreted as observed accounting policies from the dataset.

These queries are diagnostic and analytical only.
They do not modify, delete, or correct the source data.
===============================================================================
*/


-- =============================================================================
-- 1. SALE PRICE VALIDATION
-- =============================================================================
-- Purpose:
-- Validate the sale_price field before using it as the basis for revenue.
--
-- Checks:
-- - Total records
-- - NULL values
-- - Zero or negative values
-- - Minimum sale price
-- - Maximum sale price
-- - Average sale price
-- =============================================================================

SELECT
    COUNT(*) AS total_records,
    COUNTIF(sale_price IS NULL) AS null_sale_prices,
    COUNTIF(sale_price <= 0) AS zero_or_negative_sale_prices,
    MIN(sale_price) AS min_sale_price,
    MAX(sale_price) AS max_sale_price,
    AVG(sale_price) AS avg_sale_price
FROM `bigquery-public-data.thelook_ecommerce.order_items`;


-- =============================================================================
-- 2. INVENTORY COST VALIDATION
-- =============================================================================
-- Purpose:
-- Validate inventory_items.cost before using it as the COGS source.
--
-- Checks:
-- - Total sold items with inventory match
-- - NULL cost values
-- - Zero or negative cost values
-- - Minimum cost
-- - Maximum cost
-- - Average cost
-- =============================================================================

SELECT
    COUNT(*) AS total_records,
    COUNTIF(ii.cost IS NULL) AS null_costs,
    COUNTIF(ii.cost <= 0) AS zero_or_negative_costs,
    MIN(ii.cost) AS min_cost,
    MAX(ii.cost) AS max_cost,
    AVG(ii.cost) AS avg_cost
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
    ON oi.inventory_item_id = ii.id;


    -- =============================================================================
-- 3. PRODUCT AND INVENTORY CONSISTENCY
-- =============================================================================
-- Purpose:
-- Validate that the inventory item associated with each order_item belongs
-- to the same product referenced by order_items.product_id.
--
-- Expected result: 0 inconsistent records.
-- =============================================================================

SELECT
    COUNT(*) AS product_inventory_mismatches
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
    ON oi.inventory_item_id = ii.id

WHERE oi.product_id != ii.product_id;


-- =============================================================================
-- 4. SALE PRICE VS COST VALIDATION
-- =============================================================================
-- Purpose:
-- Identify sold items where sale_price is lower than inventory cost.
--
-- A result greater than 0 would require further investigation before using
-- the fields for gross profit analysis.
--
-- Expected result based on previous validation: 0 records.
-- =============================================================================

SELECT
    COUNT(*) AS sale_price_below_cost
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
    ON oi.inventory_item_id = ii.id

WHERE oi.sale_price < ii.cost;


-- =============================================================================
-- 5. FINANCIAL RECOGNITION RULES
-- =============================================================================
-- Purpose:
-- Apply the analytical business rules adopted by this project for financial
-- recognition by order-item status.
--
-- Complete   → Revenue and COGS recognized
-- Returned   → Revenue and COGS reversed
-- Cancelled  → No recognized Revenue or COGS
-- Processing → Pending
-- Shipped    → Pending
--
-- IMPORTANT:
-- These are project-level analytical assumptions, not accounting policies
-- explicitly provided by TheLook.
-- =============================================================================

SELECT
    oi.status,
    COUNT(*) AS item_count,
    ROUND(SUM(oi.sale_price), 2) AS sale_value,
    ROUND(SUM(ii.cost), 2) AS cost_value
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
    ON oi.inventory_item_id = ii.id

GROUP BY oi.status

ORDER BY oi.status;


-- 5.1 Apply financial recognition classification
-- Translate operational status into the analytical financial treatment
-- adopted for this project.

SELECT
    status,
    CASE
        WHEN status = 'Complete' THEN 'Recognized'
        WHEN status = 'Returned' THEN 'Reversed'
        WHEN status = 'Cancelled' THEN 'Not Recognized'
        WHEN status IN ('Processing', 'Shipped') THEN 'Pending'
        ELSE 'Review'
    END AS financial_treatment,
    COUNT(*) AS item_count,
    ROUND(SUM(sale_price), 2) AS sale_value
FROM `bigquery-public-data.thelook_ecommerce.order_items`

GROUP BY
    status,
    financial_treatment

ORDER BY status;


-- =============================================================================
-- 6. FINANCIAL BASELINE
-- =============================================================================
-- Purpose:
-- Calculate the main financial KPIs using the recognition rules adopted
-- for this project.
--
-- Recognized Revenue and COGS are based only on Complete items.
-- Processing and Shipped values remain pending.
-- Cancelled values are not recognized.
-- Returned values are treated as reversed.
-- =============================================================================

SELECT
    ROUND(SUM(
        CASE
            WHEN oi.status = 'Complete' THEN oi.sale_price
            ELSE 0
        END
    ), 2) AS recognized_revenue,

    ROUND(SUM(
        CASE
            WHEN oi.status = 'Complete' THEN ii.cost
            ELSE 0
        END
    ), 2) AS recognized_cogs,

    ROUND(SUM(
        CASE
            WHEN oi.status = 'Complete'
                THEN oi.sale_price - ii.cost
            ELSE 0
        END
    ), 2) AS gross_profit,

    ROUND(
        SAFE_DIVIDE(
            SUM(CASE
                WHEN oi.status = 'Complete'
                    THEN oi.sale_price - ii.cost
                ELSE 0
            END),
            SUM(CASE
                WHEN oi.status = 'Complete'
                    THEN oi.sale_price
                ELSE 0
            END)
        ) * 100,
        2
    ) AS gross_margin_pct,

    ROUND(SUM(
        CASE
            WHEN oi.status IN ('Processing', 'Shipped')
                THEN oi.sale_price
            ELSE 0
        END
    ), 2) AS pending_order_value,

    ROUND(SUM(
        CASE
            WHEN oi.status = 'Returned'
                THEN oi.sale_price
            ELSE 0
        END
    ), 2) AS return_associated_value,

    ROUND(SUM(
        CASE
            WHEN oi.status = 'Cancelled'
                THEN oi.sale_price
            ELSE 0
        END
    ), 2) AS cancelled_value

FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
    ON oi.inventory_item_id = ii.id;