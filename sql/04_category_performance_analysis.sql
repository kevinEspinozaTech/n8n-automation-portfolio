/*
===============================================================================
PROJECT 01 — AI-Powered Marketing Decision & Content Automation System
===============================================================================

FILE:
04_category_performance_analysis.sql

STAGE:
Stage 2 — Data Preparation & Analytical Validation

PURPOSE:
Evaluate product-category performance using financial and operational metrics
to support the category decision model developed in this project.

SOURCE DATASET:
bigquery-public-data.thelook_ecommerce

ANALYSIS AREAS:
1. Category financial performance
2. Category operational performance
3. Combined financial + operational category view
4. Primary decision criteria — range validation
5. Primary decision criteria — Min-Max normalization
6. Balanced category decision model
7. Sensitivity analysis — multiple business scenarios
8. Scenario ranking and robustness analysis (includes Robust Candidate
   classification)

NOTE:
This list has eight areas, matching the eight numbered sections in this file.
Section 8 covers three closely related steps in one continuous query:
scenario-rank comparison, robustness scoring (average_rank, rank_variation),
and the final Robust Candidate / Sensitive classification.

PRIMARY DECISION CRITERIA:
- Gross Profit      → Higher is better
- Gross Margin      → Higher is better
- Sales Volume      → Higher is better
- Return Rate       → Lower is better

SECONDARY METRIC:
- Cancellation Rate

FINANCIAL SCOPE:
Financial metrics use Complete items and delivered_at as the recognition date.
The current month is excluded from historical financial analysis.

OPERATIONAL SCOPE:
Return and cancellation metrics use final-status items and created_at for
cohort assignment. The current month is excluded.

IMPORTANT:
The financial and operational components intentionally use different temporal
cohorts because Cancelled items do not have delivered_at.

Scenario weights, normalization rules, and robustness thresholds are analytical
assumptions adopted for this project. They are not observed dataset facts.

TheLook is a synthetic and dynamic public dataset.
Results may change between executions.

These queries are analytical only.
They do not modify, delete, or correct the source data.
===============================================================================
*/


-- =============================================================================
-- 1. CATEGORY FINANCIAL PERFORMANCE
-- =============================================================================
-- Purpose:
-- Measure recognized financial performance by product category.
--
-- Financial rules:
-- - Only Complete items are recognized.
-- - delivered_at is used as the recognition date.
-- - The current month is excluded.
--
-- Metrics:
-- - Completed items / sales volume
-- - Revenue
-- - COGS
-- - Gross Profit
-- - Gross Margin %
-- =============================================================================

SELECT
    p.category,

    COUNT(*) AS completed_items,

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

INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
    ON oi.product_id = p.id

INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
    ON oi.inventory_item_id = ii.id

WHERE oi.status = 'Complete'
  AND oi.delivered_at IS NOT NULL
  AND DATE(oi.delivered_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)

GROUP BY p.category

ORDER BY gross_profit DESC;


-- =============================================================================
-- 2. CATEGORY OPERATIONAL PERFORMANCE
-- =============================================================================
-- Purpose:
-- Measure return and cancellation behavior by product category.
--
-- Operational cohort:
-- - Uses created_at for cohort assignment.
-- - Excludes the current month.
-- - Includes only final statuses:
--   Complete, Returned, Cancelled.
--
-- Return Rate:
-- Returned / (Complete + Returned)
--
-- Cancellation Rate:
-- Cancelled / (Complete + Returned + Cancelled)
-- =============================================================================

SELECT
    p.category,

    COUNTIF(oi.status = 'Complete') AS complete_items,

    COUNTIF(oi.status = 'Returned') AS returned_items,

    COUNTIF(oi.status = 'Cancelled') AS cancelled_items,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(oi.status = 'Returned'),
            COUNTIF(oi.status IN ('Complete', 'Returned'))
        ) * 100,
        2
    ) AS return_rate_pct,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(oi.status = 'Cancelled'),
            COUNTIF(oi.status IN ('Complete', 'Returned', 'Cancelled'))
        ) * 100,
        2
    ) AS cancellation_rate_pct

FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
    ON oi.product_id = p.id

WHERE DATE(oi.created_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)
  AND oi.status IN ('Complete', 'Returned', 'Cancelled')

GROUP BY p.category

ORDER BY return_rate_pct ASC;


