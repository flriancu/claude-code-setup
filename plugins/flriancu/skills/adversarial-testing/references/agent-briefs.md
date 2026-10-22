# Agent briefs

How to write the prompt for each testing agent, and a catalogue of angles to choose from.

## Contents
1. Brief template
2. Report format (paste into every brief)
3. Creativity mandate and techniques (paste the mandate into every brief)
4. Angle catalogue
5. Re-verification brief

## 1. Brief template

An agent starts with none of your context, so the brief carries everything it needs: what the
project is, where to read first, the hard rules, the angle, and the report format. Keep the
angle concrete — a list of specific attacks gets better coverage than "try to break it".

```
You are <role: testing as a first-time user | adversarially testing X | …>. <One line on the
goal: be merciless and concrete; find what crashes, hangs, misleads, loses data or gives wrong
answers.>

## The project
<Path. What it is and who uses it, in 3–5 lines. The parts relevant to this angle, with file
paths. Commands to run it. What to read first: README, requirements, the key sources.>

## Hard rules
- NEVER modify <real repo path> (read only; no git commands that write). <Name anything live:
  servers, ports, another session's dev server> — never touch them.
- Work in your own clone: <clone command into scratch/<area>>, then <install command> (no
  junction to the real dependencies: shared tool caches).
- Your ports: <dev port>, <prod/preview port>. <Browser automation: which library and browser
  channel, as the repo already does it.>
- Scripts and evidence in <clone>/.scratch/. Stop every server and browser you start — by its
  PID or your own port only, never by process name (other agents' and the user's servers run
  in parallel).

## Ideas (a starting floor — your own hypotheses matter more)
<Bullets from the angle catalogue, made specific to this project's files and features.>

## Creativity mandate
<The mandate from section 3, pasted verbatim.>

## Report
<Report format, below.>
```

## 2. Report format

```
Return:
1. A short verdict.
2. A table of findings: severity (high / medium / low / nit), where (file:line), exact repro
   (steps or script path), expected vs actual (exact output, stack, exit code, screenshot path),
   and on which targets it reproduced (dev / prod build / file:// / LAN).
3. UX confusions separately from outright bugs (if the angle covers UX).
4. What held up — attacks that failed, with numbers (cases, iterations, sizes).
5. What you did not test.
6. Your hypothesis log: every attack you invented, one line each — the idea, the technique it
   came from, whether it was in the brief/catalogue or yours, and the outcome (bug / held /
   not tried, and why). Mark your three most surprising ideas.
7. Your coverage list: every feature, input, state and path in your area, each marked tested
   (how) or not tested (why). Nothing in your area may be missing from it.
Only claim what you observed; mark anything else "suspected".
```

## 3. Creativity mandate and techniques

Paste the mandate into every brief, verbatim:

```
Be hostile. You are the project's opponent, not its QA friend: your goal is to make it fail,
lose data, lie or leak — not to confirm it works. Treat every input as an attack surface (forms,
files, URLs, storage, other tabs, network responses, the clock), treat docs and code comments as
claims to disprove, and treat "a user wouldn't do that" as an invitation. Think like a real
attacker too: injection, stored script, leaked tokens or personal data, tampered or replayed
files, hostile third-party responses. Aim all of it only at your isolated copy — never at live
instances, real accounts or third-party services (fake those).

Be merciless and comprehensive: leave no stone unturned. Start by mapping EVERY feature, input,
state and code path in your area into a coverage list; at the end, account for each item
(tested, and how — or not tested, and why). Assume bugs exist until proven otherwise: a working
happy path proves nothing, and a first bug in an area means dig deeper there, not move on. Do
not stop early: keep going until two consecutive rounds of new ideas find nothing, and say so.
Report severity honestly, neither softened nor inflated.

Be extremely creative. The ideas above are the floor; the bugs worth finding are the ones
nobody listed. Before you test anything, write down at least 20 attack hypotheses of your own,
at least half of them NOT in this brief, using the techniques below. Prefer strange and specific
over generic ("set the clock to 23:59:59 on 31 Dec, open the editor, wait two seconds, save"
beats "test dates"). Cheap absurd ideas are welcome — try them. Test every hypothesis that is
cheap, and the most promising ones in depth; keep inventing as you learn how the app behaves:
every surprise is a lead, so follow it until it stops paying. Combine features that were never
meant to meet. Stay rigorous: a finding counts only when you reproduced it; everything else is
"suspected".

Techniques (use several):
- Inversion: for each promise in the README/requirements, try to make the opposite happen.
- Make it lie: find a state where the UI says something false (saved / up to date / correct total).
- Personas: a hurried phone user on a train, a screen-reader user, a grandparent, a power user
  with years of data, a malicious teammate, someone whose OS is in another language and time zone.
- Time travel: midnight, DST switches, 29 Feb, year boundaries, a tab left open for days, the
  clock moving backwards, two devices whose clocks disagree.
- Collisions: two features at once (edit while syncing, undo while switching year, import
  while a dialog is open), two tabs, two accounts, the same action twice in one frame.
- Extremes: zero, one, the maximum, the maximum plus one, empty, enormous, deeply nested.
- Environment: offline mid-action, slow CPU, tiny or huge screens, zoom, blocked third parties,
  storage full or forbidden, extensions injecting markup, an old browser.
- Misuse as intended: use each feature exactly as designed but in an order, quantity or context
  the author didn't imagine.
- Embarrassment test: what would make the author wince in front of a user? Go find it.
- Follow the money: where does data get written, merged or deleted? Attack those paths hardest.
- Attacker's eye: what could a malicious file, link, extension, network or co-user make the app
  run, reveal, overwrite or believe? Where does untrusted data meet HTML, URLs, storage or eval?
```

