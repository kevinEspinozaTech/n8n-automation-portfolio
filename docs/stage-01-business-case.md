# Stage 01 — Business Case & Data Acquisition

**Stage 1 Status: COMPLETED**

## Stage Objective

Establish, before touching any data, a clear understanding of the (fictional) business problem this project addresses: what the company needs to decide, why, and what evidence the analysis should ultimately produce. This stage defines the questions the project exists to answer — it does not yet acquire, load, or analyze any data.

## Business Context

The scenario is a **fictional** e-commerce company. This is a constructed learning/portfolio case, not a description of any real business.

Leadership has noticed that sales are not growing at the expected rate. The company has a **limited marketing budget** and needs to decide where to concentrate its efforts to improve growth and profitability.

Before looking at any data, a Business Understanding exercise was carried out to frame the problem. The initial questions raised were:

1. What does the company sell?
2. How does it sell its products?
3. Where does it sell them?
4. Which are its top-performing products?
5. Which products generate the highest margins?
6. Who is the target customer?
7. What channels does the company use to reach those customers?

The analysis was then extended to include a time dimension:

- How are sales evolving over time?
- Are sales actually declining, or simply growing more slowly than expected?
- How does performance change by month/year/period?

A need to analyze marketing activity specifically was also identified:

- when the target customer visits/interacts with the website
- historical campaigns
- campaign metrics
- channels used
- social media platforms used
- best-performing time windows
- content types
- conversion behavior

Conceptually, the project should eventually be able to analyze a funnel such as:

```
Impression → Click → Website Visit / Session → Add to Cart → Purchase / Conversion → Revenue → Profit
```

which later connects to metrics such as CTR, Conversion Rate, CPA, Revenue, Profit, ROI, and ROAS. **None of these metrics are calculated yet** — this stage only establishes that they are relevant.

## Business Problem Statement

A fictional e-commerce company has detected that its sales are not growing at the expected rate and operates with a limited marketing budget. Rather than increasing spend broadly, the company needs to identify *where* to concentrate its limited resources.

To do that, it needs to understand:

- which products/categories represent the strongest commercial opportunities
- which products are genuinely profitable, not just high-selling
- which customer segments show the greatest potential
- which channels and content types have historically performed well
- where the company should focus its next marketing efforts

The goal is to use data-driven evidence to prioritize actions that can plausibly improve growth and profitability — rather than deciding based on intuition alone.

## Stakeholder Need

Leadership (the decision-maker in this fictional scenario) needs a small, prioritized, well-justified set of opportunities to act on — not a full data dump. Given the limited marketing budget, the value of this project is in **narrowing** the decision space to a handful of well-supported recommendations, each backed by evidence rather than assumption.

## Initial Business Questions

- What does the company sell, and how/where does it sell it?
- Which products/categories are top sellers?
- Which products/categories generate the best margins (not just the best revenue)?
- Who is the target customer, and what channels reach them?
- Are sales actually declining, or growing more slowly than expected?
- How does performance change over time (by month/year/period)?
- What marketing channels, campaigns, and content types have been used historically, and how did they perform?
- When does the target customer engage most (best-performing time windows)?

## Decision Framework

The reasoning the project will follow, conceptually:

**WHAT should we promote?**
→ Products / Categories / Profitability / Sales Trends

**WHO should we target?**
→ Customers / Segments / Behavior

**WHERE / HOW / WHEN should we reach them?**
→ Channels / Campaigns / Content / Timing

**WHAT happened afterward?**
→ Conversion / Revenue / Profit / Marketing Performance

This later feeds the project's intended feedback loop:

```
DATA → INSIGHT → DECISION → MARKETING ACTION → AUTOMATION → CONTENT → PERFORMANCE → DATA
```

### Decision Question (provisional)

> Which 3–5 marketing opportunities should the company prioritize based on profitability, sales trends, customer behavior, and traffic-source/engagement behavior — and for each one, which product, audience, channel, and content approach should be prioritized?

This is a **provisional** central question for the project. It may be refined once data acquisition and modeling (later stages) reveal what is actually measurable.