-- =============================================================================
-- 3. COMBINED FINANCIAL + OPERATIONAL CATEGORY VIEW
-- =============================================================================
-- Purpose:
-- Combine financial and operational category metrics into a single
-- analytical view.
--
-- IMPORTANT:
-- Financial and operational metrics intentionally use different temporal
-- cohorts. Therefore, financial_completed_items and operational_complete_items
-- are not expected to match exactly.
-- =============================================================================

WITH financial_metrics AS (

    SELECT
        p.category,

        COUNT(*) AS financial_completed_items,

        SUM(oi.sale_price) AS revenue,

        SUM(ii.cost) AS cogs,

        SUM(oi.sale_price - ii.cost) AS gross_profit,

        SAFE_DIVIDE(
            SUM(oi.sale_price - ii.cost),
            SUM(oi.sale_price)
        ) * 100 AS gross_margin_pct

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
        ON oi.inventory_item_id = ii.id

    WHERE oi.status = 'Complete'
      AND oi.delivered_at IS NOT NULL
      AND DATE(oi.delivered_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)

    GROUP BY p.category
),

operational_metrics AS (

    SELECT
        p.category,

        COUNTIF(oi.status = 'Complete') AS operational_complete_items,

        COUNTIF(oi.status = 'Returned') AS returned_items,

        COUNTIF(oi.status = 'Cancelled') AS cancelled_items,

        SAFE_DIVIDE(
            COUNTIF(oi.status = 'Returned'),
            COUNTIF(oi.status IN ('Complete', 'Returned'))
        ) * 100 AS return_rate_pct,

        SAFE_DIVIDE(
            COUNTIF(oi.status = 'Cancelled'),
            COUNTIF(oi.status IN ('Complete', 'Returned', 'Cancelled'))
        ) * 100 AS cancellation_rate_pct

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    WHERE DATE(oi.created_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)
      AND oi.status IN ('Complete', 'Returned', 'Cancelled')

    GROUP BY p.category
)

SELECT
    fm.category,

    fm.financial_completed_items,

    ROUND(fm.revenue, 2) AS revenue,

    ROUND(fm.cogs, 2) AS cogs,

    ROUND(fm.gross_profit, 2) AS gross_profit,

    ROUND(fm.gross_margin_pct, 2) AS gross_margin_pct,

    om.operational_complete_items,
    om.returned_items,
    om.cancelled_items,

    ROUND(om.return_rate_pct, 2) AS return_rate_pct,

    ROUND(om.cancellation_rate_pct, 2) AS cancellation_rate_pct

FROM financial_metrics AS fm

INNER JOIN operational_metrics AS om
    ON fm.category = om.category

ORDER BY fm.gross_profit DESC;


-- =============================================================================
-- 4. PRIMARY DECISION CRITERIA — RANGE VALIDATION
-- =============================================================================
-- Purpose:
-- Inspect the minimum and maximum values of the four primary decision
-- criteria before applying Min-Max normalization.
--
-- Higher is better:
-- - Gross Profit
-- - Gross Margin
-- - Sales Volume
--
-- Lower is better:
-- - Return Rate
-- =============================================================================

WITH financial_metrics AS (

    SELECT
        p.category,
        COUNT(*) AS sales_volume,
        SUM(oi.sale_price - ii.cost) AS gross_profit,

        SAFE_DIVIDE(
            SUM(oi.sale_price - ii.cost),
            SUM(oi.sale_price)
        ) * 100 AS gross_margin_pct

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
        ON oi.inventory_item_id = ii.id

    WHERE oi.status = 'Complete'
      AND oi.delivered_at IS NOT NULL
      AND DATE(oi.delivered_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)

    GROUP BY p.category
),

operational_metrics AS (

    SELECT
        p.category,

        SAFE_DIVIDE(
            COUNTIF(oi.status = 'Returned'),
            COUNTIF(oi.status IN ('Complete', 'Returned'))
        ) * 100 AS return_rate_pct

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    WHERE DATE(oi.created_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)
      AND oi.status IN ('Complete', 'Returned', 'Cancelled')

    GROUP BY p.category
),

category_metrics AS (

    SELECT
        fm.category,
        fm.gross_profit,
        fm.gross_margin_pct,
        fm.sales_volume,
        om.return_rate_pct

    FROM financial_metrics AS fm

    INNER JOIN operational_metrics AS om
        ON fm.category = om.category
)

