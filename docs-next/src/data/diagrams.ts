/** Mermaid diagram sources for architecture pages */

export const systemDiagram = `flowchart TD
  subgraph Plugin["claude-plugin-vibe-crew"]
    Manifest[".claude-plugin/plugin.json"]
    MCP[".mcp.json"]
    Settings["settings.json"]
    Hooks["hooks/hooks.json"]
    Scripts["scripts/"]
    Agents["agents/"]
    Skills["skills/"]
  end

  subgraph Runtime[".vibecrew/ Per-Project"]
    Config["config.json"]
    State["state.json"]
    Backlog["backlog.json"]
    Gamification["gamification.json"]
    Sessions["sessions/"]
    Scores["scores/"]
    Architecture["architecture/"]
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
  User((User)) --> SS["Session Startup"]
  SS --> WO["Workflow Orchestrator"]

  WO -->|Tier 1| SSC["Stack Scout"]
  WO -->|Tier 1| OP["Opponent Processor"]
  WO -->|Tier 2| BLD["Builder"]

  SSC -->|TDR| WO
  OP -->|Risk Assessment| WO

  BLD --> VER["Verifier"]
  BLD --> CR["Code Reviewer"]

  VER -->|Results| BLD
  CR -->|Findings| BLD

  BLD -->|/wrap| PC["Performance Coach"]
  PC -->|Score + Coaching| DG["Doc Generator"]

  WO -->|/audit| SA["Security Auditor"]
  WO -->|/simplify| CS["Code Simplifier"]
  WO -->|/heal| CH["CI Healer"]
  WO -->|/onboard| CA["Code Auditor"]
  WO -->|/system-review| SR["System Reviewer"]

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
    TDR --> ARCH["Architecture Diagrams"]
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
  subgraph Events["Lifecycle Events"]
    E1["SessionStart"]
    E2["PreToolUse Write/Edit"]
    E3["PreToolUse Bash"]
    E4["PostToolUse Write/Edit"]
    E4b["PostToolUse (all)"]
    E5["Notification"]
    E5b["PostToolUseFailure"]
    E6["Stop"]
  end

  subgraph Guards["Pre-Action Guards"]
    PG["phase-gate.sh"]
    RP["restrict-paths.sh"]
    PD["protect-data.sh"]
    VPT["validate-phase-transition.sh"]
    VS["validate-signal.sh"]
  end

  subgraph Post["Post-Action Processors"]
    FC["format-code.sh"]
    VSS["validate-skill-schema.sh"]
    DT["drift-tracker.sh"]
    NT["notify.sh"]
  end

  subgraph Stop["Session End Checks"]
    DCB["drift-circuit-breaker.sh"]
    CC["check-context.sh"]
    CG["cost-guardrails.sh"]
    CL["claude-md-lint.sh"]
    QG["quality-gate.sh"]
  end

  subgraph Init["Session Init"]
    SS["session-startup.sh"]
    SY["sync-state.sh"]
    ER["error-recovery.sh"]
    CR["compact-reinject.sh"]
  end

  E1 --> Init
  E2 --> Guards
  E3 --> PD
  E3 --> VPT
  E2 --> VS
  E4 --> FC
  E4 --> VSS
  E4b --> DT
  E5 --> NT
  E5b --> NT
  E6 --> Stop

  style Events fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Guards fill:#18181b,stroke:#f87171,color:#fafafa
  style Post fill:#18181b,stroke:#4ade80,color:#fafafa
  style Stop fill:#18181b,stroke:#fbbf24,color:#fafafa
  style Init fill:#18181b,stroke:#60a5fa,color:#fafafa
`;

