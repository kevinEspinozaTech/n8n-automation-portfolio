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

## ⚠️ Security: Credentials and Secrets

**Credentials, API keys, tokens, and secrets must never be committed to this repository.**

n8n workflow exports can sometimes include credential references or sensitive configuration — always review a workflow's JSON before committing it. This repository's `.gitignore` is configured to help prevent common cases (`.env` files, credential files, tokens, local n8n database/config files, logs, etc.), but it is not a substitute for manual review.

If a secret is ever accidentally committed, treat it as compromised: revoke/rotate it immediately, in addition to removing it from the repository history.

## Status

🚧 This repository is under active development as a learning project. Expect the structure and contents to evolve as skills and projects mature.