SELECT
    ROUND(MIN(gross_profit), 2) AS min_gross_profit,
    ROUND(MAX(gross_profit), 2) AS max_gross_profit,

    ROUND(MIN(gross_margin_pct), 2) AS min_gross_margin,
    ROUND(MAX(gross_margin_pct), 2) AS max_gross_margin,

    MIN(sales_volume) AS min_sales_volume,
    MAX(sales_volume) AS max_sales_volume,

    ROUND(MIN(return_rate_pct), 2) AS min_return_rate,
    ROUND(MAX(return_rate_pct), 2) AS max_return_rate

FROM category_metrics;


-- =============================================================================
-- 5. PRIMARY DECISION CRITERIA — MIN-MAX NORMALIZATION
-- =============================================================================
-- Purpose:
-- Normalize the four primary category decision criteria to a common
-- 0–100 scale using Min-Max normalization.
--
-- Higher score = more favorable performance.
--
-- Higher is better:
-- - Gross Profit
-- - Gross Margin
-- - Sales Volume
--
-- Lower is better:
-- - Return Rate
-- =============================================================================

WITH financial_metrics AS (

    SELECT
        p.category,
        COUNT(*) AS sales_volume,
        SUM(oi.sale_price - ii.cost) AS gross_profit,

        SAFE_DIVIDE(
            SUM(oi.sale_price - ii.cost),
            SUM(oi.sale_price)
        ) * 100 AS gross_margin_pct

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
        ON oi.inventory_item_id = ii.id

    WHERE oi.status = 'Complete'
      AND oi.delivered_at IS NOT NULL
      AND DATE(oi.delivered_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)

    GROUP BY p.category
),

operational_metrics AS (

    SELECT
        p.category,

        SAFE_DIVIDE(
            COUNTIF(oi.status = 'Returned'),
            COUNTIF(oi.status IN ('Complete', 'Returned'))
        ) * 100 AS return_rate_pct

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    WHERE DATE(oi.created_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)
      AND oi.status IN ('Complete', 'Returned', 'Cancelled')

    GROUP BY p.category
),

category_metrics AS (

    SELECT
        fm.category,
        fm.gross_profit,
        fm.gross_margin_pct,
        fm.sales_volume,
        om.return_rate_pct

    FROM financial_metrics AS fm

    INNER JOIN operational_metrics AS om
        ON fm.category = om.category
),

normalized_metrics AS (

    SELECT
        *,

        SAFE_DIVIDE(
            gross_profit - MIN(gross_profit) OVER (),
            MAX(gross_profit) OVER () - MIN(gross_profit) OVER ()
        ) * 100 AS score_gross_profit,

        SAFE_DIVIDE(
            gross_margin_pct - MIN(gross_margin_pct) OVER (),
            MAX(gross_margin_pct) OVER () - MIN(gross_margin_pct) OVER ()
        ) * 100 AS score_gross_margin,

        SAFE_DIVIDE(
            sales_volume - MIN(sales_volume) OVER (),
            MAX(sales_volume) OVER () - MIN(sales_volume) OVER ()
        ) * 100 AS score_sales_volume,

        SAFE_DIVIDE(
            MAX(return_rate_pct) OVER () - return_rate_pct,
            MAX(return_rate_pct) OVER () - MIN(return_rate_pct) OVER ()
        ) * 100 AS score_return_rate

    FROM category_metrics
)

SELECT
    category,

    ROUND(gross_profit, 2) AS gross_profit,
    ROUND(gross_margin_pct, 2) AS gross_margin_pct,
    sales_volume,
    ROUND(return_rate_pct, 2) AS return_rate_pct,

    ROUND(score_gross_profit, 2) AS score_gross_profit,
    ROUND(score_gross_margin, 2) AS score_gross_margin,
    ROUND(score_sales_volume, 2) AS score_sales_volume,
    ROUND(score_return_rate, 2) AS score_return_rate

FROM normalized_metrics

ORDER BY score_gross_profit DESC;