export const commandsDiagram = `flowchart TD
  subgraph User["User Input"]
    CMD["/slash-command"]
  end

  subgraph Skill["Skill Layer"]
    SM["SKILL.md"]
  end

  subgraph Routing["Agent Routing"]
    SO["Script-Only"]
    SA["Single Agent"]
    MA["Multi-Agent"]
  end

  subgraph Agents["Agent Execution"]
    WO["Orchestrator"]
    BLD["Builder"]
    VER["Verifier"]
    PC["Perf Coach"]
    DG["Doc Generator"]
  end

  subgraph Output["Results"]
    ST["State Updates"]
    GIT["Git Operations"]
    FILES["Source Code"]
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
    HK["Hooks"]
    AG["Agents"]
    SK["Skills"]
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

  subgraph AgentInfra["Agent Infrastructure"]
    AMR["agent-memory-*.sh"]
    EXP["expertise-*.sh"]
    LAO["load-agent-with-overrides.sh"]
  end

  subgraph Docs["Documentation & Release"]
    GFD["generate-feature-docs.sh"]
    UCL["update-changelog.sh"]
    DRF["drift-tracker.sh"]
  end

  subgraph Integration["Integration & MCP"]
    MCS["*-mcp-*.sh"]
    RCS["recommend-companion-skills.sh"]
    VSS["validate-skill-safety.sh"]
  end

  subgraph Erosion["Erosion & Performance"]
    CES["calculate-erosion-score.sh"]
    DCB["drift-circuit-breaker.sh"]
    DAP["detect-anti-patterns.sh"]
  end

  subgraph GitCI["Git & CI/CD"]
    GCV["git-commit-validate.sh"]
    FCL["fetch-ci-logs.sh"]
    FGI["fetch-github-issue.sh"]
  end

  subgraph Context["Architecture & Context"]
    IA["inject-architecture.sh"]
    PFC["prepare-feature-context.sh"]
    CRI["compact-reinject.sh"]
  end

  subgraph Lib["scripts/lib/"]
    AW["atomic-write.sh"]
    LK["lock.sh"]
    GP["git-provider.sh"]
  end

  HK --> Core
  HK --> AgentInfra
  HK --> Context
  AG --> Feature
  AG --> Quality
  AG --> Analysis
  AG --> Docs
  AG --> Erosion
  AG --> Integration
  SK --> Feature
  SK --> State
  SK --> GitCI

  style Callers fill:#7c3aed,stroke:#a78bfa,color:#fafafa
  style Core fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Feature fill:#18181b,stroke:#4ade80,color:#fafafa
  style Quality fill:#18181b,stroke:#fbbf24,color:#fafafa
  style Analysis fill:#18181b,stroke:#60a5fa,color:#fafafa
  style State fill:#18181b,stroke:#f87171,color:#fafafa
  style AgentInfra fill:#18181b,stroke:#c084fc,color:#fafafa
  style Docs fill:#18181b,stroke:#60a5fa,color:#fafafa
  style Integration fill:#18181b,stroke:#34d399,color:#fafafa
  style Erosion fill:#18181b,stroke:#fb923c,color:#fafafa
  style GitCI fill:#18181b,stroke:#f472b6,color:#fafafa
  style Context fill:#18181b,stroke:#38bdf8,color:#fafafa
  style Lib fill:#18181b,stroke:#94a3b8,color:#fafafa
`;

