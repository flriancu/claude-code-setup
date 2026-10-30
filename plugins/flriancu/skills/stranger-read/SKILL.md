---
name: stranger-read
description: Reviews finished text the way its real audience will meet it, cold. A fresh agent with none of the author's context reads it as a named persona, adversarially but constructively and with a high bar, and reports everything vague, inconsistent, unsupported or hard to act on; the fixes go in and another round runs until one finds nothing major. Use before publishing or handing over anything other people will read - wiki or Confluence pages, reports, roadmaps, proposals, READMEs, course or tutorial content, UI strings, emails, announcements, release notes - and whenever the user says "stranger-read", "cold read", "read it as a newcomer", "would a stakeholder get this", "make it watertight", or says a text is vague or confusing.
---

# Stranger-read

An author cannot unsee their own context, so they cannot tell what the text fails to say. A
reader who has none of that context can. Each time this has been run it caught what the authors
missed: on a self-paced course, sentences whose object was only in the author's head; on a
stakeholder roadmap, missing deciders, owners, dates and definitions of done.

The measure of success is the one in ISO 24495-1:2023, the plain-language standard: readers get
what they need (relevant), can easily find it (findable), understand it (understandable) and act
on it (usable).

## 1. Set up

- **The artifact**, in the form the reader will see: the rendered page, the screen, the PDF,
  the message as it will be sent. Fix a version and note it.
- **The persona**: who reads it, what they already know and don't, how they read (on a phone,
  skimming between meetings, in a second language), and what they must be able to do or decide
  afterwards. Ask the user if the audience isn't clear; the persona drives everything.
- **The checklist** for that kind of text, from section 4.

## 2. Run the read

Spawn a fresh agent. Give it only what the persona would have: the artifact, the persona, the
purpose, the checklist, the bar and the report format. Leave out design notes, history, the
conversation and your intentions: their absence is the point. If the persona would know
something (the company, the domain), say so in the persona.

```
You are doing an adversarial stranger read of <artifact> before it is <published / handed over>.
Read it as <persona>: <what they know and don't know>, reading <how and where>. After reading,
they must be able to <decide / do what>.

Be constructive, but set the bar high: anything vague, inconsistent, unsupported, or hard to act
on is a finding. Report; don't rewrite the text.

Network: judge every site before a request reaches it, search results included; never open
piracy, warez, adult or known-redirect sites, or save an untrusted page to disk. Make no requests
to the live systems the artifact describes <unless the read needs them: say which>.

Checklist:
<the checklist for this kind of text>

Report:
1. Verdict in two sentences: could this reader act on it today?
2. Findings: severity (blocker / major / minor), where (section or a short quote), the problem
   in the reader's words ("I don't know who decides this"), and a concrete fix.
3. Questions the reader would ask that the text doesn't answer.
4. What works and must survive the fixes.
```

For a long artifact, give sections to separate agents, plus one agent that reads the whole for
consistency between sections.

## 3. Fix and repeat

- Fix at the source. If the text is generated from data or content files, fix those, not the
  output.
- One fix per root cause. When "undefined term" shows up in ten places, add a glossary or define
  terms on first use; don't patch each sentence.
- Keep the author's facts and intent. Never invent a fact to close a gap: ask the user.
- Don't reopen what the user has settled or parked; a finding against a settled decision is
  reported as such, not fixed.
- Run a new round with a fresh agent on the fixed version. Stop when a round finds no blocker
  and no major finding; two rounds is typical.
- Tell the user: rounds run, the main findings and how each was fixed, and anything left for them
  to decide.

## 4. Checklists

### Text a newcomer must act on

Instructions, courses, tutorials, UI strings, READMEs for non-specialists. Every sentence passes:

1. **The object is in the sentence.** "Write three dreams in the notebook", never "write them".
2. **Nothing from outside the text.** No references to meetings, decks, earlier versions or "as
   before" that the reader never saw.
3. **Expand on first use, per screen or section.** Abbreviations, letters and coined terms get
   their meaning the first time they appear.
4. **Inputs describe themselves.** The label says what to type, the placeholder gives an
   example, the button says what happens.
5. **Empty states point forward.** "The list is empty. Write the first item in the box above."
6. **Steps can be started now.** What, with what, where, how long, plus one example.

Also: every pronoun has its noun in the same sentence; interface elements are named exactly as
they appear on screen; it was checked at phone width.

### Documents someone must decide on

Reports, roadmaps, proposals, wiki pages for stakeholders:

- **The ask**: what each reader or team must do or decide, by when, and who decides.
- **Ownership**: owners named by role, not by person; other teams' items marked as theirs.
- **Honest, checkable status**: definitions of done that can be checked; "done" means merged or
  released; prototype work marked as prototype; decisions dated.
- **Orientation**: contents, a glossary for every term the reader may not know, status visible
  at a glance (colour plus a second cue), detail the reader doesn't need collapsed or moved out.
- **Only what changes what the reader can do or decide.** Build, toolchain and code-internal
  detail stays in the engineering document.
- **The present state**: the plan as it stands, written as if it had been right the first time;
  no account of what was misunderstood earlier.
- **Traceable claims**: each one links to its source (a repository document, a ticket, a
  measurement).
- **Concrete capability claims**: each says what it does in plain terms and whether it exists
  today, as a prototype, or only as a plan. "Lock-free scheduling where possible" or "execution
  tracing support" is not yet a claim: the reader will ask what it means.
- **Length**: anything that does not serve the ask is cut.

### Messages and announcements

- One ask, stated early; brief enough to read in a chat preview.
- The audience's language and register; understate rather than oversell when the user asks for it.
- Nothing the recipient can't act on or doesn't need.