**Refinement note (Step 1.6 audit).** The original wording of this question referenced "historical marketing performance" as one of its four bases. Now that TheLook eCommerce has been formally selected as the Primary Core Dataset (Step 1.5), campaign-level marketing performance (impressions, clicks, ad spend, attributed revenue) was confirmed **MISSING** from the core dataset in the Step 1.5 Gap Analysis. The wording above was refined to reference traffic-source and engagement behavior instead — which TheLook does support directly (`traffic_source`, session sequencing, event data) — rather than implying campaign performance is already available. This does not narrow the project's original intent: campaign-level marketing performance remains part of the project's longer-term goal and will re-enter the analysis once it becomes available, either through a clearly-labeled synthetic marketing supplement (see Step 1.5's Future Synthetic Marketing Layer) or dataset evolution — feeding into the `DATA → INSIGHT → DECISION → MARKETING ACTION → AUTOMATION → CONTENT → PERFORMANCE → DATA` feedback loop already established in the Decision Framework above, not assumed as a Stage 1 given.

## Expected Decision Output

For each prioritized opportunity, the project should eventually be able to produce information such as:

- Product / Category
- Reason it represents an opportunity
- Revenue
- Profit
- Gross Margin
- Sales Growth
- Target Customer / Segment
- Recommended Channel
- Recommended Content Type
- Recommended Publishing Window
- Historical Conversion Rate, when available
- Historical ROI / ROAS, when available
- Recommended Action
- Evidence supporting the recommendation

**Important scope boundary:** this project does not yet claim it can predict the future profit impact of increased advertising spend with certainty. Two distinct kinds of analysis are being separated on purpose:

- **Descriptive / diagnostic analysis** — "What happened, and where is the opportunity?" — this is what Stage 1 through Stage 7 target.
- **Predictive analysis** — "What is likely to happen if we act?" — this is a possible *future* extension, only to be added later, and only if the available data and methodology can actually justify it. It is explicitly out of scope for now.

## Data Requirements (Step 1.2)

The objective of this step is to document what information the company would ideally need to answer the business questions defined in Step 1.1 — **not** to design the final Power BI data model. Requirements were organized conceptually into four domains: **Sales**, **Products**, **Customers**, and **Marketing/Campaigns**.

**Important scope boundary:** these are data *requirements* (candidate fields and analytical needs), not a physical or logical data model. The formal Star Schema — fact tables, dimension tables, relationships, cardinality — belongs to Stage 3 and is **not** designed here.

### Sales Requirements

Candidate fields:

- Order / Transaction ID
- Date and Time
- Product ID
- Customer ID
- Quantity
- Unit Selling Price
- Unit Cost, when available
- Return / Cancellation information

Analytical objectives these fields would support: sales volume, evolution over time, day/hour patterns, revenue, cost, profit, margin, product-level behavior, and relating transactions back to customers.

**Note:** Revenue, Cost, Gross Profit, and Gross Margin are potentially **derived metrics** (calculated from quantity × price, and price − cost), not necessarily raw columns that exist directly in a source dataset.

### Product Requirements

Candidate fields:

- Product ID
- Product Name
- Product Type
- Category
- Subcategory
- Standard Price, when applicable
- Standard Cost, when applicable
- Seasonality classification, when known

**Note — attribute vs. derived insight:** a field like *Category* is a **product attribute** — a relatively fixed property of the product itself. Something like *"best-selling hour"* is a **derived insight** — it must be discovered from transaction data, not treated as a fixed property of the product. Similarly, historical promotions, content, and marketing channels used for a product are **not** to be treated as permanent product attributes; they belong to the marketing/campaign domain and change over time.

### Customer Requirements

Candidate analytical fields:

- Customer ID
- Age or Age Group, when appropriate and available
- Gender, when appropriate and available
- Country
- Region
- City
- Customer Segment, when available
- Signup / Registration Date, when relevant

Behavioral metrics potentially derivable from transactions (not raw fields):

- Purchase Frequency
- Average Order Value
- Return Rate
- Total Spend
- Last Purchase Date
- Preferred Purchase Time
- Potentially RFM-style metrics later

**Data minimization / privacy note:** email address, phone number, and exact street address were considered during requirements discovery but were **deliberately excluded** from the portfolio's data requirements — they are unnecessary personally identifiable information for the stated analytical objective. This is a conscious data minimization / privacy-awareness decision, not an oversight.

### Marketing / Campaign Requirements

Candidate fields:

- Campaign ID
- Campaign Name
- Product ID / Category promoted
- Target Customer Segment
- Channel / Platform
- Content Type
- Campaign Type
- Start Date
- End Date
- Publication Date / Time
- Planned Budget, when available
- Actual Ad Spend
- Impressions
- Clicks
- Conversions / Purchases
- Attributed Revenue, when available

The goal is to eventually be able to analyze:

```
PRODUCT + CUSTOMER SEGMENT + CHANNEL + CONTENT TYPE + PUBLISHING TIME → MARKETING PERFORMANCE
```

**Note:** CTR, Conversion Rate, CPA, ROAS, and ROI are potentially **derived metrics** from the fields above. Their official formulas are **not defined yet** — that belongs to Step 1.3 — KPI Requirements.

**Planned vs. actual:** Planned/expected performance (e.g. a planned budget or a target) must be kept conceptually distinct from actual observed performance (e.g. actual ad spend, actual conversions). Forecasts or targets must never be presented as if they were real, observed results.

### Data Modeling Note

During this requirements exercise, distinct candidate entities began to emerge naturally: **Sales**, **Products**, **Customers**, and **Marketing/Campaigns**. This is noted here only as an observation from requirements discovery. No definitive relationships, cardinality, or Star Schema are designed at this point — formal data modeling belongs to Stage 3.

## KPI Requirements (Step 1.3)

The objective of this step is to turn business questions such as *"Are sales growing?"*, *"Is the business becoming more profitable?"*, *"Which customers are most valuable?"*, and *"Which marketing campaigns perform best?"* into clearly defined candidate metrics, grouped into four areas: **Sales & Growth**, **Profitability**, **Customer Value/Behavior**, and **Marketing Performance**.

**Important scope boundary:** these are **KPI requirements / candidate KPIs**, not the final dashboard KPI set. Which of these can actually be implemented will depend on the availability and quality of the dataset selected in Step 1.4–1.5.

### 1. Sales & Growth KPIs

**Revenue** — total sales revenue generated from transactions.
- Transaction level: `Revenue = Quantity × Unit Selling Price`
- Aggregated level: `Revenue = SUM(transaction revenue)`

**Revenue Growth %** — `(Current Period Revenue − Previous Period Revenue) / Previous Period Revenue`
"Growth" always requires a comparison baseline. Potential comparisons include YoY (Year over Year), MoM (Month over Month), YTD vs. prior-year YTD, and Actual vs. Target/Budget when target data exists.

**Important:** Revenue growth alone is **not** sufficient evidence that the business is performing better — sales can increase while profitability decreases.

### 2. Profitability KPIs

**Cost** — `Cost = Quantity × Unit Cost`, when transaction-level quantity and unit cost are available.

**Gross Profit** — `Gross Profit = Revenue − Cost`

**Gross Margin %** — `Gross Margin % = Gross Profit / Revenue`
Gross Profit is a **monetary amount**; Gross Margin is a **percentage** representing the proportion of revenue remaining after the included product/direct costs.

**Gross Profit Growth %** — `(Current Period Gross Profit − Previous Period Gross Profit) / Previous Period Gross Profit`, with potential temporal comparisons such as YoY and MoM.

**Key analytical principle: Sales Growth ≠ Profitable Growth.** Conceptually, revenue may increase while costs increase faster, causing Gross Profit and Gross Margin to decline. (No company results are asserted here — this is a conceptual principle only.)

#### Product Opportunity Analysis

Individual product/category performance should not be evaluated using only one metric. Potential signals include combinations of Revenue, Revenue Growth, Gross Profit, Gross Margin, sales trend, customer behavior, and historical marketing performance.

A high-margin product with declining sales may represent an investigation opportunity, but the decline must **not** automatically be attributed to lack of marketing — possible causes must be investigated using evidence. Likewise, a fast-growing product with very low margin should not automatically receive more marketing investment.

**Principle:** marketing opportunities should be identified using multiple signals rather than simply selecting "top products by sales."

### 3. Customer KPIs

- **Purchase Frequency** — how frequently a customer purchases during a defined period.
- **Average Order Value (AOV)** — `AOV = Revenue / Number of Orders`
- **Return Rate** — proportion of purchases/orders/items that are returned. **Ambiguous denominator:** whether this is orders or items must be explicitly defined based on the selected dataset and business context before implementation.
- **Total Customer Spend** — total revenue associated with a customer during the analyzed period.
- **Customer Tenure** — length of the customer relationship. Exact definition may depend on available data (e.g. registration date vs. first purchase date).
- **Recency** — time elapsed since the customer's most recent purchase.

**RFM Analysis — potential extension.** R = Recency, F = Frequency, M = Monetary Value, documented here as a potential customer segmentation approach. RFM is **not** mandatory yet — whether it is implemented depends on dataset suitability.

**Analytical distinction:** a customer who has been registered for many years is not automatically a high-value active customer. Tenure, Recency, Frequency, and Monetary Value represent different aspects of customer behavior.

### 4. Marketing KPIs

- **Impressions** — number of times a campaign/content was displayed.
- **Clicks** — number of recorded clicks.
- **CTR (Click-Through Rate)** — `CTR = Clicks / Impressions`
- **Conversions** — number of desired actions attributed to the campaign. In this business case a conversion will usually refer to a purchase when appropriate, but the exact definition must be confirmed from the dataset/business context.
- **Conversion Rate** — conceptually `Conversions / Clicks`, but the denominator depends on the funnel definition: depending on available data it might instead use sessions, visits, leads, etc. **The final definition must be established before implementation.**
- **Ad Spend** — actual marketing expenditure associated with a campaign/activity.
- **CPA (Cost Per Acquisition/Conversion)** — `CPA = Ad Spend / Conversions`. Exact interpretation depends on what counts as an acquisition/conversion.
- **Attributed Revenue** — revenue attributed to a marketing campaign/activity according to the available attribution methodology. Attribution methodology matters and must not be assumed.
- **ROAS (Return on Ad Spend)** — `ROAS = Attributed Revenue / Ad Spend`. Measures revenue generated per unit of advertising spend (e.g. ROAS = 4x means €4 of attributed revenue per €1 of advertising spend). **ROAS must not be confused with profit.**
- **ROI (Return on Investment)** — documented as a candidate KPI, not to be oversimplified. General conceptual structure: `ROI = (Return/Benefit − Investment Cost) / Investment Cost`. The exact implementation requires defining which costs are included, what benefit/profit is attributable, and the attribution methodology — the final ROI definition should be validated after dataset selection and business assumptions are set.

### Marketing Funnel

```
Impression → Click → Website Visit / Session → Add to Cart → Purchase / Conversion → Revenue → Profit
```

This is the same conceptual funnel introduced in Business Context (Step 1.1); the two are unified here to avoid two slightly different versions of it in this document.

**Stage availability depends on the dataset.** Each funnel stage can only be used analytically if the selected dataset contains information sufficient to measure it. For example: Website Visit / Session may not be available; Add to Cart may not be available; marketing attribution may not be available. Whichever stages turn out to be missing will simply be excluded from analysis at that point — no missing stage is to be assumed, estimated, or invented in future analysis.

Different KPIs measure different funnel stages. A campaign with more clicks is not necessarily the best-performing campaign — a campaign may generate fewer clicks but a higher conversion rate, more purchases, more attributed revenue, and higher ROAS. Campaign performance must therefore be evaluated using multiple metrics, not a single one.

### Profitability + Marketing Connection

**HIGH ROAS ≠ HIGH PROFIT.** ROAS uses attributed *revenue*, not necessarily profit — a campaign may generate significant revenue while promoting products with high costs or low margins.

One of the strengths of this project will be the attempt to connect Marketing Performance + Sales + Product Costs + Profitability, so the eventual decision engine can move beyond "which campaign generates more revenue?" toward "which marketing opportunities are supported by evidence and contribute to profitable business growth?" Whether the selected dataset will actually support this connection is **not yet claimed** — it must be evaluated during dataset selection and gap analysis (Step 1.5).

### Time Intelligence / PL-300 Connection

Temporal comparison requirements identified so far include YoY, MoM, YTD, prior-year comparisons, and potentially Actual vs. Target. These requirements will later connect to Date Tables, relationships, filter context, and DAX time-intelligence measures — but this is **not implemented yet**; formal implementation belongs to later Power BI stages (Stage 3 onward).

### KPI Governance / Definition Principle

A KPI must have an explicit definition before implementation. For each KPI we should eventually know: business meaning, formula, numerator, denominator, time period, granularity, filters/exclusions, data source, and assumptions. This is especially important for ambiguous metrics such as Conversion Rate, Return Rate, ROI, and Customer Tenure — different definitions can produce different results.

### Core vs. Secondary KPIs

No definitive final dashboard KPI set is selected yet. Candidate KPIs will later be classified into **Core decision KPIs** and **Supporting/diagnostic KPIs**, after evaluating dataset availability, data quality, business relevance, and analytical usefulness. The future dashboard should avoid displaying metrics simply because they are calculable.

## Dataset Search & Evaluation (Step 1.4)

This step evaluates candidate public datasets against the data requirements (Step 1.2) and KPI requirements (Step 1.3) defined earlier. Two rounds of candidate research were carried out conversationally (a first pass identifying five independent candidates, and a second, adversarial deep-verification pass comparing the three strongest candidates — TheLook eCommerce, Olist, and dunnhumby) before any dataset was directly inspected. That research is not yet written into this document.

The entry below documents the first candidate to be technically validated: a direct, hands-on SQL inspection performed by Kevin against Google BigQuery's public dataset, `bigquery-public-data.thelook_ecommerce`. All findings below were obtained by running SQL queries directly in BigQuery — not by further research — and the distinction between what was **directly verified** by inspection and what remains **future possibility / analytical potential** (not yet implemented) is maintained explicitly throughout.

### TheLook Ecommerce — Technical Evaluation

**Dataset identification.** TheLook eCommerce (`bigquery-public-data.thelook_ecommerce`) is a **synthetic** dataset — its data is generated, not drawn from a real company's operations. This is stated explicitly and is not treated as a disqualifying weakness for this project: the project's core priorities are PL-300/Power BI data modeling, financial analysis, SQL, Python, and portfolio demonstration, and the business scenario itself (see Business Context, above) is already fictional — the project does not require real marketing data to satisfy these priorities. If a real-world dataset is ultimately preferred for other reasons (e.g. Olist, dunnhumby — still under evaluation), that remains a Step 1.5 decision. Should TheLook be selected, any supplementary synthetic marketing data added later to fill campaign-data gaps (see "Marketing" below) will be clearly labeled as synthetic, its generation methodology documented, and kept separate from the dataset's own data — never presented as real.

**Methodology.** All findings in this subsection were obtained by Kevin directly, running SQL queries against `bigquery-public-data.thelook_ecommerce` in Google BigQuery — not by external research or documentation review. Each finding below is labeled **DIRECTLY VERIFIED** (confirmed by an executed query) or **FUTURE POSSIBILITY / ANALYTICAL POTENTIAL** (not yet implemented, and not to be treated as already accomplished).

**Table structure — DIRECTLY VERIFIED.** A query against `INFORMATION_SCHEMA.TABLES` confirmed the dataset contains exactly seven tables: `users`, `orders`, `order_items`, `products`, `inventory_items`, `distribution_centers`, and `events`. Row counts observed at inspection time (2026-09-14) included: `events` ≈ 2,426,647 rows, `inventory_items` ≈ 490,049 rows, `order_items` ≈ 181,703 rows. **These row counts are a snapshot at the time of inspection, not a permanent property of the dataset** — TheLook is a live, periodically-regenerated public dataset, and counts should be re-verified if used again later.

**Temporal coverage — DIRECTLY VERIFIED.** `SELECT MIN(created_at), MAX(created_at), COUNT(*) FROM orders` returned a first order timestamp of 2019-01-13 07:19:49 UTC, a latest order timestamp of approximately 2026-09-14 00:35 UTC, and 125,467 total orders — spanning roughly 7+ years. This gives strong candidate support for Date Table construction and the time-intelligence work central to PL-300 (YoY, MoM, YTD, trend and seasonality analysis, and comparing Revenue growth against Profit growth over time). **This is a PL-300/analytical-value observation, not a claim that the latest timestamp corresponds to a real-world sale** — the dataset is synthetic and appears to be dynamically generated, so its "latest" data point reflects generation activity, not an actual transaction.

**Financial analysis capability — DIRECTLY VERIFIED, including a correction to an earlier assumption.** The working assumption going into this inspection was that `order_items` would contain a `cost` column. Querying `INFORMATION_SCHEMA.COLUMNS` disproved this: `order_items` has no `cost` column — its actual columns include `id`, `order_id`, `user_id`, `product_id`, `inventory_item_id`, and `sale_price`, among others. A schema-wide search for columns named `cost` located it in two other tables instead: `inventory_items.cost` (FLOAT64) and `products.cost` (FLOAT64). This correction is documented explicitly here as evidence of rigorous, evidence-based validation — the assumption was checked against the schema rather than taken for granted, and the record was corrected once disproved.

**Financial relationship — DIRECTLY VERIFIED.** A JOIN of `order_items.inventory_item_id = inventory_items.id` executed successfully, returning `order_item_id`, `order_id`, `product_id`, `inventory_item_id`, `sale_price`, and `cost` together in one row, and enabling a preliminary calculation of `sale_price − cost AS gross_profit`. **This is a preliminary schema-level capability check, not a finished KPI implementation** — no Gross Margin %, aggregation, or time-based profitability analysis has been built yet (that belongs to later stages). It is also important to state explicitly: **Gross Profit ≠ Net Profit** — this calculation reflects only sale price minus item cost; no operating expenses, taxes, marketing spend, or overhead are represented in this dataset, so nothing here should be read as a full profitability picture.

**Customer behavior / event data — DIRECTLY VERIFIED.** Grouping the `events` table by `event_type` returned six distinct types with observed counts (inspection-date snapshot, 2026-09-14): `product` ≈ 844,021, `cart` ≈ 594,235, `department` ≈ 593,676, `purchase` ≈ 181,703, `cancel` ≈ 125,077, `home` ≈ 87,935.

**Events schema — DIRECTLY VERIFIED.** `events` contains 13 columns: `id`, `user_id`, `sequence_number`, `session_id`, `created_at`, `ip_address`, `city`, `state`, `postal_code`, `browser`, `traffic_source`, `uri`, `event_type`. **FUTURE POSSIBILITY / ANALYTICAL POTENTIAL (not yet done):** combining `traffic_source` with session sequencing to analyze the path from traffic source → session → product view → cart → purchase, and building a funnel/conversion-rate analysis from it. **No conversion funnel has been built or validated yet** — only the schema's potential to support one has been confirmed.

**Session sequencing — DIRECTLY VERIFIED.** Querying `events` ordered by `session_id` and `sequence_number` showed sequential, session-scoped event patterns (e.g. department → product → cart → purchase orderings) and observed `traffic_source` values including Email and Organic in real inspected records. **This confirms the data is structured to support sequence-based analysis — it does not confirm causality, does not confirm that every cart leads to a purchase, and does not yet establish any conversion-rate or funnel-performance figures.** Those remain future analytical work.

**Data privacy / minimization note.** The `events` table includes `ip_address` and `postal_code`. Even though this data is synthetic, these fields are unnecessary for the project's stated analytical objectives, consistent with the data-minimization principle already established for customer PII in Step 1.2. If TheLook is selected, `ip_address` and `postal_code` should likely be excluded from any downstream model.

**Evaluation against project priorities:**

- **A. PL-300 / Power BI modeling — STRONG.** Seven related tables, a multi-year date range, and clear fact/dimension candidate structure (orders/order_items as transactional data; users, products, distribution_centers as dimensions) directly support Date Table design, relationships, and DAX time-intelligence work central to the certification.
- **B. Financial analysis — STRONG.** Confirmed `cost` fields in `inventory_items` and `products`, joinable to `order_items.sale_price`, directly support the Revenue/Cost/Gross Profit/Gross Margin KPI work defined in Step 1.3 (with the Gross Profit ≠ Net Profit caveat above).
- **C. SQL — STRONG.** Validating the schema already required `INFORMATION_SCHEMA` introspection, multi-table JOINs, aggregate functions, and ordered/sequenced queries — supporting genuine SQL skill demonstration.
- **D. Python / Pandas — STRONG.** Seven normalized tables with clear join keys are well suited to Pandas-based data wrangling, feature engineering, and exploratory analysis later in the project.
- **E. Portfolio — STRONG.** A well-known, credible public dataset with genuine relational depth (not a single flat CSV) that supports a believable end-to-end analytics narrative.
- **F. Marketing — PARTIAL.** Strengths directly verified: `traffic_source`, session-level behavioral sequencing, and product/cart/purchase event data, which give real (if partial) funnel-analysis potential. Gaps: no campaign ID, no ad spend, no impressions, no budget (planned or actual), no creative/content type, no publication schedule, no attributed-campaign revenue, and no explicit ROI/ROAS fields — several of the Marketing/Campaign Requirements from Step 1.2 and Marketing KPIs from Step 1.3 are not present in this dataset. **These gaps do not disqualify TheLook.** If it is selected in Step 1.5, they may be filled later with clearly-documented synthetic supplementary marketing data, consistent with the project's data-minimization and synthetic-data-labeling principles.

**Important project design principle.** Dataset selection for this project should prioritize analytical learning value and coverage of the core business model over perfect real-world marketing authenticity. The core dataset must strongly support Power BI/PL-300 work, financial analysis, SQL, Python, data modeling, and customer/product analysis, and must be able to carry a credible portfolio narrative. Marketing automation and content generation are a later extension of the project, not the primary basis for dataset selection. Missing campaign-level marketing data can be supplemented synthetically later without compromising the project's educational purpose, provided its synthetic origin is transparently and permanently documented.

**Status of this evaluation.** TheLook eCommerce has been technically validated as one candidate among several under consideration for Step 1.4 (see the Olist and dunnhumby evaluations and the Candidate Evaluation Summary below). **No dataset has been selected.** This subsection documents evidence about TheLook only; it does not constitute a Step 1.5 decision.

### Olist Brazilian E-Commerce — Candidate Evaluation

**Evidence level: DOCUMENTATION / SOURCE-BASED.** Unlike TheLook, Olist has not been directly inspected via SQL by Kevin. The findings below come from a prior conversational research pass (source-based research against dataset descriptions, official documentation, and independent write-ups), not from hands-on query execution. Claims are labeled accordingly; anything the prior research could not confirm is marked **NOT CONFIRMED** or **REQUIRES VALIDATION** rather than assumed.

**Dataset Overview.** Olist represents real, anonymized order data from an actual Brazilian e-commerce marketplace company (DOCUMENTATION / SOURCE-BASED — reported consistently, with matching wording, across multiple independent sources). Commonly reported scale: approximately 100,000 orders spanning 2016–2018 (DOCUMENTATION / SOURCE-BASED). It is distributed as a set of related flat files rather than as live tables in a query engine. A second, related dataset — the "Olist Marketing Funnel" — exists and connects to the main dataset via `seller_id` (DOCUMENTATION / SOURCE-BASED).

**Data Structure & Complexity.** Entities referenced consistently across sources (DOCUMENTATION / SOURCE-BASED): orders, order items, order payments, products, customers, sellers, order reviews, and geolocation. Fields reported: order timestamps, customer IDs, product IDs/categories, item price, freight value, payment type/installments/value, order status, and review scores/text. This structure appears well suited to multi-table relational work — order-to-items, items-to-products, orders-to-customers, orders-to-sellers, and payments-to-orders are all plausible join relationships (**ANALYTICAL POTENTIAL** — not yet built or tested). Geography and reviews add further potential analytical dimensions. Order status is reported to include cancelled/unavailable states, though a full first-party field list was not directly retrieved (DOCUMENTATION / SOURCE-BASED, not independently field-verified).

**PL-300 Potential (ANALYTICAL POTENTIAL — not yet implemented).** Real order timestamps across a genuine 2016–2018 calendar range would support authentic Date Table construction and DAX time-intelligence work (YoY, MoM, YTD). The multi-table structure also offers real relationship-modeling and Power Query practice.

**Financial Analysis Potential — important limitation.** Across the prior research, no source named a product cost or COGS field anywhere in the Olist dataset; item-level data reported was price and freight_value, and payment-level data reported was payment_value/installments/payment_type. **Revenue is not the same as profit, and none of these fields represents cost.** Product cost/COGS availability is therefore **NOT CONFIRMED** and should be treated as very likely absent unless directly disproved. Practically, Gross Profit and Gross Margin (Step 1.3) cannot currently be calculated from Olist alone — a real constraint on this project's financial-analysis priority if Olist were selected, unless cost data were supplemented later (synthetically, and clearly labeled as such).

**SQL Potential (ANALYTICAL POTENTIAL — not yet tested).** The reported multi-table structure (orders, items, products, customers, sellers, payments, reviews, geolocation) would support JOINs across at least 6–8 tables, GROUP BY/aggregation exercises, filtering, and likely CTEs/subqueries and temporal analysis over the 2016–2018 range.

**Python Potential (ANALYTICAL POTENTIAL — not yet implemented).** Flat, well-documented files with a large amount of existing public reference work (per the prior research) would support cleaning, EDA, customer/product/geographic analysis, and segmentation exercises.

**Customer / Behavioral Potential.** Customer-level data reported is limited to an anonymized ID plus geography; no demographic fields (age, gender, income) were found in the prior research (DOCUMENTATION / SOURCE-BASED). Order review scores/text offer a potential customer-satisfaction angle. There is no session/browsing/click data on the shopper side, so a consumer-facing behavioral funnel (visit → cart → purchase) is **NOT CONFIRMED** to be supportable from Olist.

**Marketing Potential — requires care.** The "Olist Marketing Funnel" dataset is real and reasonably well-documented (DOCUMENTATION / SOURCE-BASED): roughly 8,000 marketing-qualified leads (MQLs), connected through fields including `origin`, `landing_page_id`, `first_contact_date`, `seller_id`, `business_segment`, `lead_type`, `declared_monthly_revenue`, `business_type`, `lead_behaviour_profile`, and `has_gtin`. However, the prior research found this funnel to be a **B2B seller-acquisition sales pipeline** (a business applying to become an Olist seller, moving through sign-up → contact → sales consultation → closed deal → seller) — **not** a B2C consumer advertising funnel of the kind this project's marketing KPIs (Step 1.3) were defined around (Impression → Click → Visit → Add to Cart → Purchase). Concretely: CTR cannot be calculated (no impressions/ad-click data in either Olist dataset); Conversion Rate is only calculable in a B2B sense (leads → closed deals), not a consumer sense; CPA cannot be calculated (no ad-spend field — `declared_monthly_revenue` is a lead's self-reported business revenue and must not be substituted for marketing spend); ROAS cannot be calculated (no spend or attributable-revenue link). This does not disqualify Olist under this project's stated priorities (marketing authenticity is not the dominant criterion), but it is a real structural mismatch with the project's consumer marketing funnel definition that would need explicit documentation if Olist were selected.

