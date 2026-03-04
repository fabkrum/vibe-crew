/** Mermaid diagram sources for architecture pages */

export const systemDiagram = `flowchart TD
  subgraph Plugin["claude-plugin-vibe-crew"]
    Manifest[".claude-plugin/plugin.json"]
    MCP[".mcp.json<br/>10 MCP Servers"]
    Settings["settings.json<br/>Permissions"]
    Hooks["hooks/hooks.json<br/>Event Bindings"]
    Scripts["scripts/<br/>~80 Bash Scripts"]
    Agents["agents/<br/>14 Agent Prompts"]
    Skills["skills/<br/>31 Slash Commands"]
  end

  subgraph Runtime[".vibecrew/ (Per-Project)"]
    Config["config.json"]
    State["state.json"]
    Backlog["backlog.json"]
    Sessions["sessions/"]
    Scores["scores/"]
    Architecture["architecture/<br/>5 .mmd files"]
  end

  CC["Claude Code"] --> Manifest
  CC --> MCP
  CC --> Settings
  CC --> Hooks
  Hooks --> Scripts
  CC --> Skills
  Skills --> Agents
  Agents --> Runtime

  style Plugin fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Runtime fill:#18181b,stroke:#4ade80,color:#fafafa
  style CC fill:#7c3aed,stroke:#a78bfa,color:#fafafa
`;

export const agentInteractionDiagram = `flowchart TD
  User((User)) --> SS[Session Startup<br/>Haiku]
  SS --> WO[Workflow Orchestrator<br/>Opus]

  WO -->|Tier 1| SSC[Stack Scout<br/>Opus]
  WO -->|Tier 1| OP[Opponent Processor<br/>Opus]
  WO -->|Tier 2| BLD[Builder<br/>Opus]

  SSC -->|TDR| WO
  OP -->|Risk Assessment| WO

  BLD --> VER[Verifier<br/>Haiku]
  BLD --> CR[Code Reviewer<br/>Opus]

  VER -->|Results| BLD
  CR -->|Findings| BLD

  BLD -->|/wrap| PC[Performance Coach<br/>Opus]
  PC -->|Score + Coaching| DG[Doc Generator<br/>Sonnet]

  WO -->|/audit| SA[Security Auditor<br/>Opus]
  WO -->|/simplify| CS[Code Simplifier<br/>Opus]
  WO -->|/heal| CH[CI Healer<br/>Opus]
  WO -->|/onboard| CA[Code Auditor<br/>Opus]
  WO -->|/system-review| SR[System Reviewer<br/>Opus]

  style User fill:#7c3aed,stroke:#a78bfa,color:#fafafa
  style SS fill:#18181b,stroke:#fbbf24,color:#fafafa
  style WO fill:#18181b,stroke:#a78bfa,color:#fafafa
  style SSC fill:#18181b,stroke:#a78bfa,color:#fafafa
  style OP fill:#18181b,stroke:#a78bfa,color:#fafafa
  style BLD fill:#18181b,stroke:#a78bfa,color:#fafafa
  style VER fill:#18181b,stroke:#fbbf24,color:#fafafa
  style CR fill:#18181b,stroke:#a78bfa,color:#fafafa
  style PC fill:#18181b,stroke:#a78bfa,color:#fafafa
  style DG fill:#18181b,stroke:#60a5fa,color:#fafafa
  style SA fill:#18181b,stroke:#a78bfa,color:#fafafa
  style CS fill:#18181b,stroke:#a78bfa,color:#fafafa
  style CH fill:#18181b,stroke:#a78bfa,color:#fafafa
  style CA fill:#18181b,stroke:#a78bfa,color:#fafafa
  style SR fill:#18181b,stroke:#a78bfa,color:#fafafa
`;

