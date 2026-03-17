# agents (Skill Repository)

This repository is a collection of **Skills** that provide "expert-level patterns for review, design, and implementation" to agents like Codex. Each skill consists of a `SKILL.md` file (triggering metadata + procedures/checklists) and optional `references/` (local summaries). The focus is on avoiding external dependencies and enabling decision-making even without a network connection.

## Structure

- `skills/<skill-name>/SKILL.md`: The core skill (when to use, initial questions, output contract, review perspectives).
- `skills/<skill-name>/references/`: Summaries for reference (intended to be read only when needed).
- `skills/.system/`: Helpers for skill creation/installation, etc. (Usually not modified).

## Usage (Validation/Installation)

### validate

Validates the `SKILL.md` of all skills based on minimum rules.

```sh
make validate
```

### install

Copies the skills to the skill directory (default: `~/.agents/skills`).

```sh
make install
```

## Usage in Codex

1) Place in `.agents/skills` using `make install`.
2) One-time setup: `cd $HOME/.codex; mv skills skills.bak; ln -s ~/.agents/skills`
3) Explicitly request the skill name (e.g., `$go-master` / `$java-master` / `$cs-master`).
Providing information that answers the "First Questions" (version, constraints, goals) upfront will improve accuracy.

## Usage in Gemini CLI

Skills are supported in `gemini-cli@0.24.0`.
After installation, activate it following the guide at <https://geminicli.com/docs/cli/tutorials/skills-getting-started/>.

1) Place in `.agents/skills` using `make install`.
2) One-time setup: `cd $HOME/.gemini; mv skills skills.bak; ln -s ~/.agents/skills`
3) Request as "using go-master," (e.g., "using go-master, perform a code review").
Providing information that answers the "First Questions" (version, constraints, goals) upfront will improve accuracy.

## Adding New Skills

The `skill-creator` is available as follows:

- `$skill-creator` in Codex
- Launch `skill-creator` within Gemini CLI

However, it may be better to request it in the Antigravity chat as follows:

```text
Create a new skill based on Go coding conventions and https://go.dev/doc/effective_go. Place the SKILL.md and necessary scripts/resources in .agent/skills/go-codereviewer/. This should be a specialist skill focused on Code Review, quality, performance, and software design.
```

- In this repo, common SKILLS are placed in `~/.agent/skills`.
- In the prompt above, project-specific Agent SKILLS are created in `$workspace-dir/.agent/skills` (singular `agent`, not `agents`).