export const runtimeStateDiagram = `flowchart TD
  subgraph VibeCrew[".vibecrew/ Runtime"]
    Config["config.json"]
    State["state.json"]
    Backlog["backlog.json"]
    Gamification["gamification.json"]
  end

  subgraph Dirs["Runtime Directories"]
    Arch["architecture/"]
    AnalysisDir["analysis/"]
    Sessions["sessions/"]
    Scores["scores/"]
    Signals["signals/"]
    Locks["locks/"]
    Releases["releases/"]
    Handoffs["handoffs/"]
    Workflows["workflows/"]
    Expertise["expertise/"]
    Memory["memory/"]
    AgentOverrides["agent-overrides/"]
  end

  subgraph Consumers["Who Reads/Writes"]
    Agents["Agents"]
    Hooks["Hooks"]
    Scripts["Scripts"]
    StatusBar["Status Bar"]
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

export const safetyDiagram = `flowchart TD
  subgraph Layer1["Layer 1: Permissions"]
    direction TB
    Allow["Allowed Rules"]
    Deny["Denied Rules"]
  end

  subgraph Layer2["Layer 2: Hook Guards"]
    PG["phase-gate.sh"]
    PD["protect-data.sh"]
    RP["restrict-paths.sh"]
    VS["validate-signal.sh"]
    VPT["validate-phase-transition.sh"]
  end

  subgraph Layer3["Layer 3: Quality Gate"]
    QG["quality-gate.sh"]
    CL["claude-md-lint.sh"]
    CG["cost-guardrails.sh"]
  end

  Action["Agent attempts action"] --> Layer1
  Layer1 -->|Allowed| Layer2
  Layer1 -->|Denied| Block1["Blocked immediately"]
  Layer2 -->|Passed| Execute["Action executes"]
  Layer2 -->|Blocked| Block2["Blocked with message"]
  Execute --> Layer3
  Layer3 -->|Pass| Done["Task complete"]
  Layer3 -->|Fail| Fix["Agent must fix errors"]

  style Layer1 fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Layer2 fill:#18181b,stroke:#f87171,color:#fafafa
  style Layer3 fill:#18181b,stroke:#fbbf24,color:#fafafa
  style Action fill:#7c3aed,stroke:#a78bfa,color:#fafafa
  style Block1 fill:#18181b,stroke:#f87171,color:#f87171
  style Block2 fill:#18181b,stroke:#f87171,color:#f87171
  style Execute fill:#18181b,stroke:#4ade80,color:#fafafa
  style Done fill:#18181b,stroke:#4ade80,color:#4ade80
  style Fix fill:#18181b,stroke:#fbbf24,color:#fbbf24
`;

export const mcpServersDiagram = `flowchart TD
  TDR["TDR Finalized"] --> Sync["sync-mcp-from-tdr.sh"]

  subgraph Registry["MCP Registry"]
    Bundled["Bundled Servers"]
    Extended["Extended Servers"]
  end

  Sync --> Registry
  Sync --> Match{"Pattern Match"}

  Match -->|Bundled server| Enable["Auto-Enable\nenable-mcp-server.sh"]
  Match -->|Extended server| Recommend["Recommend\n+ Setup Instructions"]
  Match -->|No match| Skip["Skip"]

  subgraph Active["Active MCP Servers"]
    Default["Context7\nChrome DevTools\nPlaywright"]
    Conditional["Supabase\nStripe\nVercel\n..."]
  end

  Enable --> Conditional
  Default --> Agents["Agents Use Tools"]
  Conditional --> Agents

  style TDR fill:#7c3aed,stroke:#a78bfa,color:#fafafa
  style Sync fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Registry fill:#18181b,stroke:#60a5fa,color:#fafafa
  style Match fill:#18181b,stroke:#fbbf24,color:#fafafa
  style Enable fill:#18181b,stroke:#4ade80,color:#fafafa
  style Recommend fill:#18181b,stroke:#60a5fa,color:#fafafa
  style Skip fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Active fill:#18181b,stroke:#4ade80,color:#fafafa
  style Agents fill:#18181b,stroke:#a78bfa,color:#fafafa
