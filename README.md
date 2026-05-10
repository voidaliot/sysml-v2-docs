# SysML v2.0 Implementation Knowledge Base

A structured documentation set extracted from the **OMG SysML v2.0 final adoption** (July 2025, formal specification September 2025), the companion **KerML 1.0** specification, and the **Systems Modeling API & Services 1.0** specification, plus the Pilot Implementation reference.

This knowledge base has **two intended consumers**:

1. **Developers** using SysML v2 — grammar, language server, syntax highlighting, validation.
2. **AI coding agents** that will help users *author* `.sysml` and `.kerml` files — language rules, modeling patterns, and a validation checklist to prevent the most common mistakes.

> The same content serves both. An AI agent should read the `language/` directory exactly the way the extension's language server consumes its grammar.

---

## How to use this knowledge base

| If you are… | Start with | Then read |
|---|---|---|
| A developer setting up the project for the first time | `vscode-extension/00-dev-environment.md` | `vscode-extension/01-architecture.md` |
| A developer scaffolding the VS Code extension | `vscode-extension/01-architecture.md` | `language/02-textual-notation-syntax.md`, `vscode-extension/03-grammar-parser.md` |
| A project lead planning the extension's delivery | `vscode-extension/IMPLEMENTATION-PLAN.md` | `vscode-extension/05-features-checklist.md`, `vscode-extension/01-architecture.md` |
| An AI agent executing implementation tasks | `vscode-extension/IMPLEMENTATION-PLAN-AI-AGENT.md` | `vscode-extension/00-dev-environment.md` |
| An AI agent asked to write `.sysml` files | `ai-agents/01-modeling-guide.md` | `ai-agents/04-validation-checklist.md`, `language/04-definition-vs-usage.md` |
| A systems engineer learning SysML v2 | `language/01-overview.md` | `language/04-definition-vs-usage.md`, `examples/` |
| Someone integrating with existing tools | `vscode-extension/06-existing-tools-and-references.md` | `language/10-standard-libraries.md` |

---

## Directory layout

```
sysml-v2-docs/
├── README.md                                   <-- you are here
│
├── language/                                   <-- the SysML v2 language itself
│   ├── 01-overview.md                          Architecture: KerML → SysML → API stack
│   ├── 02-textual-notation-syntax.md           Complete grammar reference
│   ├── 03-keywords-and-operators.md            All reserved words and symbols
│   ├── 04-definition-vs-usage.md               THE core paradigm — read this first
│   ├── 05-structural-modeling.md               part / port / item / interface / connection
│   ├── 06-behavioral-modeling.md               action / state / transition / flow / calculation
│   ├── 07-requirements-and-constraints.md      requirement / constraint / satisfy / assume / require
│   ├── 08-analysis-and-verification.md         analysis case / verification case / use case
│   ├── 09-packages-imports-and-views.md        Namespaces, imports, view / viewpoint / rendering
│   └── 10-standard-libraries.md                Kernel / Systems / Domain libraries (units, geometry…)
││
├── ai-agents/                                  <-- guidance for AI assistants
│   ├── 01-modeling-guide.md                    How to translate user intent into SysML v2
│   ├── 02-prompting-rules.md                   Hard rules & invariants the agent must respect
│   ├── 03-common-patterns.md                   Reusable templates (system, requirement, state machine…)
│   └── 04-validation-checklist.md              Pre-output checklist — run BEFORE returning code
│
└── examples/                                   <-- runnable starter material
    ├── flashlight.sysml                        Minimal end-to-end model
    └── vehicle-skeleton.sysml                  Larger model showcasing all major constructs
```

---

## Source authority and version

All content here is derived from publicly available material accompanying the **formally adopted** SysML v2.0 / KerML 1.0 / API & Services 1.0 specifications. Where examples or wording reflect the textual notation, they follow the syntax shown in the OMG specification, the Pilot Implementation example files, and the published cheat sheets.

If a downstream specification revision changes a construct, **prefer the latest OMG specification PDF** at `https://www.omg.org/spec/SysML/2.0/` over anything written here.

---

## Conventions used in this knowledge base

- **`monospace`** for SysML keywords, code fragments, and file names.
- **CamelCase** for user-defined *Definitions* in examples (e.g. `Vehicle`, `FuelPort`).
- **camelCase** for user-defined *Usages* in examples (e.g. `myCar`, `engineCoolantPort`).
- A leading `// …` comment in any code block means non-essential context that the agent may omit.
- Lines marked `⚠️` are gotchas where SysML v2 differs sharply from SysML v1 or from intuition.
- Lines marked `✅` are recommended idiomatic forms.
- Lines marked `❌` are forms that parse but are wrong, ambiguous, or deprecated.
