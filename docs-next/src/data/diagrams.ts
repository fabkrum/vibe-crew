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
