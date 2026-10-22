<p align="center">
  <img src="plugins/flriancu/.claude-plugin/icon.png" alt="A yellow rubber duck on a four-by-four mosaic of green, purple, blue and red squares" width="128">
</p>

# claude-code-setup

My Claude Code setup: four skills packaged as a plugin, and the global instructions file I use
with them. I wrote the skills from patterns in my own work: the steps I kept explaining to the
assistant, and the corrections I kept making.

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

The code style and toolchain skills encode my own conventions and my Windows setup. Read them
before relying on them elsewhere.

## Global instructions

`global/CLAUDE.md` holds the rules I want in every session: how I want root causes handled,
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
