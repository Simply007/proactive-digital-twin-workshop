# Host Comparison

Why the workshop runs on a local Ubuntu VM, and the VPS providers we tried (so you don't repeat our mistakes). This is general deployment reference.

## Agent framework

This kit runs **NanoClaw** (MIT, container-per-agent, native Anthropic Agents SDK) - small (~35k tokens, fits one Claude context), self-contained, and the right size for a 2.5h workshop. One `CLAUDE.local.md` per agent + composed fragments + skills. Installed by cloning NanoClaw and running `bash nanoclaw.sh`.

## VPS providers we tried (and what happened)

Tested 2026-06-09/10 before settling on **a local Ubuntu VM on the attendee's laptop**.

| Provider | Free? | CC required at signup | Workshop-day fit | What broke / why |
|---|---|---|---|---|
| **Local Ubuntu VM** (UTM / VirtualBox / KVM on the attendee's laptop) | Free | No | **Picked.** Works for every attendee, no signup, no credit card. | Trade-off: laptop sleep pauses the VM and the agent goes quiet. Wrap-up covers migration to an always-on host. |
| Railway | $5 starter credit, no CC | No | **Excluded.** | Does not allow the privileged containers NanoClaw needs to run its per-agent Docker. `--privileged` is denied and the Docker daemon crashes on cgroup mount with `Permission denied`, so NanoClaw cannot run. |
| Oracle Cloud Always Free | Forever-free | $1 hold (refunded same session) | **Excluded.** | A1 ARM is region-locked to your signup home region and frequently "Out of capacity" in EU regions. Amsterdam confirmed dead; community reports same in London and Paris. Frankfurt / Madrid / Stockholm have better odds but no guarantees. Cannot rely on it for workshop day. |
| AWS Free Tier (`t4g.small`) | Free 12 months, then ~$15/mo | $1 hold | **After-workshop option.** | Works fine, but the 12-month limit needs explicit disclosure. |
| Hetzner CAX11 | Paid (~€4.51/mo) | Yes | **After-workshop option.** | A clean cloud option: a real ARM Linux box, no nesting, no capacity roulette. |
| Hostinger (OpenClaw Managed / VPS) | Paid (24-mo commitment) | Yes | **After-workshop option.** | Pre-loaded AI credits, zero setup. But a 24-month minimum and locks you into the OpenClaw framework specifically. Not workshop-day friendly. |
| GCP Always Free (`e2-micro`) | Forever-free | Yes | **Excluded.** | 0.25 vCPU / 1 GB RAM is below the NanoClaw container floor. |
| Render free tier | Free Hobby | No | **Excluded.** | 512 MB RAM, web services only, cannot run the privileged Docker NanoClaw needs. |
| Fly.io | 2 VM hours / 7-day trial | Yes | **Excluded.** | Trial expires inside the conference window. |

## Bottom-line guidance

- **Workshop day**: a local Ubuntu VM on the attendee's laptop. A booted Ubuntu LTS VM is the only hard prerequisite.
- **After the workshop, for always-on**: a VPS (Hetzner, AWS, Oracle, GCP, Azure, Hostinger, Railway) or a home box (Mac Mini, Raspberry Pi). Move only after you are confident in the local VM playground. Each follows the same shape: provision Linux, then `git clone nanoclaw && bash nanoclaw.sh`.
- **Forever-free** is technically Oracle Always Free A1, but treat it as a lottery ticket, not a plan.
