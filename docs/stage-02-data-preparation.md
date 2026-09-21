# Stage 02 — Data Preparation & SQL-Based Validation

**Stage 2 Status: COMPLETE (closed 2026-09-21)**

**Naming note (pending confirmation):** this file follows the `docs/stage-XX-short-name.md` convention already established in `README.md` and in Stage 1's Stage 2 Handoff (which named Stage 2 "Data Preparation"). The checkpoint documented below covers schema/referential-integrity validation, business-rule adoption, and financial/descriptive SQL exploration together. Whether the original 11-stage project plan treats descriptive/financial exploration as part of Stage 2 or as a separate later stage has not been re-confirmed in this session — see the note at the end of this document.

## Stage Objective

Before any Power BI, DAX, Python analysis, or n8n automation work begins, this stage validates the technical reliability of the selected Stage 1 dataset (TheLook eCommerce) at the schema level, adopts explicit financial recognition business rules, and performs an initial round of descriptive SQL-based exploration (temporal, category, product, brand) to understand what the data actually shows — strictly as a checkpoint, not a completed or final analysis.

## Technical Context

- **Dataset:** `bigquery-public-data.thelook_ecommerce`, queried via the Google BigQuery Sandbox.
- **Dataset nature:** synthetic and dynamic (carried forward from Stage 1). Row counts and query results can change between executions; every figure below reflects a single snapshot, not a permanent or reproducible-on-demand result, and must never be presented as describing a real company's history.
- **Tables analyzed in this checkpoint:** `orders`, `order_items`, `products`, `inventory_items`, `users`. `events` and `distribution_centers` exist in the dataset (per Stage 1) but were not analyzed in this checkpoint.
- **Snapshot date:** 2026-09-15 for the first checkpoint (schema/status/financial-baseline/category-product-brand exploration). A second checkpoint (Category Decision Model, normalization, sensitivity/robustness analysis) was completed subsequently; its exact execution date was not specified and is not assumed. A third checkpoint, dated 2026-09-21, consolidated that model into production SQL (`sql/01`–`sql/04`) and recorded a new validated snapshot. Individual query results below are noted as approximate/rounded where Kevin reported them that way.

## Cross-Reference to Stage 1 Open Validations

Stage 1 (`stage-01-business-case.md`, Step 1.5) recorded a list of "Important Open Validations" to resolve before Stage 2. This checkpoint directly resolves several of them:

| Stage 1 open item | Status after this checkpoint |
|---|---|
| Referential integrity (orphaned foreign keys, nulls in join keys) | **Resolved** — see Referential Integrity Validation below; all orphan checks returned 0. |
| Order status values and their meanings | **Resolved** — see Status Field Validation below. |
| Return/cancellation semantics | **Partially resolved** — status-level date logic and revenue/COGS treatment are now defined (see Adopted Financial Recognition Rules); the underlying *business* reasons for returns/cancellations remain unexplored. |
| Quantity representation (whether each `order_items` row is one unit) | **Resolved** — `orders.num_of_item` reconciles against the actual count of `order_items` per order with no inconsistencies once aggregated correctly. |
| Difference between `products.cost` and `inventory_items.cost`, and which to use | **Resolved** — `inventory_items.cost` was selected as the COGS source, with validation (see Cost / COGS Source Decision below). |

Still open after this checkpoint (not addressed here): exact full column lists for `orders`/`products`/`users` beyond the fields used; general null/missing-value patterns outside the specific fields checked; duplicate-row behavior; category hierarchy structure; customer demographic/geographic attributes; timestamp/timezone handling (the chronological anomaly below touches timestamps but timezone handling itself was not separately confirmed); relationship cardinalities beyond what was directly tested.

## Referential Integrity Validation

**[OBSERVED FACT]** The following relationships were validated:

- `orders.order_id` → `order_items.order_id`
- `order_items.product_id` → `products.id`
- `order_items.inventory_item_id` → `inventory_items.id`
- `order_items.user_id` → `users.id`
- `order_items.user_id` = `orders.user_id` (consistency check for items belonging to each order)

Orphan/inconsistency checks all returned **0**:
- `order_items` without a matching order
- `order_items` without a matching product
- `order_items` without a matching inventory item
- `order_items` without a matching user
- user-ID inconsistencies between `order_items` and `orders`

`orders.num_of_item` was also checked against the actual count of `order_items` per order, with no inconsistencies once the aggregation was performed correctly.

**[BUSINESS RULE / DECISION]** Because these relationships were validated with zero orphaned/inconsistent records, `INNER JOIN` is considered safe to use in subsequent analysis where these specific relationships are involved, without needing `LEFT JOIN`/null-handling for referential-integrity reasons on this snapshot.

## Status Field Validation

**[OBSERVED FACT]** `order_items.status` contains exactly five values: `Shipped`, `Complete`, `Processing`, `Cancelled`, `Returned`. No `NULL` values and no evident spelling/casing variants were found.

The presence of date fields was observed to be consistent with each status:
- **Processing:** no later shipping/delivery/return dates.
- **Cancelled:** no shipping or delivery dates.
- **Shipped:** `shipped_at` present.
- **Complete:** `shipped_at` + `delivered_at` present.
- **Returned:** `shipped_at` + `delivered_at` + `returned_at` present.

## Chronological Anomaly

**[OBSERVED FACT]** A systematic anomaly was found: `shipped_at < created_at` in approximately 30% of shipped items.

Snapshot results (approximate):
- 35,616 records with `shipped_at < created_at`.
- By status: Complete ≈ 13,572 affected (~30.15%); Returned ≈ 5,436 affected (~30.32%); Shipped ≈ 16,608 affected (~30.24%).
- Negative differences reach approximately -95/-96 hours.

No instances of `delivered_at < shipped_at` or `returned_at < delivered_at` were found.

**[ANALYTICAL ASSUMPTION]** The anomaly appears to originate from TheLook's synthetic date-generation process. This is an interpretation, not an independently confirmed root cause — no source-level documentation of the dataset's generator was consulted to verify it.

**[BUSINESS RULE / DECISION]** These records are **not** to be modified or deleted. They may be retained for financial analysis where this specific temporal sequence does not affect the calculation. They must **not** be used directly for created→shipped duration KPIs without specific treatment.

## Sale Price Validation

**[OBSERVED FACT]** `order_items.sale_price` was validated: no `NULL` values and no values ≤ 0 were found.

Approximate range: min ≈ 0.02, max = 999, avg ≈ 59.43.

Approximate percentiles: P25 = 24.45, Median = 39.90, P75 = 69.95, P90 = 128, P95 = 172, P99 = 300, Max = 999.

The observed value `0.019999...` was interpreted as a FLOAT64 precision artifact of 0.02, not a distinct value.