export const tierFlowDiagram = `flowchart LR
  subgraph T1["Tier 1: Foundation"]
    direction TB
    V["VISION.md"] --> DS["Design System"]
    DS --> TDR["TDR"]
    TDR --> ARCH["Architecture<br/>Diagrams"]
    ARCH --> RM["Roadmap"]
    RM --> CMD["CLAUDE.md"]
  end

  subgraph T2["Tier 2: Feature Cycle"]
    direction TB
    P["Plan"] --> UID["UI Design"]
    UID --> C["Code"]
    C --> T["Test"]
    T --> R["Review"]
    R --> D["Docs"]
    D -.->|next feature| P
  end

  T1 -->|Phase Gate| T2

  style T1 fill:#18181b,stroke:#a78bfa,color:#fafafa
  style T2 fill:#18181b,stroke:#4ade80,color:#fafafa
`;

export const hooksDiagram = `flowchart TD
  subgraph Events["Claude Code Lifecycle Events"]
    E1["SessionStart"]
    E2["PreToolUse<br/>(Write/Edit)"]
    E3["PreToolUse<br/>(Bash)"]
    E4["PostToolUse<br/>(Write/Edit)"]
    E5["Notification"]
    E6["Stop"]
  end

  subgraph Guards["Pre-Action Guards (block or allow)"]
    PG["phase-gate.sh<br/>Block code before foundation"]
    RP["restrict-paths.sh<br/>Block writes outside project"]
    PD["protect-data.sh<br/>Block destructive commands"]
    VPT["validate-phase-transition.sh<br/>Enforce phase ordering"]
    VS["validate-signal.sh<br/>Validate signal schema"]
  end

  subgraph Post["Post-Action Processors"]
    FC["format-code.sh<br/>Auto-format on save"]
    NT["notify.sh<br/>OS notifications"]
  end

  subgraph Stop["Session End Checks"]
    CC["check-context.sh<br/>60%/80% warnings"]
    CG["cost-guardrails.sh<br/>Cost thresholds"]
    CL["claude-md-lint.sh<br/>CLAUDE.md validation"]
    QG["quality-gate.sh<br/>Typecheck/lint/build"]
  end

  subgraph Init["Session Init"]
    SS["session-startup.sh<br/>Environment check"]
    SY["sync-state.sh<br/>State reconciliation"]
    ER["error-recovery.sh<br/>Clear stale locks"]
    CR["compact-reinject.sh<br/>Re-inject after compact"]
  end

  E1 --> Init
  E2 --> Guards
  E3 --> PD
  E2 --> VS
  E4 --> FC
  E5 --> NT
  E6 --> Stop

  style Events fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Guards fill:#18181b,stroke:#f87171,color:#fafafa
  style Post fill:#18181b,stroke:#4ade80,color:#fafafa
  style Stop fill:#18181b,stroke:#fbbf24,color:#fafafa
  style Init fill:#18181b,stroke:#60a5fa,color:#fafafa
`;

export const commandsDiagram = `flowchart LR
  subgraph User["User Input"]
    CMD["/slash-command"]
  end

  subgraph Skill["Skill Layer"]
    SM["SKILL.md<br/>YAML frontmatter<br/>+ workflow body"]
  end

  subgraph Routing["Agent Routing"]
    direction TB
    SO["Script-Only<br/>(zero tokens)"]
    SA["Single Agent"]
    MA["Multi-Agent<br/>Orchestration"]
  end

  subgraph Agents["Agent Execution"]
    direction TB
    WO["Orchestrator"]
    BLD["Builder"]
    VER["Verifier"]
    PC["Perf Coach"]
    DG["Doc Generator"]
  end

  subgraph Output["Results"]
    ST["State Updates<br/>.vibecrew/*.json"]
    GIT["Git Operations<br/>branch/commit/PR"]
    FILES["Source Code<br/>& Documentation"]
  end

  CMD --> SM
  SM --> Routing
  SO --> ST
  SA --> Agents
  MA --> Agents
  Agents --> Output

  style User fill:#7c3aed,stroke:#a78bfa,color:#fafafa
  style Skill fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Routing fill:#18181b,stroke:#fbbf24,color:#fafafa
  style Agents fill:#18181b,stroke:#60a5fa,color:#fafafa
  style Output fill:#18181b,stroke:#4ade80,color:#fafafa
`;

