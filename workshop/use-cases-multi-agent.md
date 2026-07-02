# Multi-Agent Use Cases

Two demos that show your agent reaching beyond a single brain - spawning a team of agents for the puzzle, and rotating through OpenRouter's free models for the research. Both run from a single DM to your NanoClaw agent.

---

## Use case 1: Guess the Destination (puzzle)

One DM makes your agent spin up **four agents**, each holding one secret clue. Each agent analyzes only its own clue, then they collaborate and land on the answer: **Opatija, Croatia** - the room you are sitting in. When they are done, all four agents are put to sleep.

### Why this demo

- Each agent works in its own isolated context - the clues stay private until the collaboration phase. That is the same isolation model NanoClaw uses for agent groups, shown in miniature.
- The lifecycle is part of the lesson: agents are spawned for a job and put to sleep when the job is done.
- The meta payoff: the destination the agents guess is the workshop venue. The room always reacts.

### How to run it

Copy-paste the whole prompt below as **one DM** to your NanoClaw agent on Telegram. Inside the container, Claude spawns the four agents as subagents, waits for their findings, runs the collaboration phase, and reports back in one message.

### The prompt

```markdown
# Multi-Agent Puzzle Demo: Guess the Destination

You are running a 4-agent collaboration puzzle.

The final answer should be:

**Opatija, Croatia**

But do not reveal this answer to the agents at the beginning.

## Goal

Each agent receives one clue.
Each agent must analyze only their own clue first.
After all agents provide their findings, the agents must collaborate and guess the shared destination.

The final output must show:

1. Each agent's original clue
2. Each agent's interpretation
3. What each agent contributed to the group
4. How the agents combined the clues
5. The final guessed answer
6. Why the answer is **Opatija, Croatia**
7. Confirmation that all four agents were put to sleep

---

## Agent 1 Prompt

You are Agent 1.

Your clue is:

> A long seaside promenade stretches along the Adriatic coast. It connects elegant coastal towns and is famous for walking, sea views, old villas, and relaxing conference breaks.

Tasks:

- Explain what this clue might refer to.
- Extract the important hints.
- Do not guess the final destination yet.
- Share your findings with the other agents.

---

## Agent 2 Prompt

You are Agent 2.

Your clue is:

> A famous statue of a young woman with a bird stands by the sea. It is one of the most recognizable symbols of the town.

Tasks:

- Explain what this clue might refer to.
- Extract the important hints.
- Do not guess the final destination yet.
- Share your findings with the other agents.

---

## Agent 3 Prompt

You are Agent 3.

Your clue is:

> A historic villa with a beautiful park helped turn this place into one of the earliest luxury tourism destinations on the Croatian coast.

Tasks:

- Explain what this clue might refer to.
- Extract the important hints.
- Do not guess the final destination yet.
- Share your findings with the other agents.

---

## Agent 4 Prompt

You are Agent 4.

Your clue is:

> A developer conference called Web Summer Camp takes place here, bringing web developers together near the sea.

Tasks:

- Explain what this clue might refer to.
- Extract the important hints.
- Do not guess the final destination yet.
- Share your findings with the other agents.

---

## Collaboration Phase

After all four agents respond:

1. Read all agent findings.
2. Identify overlapping hints.
3. Discuss what destination fits all clues.
4. Resolve any uncertainty.
5. Agree on one final answer.

---

## Cleanup

Once the final answer is agreed:

1. Put all four agents to sleep (dismiss them).
2. No agent stays running after the puzzle ends.
3. Confirm in the final output that all four agents were put to sleep.

---

## Final Answer Format

Return the result in this structure:

### Agent Findings

#### Agent 1
- Clue:
- Interpretation:
- Key hints:

#### Agent 2
- Clue:
- Interpretation:
- Key hints:

#### Agent 3
- Clue:
- Interpretation:
- Key hints:

#### Agent 4
- Clue:
- Interpretation:
- Key hints:

### Collaboration Summary

Explain how the agents combined their clues.

### Final Guess

**Opatija, Croatia**

### Why This Answer Fits

Explain why all four clues point to Opatija, Croatia.

### Cleanup Confirmation

Confirm that all four agents were put to sleep once they finished.
```

**Difficulty:** Easy - one copy-paste DM.

