# Fixing and verifying

Read this before fixing findings from an adversarial test round.

## Contents
1. Fix standards
2. Proving a fix
3. Gates and environments
4. Committing and shipping
5. Operational lessons

## 1. Fix standards

- **Root cause, one place.** Find the module that owns the concern and fix it there. If three
  call sites misuse an API, the API is wrong. Registries over scattered special cases: adding a
  field, a sheet or a route should stay "one entry".
- **SOLID, the project's way.** Pages compose; data modules own writes; pure logic stays pure;
  match the existing layering rather than inventing a new one.
- **Remove classes of bugs.** Prefer a mechanism (validation at the boundary, a journal for
  unsaved text, a lock per tab, an escaping function with a property test) to patching each
  reported case.
- **Sensible and scalable.** Bound what grows (caps, timeouts, pagination); degrade with a clear
  message, never silently; an unknown input is an error with a non-zero exit, not "the latest
  state".
- **Design changes are allowed** when the original behaviour was the bug — say so in the report
  and in the tests (the old expectation was wrong), and tell re-verification agents.
- Keep comments, naming and docs in the surrounding style; update the README/design notes the
  change touches.

## 2. Proving a fix

- **A regression test per finding**, at the lowest level that shows it (unit over e2e when
  possible).
- **Check the test bites:** briefly revert the fix (or apply the old file), run the test, see it
  fail, restore. A test that passes either way proves nothing.
- **Races are reproduced, not reasoned about.** Write a script that triggers the interleaving
  (two tabs, reload during a debounce, CPU throttling, a held lock, a stalled reader), run it
  several rounds before and after. Report counts ("lost 3/8 → 0/8").
- **Rerun the agent's own repro** against the fix, on dev and on a prod build. Where a repro's
  expectation encoded the old behaviour, adjust it and say so.
- When a repro still "fails", look at the evidence before changing code: sometimes the
  behaviour is correct and the check is too strict (e.g. text kept for the next start instead of
  written now). Then decide whether the stricter behaviour is worth building.

## 3. Gates and environments

- Type-check, lint (warnings as errors if the project does), formatter check, content/data
  checks, unit tests, every e2e suite.
- e2e on the dev server **and** a fresh production build served like production (rebuild after
  the last change; restart the test server if its own code changed — a running process keeps
  the old code).
- A suite that flakes: rerun once; if it passes, find the cause (dev server re-optimising after
  edits is common) before calling it flaky.

## 4. Committing and shipping

- Logical commits: tooling/config, infrastructure (servers, scripts, CI), app changes with their
  tests. Messages in the repo's style, listing what changed and why; the user's identity and
  signing preferences; the attribution lines the session requires.
- Fix factual claims in the message before pushing (test counts, file names).
- Push only when asked; then check the CI run to completion and report its conclusion.
- Never publish to or restart a live instance unless asked. When asked: publish, verify the live
  URL serves the new build, and check the server process started after its script last changed;
  if not, offer a restart (state the downtime).

## 5. Operational lessons

- **Backslashes in shell heredocs get mangled** (regexes, `\\`, escapes in source). Write or edit
  such files with the file tools, not `python - <<EOF` or `cat <<EOF`.
- **Commit messages:** pass them through a bash heredoc (`git commit -F - <<'EOF'`) or a file; a PowerShell
  here-string given to `git commit -F -` is read as a pathspec and nothing is committed.
- **Someone else's working tree:** when another session or the user works in the repo, fix in a `git worktree`
  on a branch with its own install, so their checkout and dev server are never disturbed; merge at the end.
- **Re-verify against a commit:** commit fixes on the branch before re-verification so agents test a fixed point
  (`git fetch <repo> <branch>` in their clones); keep fixing meanwhile and tell them which commit they had.
- **Respect deliberate behaviour:** a test that encodes the "bug" on purpose (with a comment saying why) is a design
  decision; fix the misleading comment or docs, not the behaviour, and say so in the report.
- **Re-run the testers' own scripts** against the fix (serve your worktree on the ports their scripts target):
  it proves the exact reported scenario, and their scripts often fail where an expectation was the bug.
- **Line endings:** a repo without `.gitattributes` on Windows produces CRLF noise and red
  formatter checks; `* text=auto eol=lf` plus binary patterns fixes it. `git checkout -- f` may
  not rewrite a file whose only change is line endings; delete it first.
- **Clones across drives** fail with hardlinks: `git clone --no-hardlinks`.
- **Background work dies at logoff** (servers, agents). After a gap, check what still runs before
  assuming state.
- **Another session may be using the same repo** (its dev server, its working tree). Keep out
  of its ports and files; never stop processes you did not start without asking.
