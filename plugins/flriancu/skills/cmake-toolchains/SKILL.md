---
name: cmake-toolchains
description: Builds and checks a CMake C or C++ project on every one of the user's toolchains through CMake presets (MSVC 2022, MSYS2 clang64 and ucrt64, WSL clang and gcc), fixes warnings properly, verifies that MinGW binaries carry no runtime DLL dependencies, and ports projects without non-MSVC support to MSYS2 and Ninja presets. Use this whenever the user says "build it", "it fails", "cmake --build", "use the preset", "build with all toolchains", "fix the warnings", "test with mingw/msvc/wsl", mentions MSYS2, ucrt64, clang64, MinGW, Ninja, CMakePresets or toolchain files, reports a missing DLL at startup, or asks to make a project build without Visual Studio, even if they only paste a build error.
---

# CMake toolchains

The user's C and C++ repos build on several toolchains. Agents keep breaking that by running raw
cmake command lines, building the wrong configuration, cutting off the output, or silencing
warnings. The user has had to say "use cmake presets" dozens of times. This skill is how to build
in those repos, and how to bring a repo into that shape.

## Always

- **Presets only**: `cmake --preset <name>`, then `cmake --build --preset <name>`. No ad-hoc
  command lines. Don't add presets unless asked; if one is missing, propose it.
- Read `CMakePresets.json` first: configure and build presets, generators, toolchain files,
  cache variables, inherited bases. Use the names it has.
- Build the configuration the user named; default to Debug. Multi-config generators (Visual
  Studio) need `--config` unless the build preset sets it.
- Extra cache variables go at configure time (`cmake --preset <name> -DFOO=ON`), not after `--`.
- Show full output. No `Select-Object -Last N`, `tail`, `head` or grep on build output. For long
  builds, redirect to a log file and read it. Wait for the build to finish before judging it.
- If the user says they built it, don't rebuild: run or test what they built.
- Warnings: fix them in our code. In third-party code (vendored sources, submodules,
  single-header libraries, SDKs) suppress them with compile options on that target only. Keep
  warnings-as-errors on; turn it off only temporarily, and only when the user asks.
- Don't modify submodules. If one needs a change, stop and describe it.
- A repo's own CLAUDE.md build rules win (for example "MSYS while iterating; MSYS and MSVC for
  review").

## The usual presets

Many of the user's repos share these names. Check before assuming.

| Preset | Platform | Toolchain |
|---|---|---|
| `msvc-2022` | Windows | MSVC, Visual Studio 17 2022 generator (multi-config) |
| `msys-clang64-clang-ninja` | Windows | MSYS2 clang64: clang and libc++ |
| `msys-ucrt64-gcc-ninja` | Windows | MSYS2 ucrt64: gcc and libstdc++ |
| `msys-ucrt64-clang-ninja` | Windows | MSYS2 ucrt64: clang and libstdc++ |
| `clang-ninja`, `gcc-ninja` | WSL Ubuntu | system clang or gcc |

Repos may add release, sanitizer or cross-compile presets on top.

## Running each environment

- **MSYS2**: put `C:\msys64\<env>\bin` first on PATH, both to build and to run the binaries
  (PowerShell: `$env:Path = "C:\msys64\clang64\bin;$env:Path"`). Never mix ucrt64 and clang64
  binaries in one run.
- **WSL**: launch from PowerShell, not Git Bash, which rewrites `/mnt/...` arguments. Put
  multi-line commands in a script file and run `wsl -d <distro> -- bash /mnt/<path>/script.sh`;
  inline `$VAR` and `$(...)` get expanded by the Windows shell first. Builds under `/mnt/d` are
  slow and can fail with "could not be removed: Permission denied" when Defender locks
  try_compile files: rerun before debugging CMake. Two distros never share a build directory.
- **sccache**: when presets use it as the compiler launcher, start the server before a cold
  parallel build (`sccache --start-server`). A Linux sccache server reachable from Windows (WSL
  mirrored networking) breaks the Windows client with version-mismatch errors: stop the other
  side's server first.
- **VS Code**: if F7 builds a target that doesn't exist (`ALL_BUILD` under Ninja, `all` under
  MSBuild), fix the build preset or CMake Tools settings rather than adding fake targets.

## Checking a build

For each relevant preset: configure if needed, build, and run the tests (ctest or the repo's
runner) when asked or when the change touches tested code. Report in a table:

| Preset | Configure | Build | Warnings | Tests |
|---|---|---|---|---|

Then check what each MinGW executable and DLL needs at run time:

```
C:\msys64\<env>\bin\objdump.exe -p <binary> | findstr /C:"DLL Name"
```

Expect only Windows system DLLs and the project's own. `libstdc++-6.dll`, `libgcc_s_seh-1.dll`,
`libwinpthread-1.dll` or `libc++.dll` in the list mean the static runtime isn't applied to that
target.

## Porting a project to non-MSVC toolchains

Use this when Visual Studio or its Build Tools aren't available or allowed, or when the user
wants MinGW or clang presets added. clang-cl, and clang targeting `x86_64-pc-windows-msvc`, still
need the MSVC CRT and STL headers and libraries; the Windows SDK alone is not enough. Without
Build Tools the route is MSYS2 clang64 or ucrt64. Avoid the mingw64 environment, which uses the
old msvcrt.

1. **Inventory.** Targets and languages (C, C++, RC, C#); how dependencies are found; MSVC-only
   pieces (prebuilt `.lib` files, vendor SDKs, ATL, `#pragma comment(lib, ...)`, UTF-16 resource
   files).
2. **Presets.** A CMake 3.20+ presets file with a hidden base and `msys-<env>-<compiler>-ninja`
   configure and build presets. If the repo has shared toolchain files and target helpers, use
   them (a toolchain file picks compilers, not the generator or build type). Turn on
   `CMAKE_EXPORT_COMPILE_COMMANDS`. Don't hard-code `C:/msys64`: use an environment variable with
   a default in the preset.
3. **Gate MSVC-only features** in one place: an option such as `USE_<FEATURE>` that defaults ON
   only where supported, a check on `CMAKE_CXX_COMPILER_ID`, the sources excluded, and a matching
   preprocessor define for integration code. Never link MSVC-built static libraries into MinGW
   targets (`__security_cookie` and `__chkstk` errors): rebuild from source or use the MSYS2
   package.
4. **Windows libraries** that MinGW needs spelled out, on the target that uses them: for example
   ws2_32, mswsock, mfplat, mf, mfuuid, strmiids, ksuser, ksguid, gdiplus, ole32, uuid.
5. **Resources**: llvm-rc for clang, windres for gcc; RC files as UTF-8 (with a BOM where the
   tool needs one).
6. **Static runtime**: `-static-libgcc -static-libstdc++`, winpthread as a whole archive, static
   libc++ on clang64, applied to executables and shared libraries through one interface target or
   the shared helper. Don't duplicate what a shared helper already does. DLLs that can't be
   static (an MSYS2 OpenCV, say) get a post-build copy of exactly the needed set, computed from
   their dependencies, not a hand-kept list grown one missing-DLL dialog at a time.
7. **Modern CMake**: `target_*` commands, `list(APPEND)`, functions that take the target name, no
   global flags, the smallest change that works.
8. **Debugging**: VS Code launch configurations using CMake Tools' `${command:cmake.launchTargetPath}`,
   the environment's own gdb or lldb, and PATH set for that environment.
9. Build every preset, run the binaries, check their DLLs, and report.
