<p align="center">
  <img src="plugins/flriancu/.claude-plugin/icon.png" alt="A yellow rubber duck on a four-by-four mosaic of green, purple, blue and red squares" width="128">
</p>

# claude-code-setup

A Claude Code setup: six skills packaged as a plugin, and a global instructions file that goes
with them. The skills capture recurring patterns from real work: steps that had to be explained
to the assistant again and again, and corrections that kept coming back.

## Install the skills

In a Claude Code session:

```
/plugin marketplace add flriancu/claude-code-setup
/plugin install flriancu@flriancu-plugins
```

Or from a terminal:

```
claude plugin marketplace add flriancu/claude-code-setup
claude plugin install flriancu@flriancu-plugins
```

Claude picks a skill when a task matches its description. You can also call one directly,
for example `/flriancu:code-style-pass`.

## The skills

| Skill | What it does |
|---|---|
| `requirements-kickoff` | Starts a new effort with numbered clarifying questions, then writes a `REQUIREMENTS.md` contract and a phased plan, then runs one phase at a time on request. |
| `code-style-pass` | Applies a C and C++ style checklist in one pass (one return per function, airy layout, explicit comparisons, named casts, const-correctness, noexcept, no default arguments, ASCII comments), plus the same core rules for Python, then builds and reports. |
| `cmake-toolchains` | Builds a CMake project through its presets on MSVC, MSYS2 clang64 and ucrt64, and WSL; fixes warnings; checks MinGW binaries for runtime DLLs; ports projects that only build with MSVC. |
| `adversarial-testing` | Tests an app or tool hard with parallel agents, each on its own isolated copy and attacking from a different angle; on request, fixes the findings with regression tests and re-verifies. |
| `stranger-read` | Reviews finished text cold before it goes out: a fresh agent reads it as the real audience, with a high bar, and reports what is vague, inconsistent, unsupported or hard to act on; rounds repeat until nothing major is left. Checklists for newcomer text, decision documents and messages, anchored in ISO 24495-1 plain language. |
| `ui-clarity` | Rules for interfaces, viewers and diagrams a first-time user understands without help: views built around questions, wording, widgets and scrolling, views that don't jump, arrows that follow the flow, complete legends, and design options shown side by side. |

The code style and toolchain skills encode specific conventions and a Windows setup. Read them
before relying on them elsewhere.

## Global instructions

`global/CLAUDE.md` holds the rules that apply in every session: how to handle root causes,
evidence for claims, when to act and when to only propose, fidelity to other people's content,
tools, git and writing. Plugins can't install a global `CLAUDE.md`, so copy it by hand:

```
cp global/CLAUDE.md ~/.claude/CLAUDE.md
```

If you already have one, merge the sections you want instead of overwriting it.

## Layout

```
.claude-plugin/marketplace.json     the marketplace: one plugin, "flriancu"
plugins/flriancu/
  .claude-plugin/plugin.json        the plugin manifest
  .claude-plugin/icon.png           the plugin icon
  skills/<skill>/SKILL.md           one folder per skill, with its reference files and scripts
global/CLAUDE.md                    global instructions, copied by hand
```
