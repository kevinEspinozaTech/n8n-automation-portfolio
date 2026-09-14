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

Reference notes, setup guides, architecture explanations, and any written documentation that supports the workflows in this repository.

### `templates/`

Reusable workflow skeletons, starter nodes, and boilerplate patterns that can be copied into new projects.

## Planned Architecture (Future Stages)

The structure above reflects the **current state of the repository only**. As the project grows beyond n8n into a broader data/BI/automation/AI portfolio, the following will be added — **one folder at a time, only when the stage that needs it begins**, not in advance:

```
data/
├── raw/          # Original public dataset — never modified directly
├── synthetic/    # Data created to fill gaps in the public dataset;
│                 # always clearly documented as synthetic, never
│                 # presented as real
└── processed/    # Cleaned/transformed output derived from raw + synthetic

sql/              # SQL Server scripts and queries
notebooks/        # Jupyter notebooks (Python analysis)
powerbi/          # Power BI files and related assets
content/          # AI-generated content artifacts (later stages)
results/          # Outputs, findings, and performance metrics

docs/
└── stage-XX-short-name.md   # One documentation/log file per stage
```

None of these folders or files exist in the repository yet.

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

Sections are filled in progressively as each stage advances rather than all at once. No `docs/stage-XX-*.md` file exists yet — the first is created when Stage 1 begins.

## ⚠️ Security: Credentials and Secrets

**Credentials, API keys, tokens, and secrets must never be committed to this repository.**

n8n workflow exports can sometimes include credential references or sensitive configuration — always review a workflow's JSON before committing it. This repository's `.gitignore` is configured to help prevent common cases (`.env` files, credential files, tokens, local n8n database/config files, logs, etc.), and now also covers Python/Jupyter artifacts and local SQL Server backup files in preparation for upcoming stages — but it is not a substitute for manual review.

If a secret is ever accidentally committed, treat it as compromised: revoke/rotate it immediately, in addition to removing it from the repository history.

## Pending Decisions

- **License** — this is a public repository, so a license (e.g. MIT) is likely appropriate, but the choice is deferred until closer to Stage 10. We want to decide deliberately what a license should permit regarding the code and n8n workflows in this portfolio, rather than defaulting to one now.

## Status

🚧 Stage 0 (Environment Setup) is complete. The repository is being prepared for Stage 1 (Business Case & Data Acquisition). Expect the structure and contents to evolve incrementally, one stage at a time, as skills and projects mature.