-- =============================================================================
-- 6. BALANCED CATEGORY DECISION MODEL
-- =============================================================================
-- Purpose:
-- Create a baseline multi-criteria category score using equal weights.
--
-- Analytical assumption:
-- Gross Profit  = 25%
-- Gross Margin  = 25%
-- Sales Volume  = 25%
-- Return Rate   = 25%
--
-- Higher final score = stronger relative performance across the four criteria.
-- =============================================================================
WITH financial_metrics AS (

    SELECT
        p.category,
        COUNT(*) AS sales_volume,
        SUM(oi.sale_price - ii.cost) AS gross_profit,

        SAFE_DIVIDE(
            SUM(oi.sale_price - ii.cost),
            SUM(oi.sale_price)
        ) * 100 AS gross_margin_pct

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
        ON oi.inventory_item_id = ii.id

    WHERE oi.status = 'Complete'
      AND oi.delivered_at IS NOT NULL
      AND DATE(oi.delivered_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)

    GROUP BY p.category
),

operational_metrics AS (

    SELECT
        p.category,

        SAFE_DIVIDE(
            COUNTIF(oi.status = 'Returned'),
            COUNTIF(oi.status IN ('Complete', 'Returned'))
        ) * 100 AS return_rate_pct

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    WHERE DATE(oi.created_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)
      AND oi.status IN ('Complete', 'Returned', 'Cancelled')

    GROUP BY p.category
),

category_metrics AS (

    SELECT
        fm.category,
        fm.gross_profit,
        fm.gross_margin_pct,
        fm.sales_volume,
        om.return_rate_pct

    FROM financial_metrics AS fm

    INNER JOIN operational_metrics AS om
        ON fm.category = om.category
),

normalized_metrics AS (

    SELECT
        *,

        SAFE_DIVIDE(
            gross_profit - MIN(gross_profit) OVER (),
            MAX(gross_profit) OVER () - MIN(gross_profit) OVER ()
        ) * 100 AS score_gross_profit,

        SAFE_DIVIDE(
            gross_margin_pct - MIN(gross_margin_pct) OVER (),
            MAX(gross_margin_pct) OVER () - MIN(gross_margin_pct) OVER ()
        ) * 100 AS score_gross_margin,

        SAFE_DIVIDE(
            sales_volume - MIN(sales_volume) OVER (),
            MAX(sales_volume) OVER () - MIN(sales_volume) OVER ()
        ) * 100 AS score_sales_volume,

        SAFE_DIVIDE(
            MAX(return_rate_pct) OVER () - return_rate_pct,
            MAX(return_rate_pct) OVER () - MIN(return_rate_pct) OVER ()
        ) * 100 AS score_return_rate

    FROM category_metrics
),

balanced_model AS (

    SELECT
        *,

        (
            score_gross_profit * 0.25 +
            score_gross_margin * 0.25 +
            score_sales_volume * 0.25 +
            score_return_rate * 0.25
        ) AS balanced_score

    FROM normalized_metrics
)

SELECT
    category,

    ROUND(gross_profit, 2) AS gross_profit,
    ROUND(gross_margin_pct, 2) AS gross_margin_pct,
    sales_volume,
    ROUND(return_rate_pct, 2) AS return_rate_pct,

    ROUND(score_gross_profit, 2) AS score_gross_profit,
    ROUND(score_gross_margin, 2) AS score_gross_margin,
    ROUND(score_sales_volume, 2) AS score_sales_volume,
    ROUND(score_return_rate, 2) AS score_return_rate,

    ROUND(balanced_score, 2) AS balanced_score,

    RANK() OVER (
        ORDER BY balanced_score DESC
    ) AS rank_balanced

FROM balanced_model

ORDER BY rank_balanced;


-- =============================================================================
-- 7. SENSITIVITY ANALYSIS — MULTIPLE BUSINESS SCENARIOS
-- =============================================================================
-- Purpose:
-- Test whether category prioritization remains stable when
-- business priorities and KPI weights change.
--
-- The same four normalized criteria are evaluated under
-- three different weighting scenarios:
--
-- Scenario A — Balanced
-- Gross Profit: 25%
-- Gross Margin: 25%
-- Sales Volume: 25%
-- Return Rate: 25%
--
-- Scenario B — Profitability
-- Gross Profit: 30%
-- Gross Margin: 30%
-- Sales Volume: 20%
-- Return Rate: 20%
--
-- Scenario C — Growth with Controlled Risk
-- Gross Profit: 20%
-- Gross Margin: 30%
-- Sales Volume: 20%
-- Return Rate: 30%
--
-- IMPORTANT:
-- These weights are analytical assumptions used for
-- sensitivity testing. They are not observed dataset facts.
-- =============================================================================
WITH financial_metrics AS (

    SELECT
        p.category,
        COUNT(*) AS sales_volume,
        SUM(oi.sale_price - ii.cost) AS gross_profit,

        SAFE_DIVIDE(
            SUM(oi.sale_price - ii.cost),
            SUM(oi.sale_price)
        ) * 100 AS gross_margin_pct

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
        ON oi.inventory_item_id = ii.id

    WHERE oi.status = 'Complete'
      AND oi.delivered_at IS NOT NULL
      AND DATE(oi.delivered_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)

    GROUP BY p.category
),

