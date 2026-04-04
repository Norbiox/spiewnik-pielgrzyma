---
name: Use uv add for dependencies
description: Always use `uv add` command to add dependencies, never edit pyproject.toml manually
type: feedback
---

Always use `uv add` to add dependencies instead of editing pyproject.toml manually.

**Why:** User preference for using uv's CLI workflow consistently.

**How to apply:** When adding new packages, run `uv add <package>` from the project directory. This updates both pyproject.toml and uv.lock in one step.
