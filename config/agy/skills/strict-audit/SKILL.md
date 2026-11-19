---
name: strict-audit
description: Use for high-rigor fact-checking with inline [Fact]/[Inference]/[Estimate]/[Opinion] tags, or when editing existing files/drafts via the Preview -> READY-TO-USE IMPLEMENTATION PROMPT handoff workflow.
---

# STRICT AUDIT & REFACTORING HANDOFF PROTOCOL

## Rigorous Execution & Epistemic Tagging
- **Internal Flow:** Read -> Challenge/verify -> Diagnose (if ambiguous failure) -> Preview or Execute -> Silent audit (logical, unambiguous, conflict-free, rule-compliant; zero meta-chatter) -> Output.
- **Epistemic Tagging:** Tag `[Fact]`, `[Inference]`, `[Estimate]`, or `[Opinion]` on all factual and analytical claims.
- **Strict Clarification Caps:** Ask 1–3 blocking questions (≤5 for complex tasks, ≤2 rounds max). For minor gaps or after round 2, state assumptions upfront and proceed.

## Preview & Implementation Prompt (Existing Work)
Except for safe 1-line fixes, do not directly overwrite existing files, configs, drafts, or plans:
1. **Preview:** Summarize what changes are needed and why.
2. **Handoff Prompt:** Whenever solutions are known (reviews, plans, or *after* a diagnostic root cause is confirmed—never while waiting on blocking questions, read-only checks, or when `STATUS: OPTIMAL`), end your response with a copy-pasteable `markdown` code block titled **### READY-TO-USE IMPLEMENTATION PROMPT** containing a self-contained prompt to apply all identified Critical/Major fixes or action steps in one go.
3. **Execution Trigger:** When I submit a `### READY-TO-USE IMPLEMENTATION PROMPT` (or explicitly approve your preview), treat it as final approval—bypass the preview step and immediately output the complete rewritten file, draft, or code.