operational_metrics AS (

    SELECT
        p.category,

        SAFE_DIVIDE(
            COUNTIF(oi.status = 'Returned'),
            COUNTIF(oi.status IN ('Complete', 'Returned'))
        ) * 100 AS return_rate_pct

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    WHERE DATE(oi.created_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)
      AND oi.status IN ('Complete', 'Returned', 'Cancelled')

    GROUP BY p.category
),

category_metrics AS (

    SELECT
        fm.category,
        fm.gross_profit,
        fm.gross_margin_pct,
        fm.sales_volume,
        om.return_rate_pct

    FROM financial_metrics AS fm

    INNER JOIN operational_metrics AS om
        ON fm.category = om.category
),

normalized_metrics AS (

    SELECT
        *,

        SAFE_DIVIDE(
            gross_profit - MIN(gross_profit) OVER (),
            MAX(gross_profit) OVER () - MIN(gross_profit) OVER ()
        ) * 100 AS score_gross_profit,

        SAFE_DIVIDE(
            gross_margin_pct - MIN(gross_margin_pct) OVER (),
            MAX(gross_margin_pct) OVER () - MIN(gross_margin_pct) OVER ()
        ) * 100 AS score_gross_margin,

        SAFE_DIVIDE(
            sales_volume - MIN(sales_volume) OVER (),
            MAX(sales_volume) OVER () - MIN(sales_volume) OVER ()
        ) * 100 AS score_sales_volume,

        SAFE_DIVIDE(
            MAX(return_rate_pct) OVER () - return_rate_pct,
            MAX(return_rate_pct) OVER () - MIN(return_rate_pct) OVER ()
        ) * 100 AS score_return_rate

    FROM category_metrics
),

scenario_scores AS (

    SELECT
        category,
        gross_profit,
        gross_margin_pct,
        sales_volume,
        return_rate_pct,

        score_gross_profit,
        score_gross_margin,
        score_sales_volume,
        score_return_rate,

        -- Scenario A: Balanced
        ROUND(
            score_gross_profit * 0.25 +
            score_gross_margin * 0.25 +
            score_sales_volume * 0.25 +
            score_return_rate * 0.25,
            2
        ) AS score_balanced,

        -- Scenario B: Profitability
        ROUND(
            score_gross_profit * 0.30 +
            score_gross_margin * 0.30 +
            score_sales_volume * 0.20 +
            score_return_rate * 0.20,
            2
        ) AS score_profitability,

        -- Scenario C: Growth with Controlled Risk
        ROUND(
            score_gross_profit * 0.20 +
            score_gross_margin * 0.30 +
            score_sales_volume * 0.20 +
            score_return_rate * 0.30,
            2
        ) AS score_growth_controlled_risk

    FROM normalized_metrics
)

SELECT *
FROM scenario_scores
ORDER BY score_balanced DESC;


-- =============================================================================
-- 8. SCENARIO RANKING AND ROBUSTNESS ANALYSIS
-- =============================================================================
-- Purpose:
-- Evaluate whether category performance remains stable when
-- the decision-model weights change across the three scenarios.
--
-- Robustness will be evaluated using:
--   1. Rank under each scenario
--   2. Average rank across scenarios
--   3. Rank variation between scenarios
--
-- Lower average rank = stronger overall position.
-- Lower rank variation = greater stability across assumptions.
-- =============================================================================
WITH financial_metrics AS (

    SELECT
        p.category,
        COUNT(*) AS sales_volume,
        SUM(oi.sale_price - ii.cost) AS gross_profit,

        SAFE_DIVIDE(
            SUM(oi.sale_price - ii.cost),
            SUM(oi.sale_price)
        ) * 100 AS gross_margin_pct

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
        ON oi.inventory_item_id = ii.id

    WHERE oi.status = 'Complete'
      AND oi.delivered_at IS NOT NULL
      AND DATE(oi.delivered_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)

    GROUP BY p.category
),

