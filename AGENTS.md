# Repository Guidelines

## Project Structure & Module Organization
- `skills/` contains all skill packages. Each skill lives in `skills/<skill-name>/` with a required `SKILL.md` and optional `references/`, `scripts/`, and `assets/`.
- `skills/.system/` holds system skills (e.g., `skill-creator`, `skill-installer`) and their helper scripts.
- `.serena/` is local metadata and is gitignored; avoid relying on it for repo logic.

## Build, Test, and Development Commands
This repository is content- and script-focused; there is no global build.
- Initialize a new skill:
  - `python3 skills/.system/skill-creator/scripts/init_skill.py my-skill --path skills/`
  - Creates the skill folder with `SKILL.md` and optional resources.
- Validate a skill’s `SKILL.md`:
  - `python3 skills/.system/skill-creator/scripts/quick_validate.py skills/my-skill`
  - Checks YAML frontmatter and naming rules.
- List curated installable skills:
  - `python3 skills/.system/skill-installer/scripts/list-curated-skills.py`

## Coding Style & Naming Conventions
- `SKILL.md` files use YAML frontmatter and Markdown sections; keep headings concise and actionable.
- Skill directory names are lowercase hyphen-case (e.g., `go-master`).
- Python scripts follow 4-space indentation and include a shebang when executable.
- Match the existing formatting in the file you edit; avoid unnecessary reflow.

## Testing Guidelines
- No automated test suite is configured. Use `quick_validate.py` for `SKILL.md` changes.
- For script edits, run the script directly with `python3` and validate output manually.

## Commit & Pull Request Guidelines
- Git history only includes an initial commit, so no formal convention exists yet; prefer short, imperative messages (e.g., “Add rust skill references”).
- PRs should describe the skill(s) touched, include a brief rationale, and note any scripts run (e.g., validation).

## Security & Configuration Notes
- Avoid adding secrets or credentials to skills or references.
- Keep system scripts in `skills/.system/` unchanged unless the change is required and documented.
