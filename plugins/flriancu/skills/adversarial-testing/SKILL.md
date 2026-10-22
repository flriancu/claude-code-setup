---
name: adversarial-testing
description: Merciless, multi-angle testing of an app or tool — from a first-time user's point of view and by trying to break it — run by parallel agents on isolated copies, then (when asked) fixing every finding with regression tests, re-verifying, and shipping. Use this whenever the user wants a project tested hard, adversarially, "as a new user", "try to break it", "find bugs", a QA pass, a bug bash, a re-test after fixes, or "address all findings"; also when they ask whether the latest push holds up, even if they don't say "adversarial".
---

# Adversarial testing

Find what breaks, confuses or lies in a project — inputs, cross-module workflows, import/export,
races, servers, outputs — then, on request, fix it properly and prove the fix. The work is split
across parallel agents, each attacking from one angle, each on its own isolated copy, so a whole
project gets covered in one pass without disturbing anything real.

The loop has four phases. Testing always happens; fixing only when the user asks for it (a test
request is not a fix request — report and offer).

1. **Isolate** — decide where testing can happen without harming anything live.
2. **Test** — baseline, then parallel agents by angle, then one consolidated report.
3. **Fix** (when asked) — sensible, maintainable fixes with tests that fail without them.
4. **Re-verify and ship** — rerun the repros, look for new bugs, gates, commit, push, CI.

## 1. Isolate

Testing on something people use is the one irreversible mistake here, so settle it first.

- Find out what is live (a running server, a deployed site, another session's dev server, a
  shared database). If the user hasn't said, ask whether the live instance must stay up and what
  you may use instead. Never test against it; never restart or republish it without being asked.
- Give every agent its own clone (`git clone --no-hardlinks <repo> <scratch>/<area>`; hardlinks
  fail across drives), its own dependency install (never a junction or symlink to the real
  `node_modules`: tool caches such as Vite's live inside it and would be shared with whoever runs
  the real one), its own port range, and its own evidence folder. Writes to the real repo are off
  limits for agents.
- Test both the dev server and a production build (served the way production serves it, and as
  a `file://` page if the app is meant to open offline). Many bugs exist in only one of them
  (code splitting, hashed asset names, minification, service paths).
- `scripts/isolated-clone.ps1` (PowerShell 7) makes a clone, installs dependencies and prints
  free ports. Details and server recipes: `references/isolation.md`.

## 2. Test

**Baseline first.** Run the project's own checks (type-check, lint, unit tests, e2e) and note the
result. A red baseline changes how findings are read, and later you need it to show nothing
regressed.

**Map the surface.** Read the README, requirements and the entry points so you know every input:
forms and text fields, files imported, URLs and query params, local storage, CLI arguments,
config/data files, network endpoints, clipboard/share/download outputs, multiple tabs/devices.

**Fan out.** Launch the agents in one message, in the background, each with a brief built from
`references/agent-briefs.md` (it has the brief template and a catalogue of angles). Pick 4–6
angles that fit the project; the usual core:

- first-time user (desktop and phone, every language, keyboard, offline)
- adversarial UI (hostile input, corrupted storage, URL tricks, races, resize storms, injection)
- data/inputs/CLI (malformed files, fuzzing, validator-vs-engine consistency, exit codes)
- outputs and logic (exports round-trip, answers checked against hand derivation or an
  independent implementation, property tests)
- plus server, import/export, multi-tab/lifecycle, upgrade paths — whatever the project has
- **always one wildcard agent** with no fixed angle (see the catalogue): its only job is the
  attacks nobody listed

Each brief states the hard rules (isolation, no writes to the real repo, ports, stop what you
start), the angle with concrete ideas, the **creativity mandate**, and the exact report format.
Agents must separate what they observed from what they suspect; a report full of guesses costs
more than it saves.