Why the log matters: it shows the coordinator how wide the search was, which ideas were tried,
and where blind spots remain. A thin or obvious log (mostly catalogue items) gets the agent sent
back for another round.

## 4. Angle catalogue

Pick the ones the project has. Merge small ones; split big ones (a server deserves its own).
Always add the wildcard.

**Wildcard (every run).** No assigned area. Read the whole project, then attack wherever the
other angles are least likely to look: the seams between features, assumptions written in
comments, the code nobody tests, the paths the README never mentions. Its brief asks for at
least 30 hypotheses, two thirds of them its own, and explicitly invites absurd ideas. It may
overlap other agents only when it attacks the same thing in a way they wouldn't.

**First-time user.** Desktop (1440×900, 1024×768) and phone (390×844 touch, 360×640, landscape),
every UI language. Is it clear what this is and what to do first? Every promised task done start
to finish; where you got stuck, misled, or something silently did nothing. Labels, empty states,
errors, untranslated or truncated text, tap targets, overlap. Keyboard only (focus order, visible
focus, Escape), screen-reader basics (roles, names), zoom 200%, dark mode, reduced motion.
Reload, back/forward, what persists. Console errors. If the app has user roles or configurations
(solo, pair, group; admin, member), walk through start to finish once per combination: some
problems only show over a whole course or workflow, never on a single screen.

**Adversarial UI.** Text fields with hostile input (huge, unicode, RTL, emoji halves, control
chars, markup/HTML, markdown, formula-like `=cmd`), every form submitted twice/fast. Storage
(localStorage, IndexedDB, cookies) corrupted, wrong-typed, prototype keys (`__proto__`,
`constructor`), huge, quota full, blocked/throwing. URL/hash params hostile (unknown ids,
impossible dates, 1e309, script, repeated, very long). Interaction races: rapid toggles,
double-clicks, navigation mid-save or mid-layout, resize/rotate storms, CPU throttled 6×.
Multiple tabs on the same data. Text rendered unescaped anywhere (XSS). Memory over hundreds of
operations.

**Data, inputs, CLI.** Malformed files (YAML/JSON/CSV): anchors/alias bombs, duplicate keys,
tags, BOM, CRLF, non-UTF-8, empty, a directory with the file's name. Ids that are prototype
names, differ by case or Unicode normalisation. Semantic edge cases (cycles, dangling refs,
dates out of order or impossible). CLI arguments missing, malformed, special characters; exit
codes a CI relies on. Write a mutation fuzzer: random edits of the real data, run validator +
engine + exporters in-process, flag crashes, hangs (>2 s), and inputs the validator accepts that
something downstream chokes on.

**Outputs and logic.** Every export round-trips (export → import → export identical; copied
snippets paste back valid). Answers checked against a hand derivation for a few cases and an
independent implementation for many (random scenarios, compare). Property tests: monotonicity,
idempotence, order independence. Generated artefacts (diagrams, PDFs, schemas, calendars,
markdown) valid by a strict parser/renderer, with hostile labels; deterministic between runs.
Dates and time zones (midnight, DST, UTC vs local).

**Import/export and backups.** Exports opened by other apps; imports of files from older
versions, other apps, truncated, renamed (.txt), huge, hostile; an import while another tab
edits; what an import overwrites and whether the user was warned.

**Lifecycle and races.** Close/reload mid-typing (on a 6× throttled CPU), text kept or lost;
two tabs editing the same field; wipe/import/upgrade in one tab while another is open; offline
then online; a new version deployed while a tab is open (missing chunks).

**Server and deployment.** Path traversal (`..`, encoded, trailing dot/space, alternate data
streams, 8.3 names, junctions/symlinks), methods, Range requests (multiple, overlapping, past
the end), slow and stalled readers (do they block others?), many connections, caching headers,
publish while serving (atomicity, old assets kept for open tabs), what happens on logoff/reboot.

## 5. Re-verification brief

After fixes, a re-verification agent gets: the list of findings with their repro script paths,
the commit or tree state to test, both targets (dev and a fresh prod build), and the task:
"For each finding, rerun the repro and report FIXED / NOT FIXED / CHANGED BY DESIGN with
evidence; then attack the fixes themselves (new races, new inputs they enable) and report new
bugs in the usual format." Tell it which scripts were written for the old behaviour, so it
updates expectations instead of reporting design changes as failures. The creativity mandate
applies here too: a fix is new code with new assumptions, so ask for fresh hypotheses aimed at
the fixes, not only reruns.
