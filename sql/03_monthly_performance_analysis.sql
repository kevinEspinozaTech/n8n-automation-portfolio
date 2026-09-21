/*
===============================================================================
PROJECT 01 — AI-Powered Marketing Decision & Content Automation System
===============================================================================

FILE:
03_monthly_performance_analysis.sql

STAGE:
Stage 2 — Data Preparation & Analytical Validation

PURPOSE:
Analyze monthly financial performance using completed sales and the financial
recognition rules adopted for this project.

SOURCE DATASET:
bigquery-public-data.thelook_ecommerce

ANALYSIS AREAS:
1. Historical period validation
2. Monthly financial aggregation
3. Month-over-Month (MoM) growth
4. Year-over-Year (YoY) growth
5. Monthly profitability trends

FINANCIAL SCOPE:
Only order_items with status = 'Complete' are treated as recognized sales.

TIME RULE:
delivered_at is used as the financial recognition date for completed sales.

CURRENT-MONTH RULE:
The current month is excluded from historical trend analysis because it is
incomplete and the dataset may contain future delivered_at values within the
current month.

IMPORTANT:
TheLook is a synthetic and dynamic public dataset.
Results may change between executions.

These queries are analytical only.
They do not modify, delete, or correct the source data.
===============================================================================
*/


-- =============================================================================
-- 1. HISTORICAL PERIOD VALIDATION
-- =============================================================================
-- Purpose:
-- Validate the available delivery-date range for completed sales and identify
-- future delivery dates before building the monthly historical analysis.
--
-- delivered_at is used as the financial recognition date.
-- =============================================================================

SELECT
    MIN(DATE(delivered_at)) AS first_delivery_date,
    MAX(DATE(delivered_at)) AS last_delivery_date,
    COUNT(*) AS total_complete_items,

    COUNTIF(
        DATE(delivered_at) > CURRENT_DATE()
    ) AS future_complete_items

FROM `bigquery-public-data.thelook_ecommerce.order_items`

WHERE status = 'Complete'
  AND delivered_at IS NOT NULL;


  -- =============================================================================
-- 2. MONTHLY FINANCIAL AGGREGATION
-- =============================================================================
-- Purpose:
-- Aggregate recognized financial performance by completed delivery month.
--
-- Only Complete items are included.
-- The current month is excluded so that historical comparisons use only
-- closed months.
-- =============================================================================

SELECT
    DATE_TRUNC(DATE(oi.delivered_at), MONTH) AS month,

    COUNT(*) AS items_sold,

    ROUND(
        SUM(oi.sale_price),
        2
    ) AS revenue,

    ROUND(
        SUM(ii.cost),
        2
    ) AS cogs,

    ROUND(
        SUM(oi.sale_price - ii.cost),
        2
    ) AS gross_profit,

    ROUND(
        SAFE_DIVIDE(
            SUM(oi.sale_price - ii.cost),
            SUM(oi.sale_price)
        ) * 100,
        2
    ) AS gross_margin_pct

FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
    ON oi.inventory_item_id = ii.id

WHERE oi.status = 'Complete'
  AND oi.delivered_at IS NOT NULL
  AND DATE(oi.delivered_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)

GROUP BY month

ORDER BY month;


-- =============================================================================
-- 3. MONTH-OVER-MONTH AND YEAR-OVER-YEAR GROWTH
-- =============================================================================
-- Purpose:
-- Compare monthly recognized revenue with the previous month (MoM)
-- and the same month of the previous year (YoY).
--
-- LAG(..., 1)  → previous month
-- LAG(..., 12) → same month of previous year
-- =============================================================================

WITH monthly_performance AS (

    SELECT
        DATE_TRUNC(DATE(oi.delivered_at), MONTH) AS month,

        COUNT(*) AS items_sold,

        SUM(oi.sale_price) AS revenue,

        SUM(ii.cost) AS cogs,

        SUM(oi.sale_price - ii.cost) AS gross_profit

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
        ON oi.inventory_item_id = ii.id

    WHERE oi.status = 'Complete'
      AND oi.delivered_at IS NOT NULL
      AND DATE(oi.delivered_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)

    GROUP BY month
),

growth_comparison AS (

    SELECT
        *,

        LAG(revenue, 1) OVER (
            ORDER BY month
        ) AS previous_month_revenue,

        LAG(revenue, 12) OVER (
            ORDER BY month
        ) AS previous_year_revenue

    FROM monthly_performance
)

SELECT
    month,
    items_sold,

    ROUND(revenue, 2) AS revenue,
    ROUND(cogs, 2) AS cogs,
    ROUND(gross_profit, 2) AS gross_profit,

    ROUND(
        SAFE_DIVIDE(gross_profit, revenue) * 100,
        2
    ) AS gross_margin_pct,

    ROUND(
        SAFE_DIVIDE(
            revenue - previous_month_revenue,
            previous_month_revenue
        ) * 100,
        2
    ) AS revenue_mom_pct,

    ROUND(
        SAFE_DIVIDE(
            revenue - previous_year_revenue,
            previous_year_revenue
        ) * 100,
        2
    ) AS revenue_yoy_pct

FROM growth_comparison

ORDER BY month;


-- =============================================================================
-- 4. MONTHLY PROFITABILITY TREND
-- =============================================================================
-- Purpose:
-- Evaluate the relationship between monthly sales volume, revenue,
-- gross profit, and gross margin over time.
--
-- This analysis helps determine whether revenue growth is accompanied by
-- higher sales volume and whether profitability remains relatively stable.
-- =============================================================================

WITH monthly_profitability AS (

    SELECT
        DATE_TRUNC(DATE(oi.delivered_at), MONTH) AS month,

        COUNT(*) AS items_sold,

        SUM(oi.sale_price) AS revenue,

        SUM(ii.cost) AS cogs,

        SUM(oi.sale_price - ii.cost) AS gross_profit

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
        ON oi.inventory_item_id = ii.id

    WHERE oi.status = 'Complete'
      AND oi.delivered_at IS NOT NULL
      AND DATE(oi.delivered_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)

    GROUP BY month
)

SELECT
    month,
    items_sold,

    ROUND(revenue, 2) AS revenue,

    ROUND(gross_profit, 2) AS gross_profit,

    ROUND(
        SAFE_DIVIDE(gross_profit, revenue) * 100,
        2
    ) AS gross_margin_pct,

    ROUND(
        SAFE_DIVIDE(revenue, items_sold),
        2
    ) AS average_revenue_per_item

FROM monthly_profitability

ORDER BY month;