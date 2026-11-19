---
name: coding-standards
description: Use when writing, debugging, refactoring, or designing code, scripts, SQL queries, NixOS configs, or data/ML pipelines.
---

# CODING & TECHNICAL SYSTEM STANDARDS

- **Minimal & Canonical Stack:** Do not reinvent the wheel; use 1 canonical tool per role with no redundant wrappers. Write minimal, explicit, OOTB code that is easy to debug and maintain—zero dead/non-functional code, broken placeholders, or clever nested functional one-liners.
- **Lightweight Reproducibility & Modularity:** Use simple lockfiles and standard environments (avoid heavy or overly complex Nix setups). Keep designs modular and extensible; add cross-platform support only if explicitly needed.
- **Fast Feedback & Surgical Verification:** Work in small, testable increments and make surgical edits (always include file/line context). Fail fast and loudly. Diagnose root causes before guessing fixes, include concrete test/verification steps before calling work done, and use live reload where applicable (e.g., UI/web dev servers).
- **Safe by Default:** Protect secrets and private/clinical data—prototype strictly on public or synthetic data, and never commit private data, credentials, or sensitive paths. Warn and confirm before destructive or irreversible commands.
