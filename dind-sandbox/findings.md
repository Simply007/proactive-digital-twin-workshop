# Workshop walkthrough validation — findings

**Date:** 2026-06-09
**Branch:** workshop-web-summer-camp-2026
**Tester:** Ondřej (driving), Claude (recording)

## Conclusion

**The current "unify on Railway" walkthrough is broken.** Railway cannot host NanoClaw, period. The recent commit `9e68670` ("unify workshop walkthrough on Railway + Anthropic, drop attendee-facing branching") needs to be reverted or rewritten before the workshop.

## Evidence

### 1. No NanoClaw image exists

`nanoclaw.sh` builds the agent container locally. It also installs Node, pnpm, and Docker Engine itself if missing. There is no `docker run nanocoai/nanoclaw` shortcut on Docker Hub or GHCR (verified via README at https://github.com/nanocoai/nanoclaw, 29.8k stars, release v2.0.64).

### 2. Railway has no empty-project shell

Pre-workshop Step 5 ("create a throwaway empty project, open the built-in shell, run `docker --version`") is impossible. Railway only exposes a shell *per running service*, not at the project level.

### 3. Railway blocks Docker-in-Docker

Deployed `docker:dind` image with `DOCKER_TLS_CERTDIR=`. Container crashed on boot. Logs show:

- `Permission denied` mounting cgroups
- `Operation not permitted` on overlayfs
- `iptables` setup failing
- `vfs_table: Could not find device or directory`

Screenshot: `04-railway-dind-crash.png`. These are kernel-level operations dockerd needs and Railway's runtime refuses. No `--privileged` exposure, no workaround.

## Implication for the workshop

NanoClaw requires:
- A real Linux host (not a sandboxed container)
- Root or sudo
- Working Docker daemon
- Ability to spawn sibling containers per agent

Railway provides none of these. The only free tier in the original walkthrough table that does is **Oracle Cloud Always Free** (4 ARM OCPU, 24 GB RAM, real root, real Docker — at the cost of a $1 CC hold).

## Recommended path

Revert commit `9e68670` (and possibly the 4-5 commits before it that built up to the Railway-only decision). Reinstate Oracle Cloud Always Free as the primary host. Keep Hostinger as the paid easy-button, as before.

The "CC required for $1 hold" friction is real but solvable in pre-workshop email: explicit screenshot of the Oracle CC step, "no charge will be made," and a hotline for stuck attendees a week before the event.

## Oracle Cloud verification — live test (2026-06-09)

Signed up fresh. Findings:

### Signup
- Home region picked: **Netherlands Northwest (Amsterdam)** — `eu-amsterdam-1`.
- CC $1 hold processed and **refunded same session** (no multi-day verification limbo).
- Account usable for instance creation immediately.
- Signup time: ~15 min including forms + verification.
- Verdict: signup friction is real but **same-session** if everything aligns. Pre-workshop lead time of ~1 week is sufficient buffer.

### Instance create wizard — friction points logged
1. Default "create new VCN" path produces info warning *"You must select a public subnet to assign a public IPv4 address"* — confusing because the auto-created subnet IS public. Walkthrough needs explicit "pick public subnet" step.
2. Default boot volume is **47 GB**. Bumped to 100 GB (still inside Always Free 200 GB cap) to give Docker + per-agent containers room.
3. Image picker shows three Ubuntu 22.04 variants. Correct choice for A1.Flex (ARM) is **"Canonical Ubuntu 22.04"** (NOT "Minimal" — full image has `git`, `curl`, `wget` pre-installed). The image listing is multi-arch under one name; OCI auto-selects the aarch64 build for ARM shapes.
4. SSH key step asks the right question ("are you sure you want to create without SSH?") — good attendee safety net.

### A1 ARM capacity — **BLOCKED in Amsterdam**
Attempted `VM.Standard.A1.Flex` (1 OCPU / 6 GB) in `eu-amsterdam-1` AD-1. Result:

> **Out of capacity for shape VM.Standard.A1.Flex in availability domain AD-1.** Create the instance in a different availability domain or try again later.

Amsterdam has only one AD, so "try another AD" is misleading advice from Oracle. The only path forward in Amsterdam is **persistent retry until capacity opens** (hours-to-days, community-known pattern).

Screenshot: `08-oracle-amsterdam-out-of-capacity.png`.

### What this means for the workshop

- **Always Free is bound to home region** — attendees cannot switch to Frankfurt/Madrid after signup without creating a new account.
- The pre-workshop email **must** recommend home regions with better A1 inventory at signup time. Strongest candidates (community reports as of 2026): **Frankfurt (eu-frankfurt-1), Madrid (eu-madrid-1), Stockholm (eu-stockholm-1)**. Avoid: **Amsterdam, London, Paris**.
- Attendees who already have an Oracle Cloud account in a bad region need a path to a new tenancy or a fallback host on workshop day.
- Presenter (Ondřej) currently has Amsterdam — needs either to spin up a retry script over the next few weeks until A1 opens, or create a second tenancy in Frankfurt for the presenter demo.

### Oracle Cloud — DROPPED as workshop host

**Decision (2026-06-09):** Oracle Always Free A1 is unreliable enough at the regional level that *any* attendee can be blocked on workshop day with no recourse. Even if Frankfurt has capacity today, it may be full on July 2. Always Free + home-region-lock + capacity scarcity is a combination the workshop cannot survive.

Oracle stays in the "where to go next" wrap-up section as a forever-free option for attendees who want to migrate after the workshop, with explicit "capacity is hit or miss" warning.

## DinD sandbox validation — additional findings (2026-06-09)

While validating the local-Docker walkthrough, we also tried running the install end-to-end inside a privileged Docker-in-Docker sandbox container (to avoid touching the host directly during the validation). Findings worth keeping for future testers and the workshop doc:

### NanoClaw requires a Debian/Ubuntu host distro
`setup/install-node.sh` calls NodeSource's `setup_*.x` shell script, which prints `Error: This script is only supported on Debian-based systems.` and exits on Alpine / RHEL / Oracle Linux / Arch / etc.

**Impact:** The official `docker:dind` image (Alpine-based) **cannot host NanoClaw directly**. Same for any RHEL-family base. The host options for NanoClaw narrow to Debian / Ubuntu (and their derivatives like Linux Mint).

### DinD-specific gotchas (do not occur on a real VPS or laptop Docker)
These all show up only when running NanoClaw *inside* an unprivileged-ish container; they don't appear when NanoClaw runs on the actual host:

1. **`$USER` env var unset in `docker exec` sessions.** `setup/install-docker.sh` references `$USER` and dies with `unbound variable` on the `usermod -aG docker $USER` step. Real SSH logins set `$USER` automatically; `docker exec` does not, unless you pass `-e USER=<name>` explicitly.
2. **No systemd inside the container.** The script then tries `sudo systemctl start docker` to bring up the daemon; this fails with `System has not been booted with systemd as init system (PID 1)`. On a real VPS, systemd runs and the call succeeds.
3. **Overlay-on-overlay storage driver failure.** If the inner dockerd defaults to `overlay2` while Docker Desktop's outer storage is also `overlay2`, builds fail with `mount: overlay: invalid argument` when BuildKit tries to set up cache mounts. Workaround: pre-configure the inner dockerd with `/etc/docker/daemon.json` → `{"storage-driver":"vfs"}` **before** dockerd ever starts. VFS works but image builds are significantly slower and use much more disk.
4. **Minimal Ubuntu Docker image (`ubuntu:22.04`) ships without `sudo` or `git`.** The cloud Ubuntu images attendees use on Hetzner / AWS have these pre-installed; the Docker image does not. Pre-install `sudo curl git ca-certificates` before running the script.

### Recommended DinD sandbox recipe (if anyone tests this path again)
Based on what worked: Ubuntu base + pre-installed Docker engine + VFS storage driver + a non-root nanoclaw user + `$USER` env var passed in:

```bash
docker run -d --name nanoclaw-sandbox \
  --privileged \
  -v $HOME/nanoclaw-workspace:/work \
  -w /work \
  --restart unless-stopped \
  buildpack-deps:jammy-curl \
  bash -c "apt update && apt install -y sudo && \
           curl -fsSL https://get.docker.com | sh && \
           mkdir -p /etc/docker && \
           echo '{\"storage-driver\":\"vfs\"}' > /etc/docker/daemon.json && \
           sleep infinity"
```

Then create the `nanoclaw` user, add to `sudo` and `docker` groups, chown `/work`, start `dockerd` as a background process (no systemd), and `docker exec -it -u nanoclaw -e USER=nanoclaw nanoclaw-sandbox bash` before running `bash nanoclaw.sh`.

### Conclusion for the workshop
Local DinD has too many gotchas for attendees to debug in a 2.5h hands-on session. It's a fine **isolated validation environment for the presenter**, but it should not be presented as an attendee path. The workshop doc keeps **"NanoClaw on your laptop's Docker directly"** as the primary path, with a note acknowledging the security trade-off (NanoClaw's install script touches the host) and pointing security-conscious attendees to a cloud VM (Hetzner CAX11) or a local Lima VM as the isolated alternative.

### More findings from the DinD validation (2026-06-09 continued)

5. **VFS storage driver is significantly slower for builds.** First NanoClaw agent image build inside the DinD sandbox took **12m 16s**. The same build on a real host with `overlay2` typically takes 3-4 min. The slowdown is VFS copying every layer instead of overlaying. This is one more reason to avoid DinD for attendees: a 12-min build during the workshop kills the schedule.

6. **OneCLI gateway can't auto-detect a bind address inside a container.** After the build succeeds, NanoClaw's setup tries to install OneCLI (the credential vault). OneCLI errors with:
   > `Could not safely determine a bind address for OneCLI. Please set ONECLI_BIND_HOST and try again`

   Inside a sandbox container, no interface looks like a "real" host IP. Fix: bake `ONECLI_BIND_HOST=127.0.0.1` into `/etc/environment` AND `/etc/bash.bashrc` of the sandbox during creation. `/etc/environment` alone is **not enough** because PAM is bypassed by `docker exec` — bash sub-shells won't load it. For real-VPS attendees this should not appear (the VPS has a public interface OneCLI detects); for any container-based environment it needs to be set explicitly.

7. **NanoClaw's auto-pairing fails when polling lags behind code rotation.** NanoClaw's setup wizard regenerates pairing codes every few seconds and invalidates earlier ones. If the agent service isn't running when the user sends the code (e.g., systemd-based service start failed silently in a container with no systemd), the code sits in Telegram's queue. Once the agent finally starts, it consumes the entire queue at once including old invalidated codes, and the pairing step exits with `Pairing 7702 disappeared` even though the user sent the right one. Fix: drain Telegram's queue with `getUpdates?offset=-1`, manually start the agent with `nohup node dist/index.js &`, then redo `pair-telegram`. Real VPS users running systemd don't see this because their service is up before the wizard's first code.

8. **Agent containers can't reach OneCLI by default in DinD.** NanoClaw configures each spawned agent container with `https_proxy=http://...@host.docker.internal:10255` and adds `host.docker.internal:host-gateway` to `/etc/hosts`. In DinD, `host-gateway` resolves to the inner bridge gateway (e.g., `172.18.0.1`), but OneCLI is bound to **the sandbox's `127.0.0.1`** (loopback) — unreachable from the bridge. Agent calls show `Error: API retry (retryable: true)` indefinitely. Fix: install `socat` in the sandbox and forward `172.18.0.1:10254-10255` to `127.0.0.1:10254-10255`:
   ```bash
   apt install -y socat
   nohup socat TCP-LISTEN:10254,fork,reuseaddr,bind=172.18.0.1 TCP:127.0.0.1:10254 &
   nohup socat TCP-LISTEN:10255,fork,reuseaddr,bind=172.18.0.1 TCP:127.0.0.1:10255 &
   ```
   Real-host attendees never hit this because OneCLI binds to host loopback and Docker Desktop's `host.docker.internal` is wired to that same loopback by design.

9. **OneCLI bind address leaks into agent replies as a URL.** When NanoClaw's agent prompts the user to connect a third-party service (e.g., OpenAI for voice transcription), it emits the OneCLI connection URL using the bind host — `http://127.0.0.1:10254/connections/...`. On a real laptop install, this works (host loopback = the user's Mac). In a sandbox, `127.0.0.1` is the sandbox's loopback and the user's browser can't reach it. Fix: spin up a port-forwarder side-container that shares the sandbox's network:
   ```bash
   docker run -d --name nanoclaw-onecli-proxy \
     --network=container:nanoclaw-sandbox \
     -p 10254:10254 \
     alpine sleep infinity
   ```
   Then the URL works as-is from the Mac browser. Real-host attendees never see this issue.

### End-to-end DinD validation (2026-06-10)
After applying all 8 fixes, the full Exercise 1 flow worked: agent container spawned, Claude API call reached via OneCLI proxy, Telegram bot ("Ondrejbot") replied to `ping` with a contextual greeting. First-reply latency: ~3 minutes (container spawn + first cold-start LLM call under VFS storage). Subsequent messages are <10s.

### Bottom line for the workshop walkthrough
The presenter-side validation in DinD revealed **8 distinct DinD-specific gotchas** (Debian-only, `$USER` unset, no systemd, overlay-on-overlay, VFS build slowness, OneCLI bind address, code-rotation race, agent-to-OneCLI network bridge). None of these affect attendees running NanoClaw directly on their host. The walkthrough keeps "**run on your laptop's Docker**" as the path. The DinD recipe (`_outputs/workshop-recording/setup-dind-sandbox.sh`) and the manual fixes documented here exist only for presenter-side validation when the laptop must stay clean.