The extremely low-priced product was investigated: **"Indestructable Aluminum Aluma Wallet - RED"**, `product_id = 14235`, catalog cost ≈ 0.01, retail price ≈ 0.02, sold multiple times at that price.

**[ANALYTICAL ASSUMPTION / DECISION]** This is treated as an unusual but internally consistent outlier (price and cost are proportionate to each other) and was **not** removed from the data.

## Cost / COGS Source Decision

**[BUSINESS RULE / DECISION]** `inventory_items.cost` was selected as the source of COGS (Cost of Goods Sold), joined via `order_items.inventory_item_id = inventory_items.id`.

**[OBSERVED FACT]** Supporting validations: no `NULL` cost values; no cost ≤ 0; zero cases where `sale_price < cost`; zero cases of product-ID mismatch between `order_items.product_id` and `inventory_items.product_id`.

`inventory_items.cost` is therefore the currently selected source for calculating the cost of goods sold in this project. (`products.cost` also exists per Stage 1 but was not selected as the COGS source for these calculations.)

## Adopted Financial Recognition Rules

**[BUSINESS RULE / DECISION]** A conservative revenue/COGS recognition model was adopted, by status:

| Status | Revenue | COGS |
|---|---|---|
| Complete | Recognized | Recognized |
| Processing | Pending | Pending |
| Shipped | Pending / in transit | Pending / in transit |
| Cancelled | 0 | 0 |
| Returned | 0 (final) — sale considered fully reversed | Reversed (assumes the product returns to inventory) |

**[ANALYTICAL ASSUMPTION]** For Returned items, the baseline financial model also reverses the COGS of the returned product, **assuming** the product physically returns to inventory. This is an explicit modeling assumption, not a fact confirmed in the data.

**[DATASET LIMITATION]** This does **not** mean a return is free. In a real business there would potentially be shipping cost, return shipping, handling, inspection, restocking, damaged goods, and loss of value — but sufficient information to quantify these costs has not currently been found in TheLook. Specifically, TheLook does not provide sufficient information about: outbound logistics cost, return shipping, inspection costs, restocking costs, damaged returned products, refund fees, or loss of product value. Therefore, none of these costs are deducted from Gross Profit, and Gross Profit must **not** be described as fully accounting for the economic cost of returns — this is part of why Return Rate is retained as a separate risk KPI rather than folded into the financial metric. A delivery cost or return cost must **not** be invented and presented as real data. A future sensitivity-analysis scenario using synthetic/hypothetical costs, clearly labeled as an **ASSUMPTION**, is a possible future extension — not built now.

## Financial Baseline (Snapshot)

**[OBSERVED FACT — snapshot result]**

- Recognized Revenue: ≈ 2,654,969.61
- Recognized COGS: ≈ 1,275,752.24
- Gross Profit: ≈ 1,379,217.38
- Gross Margin: ≈ 51.95%
- Pending order value: ≈ 5,453,369.65
- Value associated with returns: ≈ 1,058,225.90
- Cancelled value: ≈ 1,626,111.44

Small cent-level differences can occur due to FLOAT64 precision and rounding.

## Temporal Analysis

**[BUSINESS RULE / DECISION]** For Complete sales, `delivered_at` was selected as the financial recognition date.

**[OBSERVED FACT]** Deliveries dated after the current analysis date were detected, attributable to the dataset's synthetic/dynamic nature. September 2026 is an incomplete month as of the snapshot.

**[BUSINESS RULE / DECISION]** The current month is therefore fully excluded from historical analysis, using:

```sql
DATE(oi.delivered_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)
```

This allows complete months to be compared against complete months.

**[OBSERVED FACT]** Monthly Revenue, COGS, Gross Profit, Gross Margin, MoM Growth, and YoY Growth were calculated. Observed examples (approximate):

| Month | Revenue | MoM | YoY |
|---|---|---|---|
| Aug 2026 | ≈ 127,177.22 | +9.56% | +135.84% |
| Jul 2026 | ≈ 116,083.94 | +18.46% | +100.16% |
| Jun 2026 | ≈ 97,995.54 | +14.18% | +112.86% |

Margin remained relatively stable around ~52% across these months.

**[ANALYTICAL ASSUMPTION — provisional interpretation]** The observed growth appears to be driven primarily by volume rather than large margin changes. This is a provisional interpretation of a synthetic dataset's snapshot, not a business conclusion about a real company.

## Category Analysis

**[OBSERVED FACT]** Categories were analyzed using Complete sales prior to the current month, using: orders, items, revenue, revenue share, COGS, gross profit, gross margin, average price/item, and gross profit/item.

Findings:
- **Outerwear & Coats:** high Revenue and good margin.
- **Jeans:** high Revenue but significantly lower margin.
- **Suits & Sport Coats:** lower volume but elevated margin.
- **Blazers & Jackets:** elevated margin.
- **Active:** good margin.
- **Tops & Tees:** high volume but lower margin.

**[ANALYTICAL ASSUMPTION — provisional interpretation]** Volume ≠ profitability.

## Product Analysis

**[OBSERVED FACT]** Products were analyzed using Complete sales prior to the current month.

**[ANALYTICAL ASSUMPTION]** A threshold of `completed_units >= 5` was used provisionally to reduce rankings dominated by single-sale products. This filter does **not** mean products with fewer than 5 units are invalid — it is solely an analytical threshold, not a validity judgment.

**[OBSERVED FACT]** Several products leading by Gross Profit had only 5–6 sales at elevated unit prices.

**[ANALYTICAL ASSUMPTION — provisional interpretation]** There is not yet sufficient evidence to declare a single, consistent "winning product."

## Brand Analysis

**[OBSERVED FACT]** Brands were analyzed using Complete sales prior to the current month, using a volume threshold to focus on brands with a more significant base.

Findings:
- **Calvin Klein:** led Gross Profit, primarily through scale.
- **Diesel:** high Revenue and high average price.
- **Carhartt:** good balance of volume and margin.
- **Ray-Ban:** high margin.
- **7 For All Mankind / True Religion:** high prices but a higher proportion of COGS.

**[ANALYTICAL ASSUMPTION — provisional interpretation]** Premium price ≠ automatically better margin.

## Return Rate & Cancellation Rate Definitions

**[BUSINESS RULE / DECISION — KPI definitions]**

```
Return Rate = Returned / (Complete + Returned) × 100
Cancellation Rate = Cancelled / (Complete + Returned + Cancelled) × 100
```

`Processing` and `Shipped` are excluded from the denominator because they do not yet have a final outcome.