**Portfolio Potential (ANALYTICAL POTENTIAL).** A real, recognizable company with genuine transaction dates offers strong portfolio credibility and a believable end-to-end e-commerce narrative — not yet demonstrated in this project.

**Limitations / Gaps.**
- Product cost/COGS: **NOT CONFIRMED** to exist anywhere in the dataset; treat as very likely absent.
- No consumer-facing marketing/campaign data (impressions, clicks, ad spend, content type, publishing schedule) — the only available "marketing" dataset (Marketing Funnel) is B2B seller acquisition, not applicable to the project's consumer funnel KPIs.
- No customer demographic fields (age, gender, segment) confirmed.
- License terms: **NOT CONFIRMED** — the prior research could not verify the exact license (commonly reported, with only moderate confidence, as non-commercial-restricted); **REQUIRES VALIDATION** directly on the source page before any public-portfolio use if Olist is selected.
- None of the above has been directly re-validated by hands-on inspection (SQL/Python) by Kevin — everything here is source-based and **REQUIRES VALIDATION** before implementation.

**Overall Candidate Assessment.**
- PL-300 Learning Potential: STRONG (analytical potential)
- Financial Analysis Potential: PARTIAL (revenue-side data is strong; cost/COGS not confirmed)
- SQL Potential: STRONG (analytical potential)
- Python Potential: STRONG (analytical potential)
- Customer / Behavioral Potential: MODERATE (geography + reviews; no demographics or browsing behavior confirmed)
- Marketing Potential: PARTIAL (real funnel data exists but is B2B, not applicable to the project's consumer funnel/KPIs)
- Portfolio Potential: STRONG (real, recognizable company and dataset)
- Evidence Level: **DOCUMENTATION / SOURCE-BASED — NOT YET DIRECTLY VALIDATED**

### dunnhumby — The Complete Journey — Candidate Evaluation

**Evidence level: DOCUMENTATION / SOURCE-BASED.** The prior research pass went one step beyond typical secondary research — it read dunnhumby's own official source-files page plus the actual column-loading code for the raw `transaction_data` file (a source-code-level read, not a summary). This is still not a direct SQL/Python inspection performed by Kevin, so it remains DOCUMENTATION / SOURCE-BASED for this document's evidence-level purposes, though it draws on a more primary source than typical secondary write-ups.

**Dataset Overview.** dunnhumby's own official page describes the dataset as "a representation of household level transactions" — not explicitly labeled "real" or "synthetic" (DOCUMENTATION / SOURCE-BASED, primary-source phrasing). This is the most defensible label to carry into this project's documentation. **Important discrepancy — REQUIRES VALIDATION:** the official page states 2,500 households over a two-year period, while independent secondary sources describing the commonly-circulated version consistently report 2,469 households over one year, with 1,469,307 transaction rows. These do not match; the likely explanation (not confirmed) is that these are two different releases/vintages of the dataset. This must be resolved before either figure is relied upon. It is distributed as a set of related flat files (commonly via a Kaggle mirror or a third-party R package).

**Data Structure & Complexity.** Tables confirmed from the official user guide (DOCUMENTATION / SOURCE-BASED): `hh_demographic`, `transaction_data`, `campaign_table`, `campaign_desc`, `coupon`, `coupon_redempt`, `causal_data`, `product`. The prior research found these to form a genuinely connected relational structure: `campaign_table` links `household_key` to `campaign_id`; `campaign_desc` gives campaign type/duration; `coupon` links `coupon_upc` to `product_id` to `campaign_id`; `coupon_redempt` links `household_key`, `coupon_upc`, and redemption day; `causal_data` links `product_id`, `store_id`, and week (in-store display/mailer promotion). This relational depth was described in the prior research as the strongest of the three finalists on this specific dimension.

**PL-300 Potential — ANALYTICAL POTENTIAL, with an important caveat.** The rich relational joins (campaign ↔ coupon ↔ product ↔ transaction ↔ household) offer strong DAX/relationship-modeling practice. However, the time-structure finding is a significant limitation specifically for PL-300 work: a source-code-level read of the original `transaction_data` file found only a `DAY` (integer) and `TRANS_TIME` (integer) field — **there is no calendar date column in the original files.** Calendar-style dates seen in some secondary sources (e.g. "2016-12-28 to 2018-01-07") appear, per the prior research, to come from a third-party package's own derived calendar overlay — not dunnhumby's original files. **Building a genuine Date Table with real calendar semantics is therefore NOT CONFIRMED to be possible from the original data.** An arbitrary calendar could only be used as a clearly-labeled educational abstraction (e.g., "DAY 1 mapped to an arbitrary anchor date solely to practice Date Table/DAX mechanics; this does not represent the real purchase dates") — presenting a fabricated calendar as if it were real would directly violate this project's own synthetic-data labeling rule.

**Financial Analysis Potential.** Product cost/COGS is **CONFIRMED absent**, per two independent sources in the prior research reading the same schema ("No product cost/COGS included"). `SALES_VALUE` is the retailer's realized revenue post-discount — not a cost figure, and must not be conflated with COGS. **Gross Profit and Gross Margin (Step 1.3) cannot currently be calculated from dunnhumby alone** — the same limitation found for Olist. Discount-related fields (`retail_disc`, `coupon_disc`, `coupon_match_disc`) are confirmed distinct from cost and represent promotional discounting, not COGS.

**SQL Potential (ANALYTICAL POTENTIAL — not yet tested).** The reported ~1.4M+ transaction rows and the many-to-many coupon-to-product relationship would support non-trivial JOIN, GROUP BY, aggregation, filtering, and likely CTE/subquery exercises.

**Python Potential (ANALYTICAL POTENTIAL — not yet implemented).** Cleaning, EDA, and customer/product/campaign analysis are plausible given the documented structure; the prior research noted less Python-specific public reference material available than for Olist.

**Customer Behavior Potential.** A persistent `household_key` across the reported 1–2 year period, combined with demographic fields (age, income, family composition) for a subset of households, was described in the prior research as a genuine strength — potentially the richest customer-behavior structure of the three finalists. This has not been directly inspected.

**Marketing Potential.** Per the prior research, "marketing" in this dataset means **direct mail circulars, coupons, and in-store display/shelf placement** — explicitly not digital advertising. There is no impressions, ad-click, or digital campaign spend data. Concretely: CTR cannot be calculated (no impressions/clicks of any kind); CPA cannot be calculated (no spend/cost-per-campaign figure); ROAS cannot be calculated (no spend figure); ROI cannot be calculated in the classic sense (no campaign cost figure to use as an investment base). What the prior research identified as genuinely calculable instead: coupon redemption rate (coupons issued vs. redeemed), incremental basket/sales lift for campaign-exposed vs. non-exposed households, and display/mailer association with sales — legitimate direct-marketing-style metrics, but not the digital-ad KPIs (CTR/CPA/ROAS) originally scoped in Step 1.3.

**Portfolio Potential (ANALYTICAL POTENTIAL).** The "representation of real-world data" label is honest and defensible for portfolio use, and the connected campaign/coupon/transaction structure supports a genuine marketing-to-sales narrative. One noted mismatch: this is grocery-retail data, not e-commerce, which differs from this project's stated e-commerce business case and would need to be reconciled or explicitly reframed if selected.

**Limitations / Gaps.**
- Product cost/COGS: **CONFIRMED absent** — Gross Profit/Margin cannot currently be calculated.
- No genuine calendar dates in the original files — only `DAY`/`TRANS_TIME` integers; any real-looking dates seen elsewhere likely come from a third-party overlay and must not be presented as authentic without explicit labeling.
- Household-count/period figures are inconsistent between sources (2,500/2yr vs. 2,469/1yr, 1,469,307 rows) — **REQUIRES VALIDATION** before being cited as fact.
- No digital marketing data (impressions, clicks, ad spend, content type, publishing schedule) — "marketing" here is direct mail/coupon/in-store, not digital.
- License: the commonly-cited CC0 label applies to a third-party redistribution package, not confirmed to be dunnhumby's own official terms for the source-files download — **NOT CONFIRMED**, requires direct verification before public-portfolio use.
- None of the above has been directly re-validated by hands-on inspection (SQL/Python) by Kevin — everything here is source-based and **REQUIRES VALIDATION** before implementation.

**Overall Candidate Assessment.**
- PL-300 Learning Potential: MODERATE (strong relational/DAX practice; genuine Date Table/time-intelligence practice NOT CONFIRMED possible without a labeled synthetic calendar)
- Financial Analysis Potential: PARTIAL (cost/COGS confirmed absent)
- SQL Potential: STRONG (analytical potential)
- Python Potential: STRONG (analytical potential)
- Customer Behavior Potential: STRONG (analytical potential — persistent household key + demographics)
- Marketing Potential: MODERATE (real, connected promotional structure; not digital-ad KPIs as originally scoped)
- Portfolio Potential: MODERATE (credible "representation of real data" label; grocery-retail narrative mismatch with the project's e-commerce business case)
- Evidence Level: **DOCUMENTATION / SOURCE-BASED (including a source-code-level read of the raw file loader) — NOT YET DIRECTLY VALIDATED**

### Candidate Evaluation Summary

**This is not the final selection matrix.** It is a compact qualitative comparison of what is currently known about each candidate, intended to support Step 1.5 (Dataset Selection & Gap Analysis) — not to replace it. No weighted score is calculated here, and no candidate is declared a winner.

| Category | TheLook eCommerce | Olist Brazilian E-Commerce | dunnhumby — The Complete Journey |
|---|---|---|---|
| PL-300 Learning Potential | STRONG | STRONG | MODERATE |
| Financial Analysis Potential | STRONG | PARTIAL | PARTIAL |
| SQL Potential | STRONG | STRONG | STRONG |
| Python Potential | STRONG | STRONG | STRONG |
| Customer Analysis | MODERATE | MODERATE | STRONG |
| Behavioral / Funnel Analysis | MODERATE (event schema directly verified; funnel not yet built) | WEAK (no consumer session/browsing data confirmed) | WEAK (no pre-purchase browsing/funnel data confirmed) |
| Marketing Data | PARTIAL (traffic_source + session behavior; no campaigns/spend) | PARTIAL (real funnel exists but is B2B seller-acquisition, not consumer) | PARTIAL (real coupon/mailer/display structure; not digital ads) |
| Time Intelligence | STRONG (7+ year real-style timestamps, directly verified) | STRONG (genuine 2016–2018 calendar dates, source-based) | WEAK (original files have no calendar dates — DAY/TRANS_TIME integers only) |
| Portfolio Potential | STRONG | STRONG | MODERATE |
| Accessibility / Practicality | STRONG (free BigQuery public dataset, queryable directly, no download needed) | MODERATE (flat files; license terms not confirmed) | MODERATE (flat/R-package files; license terms not confirmed) |
| Major Known Gap | No campaign/ad-spend/impression data | Product cost/COGS not confirmed; marketing funnel is B2B, not consumer | Product cost/COGS confirmed absent; no genuine calendar dates in original files |
| Evidence Level | **DIRECT SQL VALIDATION** | **SOURCE-BASED / NOT YET DIRECTLY VALIDATED** | **SOURCE-BASED / NOT YET DIRECTLY VALIDATED** |

**Methodological reminder.** Consistent with this stage's methodology (Business Problem → Business Questions → Data Requirements → KPI Requirements → Dataset Search → Dataset Evaluation → Dataset Selection → Gap Analysis), this summary exists to answer *"what do we know about each candidate?"* — not *"which dataset are we choosing?"* Dataset evaluation is being driven by the requirements defined in Steps 1.2 and 1.3, rather than by picking a convenient dataset first and adapting the business case afterward. Explicit selection criteria, and potentially a weighted scoring matrix, belong to Step 1.5.

**Screening process note.** Step 1.4 used a funnel-style selection process rather than formally evaluating every dataset ever discovered:

```
Broad Candidate Search → Preliminary Screening → Finalist Evaluation → Dataset Selection (Step 1.5)
```

A first, broad exploratory search surfaced several public datasets, including AdventureWorks, the GA4 Sample Ecommerce / Google Merchandise Store dataset, the Coupon Purchase Prediction (Ponpare) dataset, and the Instacart Market Basket Analysis dataset. These were screened at a preliminary level against the project's priorities (PL-300 learning, financial/business analysis, SQL, Python, customer/product analysis, portfolio potential) and were not advanced to formal, in-depth evaluation — this was an intentional scope decision at the screening stage, not missing work. TheLook eCommerce, Olist, and dunnhumby were the three candidates that advanced to the finalist stage and received the full, formal Candidate Evaluation documented above. Not every discovered dataset requires full technical evaluation — only the finalists that plausibly fit the project's requirements do.

## Dataset Selection & Gap Analysis (Step 1.5)

This step formally selects the primary dataset for Project 01 and documents where it falls short of the requirements defined in Step 1.2 and the KPIs defined in Step 1.3, so those gaps are known and planned for rather than discovered later.

### Selection Philosophy

The final dataset is selected according to the actual objectives of this project — not according to which candidate is the most realistic overall. The project's priorities, in order, are: (1) PL-300/Power BI learning, (2) financial analysis, (3) SQL + Python practice, (4) portfolio strength, and (5) data/marketing realism. Marketing realism is intentionally weighted lowest because missing campaign-level marketing data can be supplemented later with clearly labeled synthetic data (see the Future Synthetic Marketing Layer and Original vs. Synthetic Data Principle sections below), whereas the other priorities depend on the core dataset itself. The core dataset must primarily support professional analytical learning across PL-300, financial analysis, SQL, and Python — realism is a secondary, not primary, selection criterion.

### Weighted Decision Matrix

| Criterion | Weight | TheLook Rating | TheLook Points | Olist Rating | Olist Points | dunnhumby Rating | dunnhumby Points |
|---|---|---|---|---|---|---|---|
| PL-300 / Power BI Learning | 30% | 5 | 30.0 | 5 | 30.0 | 3 | 18.0 |
| Financial Analysis | 25% | 5 | 25.0 | 3 | 15.0 | 3 | 15.0 |
| SQL + Python Potential | 20% | 5 | 20.0 | 5 | 20.0 | 5 | 20.0 |
| Portfolio Strength | 15% | 4 | 12.0 | 5 | 15.0 | 4 | 12.0 |
| Data / Marketing Realism | 10% | 2 | 4.0 | 5 | 10.0 | 4 | 8.0 |
| **Total** | **100%** | | **91.0** | | **90.0** | | **73.0** |

Formula used: `Weighted Points = (Rating / 5) × Weight`, summed across all five criteria. Ratings (1 = Very Weak, 5 = Very Strong) are those derived from the completed Step 1.4 evaluation.

**Arithmetic verification note.** This matrix was computed independently rather than copied from any pre-stated total. TheLook's independently computed total (91.0) matches. **Olist's independently computed total is 90.0, and dunnhumby's is 73.0** — both differ from figures referenced when this task was framed (86 and 71, respectively). Recomputing with the exact ratings and weights specified above (shown in full in the table) consistently produces 90.0 for Olist and 73.0 for dunnhumby; this is documented transparently rather than silently adjusted to match a different pre-stated number. **The ranking and selection conclusion are unaffected by this correction** — TheLook still ranks first under either set of totals (91 > 90 > 73, same ordering as 91 > 86 > 71) — but the margin between TheLook and Olist is narrower than a comparison against the originally-referenced figures would suggest (1.0 point, not 5.0 points), which is itself relevant context for how decisively TheLook "wins" (see below).

### Why TheLook Wins

TheLook does not win because it is the most realistic or the most polished dataset — it wins because it provides the best overall fit for this project's weighted objectives, and by a narrow margin over Olist (91.0 vs. 90.0), not a landslide. Its strongest advantages, drawn from the direct SQL validation performed in Step 1.4, are: a strong multi-table relational structure (7 verified tables); several years of temporal data (orders spanning 2019-01-13 to the inspection-time latest order, ~7+ years); direct transaction/order data; `sale_price` at the order-item level; product/inventory cost (`inventory_items.cost`, `products.cost`); customer data (`users`); product/category data (`products`); behavioral events (`events`); session sequencing (`session_id`/`sequence_number`); `traffic_source`; strong Power BI modeling potential; strong DAX/Time Intelligence potential given the multi-year date range; strong SQL potential (already demonstrated through the INFORMATION_SCHEMA introspection, JOINs, and aggregation used to validate it); strong Python/Pandas potential given the normalized multi-table structure; and sufficient complexity for a professional portfolio project.

TheLook's weaker marketing realism (rated 2/5) is acknowledged openly rather than hidden — it is the dataset's clearest weakness relative to the other two finalists, and is the direct reason a future synthetic marketing layer is being planned (see below).

**TheLook is synthetic.** This must be stated plainly and carried through the rest of the project: TheLook eCommerce is a generated, fictitious dataset, not a real company's transactional history, and it must never be presented as if it were real.

### Why Olist Was Not Selected

Olist remains a very strong alternative, and the matrix reflects that: it is essentially tied with TheLook (90.0 vs. 91.0). Its strengths include real/anonymized e-commerce history, a strong relational structure, strong SQL potential, strong Power BI potential (genuine 2016–2018 calendar dates), excellent portfolio credibility, and a realistic Brazilian e-commerce context.

Based on the completed Step 1.4 evaluation, its main limitation relative to this project's objectives is financial analysis. **Product cost/COGS was NOT CONFIRMED** to exist anywhere in the Olist dataset. Therefore, revenue-related analysis may be possible from Olist, but **Gross Profit and Gross Margin cannot be treated as natively supported without additional cost data.** Separately, the Olist Marketing Funnel dataset is primarily a B2B seller-acquisition pipeline, not a complete B2C consumer advertising funnel — it does not automatically solve this project's campaign-level marketing requirements.

Olist is not a bad dataset. It simply scores slightly lower than TheLook for this project's specific, weighted objectives.

### Why dunnhumby Was Not Selected

dunnhumby's strengths include substantial transaction history (~1.4M+ rows per prior research), household/customer behavior via a persistent `household_key`, product analysis, genuinely connected campaign/coupon/promotion relationships, strong SQL/Python potential, and useful marketing/promotional context (direct mail, coupons, in-store display).

However, the limitations already established in Step 1.4 carry forward directly into a lower score here: product cost/COGS is confirmed absent, which weakens direct profitability analysis; the original data structure uses `DAY`/`TRANS_TIME`-style integer temporal fields rather than a normal real calendar timeline, undercutting genuine Date Table/time-intelligence practice; the household-count/period figures reported for the dataset are inconsistent between sources and require validation; and its "marketing" information is promotional/coupon-oriented (direct mail, in-store display) rather than a complete modern digital-advertising attribution model (no impressions, clicks, or digital spend).

dunnhumby is not a poor dataset — its connected campaign/coupon/transaction structure is, if anything, the richest of the three finalists on that specific dimension. It is simply less aligned with this project's two highest-weighted objectives (PL-300 learning and financial analysis, together 55% of the total weight), where it scored moderate rather than strong.

### Formal Selection Statement

**PRIMARY CORE DATASET:** TheLook Ecommerce

**ROLE:** Core transactional, financial, product, customer, behavioral, and temporal dataset for Project 01.

**SOURCE:** Google BigQuery Public Dataset — `bigquery-public-data.thelook_ecommerce`

**DATA NATURE:** Synthetic e-commerce dataset. Not a real company's transactional history.

**SELECTION REASON:** Best weighted fit for PL-300 learning, financial analysis, SQL/Python practice, and end-to-end portfolio development, per the Weighted Decision Matrix above (91.0/100, ahead of Olist at 90.0/100 and dunnhumby at 73.0/100).

This is now the official dataset selection for the project.

### Gap Analysis — TheLook vs. Step 1.2 Data Requirements

Each requirement from Step 1.2 is classified as **AVAILABLE** (directly verified to exist), **DERIVABLE** (computable from available fields, but not itself a raw field), **MISSING** (confirmed not to exist in the verified schema), **NOT YET VALIDATED** (not yet inspected — not guessed in either direction), or **NOT REQUIRED**. Only what Step 1.4 directly verified, or what is already safely documented elsewhere in this project, is used as the basis for these classifications.

**SALES / TRANSACTIONS**

| Requirement (Step 1.2) | Classification | Notes |
|---|---|---|
| Order / Transaction ID | AVAILABLE | `order_items`/`orders` tables directly verified; `order_id` confirmed present in `order_items`. |
| Date and Time | AVAILABLE | `orders.created_at` directly verified via the MIN/MAX/COUNT temporal query. |
| Product ID | AVAILABLE | `order_items.product_id` confirmed present in the schema check. |
| Customer ID | AVAILABLE | `order_items.user_id` confirmed present; `users` table directly verified to exist. |
| Quantity | NOT YET VALIDATED | Whether each `order_items` row represents one unit or another convention has not been confirmed (see Open Validations). |
| Unit Selling Price | AVAILABLE | `order_items.sale_price` directly verified. |
| Unit Cost | AVAILABLE | `inventory_items.cost` and `products.cost` directly verified; which one is transaction-consistent still requires validation (see Open Validations). |
| Return / Cancellation information | NOT YET VALIDATED | Order status / return handling was not part of Kevin's direct SQL inspection in Step 1.4 and must be validated before final financial measures are implemented. |

**PRODUCTS**

| Requirement (Step 1.2) | Classification | Notes |
|---|---|---|
| Product ID | AVAILABLE | `products` table directly verified to exist; joins from `order_items.product_id`. |
| Product Name | NOT YET VALIDATED | Not part of the direct schema inspection performed so far. |
| Product Type | NOT YET VALIDATED | Same as above. |
| Category | NOT YET VALIDATED | Category hierarchy is an explicit open validation item (see Open Validations); not part of Kevin's own direct schema inspection. |
| Subcategory | NOT YET VALIDATED | Same as above. |
| Standard Price | NOT YET VALIDATED | Only `products.cost` was directly confirmed via the schema search; a distinct standard/retail price field on `products` itself was not directly confirmed (`order_items.sale_price` is the directly-verified transaction-level price). |
| Standard Cost | AVAILABLE | `products.cost` (FLOAT64) directly verified. |
| Seasonality classification | NOT YET VALIDATED | Not found in any schema check performed so far; not treated as confirmed absent without a direct check. |

**CUSTOMERS**

| Requirement (Step 1.2) | Classification | Notes |
|---|---|---|
| Customer ID | AVAILABLE | `users` table directly verified to exist; `order_items.user_id` confirmed. |
| Age / Age Group | NOT YET VALIDATED | Not part of the direct schema inspection performed so far. |
| Gender | NOT YET VALIDATED | Same as above. |
| Country / Region / City | NOT YET VALIDATED | Geographic fields are an explicit open validation item (see Open Validations); the `events` table was directly verified to include `city`/`state`, but the `users` table's own geographic fields were not directly inspected. |
| Customer Segment | NOT YET VALIDATED | No raw segment field has been confirmed; if implemented, this would more likely be a derived classification (e.g. RFM-based) than a raw column. |
| Signup / Registration Date | NOT YET VALIDATED | Not part of the direct schema inspection performed so far. |
| Purchase Frequency (derived) | DERIVABLE | Computable from `order_items`/`orders` (`user_id` + `created_at`) once the not-yet-validated fields above are confirmed. |
| Average Order Value / AOV (derived) | DERIVABLE | Computable from `sale_price` grouped by order/user. |
| Return Rate (derived) | NOT YET VALIDATED | Depends on the not-yet-validated return/cancellation status handling above. |
| Total Spend (derived) | DERIVABLE | Sum of `sale_price` by `user_id`. |
| Last Purchase Date / Recency (derived) | DERIVABLE | From `orders.created_at` by `user_id`. |
| Preferred Purchase Time (derived) | DERIVABLE | From `created_at` timestamp patterns, pending timezone/timestamp-handling validation (see Open Validations). |
| RFM (derived) | DERIVABLE | Composite of the above; pending the same underlying validations. |

**MARKETING**

| Requirement (Step 1.2) | Classification | Notes |
|---|---|---|
| traffic_source | AVAILABLE | Directly verified in `events` schema and observed in real inspected records (Email, Organic). |
| Session / behavioral data | AVAILABLE | `events` table directly verified (`session_id`, `sequence_number`, `event_type`, etc.). |
| Campaign ID | MISSING | Not part of the 7 verified TheLook tables; no campaign/ad-management table exists in the current dataset. |
| Campaign Name | MISSING | Same as above. |
| Campaign Budget (planned) | MISSING | Same as above. |
| Actual Ad Spend | MISSING | Same as above. |
| Impressions | MISSING | Same as above. |
| Clicks | MISSING | Same as above. |
| Creative / Content Type | MISSING | Same as above. |
| Target Segment (marketing-defined) | MISSING | Same as above. |
| Publication Date/Time (campaign-level) | MISSING | Same as above. |
| Attributed Campaign Revenue | MISSING | Same as above. |
| Campaign-specific Conversions | MISSING | Same as above. |
| CPA / ROAS / marketing ROI (as raw or attributable fields) | MISSING | Cannot be honestly calculated from TheLook alone; must not be invented. |

**BEHAVIOR / FUNNEL**

| Requirement | Classification | Notes |
|---|---|---|
| `user_id`, `session_id`, `sequence_number`, `created_at`, `traffic_source`, `uri`, `event_type` | AVAILABLE | All directly verified in the `events` schema (13 columns total). |
| Observed event types (home, department, product, cart, purchase, cancel) | AVAILABLE | Directly verified via the `event_type` grouping query. |
| A finalized behavioral funnel (Traffic Source → Session → Product Interaction → Cart → Purchase) | NOT YET VALIDATED | Schema supports it and session sequencing was directly observed, but no funnel, conversion rate, or denominator definition has been implemented or validated yet — this is analytical potential, not a completed capability. Not every session should be assumed to follow the same sequence. |

**TIME**

| Requirement | Classification | Notes |
|---|---|---|
| Order-level timestamps | AVAILABLE | `orders.created_at` directly verified; ~7+ years of coverage (2019-01-13 to ~2026-09-14 at inspection time). |
| Event-level timestamps | AVAILABLE | `events.created_at` directly verified as part of the events schema. |
| Genuine calendar-based Date Table construction | DERIVABLE | Real-style timestamps support it, pending Stage 3 implementation; timezone/timestamp handling itself is an open validation item (see Open Validations). |
| Update/refresh cadence, permanent row counts | NOT YET VALIDATED | Row counts documented in Step 1.4 are explicitly inspection-date snapshots, not permanent facts. |

**FINANCIAL**

| Requirement | Classification | Notes |
|---|---|---|
| Line-level selling price | AVAILABLE | `order_items.sale_price` directly verified. |
| Line-level/product-level cost | AVAILABLE | `inventory_items.cost` and `products.cost` directly verified; which cost source is transaction-consistent requires validation (see Open Validations). |
| Revenue (derived) | DERIVABLE | From `sale_price`. |
| COGS (derived) | DERIVABLE | From the cost fields, pending the cost-source validation above. |
| Gross Profit (derived) | DERIVABLE | Pending final business logic for returns/cancellations and which cost field to use. |
| Gross Margin % (derived) | DERIVABLE | Same dependency as Gross Profit. |
| Operating expenses, taxes, overhead (for Net Profit) | MISSING | Not part of this dataset — Net Profit is out of scope for TheLook alone (Gross Profit ≠ Net Profit, as already established in Step 1.4). |

**DATA GOVERNANCE / PROVENANCE**

| Requirement | Classification | Notes |
|---|---|---|
| Dataset origin documented | AVAILABLE | Google BigQuery public dataset, access directly confirmed. |
| Synthetic-data status documented | AVAILABLE | Confirmed and explicitly documented (Step 1.4). |
| Privacy/PII fields identified | AVAILABLE | `ip_address`, `postal_code` in `events` directly verified and flagged for data minimization (Step 1.4). |
| Licensing / redistribution terms for public-repo use | NOT YET VALIDATED | Query access confirmed; redistribution/licensing terms have not been independently reviewed (see Licensing / Redistribution Gap below). |

### KPI Feasibility Assessment (vs. Step 1.3)

Each candidate KPI is classified as **SUPPORTED / DERIVABLE**, **REQUIRES BUSINESS LOGIC VALIDATION**, **REQUIRES SYNTHETIC / SUPPLEMENTARY DATA**, or **NOT CURRENTLY SUPPORTED**, based conservatively on the Gap Analysis above.

| KPI | Feasibility | Notes |
|---|---|---|
| Revenue | SUPPORTED / DERIVABLE | From `sale_price`. |
| Revenue Growth % | SUPPORTED / DERIVABLE | Assuming a proper Date Table (Stage 3). |
| MoM | SUPPORTED / DERIVABLE | Assuming a proper Date Table later. |
| YoY | SUPPORTED / DERIVABLE | Assuming a proper Date Table later. |
| YTD | SUPPORTED / DERIVABLE | Assuming a proper Date Table later. |
| Cost / COGS | REQUIRES BUSINESS LOGIC VALIDATION | Two candidate cost fields exist (`inventory_items.cost`, `products.cost`); which is transaction-consistent must be validated first. |
| Gross Profit | REQUIRES BUSINESS LOGIC VALIDATION | Requires final business logic for returns/cancellations and cost-field choice. |
| Gross Margin % | REQUIRES BUSINESS LOGIC VALIDATION | Same dependency as Gross Profit. |
| Gross Profit Growth % | REQUIRES BUSINESS LOGIC VALIDATION | Depends on Gross Profit being finalized first, plus a Date Table. |
| Purchase Frequency | SUPPORTED / DERIVABLE | From `orders`/`order_items` by `user_id`. |
| AOV | SUPPORTED / DERIVABLE | From `sale_price` grouped by order. |
| Return Rate | REQUIRES BUSINESS LOGIC VALIDATION | Depends on the not-yet-validated return/cancellation/order-status handling; denominator ambiguity already flagged in Step 1.3. |
| Total Spend | SUPPORTED / DERIVABLE | Sum of `sale_price` by `user_id`. |
| Recency | SUPPORTED / DERIVABLE | From `orders.created_at` by `user_id`. |
| RFM | SUPPORTED / DERIVABLE | Composite; pending the same underlying field validations as the components above. |
| CTR | REQUIRES SUPPLEMENTARY MARKETING DATA | No impressions/clicks fields exist in TheLook. |
| Conversion Rate | REQUIRES BUSINESS LOGIC VALIDATION | Potentially derivable from behavioral events (`session_id`/`event_type`), but the denominator/funnel definition requires validation; not to be conflated with a marketing-attributed conversion rate, which would require campaign data. |
| Ad Spend | REQUIRES SUPPLEMENTARY MARKETING DATA | Not present in TheLook. |
| CPA | REQUIRES SUPPLEMENTARY MARKETING DATA | Not present in TheLook. |
| Attributed Revenue | REQUIRES SUPPLEMENTARY MARKETING DATA | No campaign/attribution structure exists in TheLook. |
| ROAS | REQUIRES SUPPLEMENTARY MARKETING DATA | Not present in TheLook. |
| ROI | REQUIRES SUPPLEMENTARY MARKETING DATA | Also requires attributable profit/cost logic once supplementary data exists; must not be conflated with ROAS. |

### Important Open Validations

The following technical items should be validated before or during Stage 2, before final KPI/business logic is implemented. None of these are resolved now — they are recorded as a validation checklist for upcoming data-preparation and modeling work:

- Exact `orders` schema (full column list beyond `created_at`).
- Exact `products` schema (full column list beyond `cost`).
- Exact `users` schema (full column list, geography, demographics).
- Order status values and their meanings.
- Return/cancellation semantics.
- Quantity representation — whether each `order_items` row represents one unit or another convention.
- The difference between `products.cost` and `inventory_items.cost`, and which should be used for transaction-consistent profitability.
- Null/missing-value patterns across key tables.
- Duplicate-row behavior.
- Category hierarchy structure in `products`.
- Customer attributes (age, gender, geography, segment) in `users`.
- Geographic fields (in `users` vs. in `events`).
- Timestamp/timezone handling.
- Relationship cardinalities (e.g. orders-to-order_items, inventory_items-to-order_items).
- Referential integrity (orphaned foreign keys, nulls in join keys).

### Future Synthetic Marketing Layer (Design Direction Only)

If needed in a later stage, Project 01 may create a clearly labeled supplementary dataset such as `synthetic_marketing_campaigns` to fill the marketing gaps identified above. Potential future fields could include: `campaign_id`, `campaign_name`, `product_id`/category, `target_segment`, `channel`, `content_type`, `campaign_start`, `campaign_end`, `publication_datetime`, `planned_budget`, `actual_ad_spend`, `impressions`, `clicks`, `conversions`, `attributed_revenue`.

**This is only a future design direction.** No schema is finalized here, no table has been created, no CSV files have been generated, and no values have been produced. The exact design must depend on findings from the real/core analytical work still to come.

### Original vs. Synthetic Data Principle

This project's data will maintain two clearly separated origins going forward:

**ORIGINAL / CORE DATA — TheLook eCommerce.** Purpose: transactions, products, customers, cost, behavior, time, traffic sources.

**FUTURE SYNTHETIC SUPPLEMENT — Marketing campaign layer (not yet created).** Purpose: campaign economics, ad spend, impressions, clicks, content type, campaign attribution.

These two data origins must remain clearly separated, consistent with the `data/raw/ | synthetic/ | processed/` convention already registered in `README.md`. Synthetic data must never be presented as part of the original TheLook dataset.

### Licensing / Redistribution Gap

Access to TheLook through Google BigQuery has been confirmed (Step 1.4). However, this does not automatically mean that committing a full raw copy of the dataset into a public GitHub repository is appropriate — redistribution/licensing terms for TheLook have not been independently verified. Until clarified, the safer portfolio strategy is: document the public dataset source; document reproducible queries/extraction steps; and avoid committing unnecessary full raw copies publicly. No license is claimed here that has not been verified.

### Privacy / Data Minimization (Carried Forward)

The data-governance decision from Step 1.4 carries forward unchanged: the `events` table contains `ip_address` and `postal_code`, and even though TheLook is synthetic, these fields are not necessary for this project's core analytical objectives. The project should continue to practice data minimization and exclude fields that do not support the business question from downstream analytical datasets.

## Assumptions / Current Limitations

- The business, its products, customers, and history are **entirely fictional**, constructed for learning and portfolio purposes. No real company is being described or represented.
- TheLook eCommerce has been formally selected as the project's Primary Core Dataset (Step 1.5). It is synthetic and does not cover campaign-level marketing data — a future, clearly-labeled synthetic marketing supplement may be added later (see Step 1.5's Future Synthetic Marketing Layer section), but has not been created yet.
- Any synthetic data introduced later must be clearly labeled as synthetic and kept separate from real/public data (see the data organization convention in `README.md`) — it must never be presented as if it were real.
- No figures, metrics, or results appear in this document. Everything above is a framing of the problem, not an analysis of any data.
- The Decision Question above is provisional and may be adjusted once real data constraints are known.

## Concepts Learned

- **Business Understanding** as a distinct, deliberate first step of a data project — defining the problem and the questions *before* touching data, following a CRISP-DM-style approach rather than jumping straight to analysis.
- The distinction between a **business problem statement** (why this project exists) and a **decision question** (the specific, answerable question the analysis targets).
- The importance of separating **descriptive/diagnostic** analysis ("what happened, where's the opportunity") from **predictive** analysis ("what will happen if we act") early, so the project doesn't overstate what it can conclude from historical data alone.
- Framing a marketing funnel conceptually (Impression → Click → Visit → Add to Cart → Purchase → Revenue → Profit) before any metric is calculated, to know in advance what the data will eventually need to support.
- **Data Requirements** as a distinct step: documenting what information a business question needs *before* looking for a dataset.
- The difference between **raw/source fields** (e.g. Unit Selling Price, Unit Cost) and **derived metrics** (e.g. Revenue, Gross Margin, CTR, ROAS) calculated from them.
- The difference between an **entity attribute** (e.g. Product Category — relatively fixed) and an **analytical insight** (e.g. best-selling hour — discovered from transactions, not a fixed property).
- **Data minimization / avoiding unnecessary PII** — deliberately excluding personal fields (email, phone, exact address) that aren't needed for the stated analytical objective, rather than collecting everything "just in case."
- The distinction between **planned/expected** marketing performance and **actual observed** performance, and why forecasts must not be presented as real results.
- A **requirements-first approach**: defining data and KPI requirements before searching for or selecting a dataset, so business questions shape the data search rather than the other way around.
- **KPI definition discipline**: a KPI needs an explicit business meaning, formula, numerator/denominator, time period, granularity, filters, data source, and assumptions before it can be implemented.
- **Comparison baselines**: "growth" is meaningless without an explicit baseline (YoY, MoM, YTD vs. prior-year YTD, Actual vs. Target).
- **Revenue vs. Profit vs. Margin**: Revenue and Gross Profit are monetary amounts; Gross Margin is a percentage — and Sales Growth ≠ Profitable Growth.
- **YoY / MoM / YTD** as time-intelligence comparison concepts that will later connect to Date Tables and DAX time intelligence (Stage 3+), not implemented yet.
- Customer behavior metrics (Purchase Frequency, AOV, Return Rate, Tenure, Recency) and the **RFM** (Recency/Frequency/Monetary) concept as a potential, non-mandatory segmentation approach.
- The **marketing funnel** (Impression → Click → Visit → Purchase → Revenue → Profit) and that different KPIs (CTR, Conversion Rate, CPA, ROAS, ROI) measure different funnel stages.
- **ROAS vs. Profit**: high ROAS does not mean high profit, since ROAS is based on attributed revenue, not on cost/margin.
- The importance of explicit metric definitions and denominators, especially for ambiguous metrics (Conversion Rate, Return Rate, ROI, Customer Tenure).
- **Multi-signal decision making**: evaluating products/campaigns using combinations of metrics rather than a single metric like "top products by sales."
- Distinguishing **directly verified** findings (confirmed by an executed query) from **future possibility / analytical potential** (schema supports it, but nothing has been built yet) as a documentation discipline, so future capabilities are never presented as already implemented.
- Using `INFORMATION_SCHEMA.TABLES` and `INFORMATION_SCHEMA.COLUMNS` to verify a dataset's actual structure before relying on assumptions about it — and correcting an assumption (that `order_items` contained a `cost` column) once the schema disproved it.
- Treating row counts and "latest timestamp" observations from a live/regenerated public dataset as inspection-date snapshots, not permanent facts.
- The difference between a preliminary schema-level financial calculation (`sale_price − cost`) and a finished KPI implementation — and reaffirming that **Gross Profit ≠ Net Profit** when no operating expenses, taxes, or overhead are represented in the data.
- Extending the data-minimization principle (established for customer PII in Step 1.2) to behavioral/event data as well (e.g. `ip_address`, `postal_code` in an events table).
- **Dataset evaluation vs. dataset selection** as distinct steps: evaluating multiple candidates against the fixed requirements from Steps 1.2/1.3 before choosing one, rather than picking a convenient dataset first and adapting the business case afterward.
- **Evidence-level discipline across sources**: explicitly distinguishing directly-verified findings (hands-on SQL inspection) from documentation/source-based findings (prior research, official pages, secondary write-ups) from analytical potential (schema could support it, not yet built), so unverified claims are never presented with the same confidence as hands-on validation.
- Financial/profitability analysis requires **confirmed cost data**, not just revenue/price fields — a dataset can look financially rich on the revenue side while remaining unable to support Gross Profit or Gross Margin at all.
- **Marketing-data richness should be weighted according to the project's actual stated priorities**, not treated as a dominant selection criterion by default — a dataset can be an excellent overall candidate while being only partially suited to the original consumer marketing funnel.
- A downstream or third-party redistribution of a dataset (e.g. a derived calendar overlay, a differently-stated license) can differ from the original source's own data and terms — worth verifying directly rather than trusting secondary packaging.
- **Weighted decision matrices** as a structured way to translate stated project priorities into an auditable dataset-selection score, rather than an intuitive or subjective choice.
- **Independently verifying arithmetic before trusting a stated result** — treating even a pre-stated "expected" total as something to check, not copy; a close final ranking can still hold even when a specific total was inaccurate.
- **Gap Analysis** as a distinct step from dataset selection: classifying each documented requirement against the selected dataset as AVAILABLE / DERIVABLE / MISSING / NOT YET VALIDATED / NOT REQUIRED, rather than assuming a selected dataset satisfies everything defined earlier.
- **KPI feasibility assessment** as a distinct exercise from KPI definition (Step 1.3): a well-defined KPI can still be currently unsupported, dependent on business-logic validation, or dependent on supplementary data.
- Distinguishing capability that is **DERIVABLE** (the raw fields exist) from capability that **REQUIRES BUSINESS LOGIC VALIDATION** (the raw fields exist, but how to interpret/combine them isn't settled) from capability that **REQUIRES SUPPLEMENTARY DATA** (the fields don't exist in the core dataset at all).
- Documenting dataset limitations and open validations as part of professional analytical work, rather than something to resolve silently or hide before moving to implementation.
- Keeping **original and synthetic data provenance** architecturally separate from the moment of dataset selection onward — before any synthetic data has even been created.

## Skills Demonstrated

- Business Understanding / requirements framing for a data analytics project.
- Translating a vague business concern ("sales aren't growing enough") into a specific, prioritization-oriented decision question.
- Structuring an analytical framework (What / Who / Where-How-When / What happened) that maps directly to a future data model and marketing funnel.
- Requirements gathering across data (Sales/Products/Customers/Marketing) and KPI domains, with explicit formulas, ambiguous-denominator flags, and governance principles defined before any dataset was chosen.
- Dataset research and comparative evaluation of multiple public candidates against fixed, pre-defined requirements, using a documented two-stage screening process.
- Hands-on technical dataset validation via SQL: `INFORMATION_SCHEMA` introspection, multi-table JOINs, aggregate/grouped queries, and ordered/sequenced queries executed directly against Google BigQuery.
- Evidence-based correction of an initial assumption (the `order_items.cost` assumption) once schema inspection disproved it, with the correction documented transparently rather than silently fixed.
- Weighted, criteria-based decision-making: building a weighted decision matrix and independently verifying its arithmetic — including catching and transparently correcting a discrepancy in previously-referenced totals — rather than selecting a dataset by intuition or accepting a stated result unchecked.
- Structured Gap Analysis and KPI Feasibility Assessment against a selected dataset, using a controlled classification vocabulary (AVAILABLE / DERIVABLE / MISSING / NOT YET VALIDATED; SUPPORTED-DERIVABLE / REQUIRES BUSINESS LOGIC VALIDATION / REQUIRES SUPPLEMENTARY DATA).
- Data provenance and governance discipline: separating original from (not-yet-created) synthetic data, documenting licensing/redistribution uncertainty rather than assuming it away, and applying data minimization to unnecessary PII/behavioral fields.
- Professional project documentation discipline: distinguishing assumptions from facts, explicitly marking what is *not* known or decided yet, and auditing a completed stage end-to-end for internal consistency before closing it.

## Stage 1 Validation

This section is the final audit confirming that Stage 1 successfully established each of the following before being closed:

- **Business problem** — a fictional but clearly framed business problem (stagnant sales growth, a limited marketing budget) was defined in Business Context and the Business Problem Statement (Step 1.1).
- **Stakeholder context** — a stakeholder need (a small, evidence-backed set of prioritized opportunities, not a full data dump) was documented (Step 1.1).
- **Business questions** — an explicit list of initial and extended business questions was documented, including the time dimension and marketing-activity dimension (Step 1.1).
- **Data requirements** — candidate fields across Sales, Products, Customers, and Marketing/Campaigns were documented, with raw fields distinguished from derived metrics (Step 1.2).
- **KPI requirements** — candidate KPIs across Sales & Growth, Profitability, Customer Value/Behavior, and Marketing Performance were defined conceptually, with formulas, ambiguous-denominator flags, and governance principles (Step 1.3).
- **Candidate dataset search** — a broad, two-pass research process identified multiple public candidates (Step 1.4).
- **Candidate screening** — four candidates (AdventureWorks, GA4/Google Merchandise Store, Ponpare, Instacart) were screened out at a preliminary level as an intentional scope decision, not abandoned work (Step 1.4).
- **Finalist evaluation** — three finalists (TheLook, Olist, dunnhumby) received full, evidence-labeled evaluations, with TheLook technically validated via direct SQL inspection and Olist/dunnhumby evaluated from documentation/source-based research (Step 1.4).
- **Weighted dataset selection** — a weighted decision matrix was built and independently verified twice (Step 1.5, and again in this Step 1.6 audit), including transparently documenting and correcting an arithmetic discrepancy in previously-referenced totals without changing the resulting ranking (Step 1.5).
- **Selected Primary Core Dataset** — TheLook eCommerce, `bigquery-public-data.thelook_ecommerce`, explicitly documented as synthetic (Step 1.5).
- **Gap analysis** — TheLook was compared against the Step 1.2 requirements across 8 categories, with each requirement classified rather than assumed available (Step 1.5).
- **KPI feasibility** — every KPI defined in Step 1.3 was assessed for current feasibility against TheLook (Step 1.5).
- **Known limitations** — TheLook's synthetic nature, missing campaign-level marketing data, and open schema questions were documented explicitly, not hidden (Step 1.4, Step 1.5).
- **Open technical validations** — a concrete list of items to resolve in Stage 2 was recorded (Step 1.5).
- **Provenance principles** — the Original vs. Synthetic Data Principle was documented before any synthetic data was created (Step 1.5).
- **Data-governance considerations** — data minimization (excluding `ip_address`/`postal_code` and other unnecessary PII) and licensing/redistribution caution were documented and carried through consistently (Step 1.2, Step 1.4, Step 1.5).

**Stage 1 outcome.** Stage 1 established a defensible analytical foundation for Project 01: a documented business problem, structured data and KPI requirements defined before any dataset was chosen, a transparent and independently-verified dataset selection process, and an honest account of what the selected dataset can and cannot yet support. TheLook eCommerce was selected as the Primary Core Dataset based on a weighted decision framework aligned with the project's PL-300, financial-analysis, SQL/Python, and portfolio objectives — winning by a narrow, honestly-reported margin over Olist (91.0 vs. 90.0), not by an overwhelming advantage. No data has been analyzed, no model has been built, and no dashboard, DAX measure, or production SQL exists yet — Stage 1 is a foundation, not an analysis.

## Stage 2 Handoff

Stage 2 — **Data Preparation** — begins with validating and profiling the selected TheLook data before any transformation is attempted. Building on the Important Open Validations recorded in Step 1.5, Stage 2 should investigate items such as: exact table schemas (`orders`, `products`, `users`, and the remaining tables beyond what was directly queried in Step 1.4); null and missing-value patterns; duplicate-row behavior; data types; the `order_items` quantity convention; order status values and return/cancellation handling; the distinction between `products.cost` and `inventory_items.cost` and which is transaction-consistent for profitability; category and customer attribute fields; timestamp/timezone handling; relationship cardinalities; and referential integrity across the seven verified tables.

Once these are profiled and understood, Stage 2 proceeds into Power Query / data-preparation work. **None of this is solved, designed, or implemented now** — no Stage 2 files have been created, no Star Schema has been designed, and no Power Query, DAX, Python, or production SQL work has begun. Stage 1 closes as a documentation and decision-making stage only.

## Stage Log

- **Step 1.1 — Business Understanding**
  **Status: COMPLETED**
  Defined the fictional business context, the business problem statement, the provisional decision question, the analytical framework (What/Who/Where-How-When/What happened), and the expected shape of the decision output — including an explicit boundary between descriptive/diagnostic analysis (in scope now) and predictive analysis (out of scope for now). No data has been sourced, downloaded, or analyzed at this step.

- **Step 1.2 — Data Requirements**
  **Status: COMPLETED**
  Documented candidate data requirements across four domains (Sales, Products, Customers, Marketing/Campaigns) needed to answer the Step 1.1 business questions. Distinguished raw/source fields from derived metrics, product attributes from analytical insights, and planned from actual marketing performance. Deliberately excluded unnecessary PII (email, phone, exact address) as a data-minimization decision. Noted that candidate entities (Sales, Products, Customers, Marketing/Campaigns) are emerging, without designing a Star Schema or relationships — that belongs to Stage 3. No dataset was searched for or selected at this step, and no KPI formulas were defined.

- **Step 1.3 — KPI Requirements**
  **Status: COMPLETED**
  Documented candidate KPIs across four areas (Sales & Growth, Profitability, Customer Value/Behavior, Marketing Performance), including conceptual formulas, explicit flags on ambiguous denominators (Return Rate, Conversion Rate, CPA, ROI), the distinction between Revenue/Profit (monetary) and Margin (percentage), the principle that Sales Growth ≠ Profitable Growth, the marketing funnel, and that ROAS ≠ Profit. Registered the KPI governance principle (every KPI needs an explicit definition before implementation) and deferred the Core vs. Secondary KPI classification until after dataset selection. No dashboard KPI set was finalized, no Star Schema was designed, and no DAX was implemented at this step.

- **Step 1.4 — Dataset Search & Evaluation**
  **Status: COMPLETED**
  Dataset search and evaluation used a funnel-style, two-stage screening process: a broad exploratory search first surfaced several public candidates (including AdventureWorks, GA4 Sample Ecommerce / Google Merchandise Store, Coupon Purchase Prediction / Ponpare, and Instacart Market Basket Analysis), which were screened at a preliminary level against the project's priorities and intentionally not advanced to formal evaluation. Three finalists — TheLook eCommerce, Olist Brazilian E-Commerce, and dunnhumby — The Complete Journey — best matched the project's priorities (PL-300 learning, financial/business analysis, SQL, Python, customer/product analysis, portfolio potential) and received full, formal evaluations in this document: TheLook (technically validated through direct SQL inspection in BigQuery — table structure, temporal coverage, financial-analysis capability including a correction to an initial assumption about where `cost` lives in the schema, event/behavioral data, and session sequencing), Olist (documented from prior source-based research; evidence level: documentation/source-based, not yet directly validated), and dunnhumby (documented from prior source-based research, including a source-code-level read of the original transaction file; evidence level: documentation/source-based, not yet directly validated). A qualitative Candidate Evaluation Summary comparing all three finalists across PL-300, financial, SQL, Python, customer, behavioral, marketing, time-intelligence, portfolio, and accessibility dimensions was also added, with each candidate's evidence level explicitly labeled. The screening-out of the four non-finalist candidates was an intentional scope decision, not incomplete work. **No dataset has been selected — that decision belongs entirely to Step 1.5.**

- **Step 1.5 — Dataset Selection & Gap Analysis**
  **Status: COMPLETED**
  A weighted decision matrix (PL-300/Power BI 30%, Financial Analysis 25%, SQL+Python 20%, Portfolio Strength 15%, Data/Marketing Realism 10%) was applied to the three Step 1.4 finalists and independently verified: TheLook eCommerce scored 91.0/100, Olist scored 90.0/100, and dunnhumby scored 73.0/100 (the Olist and dunnhumby totals were independently recomputed and documented as differing from figures referenced when this task was framed — 86 and 71 — without changing the resulting ranking). **TheLook eCommerce was formally selected as the Primary Core Dataset for Project 01**, as the best weighted fit for this project's objectives — not as the most realistic dataset overall — with its synthetic nature stated explicitly. A structured Gap Analysis compared TheLook against the Step 1.2 data requirements across eight categories (Sales/Transactions, Products, Customers, Marketing, Behavior/Funnel, Time, Financial, Data Governance/Provenance), classifying each requirement as AVAILABLE, DERIVABLE, MISSING, or NOT YET VALIDATED. A KPI Feasibility Assessment was documented against all KPIs defined in Step 1.3. A list of Important Open Validations (schema details, quantity representation, cost-field choice, return/cancellation semantics, and others) was recorded for Stage 2. A future-only synthetic marketing layer design direction and the Original vs. Synthetic Data Principle were documented without creating any synthetic data, table, or file. Licensing/redistribution and privacy/data-minimization notes were carried forward from Step 1.4. No Star Schema, Power Query, DAX, Python analysis, or production SQL was implemented, and no data was downloaded.

- **Step 1.6 — Stage Validation & Documentation**
  **Status: COMPLETED**
  Performed a final documentation and consistency audit of the complete Stage 1 document, end to end. Verified the methodology sequence (Business Problem → Business Questions → Data Requirements → KPI Requirements → Dataset Search → Preliminary Screening → Finalist Evaluation → Weighted Dataset Selection → Gap Analysis → Stage Validation) is coherent. Refined the central Decision Question's wording — it previously referenced "historical marketing performance" as a basis for prioritization, which is not available in the selected TheLook dataset (confirmed MISSING in the Step 1.5 Gap Analysis) — replacing it with traffic-source/engagement behavior (which TheLook does support) and adding an explicit refinement note preserving the project's original long-term intent for campaign-level marketing data via the feedback loop and future synthetic supplement. Cross-checked Step 1.2 Data Requirements against the Step 1.5 Gap Analysis and Step 1.3 KPI Requirements against the Step 1.5 KPI Feasibility Assessment; found both internally consistent, with no requirement or KPI presented as available/supported beyond what Step 1.4/1.5 established. Re-independently-verified the weighted decision matrix a second time (TheLook 91.0, Olist 90.0, dunnhumby 73.0) and confirmed no stale reference to the earlier 86/71 figures exists outside the two places that transparently document and explain the correction. Confirmed evidence levels (TheLook: directly verified; Olist/dunnhumby: documentation/source-based) were not upgraded anywhere. Confirmed Revenue ≠ Profit, Gross Profit ≠ Net Profit, and ROAS ≠ ROI are preserved throughout, and that CTR/CPA/ROAS/ROI remain undefined-by-implementation (no invented values). Confirmed synthetic marketing data remains undesigned and uncreated, and that the Original vs. Synthetic Data Principle, licensing/redistribution caution, and data-minimization principle all carry through consistently. Added a `## Stage 1 Validation` section confirming all required elements were established, an expanded `## Skills Demonstrated` section reflecting the full skill set exercised across Stage 1, and a `## Stage 2 Handoff` section pointing to Stage 2 (Data Preparation) without solving, designing, or implementing any of it now.

**Stage 1 Status: COMPLETED** — Business Problem, Data Requirements, KPI Requirements, Dataset Search, Evaluation, Selection, Gap Analysis, and Stage Validation are all complete. Stage 2 (Data Preparation) has not begun.

**Methodology note:** Stage 1 deliberately follows this sequence: Business Problem → Business Questions → Data Requirements → KPI Requirements → Dataset Search → Dataset Evaluation → Dataset Selection → Gap Analysis → Stage Validation. Data requirements and KPI requirements are defined *before* searching for a dataset, precisely so that business questions are not later reshaped to fit whatever columns a convenient dataset happens to have.
