---
name: ui-clarity
description: Rules for building and reviewing app interfaces, interactive viewers and diagrams so a first-time user understands them without help - what each view is for, wording on screen, controls and widgets, scrolling and layout, views that don't jump, diagram notation and legends - and for presenting design options. Use whenever building or changing a UI, a web app page, a settings screen, an onboarding flow, a graph or diagram viewer, a chart legend or a printable diagram, when the user reports something on screen as confusing, cryptic, cramped, cut off or jumping, or asks for UX polish, even if they don't say "UX".
---

# UI clarity

These rules come from three apps the user built and tested by hand: a self-paced course, a
graph viewer of a house's utilities, and a time-off planner. Every rule below answers something
the user actually hit. The common thread: the screen has to explain itself to someone who has
never seen it, and must never surprise them.

## Start from the questions

- Design each view from a question the user brings to the app ("what fails if the grid goes
  down?"). One focused view per question beats one view that shows everything. Keep the
  everything-view as a separate artifact, such as a printable poster.
- Give each control one clear job. Remove controls that don't earn their place; two similar
  buttons ("fit" and "fill") confuse more than they help.
- Show a selector even when it has a single option, so the concept is visible before a second
  option exists.
- Multi-step choices disclose progressively: the next choice appears only after the previous one
  is made.
- Settings apply immediately. No save button.

## Words on screen

- Every screen's text passes the stranger-read skill's newcomer checklist.
- Say what the user spends and what they get, in a full sentence, rather than a code or badge:
  "You use 1 day of leave and are off 5 days in a row, Friday 27 November to Tuesday 1 December",
  not a "1 -> 5" badge. Put detail in a tooltip or editor, not on a dense grid.
- Full day and month names. No abbreviations the user has to decode.
- Device-neutral wording: "this device", not "phone".
- Choice labels speak in the user's voice ("I do the course alone, with a friend"), with one line
  of help under each.
- Dates are formatted for the reader's language and locale, never printed as a raw date string.
  A date that means a calendar day is stored and compared as a local date, not as UTC midnight.
- Unicode symbols and emoji are fine as icons where they help scanning; give each one an
  accessible name.

## Controls and widgets

- Use an established library for generic widgets (date pickers, comboboxes, menus), themed to the
  site. Native inputs render in the operating system's locale format: a Windows short-date
  setting once turned an empty date field into "dd-----yyyy".
- When content scrolls, the scrollbar is visible and styled like the site. Prefer scrolling to
  paging buttons. Tables that scroll keep their header row and first column pinned; headers read
  horizontally.
- Sliders show labelled gradations, snap only to those marks, keep them evenly spaced, respond to
  the mouse wheel on hover, and start at a sensible default.
- Every button shares one style. Anything that expands looks expandable. Different actions get
  different icons: "step forward" must not look like "play".
- A counter or fraction says what it counts: "tick 10 of 17", not "10 / 17".
- Check at phone width and at desktop width, with the keyboard, focus visible.
- Spacing comes from one system: no stray gaps of a few pixels, no lines glued to text boxes,
  nothing showing behind pinned columns.

## Views that stay put

- An interaction never moves what the user is looking at. Folding, unfolding, filtering and
  selecting keep every node where it was; if the layout must change, animate it.
- "Fit" shows all the content, clear of banners and toolbars, and stops at a readable zoom.
- A graph or canvas resizes with the window, when it shrinks as well as when it grows. Zooming
  out stops at the fit size, and each zoom step is small.
- Expensive layout runs off the main thread and is cached, so the view never freezes.

## Logs and replay

- Event logs start collapsed and can be saved to a file with timestamps and everything needed to
  reproduce a run (version, settings, inputs), one JSON object per line (NDJSON).
- Loading and replaying a log streams it, so a huge file doesn't freeze the page.
- Replay steps backwards and forwards and shows the detail of each event. Keep live and replay
  controls apart, and always show which mode is on screen.

## Diagrams and graphs

- **Arrows follow the flow.** Every arrow points toward what it serves, and its label reads in
  the arrow's direction ("supplies", "discharges into"). Labels like "receives from" make the
  reader trace backwards; the user called them extremely counterintuitive.
- **One symbol per concept.** Shape tells the kind, colour reinforces it, and colour never carries
  meaning alone: add a glyph or a line pattern (WCAG 1.4.1).
- **Contrast and colour vision.** Graphics reach 3:1 against their surroundings (WCAG 1.4.11), and
  the palette is checked for colour-vision deficiency. The dataviz skill has the validator.
- **A legend that explains everything**: every shape, line style, arrowhead, colour and glyph, in
  plain words. Each node can explain why it exists, in a detail panel; "I can't remember why we
  have this node" is a defect.
- **Labels only where they help**, for example on the selected node's edges, anchored so that
  converging labels don't stack.
- Notation sources worth following: D. Moody, "The Physics of Notations" (IEEE TSE 2009), and
  the C4 model's notation guide.

## Choosing between designs

- Show options rendered side by side, at real sizes (icons also at 32 and 64 px), or as live
  variants on separate local ports. Describing visual options in prose wastes a round trip.
- Put a running build in front of the user early ("go live on local, I want to test"). Their
  screenshots are the best bug reports: reproduce from them before fixing.

## Before handing over

- Stranger-read on all the text.
- The adversarial-testing skill's first-time-user angle, with one walkthrough per user role and
  configuration; some problems only show over a whole workflow.
