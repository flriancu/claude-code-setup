---
name: requirements-kickoff
description: Starts a new project, tool, feature, design or investigation with requirements elicitation, then writes a REQUIREMENTS.md contract and a phased plan, then executes one phase at a time when asked. Use this whenever the user says "req elicitation", "let's make req elicitation", "ask me clarifying questions", "ask any unclear requirements", "make a md doc with phases and steps", "execute phase N", or starts something new and open-ended (a script, an app, a scraper, a 3D-printable part, a document or book conversion, a hardware bring-up, a migration, a purchase decision) where building straight away would mean guessing. Also use it when the user pushes back on a one-shot answer.
---

# Requirements kickoff

The user settles decisions explicitly and cheaply up front, then builds in reviewed steps. A
one-shot build bakes in guesses they later have to unpick. Long silent deliberation before
anything is on paper annoys them just as much ("no need for one shot, why the long thinking?
let's draft a doc with phases"). So get questions and a plan on paper fast, and let them steer.

## 1. Gather, briefly

- Read what was provided: files, folders, links, images, earlier chats and memory notes, the
  repo README. Note what is already decided so you don't ask it again.
- If an input is still missing ("link incoming", "photo will arrive later"), start the questions
  anyway and mark which ones depend on it.
- Don't write code or change files yet. Don't deliberate at length: the questions are the
  thinking tool.

## 2. Ask numbered questions

- One numbered list, grouped by topic when there are many. Each question is one line with the
  options you see and your recommended default, for example:
  `3. Install location: C: or D:? Recommended: D:, since C: is nearly full.`
- The user answers tersely by number ("1. both 2. bring up to date 3. ok"). Map each answer back
  carefully. "ok" or "agreed" accepts your default; "former" and "latter" refer to the order of
  your options; a skipped number means "your call, tell me what you chose".
- Cover what matters for this effort: goal and audience; scope and explicit non-goals; inputs and
  outputs (formats, locations); constraints (platform, tools allowed or forbidden, licences,
  offline use, hardware); quality bar and acceptance test ("how will we know it works"); failure
  behaviour (what happens when each part fails at any moment: a crash, a lost connection, a power
  cut, one node of several going down); fidelity (what must never be altered); where things live
  (repo, paths, remote); delivery (who receives what, how often).
- Run a second, shorter round only for answers that opened new questions. Stop asking once the
  remaining unknowns have safe defaults, and list those defaults instead.

## 3. Write the contract: REQUIREMENTS.md

Put it in the project root, creating the folder if the project is new. Keep it plain, short and
dated:

```markdown
# <Project> requirements

Agreed <YYYY-MM-DD>. This file is the contract; changes are recorded here with a date.

## Goal
## Audience and use
## Scope
## Non-goals
## Decisions
- D-01 <decision> (<date>)
## Functional requirements
- FR-01 ...
## Constraints and non-functional requirements
- NFR-01 ...
## Verification
One row per requirement: how it is verified and where the proof lives.
| ID | Method (test / inspection / analysis / demonstration) | Evidence (test case, script, file) |
## Open questions
```

Stable IDs (D-xx, FR-xx, NFR-xx) let later work, commits and reports cite them. Record the user's
answers in their own terms; don't paraphrase them into something stronger or weaker.

Give every requirement a verification method and an evidence location. The four methods are the
standard ones from requirements engineering (ISO/IEC/IEEE 29148). Prefer a test. When a
requirement can only be checked by inspection or analysis ("no direct OS thread calls",
"scheduling overhead under 100 microseconds per node"), write the check as a script that saves
its output as evidence, so the proof can be rerun rather than re-argued.

## 4. Write the plan: phases

Put it next to the requirements in PLAN.md, or in a "Phases" section when the project is small.
Phase 0 is usually setup, or a pilot that proves the riskiest assumption first. For each phase
give the goal, the steps, the deliverable, how it is verified, and the requirement IDs it serves.
Keep phases small enough to review in one sitting, and say the plan will be adjusted on the way.

Then stop. Report the two files in a few lines and recommend the first phase.

## 5. Execute on request, one phase at a time

- Run only the phases the user names ("execute phase 0", "execute phases 0 and 1", "go").
- At the end of each phase report what was done, the evidence that it works (commands run,
  outputs, test results), what deviated from the plan and why, and what comes next. Mark the
  phase done in the plan.
- "progress check" means: current phase, what is done, what is running, what is blocked.
- A new wish that changes scope goes into REQUIREMENTS.md with its date before you build it. A
  reversed decision is recorded as a reversal; the old line stays.
- Fix bugs found along the way when the user has said to; otherwise list them.
- When the last phase is done, or when the user asks, run a gap pass: requirements against code,
  tests, docs and evidence. Report each gap with its requirement ID, fix them one by one on
  request, and rerun the evidence scripts.
- Don't commit or push after each step. Propose a commit when a phase is done; push only when
  asked.

## Variants

- **Decisions without code** (a purchase, a tool choice): same questions, then a short
  comparison against the agreed criteria instead of the two files.
- **Someone else's content** (an author's book, a client's data, recordings): add a fidelity
  requirement up front. Nothing in the content changes silently; every change is proposed,
  marked and reported for approval.
