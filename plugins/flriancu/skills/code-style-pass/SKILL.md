---
name: code-style-pass
description: Applies the user's code style checklist to C and C++ (and its core rules to Python) in one pass - at most one return per function, airy layout, no `!` operator, Allman braces, named C++ casts, literal suffixes, const-correctness, noexcept, no default arguments, no OS headers in headers, ASCII-only comments that describe the present design - while following the surrounding codebase's own conventions, then builds and reports. Use this whenever the user asks to clean up, tidy, restyle or review code style, mentions "one return", "airy", "match the code base style", "const correctness", "noexcept", "c-style casts" or literal suffixes like 0U, relays PR comments about style, or before handing over new C, C++ or Python code the user will commit, even if they don't say "style".
---

# Code style pass

The user enforces these rules in every review. Without this skill they come back one rule per
round trip ("use at most one return statement per function!"). Apply the whole checklist at once,
build, and report what changed.

## Scope first

- Touch what was named: given files, the staged diff, or the branch diff against its base.
  Default to code changed on this branch; whole files only when asked ("extend the rule to the
  entire file").
- Never restyle vendored or third-party code: submodules, single-header libraries such as stb,
  SDK drops, generated code. Their warnings get target-scoped suppressions in the build instead.
  If a submodule needs a change, stop and describe it.
- A style pass changes no behaviour. If a rule can't be applied without changing behaviour,
  leave that spot and say why.

## Read the house style first

- Read `.clang-format`, `.clang-tidy`, `CODING_STANDARDS.md`, `.editorconfig` and two or three
  neighbouring files. Where the repo is specific (member suffix `_`, include guards, naming), the
  repo wins; the rules below fill the gaps.
- Read the C++ standard from CMake and stay within it. In a C++14 project that means no
  `if constexpr`, no `std::filesystem` (use the repo's path-join helper), no structured bindings.
- If `.clang-format` exists, run it on the touched files at the end.

## Checklist

### Control flow

- **At most one return per function**, and shallow nesting while getting there. The user rejects
  deep pyramids as firmly as multiple returns. Use a result variable and staged conditions:

  ```cpp
  bool Sensor::Configure(const Config &config) noexcept
  {
      bool ok = IsValid(config);

      if (ok)
      {
          ok = WriteRegisters(config);
      }

      if (ok)
      {
          ok = Verify();
      }

      return ok;
  }
  ```

- **No early exits in library code**: no `goto`, no `exit()` or `abort()` for control flow, no
  exceptions used as jumps (sentinels like "ENUMERATION_COMPLETE"). A constructor that cannot
  establish its invariant throws.
- **No `!` operator**, because it is easy to miss when reading. Compare explicitly:
  `if (ok == false)`, `if (ptr == nullptr)`, `if (items.empty() == false)`.
- **No `#elif`**: write separate `#if ... #endif` blocks.

### Layout ("airy")

- Allman braces, and braces on every control statement.
- One blank line before a `return` (unless it is alone in its block), before and after each
  `if`/`for`/`while`/`do`/`switch` block, after a run of declarations, and between a line of code
  and a following comment line.
- Comments on their own line above the code they describe, never trailing. API docs as Doxygen
  `/** ... */` on their own lines, not beside fields.
- As many parameters per line as fit; no line-length crusade unless the repo has one.

### Types and casts

- Named C++ casts instead of C-style casts. Prefer fixing the declared type over adding a cast;
  if the user rejects a cast as a warning fix, change the type instead.
- Literal suffixes that match the type: `0U` for unsigned, `0ULL` for 64-bit, `0.0F` for float.
- `enum class` instead of strings or bare ints. Convert strings only at the boundary (CLI or
  config parsing), in one place, from one list that also feeds the help text and validation.
- Vendor or OS status types (`HRESULT`, a vendor `GTSTATUS`) stay inside the translation unit
  that talks to that API; the rest of the code uses the project's own status type.
- A small type or enum shared across files gets its own header, so callers don't include a
  large one.

### const, noexcept, interfaces

- const-correctness everywhere: parameters, locals, member functions, callback signatures,
  pointers to const.
- `noexcept` on functions that cannot throw. Check the callees first: allocation can throw.
- Interface methods are pure virtual; depend on the interface, not the concrete class.
- **No default arguments**, and no default values in constructors or config structs unless the
  user asks. Callers state what they mean. CLI arguments are required, not defaulted.

### Headers and platform code

- OS and vendor SDK headers (`windows.h`, `pthread.h`, ...) only in translation units, never in
  headers. Platform code lives in `win/` and `posix/` files behind a platform-neutral interface.
- No globals for app or test state. RAII owners; no `new` without an owner.

### Comments and text

- ASCII only in comments and console output: no em-dashes, arrows, Greek letters, box drawing or
  emoji. UI string literals may use Unicode where needed.
- Comments describe the present design and the reason for it, never its history ("used to",
  "previously", "was changed to"). History belongs in the commit message and the CHANGELOG.
- Prefer self-documenting names to inline comments; document each function and class instead.
- Code or text the user supplied verbatim (an enum, a snippet, a message) goes in exactly as
  given: no added comments, no reformatting.

### Warnings

- Fix warnings in our code rather than silencing them: shadowing (rename), unused parameters
  (drop the name or cast to void), narrowing (fix the type), missing initializers (initialize).

## Python

- The same core rules: at most one return per function, airy layout, a blank line before `elif`
  and `else`, comments on their own line, ASCII only, no emoji.
- `pathlib` for paths; no `sys.exit` inside functions (`main()` returns an int and the module ends
  with `raise SystemExit(main())`); the standard `logging` module; Python 3.10+ syntax.
- Validated config via pydantic with `extra='forbid'`; required CLI arguments instead of defaults;
  no autodetection unless asked. Run it with the project's own `.venv`.

## Finish

- Build with every preset the repo has (the cmake-toolchains skill covers this) and run the
  tests. A style pass that breaks one toolchain is not done.
- Report per rule what changed (counts, files) and what was deliberately left, with the reason.
  Keep it short.
