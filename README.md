# N8N Automation Projects

A learning and portfolio repository for automation, APIs, and AI agent workflows built with [n8n](https://n8n.io/).

## Purpose

This repository documents a hands-on journey into workflow automation — starting with guided learning exercises and growing into original, professional-grade automation projects for a Data/AI portfolio.

It serves two goals:

1. **Learning log** — a structured place to practice n8n, API integrations, and AI agent design.
2. **Portfolio** — a curated showcase of polished, well-documented automation projects that demonstrate real-world automation and AI engineering skills.

The repository is expected to evolve over time: early folders will contain simple tutorial-style workflows, while later additions will reflect increasingly independent, production-quality automation projects.

## Technologies

- **[n8n](https://n8n.io/)** — low-code workflow automation platform (core tool of this repository)
- **APIs** — REST/webhook integrations with third-party services
- **AI agents / LLMs** — AI-powered nodes and agent-based automation workflows
- **JSON** — n8n workflows are exported and version-controlled as JSON files
- Additional tools and integrations will be added as the projects grow in complexity

## Folder Structure

```
.
├── workflows/               # n8n workflow JSON exports
│   ├── 01-learning/         # Tutorial and practice workflows
│   ├── 02-personal-projects/# Independent, self-directed automations
│   └── 03-portfolio-projects/ # Polished, portfolio-ready automations
├── docs/                    # Notes, guides, and project documentation
│   ├── stage-01-business-case.md
│   └── stage-02-data-preparation.md
├── sql/                     # SQL scripts (added in Stage 2 — see below)
├── templates/                # Reusable workflow templates and boilerplates
├── .gitignore
└── README.md
```

### `workflows/`

This is where exported n8n workflow JSON files live, organized by maturity:

- **`01-learning/`** — workflows built while following tutorials or experimenting with new nodes/concepts.
- **`02-personal-projects/`** — self-directed automations built to solve real, personal problems.
- **`03-portfolio-projects/`** — finished, documented, portfolio-ready automation projects.

### `docs/`

Reference notes, setup guides, architecture explanations, and any written documentation that supports the workflows in this repository. As of Stage 2, this includes one documentation/log file per stage (see "Development Approach" below): `stage-01-business-case.md` and `stage-02-data-preparation.md`.

### `sql/`

Added in Stage 2. Contains the project's SQL scripts — currently BigQuery SQL written against the `bigquery-public-data.thelook_ecommerce` public dataset, used for data-quality validation and analysis (Project 01, Stage 2 — Data Preparation & Analytical Validation):

- `01_data_quality_validation.sql` — referential integrity, order-item-count consistency, status/date consistency, chronological validation.
- `02_financial_validation.sql` — sale price and inventory cost validation, financial recognition rules, financial baseline.
- `03_monthly_performance_analysis.sql` — monthly financial aggregation, MoM/YoY growth, profitability trend.
- `04_category_performance_analysis.sql` — category financial/operational performance, Min-Max normalization, multi-scenario sensitivity analysis, and robustness-based category classification.

See `docs/stage-02-data-preparation.md` for the full analytical documentation and findings behind these queries.

### `templates/`

Reusable workflow skeletons, starter nodes, and boilerplate patterns that can be copied into new projects.

## Planned Architecture (Future Stages)

The structure above (Folder Structure) reflects the **current state of the repository**, including what Stage 2 has added so far (`sql/`, and the `docs/stage-01-*.md` / `docs/stage-02-*.md` files). As the project grows beyond n8n into a broader data/BI/automation/AI portfolio, the following will still be added — **one folder at a time, only when the stage that needs it begins**, not in advance:

```
data/
├── raw/          # Original public dataset — never modified directly
├── synthetic/    # Data created to fill gaps in the public dataset;
│                 # always clearly documented as synthetic, never
│                 # presented as real
└── processed/    # Cleaned/transformed output derived from raw + synthetic

notebooks/        # Jupyter notebooks (Python analysis)
powerbi/          # Power BI files and related assets
content/          # AI-generated content artifacts (later stages)
results/          # Outputs, findings, and performance metrics
```

None of these remaining folders exist in the repository yet.

## Development Approach — Stage-Based Workflow

This project is built in numbered stages (Stage 0 through Stage 10), each producing working output, documentation, and a Git commit before moving to the next stage — stages are not skipped even when a tool could technically do the work automatically.

Starting with Stage 1, each stage gets a single file at `docs/stage-XX-short-name.md` that doubles as professional project documentation and a stage log. Its sections:

- Objective
- Business / Technical Context
- Work Completed
- Decisions Made
- Concepts Learned
- Problems Encountered
- Solutions
- PL-300 Connection (when applicable)
- Skills Demonstrated
- Portfolio Evidence
- Stage Validation
- Stage Log

Sections are filled in progressively as each stage advances rather than all at once. Two such files exist so far: `docs/stage-01-business-case.md` (Stage 1, complete) and `docs/stage-02-data-preparation.md` (Stage 2, complete).

## ⚠️ Security: Credentials and Secrets

**Credentials, API keys, tokens, and secrets must never be committed to this repository.**

n8n workflow exports can sometimes include credential references or sensitive configuration — always review a workflow's JSON before committing it. This repository's `.gitignore` is configured to help prevent common cases (`.env` files, credential files, tokens, local n8n database/config files, logs, etc.), and now also covers Python/Jupyter artifacts and local SQL Server backup files in preparation for upcoming stages — but it is not a substitute for manual review.

If a secret is ever accidentally committed, treat it as compromised: revoke/rotate it immediately, in addition to removing it from the repository history.

## Pending Decisions

- **License** — this is a public repository, so a license (e.g. MIT) is likely appropriate, but the choice is deferred until closer to Stage 10. We want to decide deliberately what a license should permit regarding the code and n8n workflows in this portfolio, rather than defaulting to one now.

## Status

✅ Stage 0 (Environment Setup) is complete. ✅ Stage 1 (Business Case & Data Acquisition) is complete — the primary dataset (TheLook eCommerce) was selected through a documented evaluation and gap analysis. ✅ Stage 2 (Data Preparation & Analytical Validation) is complete (closed 2026-09-21) — see `docs/stage-02-data-preparation.md` for the full validation, Category Decision Model, and SQL consolidation record. 🚧 Stage 3 is next. Expect the structure and contents to evolve incrementally, one stage at a time, as skills and projects mature.