**[BUSINESS RULE / DECISION]** For this status-based analysis, `created_at` (rather than `delivered_at`) prior to the start of the current month was used as the cohort filter, because `Cancelled` items have no `delivered_at`. See the Cohort Difference section below for why this differs from the financial-metric cohort.

## Most Recent Combined Query

**[SUPERSEDED — see note below]** The query in this section was the working combined view at the time of the first checkpoint. It has since been superseded by the consolidated, production-structured version in `sql/03_monthly_performance_analysis.sql` and `sql/04_category_performance_analysis.sql` (Section 3, "Combined Financial + Operational Category View") — see the new **SQL File Consolidation** section below. It is kept here, unmodified, as a historical record of this checkpoint's original working query; it is functionally equivalent to (same logic, same cohort rules) but not textually identical to the later consolidated version (different CTE naming: Spanish vs. English; return/cancellation rates computed inline here vs. inside a dedicated CTE there).

The following query combines Revenue, COGS, Gross Profit, Gross Margin, Complete/Returned/Cancelled item counts, Return Rate, and Cancellation Rate by category. Reproduced verbatim as provided:

```sql
WITH metricas_financieras AS (
    SELECT
        p.category AS categoria,
        COUNT(*) AS items_completados,
        SUM(oi.sale_price) AS revenue,
        SUM(ii.cost) AS cogs

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    INNER JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` AS ii
        ON oi.inventory_item_id = ii.id

    WHERE oi.status = 'Complete'
      AND DATE(oi.delivered_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)

    GROUP BY p.category
),

estados_categoria AS (
    SELECT
        p.category AS categoria,
        COUNTIF(oi.status = 'Complete') AS items_completados,
        COUNTIF(oi.status = 'Returned') AS items_devueltos,
        COUNTIF(oi.status = 'Cancelled') AS items_cancelados

    FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi

    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
        ON oi.product_id = p.id

    WHERE DATE(oi.created_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)

    GROUP BY p.category
)

SELECT
    mf.categoria,
    mf.items_completados,
    ROUND(mf.revenue, 2) AS revenue,
    ROUND(mf.cogs, 2) AS cogs,

    ROUND(
        mf.revenue - mf.cogs,
        2
    ) AS gross_profit,

    ROUND(
        SAFE_DIVIDE(
            mf.revenue - mf.cogs,
            mf.revenue
        ) * 100,
        2
    ) AS gross_margin_porcentaje,

    ec.items_devueltos,
    ec.items_cancelados,

    ROUND(
        SAFE_DIVIDE(
            ec.items_devueltos,
            ec.items_completados + ec.items_devueltos
        ) * 100,
        2
    ) AS tasa_devolucion_porcentaje,

    ROUND(
        SAFE_DIVIDE(
            ec.items_cancelados,
            ec.items_completados
            + ec.items_devueltos
            + ec.items_cancelados
        ) * 100,
        2
    ) AS tasa_cancelacion_porcentaje

FROM metricas_financieras AS mf

INNER JOIN estados_categoria AS ec
    ON mf.categoria = ec.categoria

