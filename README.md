# agents (Skill Repository)

This repository is a collection of **Skills** that provide "expert-level patterns for review, design, and implementation" to agents like Codex. Each skill consists of a `SKILL.md` file (triggering metadata + procedures/checklists) and optional `references/` (local summaries). The focus is on avoiding external dependencies and enabling decision-making even without a network connection.

## Structure

- `skills/<skill-name>/SKILL.md`: The core skill (when to use, initial questions, output contract, review perspectives).
- `skills/<skill-name>/references/`: Summaries for reference (intended to be read only when needed).
- `skills/<skill-name>/scripts/`: Automated check scripts for code quality.
- `skills/.system/`: Helpers for skill creation/installation, etc. (Usually not modified).

## Available Skills

| Skill | Language / Domain | Description |
| ------- | ------------------- | ------------- |
| `bevy-master` | Rust / Bevy ECS | Bevy game engine expert (ECS, scheduling, plugins) |
| `c-master` | C | System-level C (C99-C23, memory safety, embedded) |
| `cleanarch-master` | Go / Architecture | Clean Architecture 4-layer enforcement |
| `cpp-master` | C++ | High-performance C++ (C++11-23, RAII, templates) |
| `csharp-master` | C# / .NET | Modern C#, ASP.NET Core, EF Core |
| `ebiten-master` | Go / Ebiten | Ebitengine 2D game development |
| `go-master` | Go | Idiomatic Go, concurrency, performance |
| `java-master` | Java / Spring | Modern Java, Spring Boot, testing |
| `mui-master` | React / MUI | Material UI design systems, Next.js integration |
| `python-master` | Python | Pythonic design, async, Pydantic, FastAPI |
| `rust-master` | Rust | Ownership, lifetimes, zero-cost abstractions |
| `typescript-master` | TypeScript | Type engineering, tsconfig, runtime safety |
| `writing-master` | Writing / Editing | Document proofreading, grammar, structure |
| `x68k-master` | X68000 / MC68000 | Sharp X68000 system programming, hardware control |
| `skill-creator` | Meta | Guide for creating and packaging new skills |

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
