# 01 — SysML v2 Language Overview

## What SysML v2 is

SysML v2 is the OMG-adopted standard (final adoption July 2025, formal specification published September 2025) for **Model-Based Systems Engineering (MBSE)**. It supersedes SysML v1, which was a UML profile; v2 is a **standalone language** with its own metamodel, formal semantics, textual syntax, graphical syntax, and standard API.

SysML v2 is delivered as **three companion specifications**, all part of the same release:

| Specification | Role |
|---|---|
| **KerML 1.0** (Kernel Modeling Language) | The semantic and syntactic foundation. SysML is built on top of KerML. |
| **SysML 2.0** | The systems-engineering language proper — `part`, `port`, `requirement`, etc. |
| **Systems Modeling API & Services 1.0** | A standard REST/HTTP API for creating, querying, and exchanging models between tools. |

Files on disk use the extensions **`.kerml`** for KerML source and **`.sysml`** for SysML source.

---

## The layered architecture

```
┌─────────────────────────────────────────────────────────┐
│ Domain libraries (Quantities & Units, Geometry, …)      │
├─────────────────────────────────────────────────────────┤
│ Systems Library  (SysML elements: Part, Port, …)        │  <-- .sysml
├─────────────────────────────────────────────────────────┤
│ Kernel Library   (KerML semantic primitives)            │  <-- .kerml
├─────────────────────────────────────────────────────────┤
│ KerML metamodel  (formal abstract syntax)               │
└─────────────────────────────────────────────────────────┘
```

A SysML model is, formally, a KerML model that uses elements imported from the Systems Library. This is why the SysML standard library begins with:

```sysml
standard library package SysML {
    private import ScalarValues::*;
    public  import Systems::*;
    package Systems {
        public import KerML::Kernel::*;
        // SysML element definitions follow
    }
}
```

A VS Code extension or AI agent **must** treat `sysml.library` as part of the language — built-in element names like `Part`, `PartUsage`, `RequirementDefinition`, etc. are resolved via library imports, not as language keywords.

---

## Why v2 differs sharply from v1

| Aspect | SysML v1 | SysML v2 |
|---|---|---|
| Foundation | UML 2 profile | KerML metamodel |
| Source of truth | XMI / proprietary tool DB | Plain text `.sysml` files |
| Block paradigm | One concept (`Block`) used for both definition and instance | Strict **Definition vs. Usage** split |
| Textual syntax | None (informal); diagrams are primary | Standard textual syntax; diagrams are **a view** |
| Requirements | Stereotyped UML class with text | First-class `requirement def` with formal `require`/`assume` constraints |
| Variability | Stereotypes | Native `variation`/`variant` keywords |
| API | None | Standard Systems Modeling API & Services |
| Diff/merge | XMI text-merge (painful) | Line-based git-friendly diffs |

> ⚠️ **Do not port v1 mental models verbatim.** A v1 *Block* maps to **either** a `part def` **or** a `part` (usage) depending on intent. Treating them as the same thing is the most common v1→v2 modeling error.

---

## The Definition / Usage paradigm in one paragraph

Every SysML v2 element comes in two forms: a **Definition** (the type / blueprint) and a **Usage** (an instance / occurrence in a context). You write `part def Vehicle` to define what a Vehicle *is*, and `part myCar : Vehicle` to instantiate one in some enclosing context. This pattern is uniform across the language: there is `part def`/`part`, `port def`/`port`, `action def`/`action`, `state def`/`state`, `requirement def`/`requirement`, `attribute def`/`attribute`, `connection def`/`connection`, `interface def`/`interface`, `view def`/`view`, `viewpoint def`/`viewpoint`, `metadata def`/`metadata`, `verification case def`/`verification case`, `analysis case def`/`analysis case`, `use case def`/`use case`, `calc def`/`calc`, `constraint def`/`constraint`, `item def`/`item`, `enum def`/`enum`. See `04-definition-vs-usage.md`.

---

## Twelve top-level element kinds in SysML v2

These are the categories an editor's outline view, an AI agent's mental model, and a code-completion menu should be organized around:

1. **Packages** — namespaces; the top-level container in any file.
2. **Parts** — components / things in the world. *Replaces v1 Block.*
3. **Items** — things that flow, are exchanged, or are consumed (mass, energy, data, signals).
4. **Ports** — interaction points on parts.
5. **Connections** — relationships between parts (extends connectors).
6. **Interfaces** — typed contracts between conjugate ports.
7. **Actions** — behaviors / steps / functions.
8. **States** — modes of a part, with entry/do/exit and transitions.
9. **Calculations** — pure expressions returning values (`calc def`).
10. **Constraints** — Boolean expressions (`constraint def`); the basis of formal requirements.
11. **Requirements** — bundles of constraints + a subject + assumptions.
12. **Analysis / Verification / Use cases** — specialized actions for evaluating and verifying the system.

Plus cross-cutting concerns: **Views & Viewpoints** (model presentation), **Metadata** (annotations, tags), **Variation/Variants** (product-line modeling), **Allocations** (cross-hierarchy mapping).

---

## What a `.sysml` file looks like, end to end

```sysml
package FlashlightModel {

    private import ISQ::*;     // SI units from standard library
    private import SI::*;

    // ---- Definitions ------------------------------------------------
    item def Light;
    item def Electricity;

    port def PowerOutPort  { out current : Electricity; }
    port def PowerInPort   :> ~PowerOutPort;            // conjugate

    part def Bulb {
        port supply : PowerInPort;
        attribute lumens : LuminousIntensityValue;
    }

    part def Battery {
        port supply : PowerOutPort;
        attribute capacity : ElectricChargeValue;
    }

    part def Switch {
        port in  : PowerInPort;
        port out : PowerOutPort;
        attribute closed : Boolean = false;
    }

    // ---- Usages: the actual flashlight assembly ---------------------
    part def Flashlight {
        part battery : Battery;
        part bulb    : Bulb;
        part switch  : Switch;

        connect battery.supply to switch.in;
        connect switch.out     to bulb.supply;
    }
}
```

Every other section in this knowledge base elaborates on a piece of this picture.