ORDER BY gross_profit DESC;
```

*(This query was originally embedded here because the project did not yet have a dedicated SQL folder. That folder now exists — see the SQL File Consolidation section below — and holds the consolidated, current version of this analysis. This embedded copy is left in place, unmodified, as the historical record of the query as it stood at the first checkpoint.)*

## IMPORTANT — Cohort Difference / Methodological Limitation

**[DATASET LIMITATION / METHODOLOGICAL DECISION — must not be hidden]** The combined query above mixes two different temporal perspectives:

- `metricas_financieras`: `Complete` status **and** `delivered_at` before the current month.
- `estados_categoria`: `created_at` before the current month, evaluated by final status.

As a result, `mf.items_completados` and `ec.items_completados` do **not** necessarily represent exactly the same cohort of items.

This is documented explicitly as a methodological decision/limitation, not concealed. The reason: Revenue is recognized on delivery; `Cancelled` items have no `delivered_at`; operational status metrics need a common date available before the final outcome is known. A stricter, closed-cohort design may be worth designing later for analyses that require the two perspectives to match exactly — not built now.

## Combined Results by Category (Snapshot)

**[OBSERVED FACT — snapshot result]**

| Category | Revenue | Gross Profit | Gross Margin | Return Rate | Cancellation Rate |
|---|---|---|---|---|---|
| Outerwear & Coats | ≈ 300,293.36 | ≈ 167,087.12 | ≈ 55.64% | ≈ 29.15% | ≈ 29.61% |
| Jeans | ≈ 284,668.03 | ≈ 132,359.84 | ≈ 46.50% | ≈ 28.19% | ≈ 29.98% |
| Sweaters | ≈ 195,000.20 | ≈ 101,451.38 | ≈ 52.03% | ≈ 28.93% | ≈ 31.22% |
| Suits & Sport Coats | ≈ 143,572.90 | ≈ 86,069.41 | ≈ 59.95% | ≈ 29.77% | ≈ 29.87% |
| Active | ≈ 104,067.36 | ≈ 60,411.55 | ≈ 58.05% | ≈ 26.64% | ≈ 29.67% |
| Accessories | ≈ 101,615.76 | ≈ 60,879.58 | ≈ 59.91% | ≈ 28.30% | ≈ 29.79% |
| Blazers & Jackets | ≈ 67,860.90 | ≈ 42,061.63 | ≈ 61.98% | ≈ 27.97% | ≈ 28.88% |

**Clothing Sets** (small sample — reported separately): Complete ≈ 41, Returned ≈ 21, Cancelled ≈ 35, Return Rate ≈ 33.87%, Cancellation Rate ≈ 36.08%.

**[ANALYTICAL ASSUMPTION]** Clothing Sets shows very high rates, but the sample is small. This must **not** be concluded to be a definitively problematic category without considering sample size.

## Provisional Interpretation

**[ANALYTICAL ASSUMPTION — explicitly not a final decision]** No category is selected as a winner yet. Different categories currently show different profiles:

- **Outerwear & Coats:** maximum scale and high Gross Profit, good margin, but returns near 29%.
- **Active:** smaller scale, high margin (~58%), and a relatively lower Return Rate (~26.6%).
- **Accessories:** high margin (~59.9%) with intermediate scale.
- **Suits & Sport Coats:** very high margin (~60%), but Return Rate near 30%.
- **Blazers & Jackets:** extremely high margin (~62%), smaller scale, Return Rate ~28%.

**Provisional shortlist for future investigation** (explicitly not a final decision): Outerwear & Coats, Active, Accessories, Suits & Sport Coats, Blazers & Jackets.

A future decision should jointly consider Revenue + Gross Profit + Gross Margin + Return Rate + Cancellation Rate + Volume/Sample Size. A category must not be selected using a single KPI — consistent with the "multi-signal decision making" principle already established in Stage 1 (Step 1.3, Product Opportunity Analysis).

**Update note (second checkpoint):** the single-KPI-at-a-time, qualitative approach above was the starting point. It was subsequently formalized into an explicit multi-dimensional scoring model with weighted scenarios and a robustness rule — see the **Category Decision Model** section onward below. That formalization extends this section; it does not overturn or delete it, and the shortlist above is preserved as the first, qualitative pass.

## Category Decision Model (Multi-Dimensional Scoring)

*(Second checkpoint — subsequent to the 2026-09-15 snapshot above. Documents additional analytical work completed manually in BigQuery since that checkpoint; exact execution date of this second round of queries was not specified and is not assumed.)*

**[BUSINESS RULE / DECISION]** A decision-support model was developed to compare product categories on four primary business dimensions, each with an explicit directional rule:

| Dimension | Direction |
|---|---|
| Gross Profit | Higher = better |
| Gross Margin | Higher = better |
| Sales Volume | Higher = better |
| Return Rate | Lower = better |

**[BUSINESS RULE / DECISION]** Cancellation Rate remains analytically useful (it is still tracked and reported — see Combined Results by Category above) but is **not** included in the primary opportunity score. This is an explicit analytical/project decision, not a property of the dataset — Cancellation Rate was not found to be unusable or unreliable; it was deliberately scoped out of this particular scoring model.

## Normalization (Min-Max Scaling)

**[BUSINESS RULE / DECISION]** Because Gross Profit, Gross Margin, Volume, and Return Rate are measured on different scales, Min-Max normalization was introduced to bring all four onto a common 0–100 scale before combining them into a score.

For metrics where higher is better (Gross Profit, Gross Margin, Volume):

```
normalized = (value - minimum) / (maximum - minimum) * 100
```

For Return Rate, where lower is better:

```
normalized = (maximum - value) / (maximum - minimum) * 100
```

In both directions: 100 = better relative performance within the current category sample; 0 = worse relative performance within the current category sample.

**[ANALYTICAL ASSUMPTION]** Min-Max scores are relative to the current dataset snapshot and will shift if the underlying (synthetic, dynamic) TheLook data changes on a later execution. Min-Max normalization is also known to be sensitive to extreme values (a single outlier category can compress the scale for all others). These scores must **not** be described or presented as absolute measures of business quality — only as relative standing within this specific sample.

## Base Opportunity Model (Balanced Baseline)

**[ANALYTICAL ASSUMPTION]** A first scenario was built giving equal weight to all four normalized dimensions:

| Dimension | Weight |
|---|---|
| Gross Profit | 25% |
| Gross Margin | 25% |
| Volume | 25% |
| Return Rate | 25% |

This 25/25/25/25 split was explicitly treated as an analytical baseline, not as an objectively correct weighting system. Initial results under this baseline showed that category ranking could shift depending on the weighting assumptions used — which is what motivated the sensitivity analysis below rather than accepting a single weighting as final.

## Sensitivity Analysis — Weighting Scenarios

**[ANALYTICAL ASSUMPTION]** Three weighting scenarios were defined to test how sensitive category rankings are to the choice of weights. All three are explicit analytical assumptions used for sensitivity testing — **not** observed facts about the dataset and **not** a claim that any one scenario is the "correct" one.

| Scenario | Gross Profit | Gross Margin | Volume | Return Rate | Purpose |
|---|---|---|---|---|---|
| 1 — Balanced | 25% | 25% | 25% | 25% | Give equal importance to the four dimensions. |
| 2 — Profitability | 30% | 30% | 20% | 20% | Give greater importance to direct financial performance. |
| 3 — Growth + Controlled Risk | 20% | 30% | 20% | 30% | Give greater importance to margin quality and return risk while still considering scale and profit. |

## Category Ranking Across Scenarios

**[BUSINESS RULE / DECISION — methodology]** Each category received a composite score under each scenario (`score_balanced`, `score_profitability`, `score_growth_controlled_risk`), computed from the Min-Max-normalized dimensions weighted per the table above. `RANK()` was then applied within each scenario to produce `rank_balanced`, `rank_profitability`, and `rank_growth_controlled_risk`.

The stated objective of this step was **not** simply to identify which single category ranks first under one scenario, but to determine which categories remain attractive across scenarios — i.e., when the underlying weighting assumptions change.

## Robustness Analysis

**[BUSINESS RULE / DECISION — methodology]** Two additional metrics were derived from the three per-scenario ranks:

```
average_rank = (rank_balanced + rank_profitability + rank_growth_controlled_risk) / 3

rank_variation = GREATEST(rank_balanced, rank_profitability, rank_growth_controlled_risk)
                 - LEAST(rank_balanced, rank_profitability, rank_growth_controlled_risk)
