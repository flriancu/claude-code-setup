# Isolation recipes

Where and how to run tests without touching anything real.

## Targets, in order of preference
1. **A dev server you start** on a free port, in your own clone.
2. **A production build you serve** the way production does (same server software or script,
   same base path), on a free port, from a scratch folder — never from the folder the live
   server reads.
3. **The built file opened as `file://`** when the app is meant to work offline or as a
   single file.
4. **Never** the live instance. If production behaviour can only be seen there, ask.

## Per-agent clone
```
pwsh <skill>/scripts/isolated-clone.ps1 -Repo <repo> -Dest <scratch>/<area> -Ports 2
```
It clones with `--no-hardlinks`, runs the project's install (`npm ci --prefer-offline` when a
lockfile is present), and prints free ports. Do not junction or symlink `node_modules` from the
real repo: Vite (`node_modules/.vite`), Next, Jest and others keep caches there, and a second
server sharing them can break the user's running one.

## Serving a production build
- Static sites: build into the scratch folder (`vite build --outDir <scratch>/dist --emptyOutDir`)
  and serve it with the project's own server script copied into scratch, or `vite preview
  --port <p> --strictPort`, with the same base path as production.
- Apps with a backend: start it with a scratch database/data directory and a test config; never
  point it at real data.
- After changing server code, restart your test server: a running process keeps the old code.

## Browser automation
Use what the repo already uses (Playwright, playwright-core with the installed Edge/Chrome
channel). For phones: device emulation (viewport, touch, user agent) plus CPU throttling
(`Emulation.setCPUThrottlingRate` via CDP) to expose races that only show on slow devices.
Network: `context.setOffline`, `page.route` to abort or delay specific files.

**Faking third parties needs a sinkhole as well as routes.** `page.route` does not see every
request: requests a page sends while it unloads or enters the back-forward cache went straight
to the real host (it happened, with a fake token, against Google), and Firefox sent CORS
preflights past the routes (it happened too). In every browser context, send everything that
isn't local to a proxy that isn't there: `proxy: { server: 'http://127.0.0.1:1', bypass:
'localhost,127.0.0.1' }` in Playwright's `use` or `launch()`. It works in every engine;
Chromium's `--host-resolver-rules` does not cover Firefox or WebKit. To fake a host for real
(CORS, redirects, unload), serve it from a local HTTPS fake that the browser resolves to.
Then any request the routes miss fails instead of leaving the machine. Put this in every brief
that fakes a third party, and in the project's own e2e config.

## Cleanup
Each agent stops every server and browser it started and reports its ports as released.
Stop processes **only by the PID you started or the port you own** — never by name
(`taskkill /IM node.exe`, `Stop-Process -Name node`, `pkill node`, `killall chrome`): other
agents' servers and the user's own dev server run at the same time, and a by-name kill takes
them all down (it happened). Put this rule in every brief's hard rules. Scratch
clones stay until the user no longer needs the evidence.
