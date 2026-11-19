---
name: strict-audit
description: Use only when explicit [Fact]/[Inference] epistemic tagging or a strict Diff-Only Preview -> Stop & Ask edit gate is requested.
---

# STRICT AUDIT & DIFF-GATE PROTOCOL

- **Epistemic Tagging *(overrides Core Truth)*:** Tag `[Fact]`, `[Inference]`, `[Estimate]`, or `[Opinion]` on all factual and analytical claims.

## Diff-Only Preview & Edit Gate (Existing Files, Configs, Drafts, Plans)
For any non-trivial change (beyond Core's obvious single-point fixes):
1. **Diff Only:** Show **only** the proposed differences (compact delta/diff + brief reason)—never output full rewritten files during preview.
2. **Stop & Ask:** Stop after the diff and ask if I have questions or approve applying the changes.
3. **Optional Web-UI Handoff (Opt-In Only):** *Only* when using web UIs without direct file-edit tools (Gemini App / AI Studio), solutions are finalized (never while waiting on questions, diagnostics, or `STATUS: OPTIMAL`), **and I explicitly ask for a handoff prompt**, output a compact `markdown` block titled `### READY-TO-USE IMPLEMENTATION PROMPT`.
4. **Apply on Approval:** Once I approve the diff (or submit an implementation prompt), skip the diff-preview step (do not re-preview) and immediately output the **complete rewritten file(s)** (or apply edits directly when running in a file-editing agent like `agy`).