**Wow:** High - live multi-agent orchestration, and the answer is the town outside the window.

---

## Use case 2: OpenRouter Researcher (one agent, rotating models)

Your agent runs a **4-step research workflow** through **OpenRouter**, rotating to the next available free model for each step - four steps, four different models - then compares the outputs and merges the best findings into one report on the EU AI Act and last quarter's AI news.

### Why this demo

- Shows one agent reaching beyond its own model: every research step is answered by a different free OpenRouter model.
- The comparison phase makes model differences visible - the agent has to judge quality, not just collect text.
- The topic is real homework for the audience: the EU AI Act affects everyone in the room.

### Setup (short)

1. Log in at <https://openrouter.ai> and create an API key (`sk-or-v1-...`).
2. Put the key into **OneCLI** (the credential vault): open the OneCLI dashboard (find it with `sudo docker ps` - port `10254`, e.g. `http://127.0.0.1:10254`), go to Connections, add OpenRouter, paste the key.
3. Run the prompt below as one DM to your agent.

**The API key is a password** - it goes only into the OneCLI form. Never commit it to GitHub, never paste it in shared chats.

### The prompt

```markdown
# OpenRouter Research Demo: One Agent, Rotating Models

You are running a 4-step research workflow using OpenRouter.

Do not spawn any subagents. You do all four steps yourself.

Use only models available through OpenRouter. Prefer free-tier models when possible.

The goal is to demonstrate:

- routing tasks through OpenRouter
- one agent using multiple models
- round-robin model selection
- comparing outputs
- merging the results into one final report

## Topic

Research the **EU AI Act** and summarize the most important AI-related news from the **last quarter**.

## Instructions

Your tasks:

1. List the free models available to you on OpenRouter and set a rotation order.
2. Run the four research steps below, sending each step through the next model in the rotation (round-robin).
3. Record which model answered which step.
4. Compare the quality of the answers.
5. Merge the best findings into one final report.
6. Clearly show which model contributed what.

---

## Step 1: AI Act Overview

Send this step through the first model in the rotation.

Research the EU AI Act at a high level.

Focus on:

- What the EU AI Act is
- Why it matters
- Who it affects
- Key obligations
- Important enforcement dates

Return:

- 5 bullet summary
- 3 important risks for companies
- 3 practical recommendations

---

## Step 2: Developer Impact

Send this step through the next model in the rotation.

Research how the EU AI Act affects software developers and AI application builders.

Focus on:

- AI system providers
- AI system deployers
- documentation requirements
- transparency requirements
- risk classification
- open-source considerations

Return:

- developer-focused summary
- practical checklist
- unclear or risky areas

---

## Step 3: Last Quarter AI News

Send this step through the next model in the rotation.

Research important AI news from the last quarter.

Focus on:

- regulation
- model releases
- enterprise AI adoption
- open-source AI
- developer tooling

Return:

- top 5 news items
- why each matters
- possible relevance for developers

---

## Step 4: Conference Angle

Send this step through the next model in the rotation.

Turn the research into a workshop-friendly narrative.

Focus on:

- what would be interesting for developers
- what could become a demo
- what could become a discussion question
- what attendees should remember

Return:

- 3 workshop talking points
- 3 audience questions
- 1 suggested hands-on exercise

---

# Comparison Phase

After all four steps finish:

1. Display every step's raw result.
2. Identify overlapping information.
3. Identify contradictions or uncertainty.
4. Compare answer quality.
5. Explain which model performed best and why.
6. Merge the findings into one final result.

---

# Final Output Format

## Step Results

### Step 1: AI Act Overview
- Model used:
- Key findings:
- Weaknesses:

### Step 2: Developer Impact
- Model used:
- Key findings:
- Weaknesses:

### Step 3: Last Quarter AI News
- Model used:
- Key findings:
- Weaknesses:

### Step 4: Conference Angle
- Model used:
- Key findings:
- Weaknesses:

## Comparison

Explain how the outputs differed.

## Merged Final Report

Create a concise final summary for workshop participants.

## Conclusion

Explain:

- how OpenRouter helped
- why model rotation was useful
- where the models disagreed
- what you changed in the final answer
```

**Difficulty:** Medium - needs an OpenRouter account and the key in OneCLI first.

**Wow:** High - four models answering side by side, and one agent judging them openly.