```

Interpretation:
- Low `average_rank` = consistently strong position across scenarios.
- Low `rank_variation` = low sensitivity to changes in scenario weights.

**[ANALYTICAL ASSUMPTION]** A category can be financially attractive under one scenario but still be considered less reliable for a marketing decision if its ranking changes significantly as assumptions change. `average_rank` and `rank_variation` are the two signals used to distinguish these cases — this is an analytical framing choice, not a statistical property inherent to the dataset.

## Robust Candidate Rule

**[BUSINESS RULE / DECISION]** The following threshold rule was adopted to classify categories:

```
IF average_rank <= 10 AND rank_variation <= 3
THEN "Robust Candidate"
ELSE "Sensitive / Lower Priority"
```

**[ANALYTICAL ASSUMPTION]** This threshold (`average_rank <= 10`, `rank_variation <= 3`) is a project decision rule, not a statistical law and not an inherent property of TheLook. Its purpose is to reduce the risk of selecting a marketing category whose apparent attractiveness depends heavily on one particular weighting configuration, by requiring both a consistently strong position *and* low sensitivity to the weighting scenario.

## Current Robust Shortlist (Snapshot)

**[OBSERVED FACT — snapshot result, second checkpoint]** At this validated snapshot, eight categories satisfied the Robust Candidate rule:

| Rank | Category | Average Rank | Rank Variation |
|---|---|---|---|
| 1 | Outerwear & Coats | 1.00 | 0 |
| 2 | Accessories | 2.00 | 0 |
| 3 | Active | 3.00 | 0 |
| 4 | Sweaters | 4.00 | 0 |
| 5 | Swim | 5.33 | 1 |
| 6 | Suits & Sport Coats | 6.33 | 3 |
| 7 | Intimates | 7.00 | 2 |
| 8 | Fashion Hoodies & Sweatshirts | 10.00 | 2 |

**[OBSERVED FACT]** Outerwear & Coats, Accessories, Active, and Sweaters all had `rank_variation = 0` in this snapshot — meaning they held the same ranking position across all three tested weighting scenarios.

**[ANALYTICAL ASSUMPTION]** This should be described as evidence of robustness **within this specific sensitivity test**, not as proof that these categories will always perform best under every possible future weighting or dataset execution.

## Current Snapshot Values — Robust Shortlist Detail

**[OBSERVED FACT — snapshot result, second checkpoint]** Underlying metric values for the eight categories above, at the most recent validated execution of this second-checkpoint analysis:

| Category | Gross Profit | Gross Margin | Volume | Return Rate | Average Rank | Rank Variation |
|---|---|---|---|---|---|---|
| Outerwear & Coats | 175,988.20 | 55.47% | 2,163 | 27.86% | 1.00 | 0 |
| Accessories | 60,014.60 | 59.95% | 2,345 | 27.62% | 2.00 | 0 |
| Active | 66,493.39 | 58.00% | 2,210 | 27.36% | 3.00 | 0 |
| Sweaters | 101,629.12 | 52.14% | 2,530 | 27.69% | 4.00 | 0 |
| Swim | 75,676.08 | 49.52% | 2,656 | 26.85% | 5.33 | 1 |
| Suits & Sport Coats | 90,270.85 | 59.84% | 1,199 | 28.17% | 6.33 | 3 |
| Intimates | 51,653.16 | 46.95% | 3,244 | 27.47% | 7.00 | 2 |
| Fashion Hoodies & Sweatshirts | 70,028.37 | 48.10% | 2,688 | 28.00% | 10.00 | 2 |

**[DATASET LIMITATION]** These values do not exactly match the Combined Results by Category snapshot earlier in this document (e.g. Outerwear & Coats Gross Profit ≈167,087.12 there vs. 175,988.20 here; Return Rate ≈29.15% there vs. 27.86% here). This is expected and consistent with TheLook being synthetic and dynamic: the two tables reflect two different query executions at two different points in time, not a correction of one by the other. Per explicit instruction, the values above are recorded as reported for this second checkpoint and are **not** silently reconciled with, or used to overwrite, the earlier snapshot — both are preserved as distinct, dated observations. The exact date/time of this second execution was not specified and is not assumed beyond "subsequent to 2026-09-15."

## Current Interpretation (Updated)

**[ANALYTICAL ASSUMPTION]** The analysis has evolved in stages:

1. Simple financial ranking (single KPIs, category/product/brand analysis above).
2. Multi-dimensional decision support (Category Decision Model, four weighted dimensions).
3. Scenario sensitivity analysis (three weighting scenarios).
4. Robustness-based candidate selection (average rank + rank variation + threshold rule).

The project does **not** claim to have proven a single, objectively best category. Instead, this progression has identified categories that remain comparatively attractive under multiple reasonable weighting scenarios — intended to provide a more defensible basis for a future marketing decision than a single-scenario or single-KPI ranking would. No category, product, or brand has been formally selected as a final recommendation as of this checkpoint.

## SQL File Consolidation (Third Checkpoint)

**[OBSERVED FACT]** The Category Decision Model described above (Category Decision Model, Normalization, Base Opportunity Model, Sensitivity Analysis, Category Ranking, Robustness Analysis, Robust Candidate Rule) has since been manually consolidated and tested in BigQuery as production-structured SQL, organized into four files:

| File | Purpose |
|---|---|
| `sql/01_data_quality_validation.sql` | Referential integrity, order-item-count consistency, status/date consistency, chronological validation. |
| `sql/02_financial_validation.sql` | Sale price and inventory cost validation, product/inventory consistency, financial recognition rules, financial baseline. |
| `sql/03_monthly_performance_analysis.sql` | Historical period validation, monthly financial aggregation, MoM/YoY growth, monthly profitability trend. |
| `sql/04_category_performance_analysis.sql` | Category financial and operational performance, combined view, primary decision criteria, Min-Max normalization, balanced model, sensitivity analysis, scenario ranking, robustness analysis, and the Robust Candidate classification. |

**[OBSERVED FACT — naming note, now resolved]** These files previously lived in a folder named `SQL/` (uppercase), while README's "Planned Architecture" registered the future folder as `sql/` (lowercase). This session could not perform that rename itself (no shell/rename tool available for this device, and Windows/NTFS treats `SQL` and `sql` as the identical folder, so a file-write-based attempt would not have changed anything — confirmed by testing that listing `sql/` returned the same files as listing `SQL/`). Two possible real-rename methods were documented for Kevin at that point (a two-step Explorer rename via a temporary name, or `git mv SQL SQL_temp && git mv SQL_temp sql`).

**Kevin subsequently performed the rename manually** (Explorer: `SQL/` → `SQL_temp/` → `sql/`), confirmed at the start of this checkpoint via a fresh device directory listing: the repository now shows a lowercase `sql/` folder containing the same four files, with identical sizes and modification times to before the rename (i.e., only the folder name changed — file contents were not touched by the rename). All folder-path references throughout this document have been updated from `SQL/...` to `sql/...` accordingly.

**[OBSERVED FACT — audit finding, now fixed]** `sql/04_category_performance_analysis.sql`'s header comment previously listed nine numbered "ANALYSIS AREAS" while the file body had eight numbered section headers, with Section 8 covering three of the nine listed areas in one continuous query. **Fixed in this checkpoint:** the header's "ANALYSIS AREAS" list was rewritten to exactly match the eight actual section titles in the file body (in order), with a short note explaining that Section 8 covers scenario-rank comparison, robustness scoring, and Robust Candidate classification together. This was a comment-only change — verified by diffing against the pre-edit version, which confirmed the semicolon count (8), top-level `SELECT` count (35), and `WITH` count (6) are identical before and after, and that every changed line falls inside a `/* ... */` header comment or a `--` banner line. No `WITH`, `SELECT`, `JOIN`, `WHERE`, `CASE`, formula, weight, threshold, or filter was touched.

**[OBSERVED FACT — audit finding, now fixed]** Comment-banner formatting was previously slightly inconsistent in `sql/04_category_performance_analysis.sql`: Sections 1–6 used a 77-character `=` line as both the top and bottom border of each section header block; Section 7 opened with a shorter (60-character) `=` line and closed with a 59-character bare `-` line instead; Section 8 opened and closed with the shorter (60-character) `=` line. **Fixed in this checkpoint:** Sections 7 and 8's banner lines were changed to the same 77-character `=` style used by Sections 1–6, for both their opening and closing borders. Comment-only change, verified the same way as above.

**[OBSERVED FACT — audit finding]** The four SQL files (re-reviewed after the comment-only fixes above), and `README.md` / `docs/stage-01-business-case.md` / `docs/stage-02-data-preparation.md`, were reviewed and contain no API keys, credentials, passwords, tokens, service-account material, or local device file paths (e.g. no Windows user/folder paths appear anywhere in the reviewed repository content).

## Third Checkpoint — Validated Snapshot (2026-09-21)

**[OBSERVED FACT — snapshot result, third checkpoint]** The following is the currently inspected portion of `sql/04_category_performance_analysis.sql` Section 8 output, from the latest validated BigQuery execution, dated 2026-09-21. The query evaluates all 26 categories in the dataset; no values for any category are inferred or invented here — only what was actually reported is recorded.

| Category | rank_balanced | rank_profitability | rank_growth_controlled_risk | average_rank | rank_variation | Classification |
|---|---|---|---|---|---|---|
| Outerwear & Coats | 1 | 1 | 1 | 1.00 | 0 | Robust Candidate |
| Jeans | 2 | 2 | 2 | 2.00 | 0 | Robust Candidate |
| Sweaters | 3 | 3 | 4 | 3.33 | 1 | Robust Candidate |
| Pants | 4 | 6 | 3 | 4.33 | 3 | Robust Candidate |
| Active | 5 | 4 | 5 | 4.67 | 1 | Robust Candidate |
| Accessories | 6 | 5 | 6 | 5.67 | 1 | Robust Candidate |
| Sleep & Lounge | 8 | 7 | 8 | 7.67 | 1 | Robust Candidate |
| Swim | 7 | 9 | 9 | 8.33 | 2 | Robust Candidate |
| Shorts | 9 | 11 | 10 | 10.00 | 2 | Robust Candidate |
| Blazers & Jackets | 14 | 10 | 7 | 10.33 | 7 | Sensitive / Lower Priority |
| Suits & Sport Coats | 12 | 8 | 11 | 10.33 | 4 | Sensitive / Lower Priority |
| *(rows 12–25)* | — | — | — | — | — | Sensitive / Lower Priority (see note below) |
| Clothing Sets | 26 | 26 | 26 | 26.00 | 0 | Sensitive / Lower Priority |

Every `average_rank` and `rank_variation` value above was independently recomputed from the reported per-scenario ranks and matches exactly (e.g. Pants: (4+6+3)/3 = 4.33, variation = 6−3 = 3; Blazers & Jackets: (14+10+7)/3 = 10.33, variation = 14−7 = 7; Clothing Sets: (26+26+26)/3 = 26.00, variation = 26−26 = 0).

**[OBSERVED FACT — full output confirmed]** All 26 categories in `sql/04` Section 8's output were manually inspected (rows 1–26, ordered by `average_rank ASC`), confirming the query returns exactly 26 rows. Rows 12 through 26 are all classified `Sensitive / Lower Priority`, and `average_rank` was reported to progress coherently (i.e., without gaps or anomalies) through the final row. Individual per-scenario ranks, `average_rank`, and `rank_variation` values for rows 12 through 25 specifically were not provided and are **not** recorded in this document — only their shared classification and the final row's exact figures are documented, to avoid inventing numbers that were not reported.

**[OBSERVED FACT]** The final row, Clothing Sets, has `rank_balanced = rank_profitability = rank_growth_controlled_risk = 26`, `average_rank = 26.00`, `rank_variation = 0`, and is classified `Sensitive / Lower Priority`.

**[ANALYTICAL ASSUMPTION — methodological interpretation, confirmed by this full-output review]** Clothing Sets demonstrates that `rank_variation = 0` indicates *stability* across scenarios, not necessarily *strong* performance — a category can be consistently weak just as easily as consistently strong. This is precisely why the Robust Candidate rule requires **both** `average_rank <= 10` **and** `rank_variation <= 3`: Clothing Sets satisfies the variation condition perfectly (0 <= 3) but fails decisively on the position condition (26.00 is far above the <= 10 threshold), and is correctly classified `Sensitive / Lower Priority` as a result. This is a validation of the classification rule's design, not a new rule.

**[DATASET LIMITATION]** This snapshot does not match the "Current Robust Shortlist" / "Current Snapshot Values" tables from the second checkpoint above — different categories appear (e.g. Jeans, Pants, Sleep & Lounge, and Shorts appear here but not there; Intimates and Fashion Hoodies & Sweatshirts appeared there but are not among the categories detailed here). Consistent with TheLook being synthetic and dynamic, and with the instruction not to overwrite historical observations as if the dataset were static, this is recorded as a third, later, distinct snapshot. It does not replace or correct the second-checkpoint tables, and the second-checkpoint tables are not replaced or corrected by it — all three checkpoints' figures are preserved side by side as dated observations, not reconciled into one "true" set of numbers. As with every other snapshot in this document, these 26 rows describe one BigQuery execution on 2026-09-21 — not a permanent or reproducible-on-demand property of TheLook, which can return different absolute values (and potentially different category-to-category comparisons) on a later execution.

## Business Interpretation of the Third Checkpoint Snapshot

**[ANALYTICAL ASSUMPTION]** The purpose of the Category Decision Model is **not** to declare an objectively "best" category. Its purpose is to identify categories that remain comparatively strong when business priorities (i.e., scenario weights) change.

**[OBSERVED FACT]** Outerwear & Coats ranks 1 → 1 → 1 across the three scenarios, with `rank_variation = 0`. This indicates extremely high stability across the three tested weighting scenarios in the current snapshot.

**[OBSERVED FACT]** Jeans ranks 2 → 2 → 2, also with `rank_variation = 0` — complete ranking stability across the tested scenarios.

**[OBSERVED FACT]** Sweaters, Active, and Accessories (and the other low-variation rows above) demonstrate comparatively stable performance under the tested weighting assumptions (`rank_variation` of 1 in each case).

**[OBSERVED FACT]** Pants has `average_rank = 4.33` and `rank_variation = 3`. It remains inside the provisional robustness threshold (`rank_variation <= 3`) but sits exactly at the maximum permitted variation boundary.

**[OBSERVED FACT]** Shorts has `average_rank = 10.00` and `rank_variation = 2`. It sits exactly at the provisional average-rank boundary (`average_rank <= 10`).

**[OBSERVED FACT]** Blazers & Jackets illustrates scenario sensitivity particularly well: ranks 14 → 10 → 7, `rank_variation = 7`. Its position improves substantially as the weighting shifts from Balanced toward Profitability and Growth + Controlled Risk, meaning its apparent attractiveness depends much more heavily on which business priorities are selected than the Robust Candidates above do.

**[OBSERVED FACT]** Suits & Sport Coats also fails the provisional robustness rule: `average_rank = 10.33`, `rank_variation = 4` (exceeds the `<= 3` threshold).

**[ANALYTICAL ASSUMPTION]** "Sensitive / Lower Priority" must **not** be interpreted as "bad category." It means the category's ranking is more sensitive to the analytical weighting assumptions used, or that it does not currently satisfy the provisional robustness thresholds adopted for this project — not that its underlying financial or operational performance is poor.

**[ANALYTICAL ASSUMPTION]** A "Robust Candidate" classification is **not**, by itself, a recommendation for marketing investment. Further investigation would still be needed before a real business decision, including factors that remain absent from the current dataset: advertising spend, impressions, clicks, campaign attribution, CAC, ROAS, inventory constraints, return handling costs, customer lifetime value, seasonality/context, and real marketing campaign data. None of these values are invented or estimated here — they are recorded as absent, consistent with the Stage 1 Gap Analysis and the marketing-data limitation already logged earlier in this document (Dataset & Methodological Limitations, item 10).

## Analytical Pipeline (End-to-End Summary)

**[ANALYTICAL ASSUMPTION — narrative summary, not a new finding]** Read together, the SQL files and this document represent one coherent analytical progression rather than a collection of disconnected exercises:

Raw TheLook data → data quality validation (`sql/01`) → referential integrity validation → status/date validation → chronological validation → financial rules (`sql/02`) → Revenue / COGS / Gross Profit / Gross Margin → monthly performance analysis (`sql/03`, MoM/YoY) → category analysis → product / brand analysis → return / cancellation analysis → combined financial + operational category view (`sql/04` Section 3) → primary decision criteria (`sql/04` Section 4) → Min-Max normalization (`sql/04` Section 5) → balanced decision model (`sql/04` Section 6) → sensitivity analysis (`sql/04` Section 7) → scenario rankings and robustness analysis → Robust Candidate classification (`sql/04` Section 8).

Throughout this pipeline, the same methodological distinction is preserved: financial metrics are based primarily on completed/delivered transactions and the adopted financial recognition rules (using `delivered_at`), while operational return/cancellation metrics are based on `created_at` and final operational statuses. These cohorts are deliberately different because `Cancelled` items do not have a `delivered_at` value — this difference is documented explicitly (see Cohort Difference / Methodological Limitation above and the header comments in `sql/04`) rather than concealed.

## Dataset & Methodological Limitations

1. TheLook is synthetic and dynamic.
2. Results can change between executions.
3. A `created_at`/`shipped_at` anomaly exists (see above).
4. The current month is excluded from historical analyses.
5. Future-dated records are generated by the dataset.
6. Sufficient logistics cost data to economically model a real return is not currently available.
7. `Returned` is modeled as a full refund + product returns to inventory, for the financial baseline.
8. Real return-related costs remain outside the current model.
9. Financial and operational metrics can use different dates/cohorts (see Cohort Difference above).
10. Marketing campaign/ad spend/impressions/clicks are not yet available in the current data layer (carried forward from Stage 1).
11. Min-Max normalized scores (see Normalization section) are relative to the current dataset snapshot, will shift on later executions, and are sensitive to extreme values — they are not absolute quality measures.
12. The three sensitivity-analysis weighting scenarios (Balanced / Profitability / Growth + Controlled Risk) and the Robust Candidate threshold rule (`average_rank <= 10 AND rank_variation <= 3`) are analytical/project decisions, not statistical laws or properties of TheLook — a different set of weights or a different threshold could produce a different shortlist.
13. The Current Snapshot Values (Robust Shortlist Detail) reflect a later query execution than the Combined Results by Category snapshot earlier in this document; the two are not directly reconciled and neither has been overwritten by the other (see the limitation note in that section).
14. The Third Checkpoint — Validated Snapshot (2026-09-21) reflects a still later query execution and only reports 11 of the dataset's 26 categories; it is neither reconciled with, nor a replacement for, the earlier snapshots (see the limitation note in that section).
15. A "Robust Candidate" classification reflects consistency across three specific, analyst-chosen weighting scenarios and a specific threshold rule — it is not, by itself, a recommendation for marketing investment; see Business Interpretation of the Third Checkpoint Snapshot above for the categories of data (ad spend, CAC, ROAS, CLV, etc.) still absent from this analysis.

If synthetic marketing data is added later, it must be clearly identified as synthetic/simulated, consistent with the Stage 1 Original vs. Synthetic Data Principle.

## Skills Demonstrated

- SQL data-quality validation: referential integrity checks across five relationships, orphan-record detection, and quantity-consistency checks (`num_of_item` vs. actual row counts).
- SQL techniques: CTEs, multi-table `INNER JOIN`s, `COUNTIF`, `SAFE_DIVIDE`, conditional aggregation, and date-based filtering (`DATE_TRUNC`).
- Financial business-rule design: a conservative, status-based revenue/COGS recognition model, explicitly distinguishing what is recognized from what is pending or reversed.
- Evidence-based source selection: choosing `inventory_items.cost` over `products.cost` for COGS, backed by explicit validation rather than assumption.
- Outlier investigation discipline: a suspicious low-price product was investigated at the row level before deciding to keep it, rather than discarded reflexively.
- Methodological transparency: documenting a cohort-definition inconsistency between two CTEs explicitly, rather than presenting a single unified-looking result.
- Multi-signal analytical discipline: declining to select a "winning" category, product, or brand from a single KPI, consistent with Stage 1's KPI governance principles.
- Multi-criteria decision modeling: Min-Max normalization to unify metrics on different scales, explicit weighted scoring, and scenario-based sensitivity analysis instead of relying on a single weighting assumption.
- Robustness testing: deriving `average_rank` and `rank_variation` across multiple scenarios, and adopting an explicit, documented threshold rule to classify candidates rather than eyeballing scenario outputs.
- Production SQL organization: consolidating exploratory validation work into four numbered, header-documented, independently runnable `.sql` files with a clear purpose and analysis-area breakdown per file.

## Stage 2 Checkpoint Status

**Stage 2 — Data Preparation & Analytical Validation: COMPLETE.**
**Closure date: 2026-09-21.**

This document captures four checkpoints, the last being the formal closure:

- **First checkpoint (2026-09-15):** schema/referential-integrity validation, status-field validation, a documented chronological anomaly, sale-price validation, a COGS source decision, adopted financial recognition rules, a financial baseline snapshot, temporal (MoM/YoY) analysis, and category/product/brand exploratory analysis.
- **Second checkpoint (subsequent to 2026-09-15; exact date not specified):** a formal multi-dimensional Category Decision Model (Gross Profit, Gross Margin, Volume, Return Rate), Min-Max normalization, a balanced baseline scenario, a three-scenario sensitivity analysis, per-scenario category ranking, a robustness analysis (`average_rank`, `rank_variation`), an explicit Robust Candidate threshold rule, and a resulting shortlist of eight categories at that snapshot.
- **Third checkpoint (2026-09-21):** the Category Decision Model manually consolidated and tested as production SQL across four files (`sql/01`–`sql/04`); a validated snapshot dated 2026-09-21, with the full 26-category output of `sql/04` Section 8 manually reviewed end to end (confirmed 26 rows total; rows 1–11 and row 26 documented with exact figures; rows 12–25 confirmed `Sensitive / Lower Priority` with `average_rank` progressing coherently, without inventing their individual figures); independently re-verified `average_rank`/`rank_variation` arithmetic throughout; a business interpretation distinguishing "Robust Candidate" from "recommended for investment," including the methodological point that `rank_variation = 0` indicates stability, not necessarily strength (illustrated by Clothing Sets); a full audit of all four SQL files (structure, duplication, CTE consistency, documentation/SQL alignment, secrets/credentials/local-path scan — none found); two comment-only cosmetic fixes applied to `sql/04` (header/body section-list alignment, banner-style unification); an initial attempt to reconcile the `SQL/` vs. `sql/` folder-naming casing, which this session could not perform itself (see SQL File Consolidation above); and, in a follow-up checkpoint, confirmation that Kevin performed the rename manually and this document's folder-path references were updated to lowercase `sql/` throughout.
- **Fourth checkpoint — Closure (2026-09-21):** a final repository consistency pass (lowercase `sql/` folder casing confirmed correct on disk; `README.md`'s Folder Structure and Planned Architecture sections updated to reflect `sql/` as part of the current repository rather than a future/nonexistent folder; remaining stale uppercase `SQL/0X` references in this document corrected to lowercase); a consolidated public-repository security review across `README.md`, both stage documents, and all four SQL files (no API keys, credentials, passwords, tokens, or local device paths found); and a final cross-file consistency check confirming `README.md`, this document, and the four SQL files describe the same file names and purposes. On the basis of this review, Stage 2 is formally marked **COMPLETE**.

**[BUSINESS RULE / DECISION — Stage 2 closure, authorized by Kevin, 2026-09-21]** Stage 2 — Data Preparation & Analytical Validation completed:

- source dataset structural/data-quality validation
- referential-integrity validation
- order-status and chronological validation
- sale-price and inventory-cost validation
- documented treatment of the synthetic chronological anomaly
- revenue-recognition and COGS business rules
- financial baseline validation
- monthly performance analysis
- category, product, and brand analysis
- returns and cancellations analysis
- multi-criteria category decision model
- Min-Max normalization
- three weighting scenarios
- scenario ranking
- robustness analysis using `average_rank` and `rank_variation`
- robust-candidate classification
- full 26-category output validation
- consolidation of validated SQL into four professional files under `sql/`
- final repository consistency and public-repository security review

**[DATASET LIMITATION / ANALYTICAL ASSUMPTION — carried forward past closure]** Closing Stage 2 does not resolve or override the methodological limitations documented throughout this file (see Dataset & Methodological Limitations above for the full list). The following remain especially relevant to how Stage 2's output should be read going forward:

- TheLook is a synthetic and dynamic public dataset; results may change between executions.
- Snapshot values recorded in this document (the financial baseline, category rankings, the 26-category validated output) reflect the dataset's state on the query execution dates given, not a fixed or permanent truth.
- The creation-to-shipping chronological anomaly (see Chronological Anomaly above) remains documented, not altered or "corrected" in the underlying data.
- Financial and operational cohorts intentionally use different temporal logic where required (`delivered_at` vs. `created_at` — see Cohort Difference / Methodological Limitation above).
- The three sensitivity-analysis weighting scenarios and the Robust Candidate threshold rule are analytical assumptions and project decisions, not observed facts about the dataset.
- The Category Decision Model and its "Robust Candidate" classification are decision support only — they identify categories that are comparatively attractive and consistent across scenarios, not a claim that any category is universally "best," and are not by themselves a recommendation for marketing investment.

No category, product, or brand has been selected as a final marketing-investment recommendation — that decision remains outside Stage 2's scope.

**Not yet started:** Power BI, DAX, Power Query implementation, Python analysis, n8n automation, Stage 3 (no Stage 3 files have been created), or any synthetic data creation.

---

## Pending Documentation Recommendations (for Kevin's review)

1. **Stage/file naming confirmation — open, carried forward past Stage 2 closure.** This checkpoint's content spans both data-preparation-style validation (referential integrity, status/date checks, quantity checks) and descriptive/financial analysis (revenue recognition, temporal trends, category/product/brand profitability). It was filed as `docs/stage-02-data-preparation.md`, matching the name already used in Stage 1's Stage 2 Handoff. If the original 11-stage project plan reserves a separate stage for descriptive/exploratory analysis (distinct from data preparation), this content may need to be split across two stage documents, or this file's scope/title broadened explicitly. This is a documentation-architecture judgment call, not a defect — it was assessed as non-blocking for Stage 2 closure (nothing in the file is inaccurate or unverified) and remains a future consideration for Kevin to resolve whenever convenient, including after closure; it has not been decided or acted on here.
2. **`SQL/` vs. `sql/` folder casing — resolved.** Kevin performed the rename manually (`SQL/` → `SQL_temp/` → `sql/`), confirmed via a fresh device directory listing at the start of this checkpoint. `sql/` (lowercase) now contains the same four `.sql` files, unchanged in content. All folder-path references in this document and in `README.md` were updated to lowercase `sql/` accordingly. No further action needed.
3. **`README.md` "## Status" line.** Updated across two turns: first (with your explicit authorization) to reflect Stage 0 complete, Stage 1 complete, Stage 2 in progress; then, in this closure pass, updated again to reflect Stage 2 complete (closed 2026-09-21) and Stage 3 as next. Kept here only as a record that this recommendation was acted on.
4. **`sql/04_category_performance_analysis.sql` minor findings — now fixed.** The header-comment-vs-body section-numbering mismatch and the Section 7/8 comment-banner style inconsistency (previously flagged) were both corrected in this checkpoint as comment-only edits, verified not to touch any query logic. No further action needed on these two items.
5. **README now references the `sql/` folder — resolved.** `README.md`'s "Folder Structure" section now lists `sql/` as part of the repository's current structure, with a `### sql/` subsection describing the four files and their purpose. The "Planned Architecture (Future Stages)" section no longer lists `sql/` as future/nonexistent, and no longer claims no `docs/stage-XX-*.md` files exist. The remaining "Planned Architecture" items (`data/`, `notebooks/`, `powerbi/`, `content/`, `results/`) are still correctly described as not yet created. No further action needed.
