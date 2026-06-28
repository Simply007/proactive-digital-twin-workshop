# Host Comparison

Why the workshop runs on local Docker, and the VPS providers we tried (so you don't repeat our mistakes).

## Agent framework

This kit runs **NanoClaw** (MIT, container-per-agent, native Anthropic Agents SDK) — small (~35k tokens, fits one Claude context), self-contained, and the right size for a 2.5h workshop. One `CLAUDE.local.md` per agent + composed fragments + skills. Installed by cloning NanoClaw into the sandbox and running `bash nanoclaw.sh`.

## VPS providers we tried (and what happened)

Tested 2026-06-09/10 before settling on **local Docker on the attendee's laptop**. Full crash logs and screenshots in [`../workshop/findings.md`](../workshop/findings.md) and [`../workshop/recordings/`](../workshop/recordings/).

| Provider | Free? | CC required at signup | Verdict | What broke / why |
|---|---|---|---|---|
| **Local Docker** (Docker Desktop / Engine on attendee laptop) | Free | No | **Picked.** Only path that works for every attendee on workshop day. | Trade-off: laptop sleep = agent dies. Wrap-up covers migration recipes. |
| Railway | $5 starter credit, no CC | No | **Excluded.** | Blocks Docker-in-Docker entirely. `--privileged` denied, `dockerd` crashes on cgroup mount with `Permission denied`. NanoClaw cannot run. See screenshot `04-railway-dind-crash.png`. |
| Oracle Cloud Always Free | Forever-free | $1 hold (refunded same session) | **Excluded.** | A1 ARM is region-locked to your signup home region and frequently "Out of capacity" in EU regions. Amsterdam confirmed dead (`08-oracle-amsterdam-out-of-capacity.png`); community reports same in London, Paris, Amsterdam. Frankfurt / Madrid / Stockholm have better odds but no guarantees. Cannot rely on it for workshop day. |
| AWS Free Tier (`t4g.small`) | Free 12 months, then ~$15/mo | $1 hold | **Demoted to wrap-up.** | Works fine, but the 12-month limit needs explicit attendee disclosure. Recommended for "free for the workshop year" path. |
| Hetzner CAX11 | Paid (€4.51/mo) | Yes | **Demoted to wrap-up as recommended always-on host.** | The cleanest cloud option. €5/mo for a real ARM Linux box. No nesting, no capacity roulette. The honest "buy a coffee instead" trade. |
| Hostinger (OpenClaw Managed / VPS) | Paid (24-mo commitment) | Yes | **Demoted to wrap-up "easy button" line.** | Pre-loaded AI credits, zero setup. But 24-month minimum and locks you into the OpenClaw framework specifically. Not workshop-day friendly. |
| GCP Always Free (`e2-micro`) | Forever-free | Yes | **Excluded silently.** | 0.25 vCPU / 1 GB RAM is below the NanoClaw container floor. |
| Render free tier | Free Hobby | No | **Excluded silently.** | 512 MB RAM, web services only, no Docker-in-Docker. |
| Fly.io | 2 VM hours / 7-day trial | Yes | **Excluded silently.** | Trial expires inside the conference window. |

## Bottom-line guidance

- **Workshop day**: local Docker on the attendee's laptop. Pre-installing Docker is the only hard prerequisite.
- **After the workshop, for always-on**: Hetzner CAX11 (€5/mo, recommended), AWS `t4g.small` (12 months free), or a Mac Mini / Raspberry Pi at home if you already own one.
- **Forever-free** is technically Oracle Always Free A1, but treat it as a lottery ticket, not a plan.