operational_metrics AS (

    SELECT
        p.category,

        SAFE_DIVIDE(
            COUNTIF(oi.status = 'Returned'),
            COUNTIF(oi.status IN ('Complete', 'Returned'))
        ) * 100 AS return_rate_pct

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    WHERE DATE(oi.created_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)
      AND oi.status IN ('Complete', 'Returned', 'Cancelled')

    GROUP BY p.category
),

category_metrics AS (

    SELECT
        fm.category,
        fm.gross_profit,
        fm.gross_margin_pct,
        fm.sales_volume,
        om.return_rate_pct

    FROM financial_metrics AS fm

    INNER JOIN operational_metrics AS om
        ON fm.category = om.category
),

normalized_metrics AS (

    SELECT
        *,

        SAFE_DIVIDE(
            gross_profit - MIN(gross_profit) OVER (),
            MAX(gross_profit) OVER () - MIN(gross_profit) OVER ()
        ) * 100 AS score_gross_profit,

        SAFE_DIVIDE(
            gross_margin_pct - MIN(gross_margin_pct) OVER (),
            MAX(gross_margin_pct) OVER () - MIN(gross_margin_pct) OVER ()
        ) * 100 AS score_gross_margin,

        SAFE_DIVIDE(
            sales_volume - MIN(sales_volume) OVER (),
            MAX(sales_volume) OVER () - MIN(sales_volume) OVER ()
        ) * 100 AS score_sales_volume,

        SAFE_DIVIDE(
            MAX(return_rate_pct) OVER () - return_rate_pct,
            MAX(return_rate_pct) OVER () - MIN(return_rate_pct) OVER ()
        ) * 100 AS score_return_rate

    FROM category_metrics
),

scenario_scores AS (

    SELECT
        category,
        gross_profit,
        gross_margin_pct,
        sales_volume,
        return_rate_pct,

        score_gross_profit,
        score_gross_margin,
        score_sales_volume,
        score_return_rate,

        -- Scenario A: Balanced
        ROUND(
            score_gross_profit * 0.25 +
            score_gross_margin * 0.25 +
            score_sales_volume * 0.25 +
            score_return_rate * 0.25,
            2
        ) AS score_balanced,

        -- Scenario B: Profitability
        ROUND(
            score_gross_profit * 0.30 +
            score_gross_margin * 0.30 +
            score_sales_volume * 0.20 +
            score_return_rate * 0.20,
            2
        ) AS score_profitability,

        -- Scenario C: Growth with Controlled Risk
        ROUND(
            score_gross_profit * 0.20 +
            score_gross_margin * 0.30 +
            score_sales_volume * 0.20 +
            score_return_rate * 0.30,
            2
        ) AS score_growth_controlled_risk

    FROM normalized_metrics
),

scenario_rankings AS (

    SELECT
        *,
        
        RANK() OVER (
            ORDER BY score_balanced DESC
        ) AS rank_balanced,

        RANK() OVER (
            ORDER BY score_profitability DESC
        ) AS rank_profitability,

        RANK() OVER (
            ORDER BY score_growth_controlled_risk DESC
        ) AS rank_growth_controlled_risk

    FROM scenario_scores
),

robustness_analysis AS (

    SELECT
        *,

        ROUND(
            (rank_balanced +
             rank_profitability +
             rank_growth_controlled_risk) / 3.0,
            2
        ) AS average_rank,

        GREATEST(
            rank_balanced,
            rank_profitability,
            rank_growth_controlled_risk
        )
        -
        LEAST(
            rank_balanced,
            rank_profitability,
            rank_growth_controlled_risk
        ) AS rank_variation

    FROM scenario_rankings
),

final_classification AS (

    SELECT
        *,

        CASE
            WHEN average_rank <= 10
                 AND rank_variation <= 3
            THEN 'Robust Candidate'
            ELSE 'Sensitive / Lower Priority'
        END AS robustness_classification

    FROM robustness_analysis
)

SELECT *
FROM final_classification
ORDER BY average_rank;