export const scriptsDiagram = `flowchart TD
  subgraph Callers["Who Calls Scripts"]
    HK["Hooks<br/>(lifecycle events)"]
    AG["Agents<br/>(via Bash tool)"]
    SK["Skills<br/>(workflow steps)"]
  end

  subgraph Core["Core Lifecycle"]
    SS["session-startup.sh"]
    QG["quality-gate.sh"]
    SL["statusline.sh"]
    NT["notify.sh"]
  end

  subgraph Feature["Feature Management"]
    UB["update-backlog.sh"]
    CP["complete-phase.sh"]
    GBC["git-branch-create.sh"]
    CKP["create-checkpoint.sh"]
  end

  subgraph Quality["Quality & Scoring"]
    CVS["calculate-vibe-score.sh"]
    AGS["aggregate-scores.sh"]
    ATG["analyze-test-gaps.sh"]
    AM["apply-mutation.sh"]
  end

  subgraph Analysis["Project Analysis"]
    DC["detect-conventions.sh"]
    EDS["extract-design-system.sh"]
    DS["detect-secrets.sh"]
    SD["scan-dependencies.sh"]
  end

  subgraph State["State & Config"]
    IV["init-vibecrew-state.sh"]
    MS["migrate-state.sh"]
    GH["generate-handoff.sh"]
    DT["detect-terminal.sh"]
  end

  HK --> Core
  AG --> Feature
  AG --> Quality
  AG --> Analysis
  SK --> Feature
  SK --> State

  style Callers fill:#7c3aed,stroke:#a78bfa,color:#fafafa
  style Core fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Feature fill:#18181b,stroke:#4ade80,color:#fafafa
  style Quality fill:#18181b,stroke:#fbbf24,color:#fafafa
  style Analysis fill:#18181b,stroke:#60a5fa,color:#fafafa
  style State fill:#18181b,stroke:#f87171,color:#fafafa
`;

export const runtimeStateDiagram = `flowchart TD
  subgraph VibeCrew[".vibecrew/ (Per-Project Runtime)"]
    Config["config.json<br/>Terminal prefs, notifications,<br/>user profile"]
    State["state.json<br/>Foundation status,<br/>active feature + phase"]
    Backlog["backlog.json<br/>Feature specs with<br/>Kanban columns"]
    Gamification["gamification.json<br/>XP, level, badges,<br/>skill tree, streaks"]
  end

  subgraph Dirs["Runtime Directories"]
    Arch["architecture/<br/>5 Mermaid .mmd files"]
    Sessions["sessions/<br/>Session logs (JSON)"]
    Scores["scores/<br/>Vibe Score breakdowns"]
    Signals["signals/<br/>Inter-agent communication"]
    Locks["locks/<br/>Advisory locks"]
    Handoffs["handoffs/<br/>Cross-session context"]
  end

  subgraph Consumers["Who Reads/Writes"]
    Agents["Agents<br/>(via scripts only)"]
    Hooks["Hooks<br/>(read for validation)"]
    Scripts["Scripts<br/>(all state mutations)"]
    StatusBar["Status Bar<br/>(read-only display)"]
  end

  Agents --> Scripts
  Scripts --> VibeCrew
  Scripts --> Dirs
  Hooks -->|read| State
  Hooks -->|read| Config
  StatusBar -->|read| State
  StatusBar -->|read| Scores

  style VibeCrew fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Dirs fill:#18181b,stroke:#4ade80,color:#fafafa
  style Consumers fill:#18181b,stroke:#fbbf24,color:#fafafa
`;