`;

export const templatesDiagram = `flowchart TD
  subgraph T1["Tier 1: /new-project"]
    VIS["VISION.md.template"]
    DS["design-system.css.template"]
    DB["design-brief.md.template"]
    TDR["tdr.md.template"]
    RM["roadmap.md.template"]
    CMD["CLAUDE.md.template"]
  end

  subgraph Setup["/setup"]
    CFG["config.json.template"]
    ST["state.json.template"]
    BL["backlog.json.template"]
    GM["gamification.json.template"]
  end

  subgraph T2["Tier 2: Feature Cycle"]
    FS["feature-spec.md.template"]
    TC["vitest/playwright/axe/k6 configs"]
    SL["session-log.json.template"]
    SC["score-breakdown.json.template"]
    HO["handoff.md.template"]
  end

  subgraph Ref["Reference Data"]
    MCP["mcp-registry.json"]
    BDG["badge-catalog.json"]
    SIG["signal-schema.json"]
    ARCH["architecture-diagrams/"]
  end

  T1 -->|Foundation artifacts| Project["Your Project"]
  Setup -->|.vibecrew/ state| Project
  T2 -->|Per-feature artifacts| Project
  Ref -->|Read by agents & scripts| Project

  style T1 fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Setup fill:#18181b,stroke:#4ade80,color:#fafafa
  style T2 fill:#18181b,stroke:#fbbf24,color:#fafafa
  style Ref fill:#18181b,stroke:#60a5fa,color:#fafafa
  style Project fill:#7c3aed,stroke:#a78bfa,color:#fafafa
`;

export const selfImprovingDiagram = `flowchart TD
  Session["Development Session"] --> Wrap["/wrap"]
  Wrap --> Score["Vibe Score Calculation"]
  Score --> Coach["Performance Coach Analysis"]
  Coach --> Eligible{"check-mutation-eligibility.sh\n(cooldown, dedup, frequency)"}

  Eligible -->|Eligible| Patterns{"Anti-pattern\ndetected 3+ times?"}
  Eligible -->|Blocked| Log["Log Session Data"]

  Patterns -->|Yes| Propose["Propose CLAUDE.md Mutation"]
  Patterns -->|No| Log

  Propose --> Approve{"User Response"}
  Approve -->|Approve| Mutate["apply-mutation.sh\nUpdates CLAUDE.md"]
  Approve -->|Edit| Revise["User revises rule text"] --> Mutate
  Approve -->|Reject| Log

  Mutate --> Log
  Log --> Telemetry["Cross-Project Telemetry"]
  Telemetry --> NextSession["Next Session\nBenefits from new rules"]
  NextSession --> Session

  style Session fill:#7c3aed,stroke:#a78bfa,color:#fafafa
  style Wrap fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Score fill:#18181b,stroke:#fbbf24,color:#fafafa
  style Coach fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Eligible fill:#18181b,stroke:#f87171,color:#fafafa
  style Patterns fill:#18181b,stroke:#fbbf24,color:#fafafa
  style Propose fill:#18181b,stroke:#60a5fa,color:#fafafa
  style Approve fill:#18181b,stroke:#fbbf24,color:#fafafa
  style Revise fill:#18181b,stroke:#60a5fa,color:#fafafa
  style Mutate fill:#18181b,stroke:#4ade80,color:#fafafa
  style Log fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Telemetry fill:#18181b,stroke:#60a5fa,color:#fafafa
  style NextSession fill:#18181b,stroke:#4ade80,color:#fafafa
`;

export const dashboardDiagram = `flowchart TD
  subgraph Source[".vibecrew/ JSON Files"]
    BL["backlog.json"]
    SE["sessions/*.json"]
    SC["scores/*.json"]
    GM["gamification.json"]
    CF["config.json"]
  end

  subgraph Pipeline["VitePress Pipeline"]
    DL["Data Loaders"]
    VUE["Vue Components"]
    WS["WebSocket"]
  end

  subgraph Tabs["Dashboard Tabs"]
    T1["Guide"]
    T2["Kanban Board"]
    T3["Session Stats"]
    T4["Trends"]
    T5["Coverage"]
    T6["Achievements"]
    T7["Settings"]
  end

  Source --> DL
  DL --> VUE
  VUE --> Tabs
  WS -.->|hot-reload| VUE

  style Source fill:#18181b,stroke:#a78bfa,color:#fafafa
  style Pipeline fill:#18181b,stroke:#4ade80,color:#fafafa
  style Tabs fill:#18181b,stroke:#fbbf24,color:#fafafa
`;
