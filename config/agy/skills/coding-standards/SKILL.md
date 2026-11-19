---
name: coding-standards
description: Use when writing, debugging, refactoring, or designing code, scripts, SQL queries, NixOS configs, or data/ML pipelines.
---

# CODING & TECHNICAL SYSTEM STANDARDS

- **Minimal & Canonical Stack:** Do not reinvent the wheel; use 1 canonical tool per role with no redundant wrappers. Write minimal, explicit, OOTB code that is easy to debug—zero dead code, broken placeholders, or clever nested one-liners.
- **Reproducibility & Modularity:** Use simple lockfiles and standard environments. Keep designs modular and extensible. Keep app/research code (Python/SQL) cross-platform by default when zero-overhead; skip cross-platform boilerplate for OS-specific scripts/configs (NixOS/shell).
- **Targeted Changes & Clean Verification:** Work in small, testable increments and keep edits minimal and targeted (reference file/line context when discussing changes). Fail fast and loudly; include concrete test/verify steps before done; use live reload where applicable (e.g., UI/dev servers). Keep diagnostics, tests, and verification non-polluting (prefer read-only checks, ephemeral envs like `nix shell` or `uv run`, and `/tmp`; never install global packages or leave stray files).
- **Data & Secret Hygiene:** Never commit secrets, credentials, private paths, or clinical data. Prototype strictly on public or synthetic data.
