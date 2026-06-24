# Architecture

Quick diagram of what this kit spins up and why.

## What `docker compose up` produces

```
your laptop (macOS / Linux / Windows + WSL2)
└── Docker Desktop / Docker Engine
    └── agent-sandbox container  (privileged, Ubuntu 22.04 base)
        ├── inner dockerd  (storage-driver=vfs, started by entrypoint.sh)
        │   ├── nanoclaw-v2-* container  (the actual agent runtime, spawned per agent group)
        │   ├── onecli container  (credential vault, port 10254)
        │   └── onecli-postgres container  (vault storage)
        ├── socat bridges  (bridge-gateway IP read at runtime by entrypoint.sh)
        │   ├── <bridge-gw>:10254 → 127.0.0.1:10254  (so inner containers can reach OneCLI)
        │   └── <bridge-gw>:10255 → 127.0.0.1:10255
        └── /work  (bind-mounted from ${AGENT_WORKSPACE} on your host)
            └── nanoclaw/  (cloned during setup: git clone + bash nanoclaw.sh)
                ├── dist/index.js  (the agent process)
                ├── data/v2.db
                ├── data/telegram-pairings.json
                ├── logs/agent.log
                └── (agent's per-group CLAUDE.local.md files)
```

Why each piece exists:

| Piece | Why |
|---|---|
| `--privileged` outer sandbox | Required for the inner `dockerd` to mount cgroups + overlay namespaces. Local Docker Desktop allows this; Railway and most managed PaaS do not (that's why we can't use them). |
| Inner `dockerd` with VFS | NanoClaw's container-per-agent model needs Docker. VFS instead of overlay2 because overlay-on-overlay fails on Docker Desktop. |
| socat bridges | OneCLI binds to the sandbox's `127.0.0.1`. Inner agent containers reach it via `host.docker.internal` → the default bridge gateway (auto-assigned by Docker — `172.17.0.1` if free, else `172.18.0.1`, …; `entrypoint.sh` reads it at runtime). socat forwards that gateway to the loopback so the connection completes. |
| Port publish `127.0.0.1:10254-10255` | When the agent prints a OneCLI URL ("connect OpenAI here: http://127.0.0.1:10254/..."), your Mac browser opens that exact URL because the published port maps to the same address inside the sandbox. |
| Bind mount `/work` | Agent state survives container restart. You can also read/edit `CLAUDE.local.md` from your host with any editor while the agent is running. |

## What's NOT in scope

- HTTPS termination / public exposure: the workshop's "always-on" story moves the agent to Hetzner / AWS / a home Pi after the session. The sandbox stays local.
- Multi-attendee shared sandbox: each attendee runs their own copy of `docker compose up` on their own laptop.
- Cluster / orchestration: one container, one process tree, one host. Intentionally simple for the workshop.