**Demand extreme creativity.** The catalogue and the brief's ideas are the floor, not the job.
The bugs that matter most are the ones nobody thought to check, so every brief carries the
creativity mandate from `references/agent-briefs.md`: before testing, each agent writes its
own list of at least 20 attack hypotheses, at least half of them *not* in the brief or the
catalogue, generated with the techniques listed there (inversion, personas, time travel,
feature collisions, "make the app lie", …); it tests the most promising ones and logs every
hypothesis with its outcome. Ask for strange, specific, even absurd attacks: an idea that
sounds silly but is cheap to try beats ten obvious ones. Creativity never relaxes rigour:
every claimed finding still needs a reproducible observation.

**Be hostile.** Agents are opponents of the project, not its QA friends: their goal is to make
it fail, lose data, lie or leak, never to confirm that it works. Every input is an attack
surface (forms, files, URLs, storage, other tabs, network responses, the clock), docs and code
comments are claims to disprove, and "the user wouldn't do that" is an invitation. Even the
first-time-user agent is hostile to the *design*: it assumes the UI misleads until shown
otherwise. Include a real attacker's goals — injection, stored script, leaking tokens or
personal data, tampered or replayed files, hostile third-party responses, abuse of permissions.
The hostility is aimed only at the isolated copies: never at live instances, real accounts,
other people's services or third-party endpoints (fake them instead).

**Be merciless and comprehensive: leave no stone unturned.** Creativity widens the search;
coverage makes sure nothing is skipped. Every agent starts by mapping *every* feature, input,
state and code path in its area into a coverage list and must account for each item at the end:
tested (how), or not tested (and why). Assume bugs exist until proven otherwise; a happy path
that works proves nothing, and a first bug in an area is a reason to dig further there, not to
move on. No early stops: an agent keeps going until two consecutive rounds of new ideas find
nothing, and says so. Severity is reported honestly — never softened to be polite, never
inflated to impress. "Out of scope" is not a reason to skip something the user would hit.

**Consolidate.** When all reports are in, merge them into one list for the user: deduplicate,
note findings several agents hit independently (strong signal), rank by severity, cite
file:line, and point to each repro script. Include what held up — it tells the user where not to
spend effort. Keep UX confusions apart from outright bugs. Mark the findings that came from
agents' own off-catalogue hypotheses and lead with the most surprising one: they show where the
project's blind spots are. If an agent's hypothesis log is thin or obvious (mostly catalogue
items), send it back via SendMessage for another, wilder round before consolidating. Merge the
agents' coverage lists against your own map of the surface: any feature, input or path that
nobody tested is a gap — send an agent after it (or test it yourself) before reporting, and list
whatever still remains untested in the report. Then offer to fix.

## 3. Fix (only when asked)

Read `references/fix-and-verify.md` before starting. In short:

- One sensible, maintainable fix per root cause, at the place that owns the concern (SOLID; no
  patching the same thing in three call sites). Prefer a small mechanism that removes a class of
  bugs over special cases.
- Every fix gets a regression test, and you check the test fails without the fix (revert the fix
  briefly, run, restore). For races, reproduce the race with a script before and after — never
  assume a race is fixed because the code looks right.
- Rerun each agent's repro script against the fix on dev **and** on a fresh production build.
- Keep the project's style: comment density, naming, idioms, docs (update the README/design notes
  the change affects).

## 4. Re-verify and ship

- When the fixes are in, send agents back (fresh ones, or the same ones via SendMessage) to rerun
  every repro and hunt for regressions and new bugs around the fixes. Two rounds is normal; a
  re-verification that finds nothing new is worth stating.
- Gates: type-check, lint, format, content checks, unit tests, every e2e suite on dev and prod.
- Commit in logical groups (tooling, infrastructure, app) with messages in the repo's style and
  the user's attribution/signing preferences; push only when the user asked; check the CI run.
- Do not publish to a live instance or restart it unless the user asks. When they do, verify it
  serves the new version and that the running process actually picked up changed server code.

## Working notes

- Agents' reports reach you, not the user: relay the substance, with severities and paths.
- Long runs: agents and background servers die when the user logs off. If a report never
  arrives, check its output file; rerun its scripts yourself rather than trusting silence.
- When the user names an instance ambiguously ("the prod copy"), say which one you understood
  before stopping or changing anything.
- More operational lessons (escaping in shell heredocs, line endings, CI checks):
  `references/fix-and-verify.md`.
