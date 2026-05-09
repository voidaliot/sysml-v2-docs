# 09 — Packages, Imports, and Views

How models are organized, navigated, and presented.

---

## 1. Packages

A **package** is a namespace and a containment unit. Every model element lives, transitively, inside a package.

```sysml
package VehicleModel {
    package Structure {
        part def Vehicle;
    }
    package Behavior {
        action def Drive;
    }
    package Requirements {
        requirement def Safe;
    }
}
```

A `.sysml` file may either:

- Begin directly with `package SomeName { … }` (one top-level package), or
- Begin with element declarations that go into an implicit package whose name matches the file.

**Recommendation**: always declare an explicit top-level package. It makes imports unambiguous and the file's role obvious.

### 1.1 Standard library packages

Packages under `library/` use a `standard library package` modifier:

```sysml
standard library package SysML {
    public import Systems::*;
}
```

User code never declares `standard` packages.

---

## 2. Imports

### 2.1 Import forms

```sysml
import OtherPkg::*;                  // all members
import OtherPkg::SomeDef;            // a single member
import OtherPkg::*::**;              // recursive — all members of all sub-packages
import OtherPkg::SomeDef as Alias;   // aliasing
```

### 2.2 Visibility

```sysml
public  import ISQ::*;     // members are re-exported by my package
private import Helpers::*; // members are local; not visible to importers of me
import Helpers::*;         // shorthand: defaults to private
```

### 2.3 Common standard imports

| Import | When you need it |
|---|---|
| `import ScalarValues::*;` | Basic types `Real`, `Integer`, `Boolean`, `String`. |
| `import ISQ::*;` | International System of Quantities — `MassValue`, `LengthValue`, `TimeValue`, `SpeedValue`, etc. |
| `import SI::*;` | Unit symbols — `kg`, `m`, `s`, `km/h`. |
| `import Geometry::*;` | Geometric primitives. |
| `import Quantities::*;` | Lower-level quantity / unit infrastructure. |

### 2.4 Best practices

- **Import what you need.** Avoid `OtherPkg::*::**` recursive imports unless the file truly needs everything.
- **Prefer `private import`** unless you explicitly want to re-export.
- **Group imports at the top** of the package body for readability.
- **Use aliases** to avoid name collisions and to clarify intent.

---

## 3. Views and viewpoints

A **view** is a way of looking at part of the model — a filtered, formatted projection. A **viewpoint** describes the *purpose* of one or more views (whose interest does it serve, what concerns does it address).

### 3.1 Viewpoint definitions

```sysml
viewpoint def MassBudgetViewpoint {
    doc /* Concern: total system mass and per-subsystem allocation. */
    stakeholder programManager;
    concern    massBudget;

    require renderViewAsTable;
}
```

### 3.2 View definitions

```sysml
view def MassBudgetView {
    frame MassBudgetViewpoint;     // links to the viewpoint
    expose veh.engine.mass,
           veh.transmission.mass,
           veh.body.mass;
    render asTable;
}
```

### 3.3 View usage

```sysml
view massBudget : MassBudgetView {
    expose myCar.*.mass;
}
```

### 3.4 Renderings

A **rendering** is a presentation specification — table, tree, graph, custom format.

```sysml
rendering def TableRendering;
rendering def TreeRendering;
rendering def InterconnectionDiagram;
```

Tools render views by interpreting the rendering definition.

---

## 4. Filtering and navigation

`expose` (in views) and `filter` (in packages) are how partial models are extracted:

```sysml
package VisibleSubset {
    filter Vehicle and not Engine;
    public import VehicleModel::*;
}
```

`expose` brings specific elements *into* a view; `filter` restricts what is *visible* at all in a package.

---

## 5. Recommended file organization

For a system of any non-trivial size:

```
my-project/
├── .meta.json                 # interchange project metadata (Sysand format)
├── .project.json              # project descriptor
├── packages/
│   ├── Structure.sysml        # parts, ports, items, connections
│   ├── Behavior.sysml         # actions, states, transitions
│   ├── Requirements.sysml     # requirement defs and usages
│   ├── Verification.sysml     # verification cases
│   ├── Analysis.sysml         # analysis cases
│   ├── Views.sysml            # views and viewpoints
│   └── Variants.sysml         # variation / variant definitions
└── README.md
```

### 5.1 One top-level package per file

Each `.sysml` file should declare exactly one top-level `package` (which may itself contain nested packages). Cross-file references work via `import`.

### 5.2 Naming conventions

| Element kind | Convention |
|---|---|
| Package | `PascalCase` (`Structure`, `VehicleRequirements`) |
| Definition (`part def`, `port def`, etc.) | `PascalCase` (`Vehicle`, `PowerInPort`) |
| Usage (`part`, `port`, etc.) | `camelCase` (`myCar`, `inboundPower`) |
| Action / calc | Verb phrase, `camelCase` (`computeMass`, `applyBrakes`) |
| Requirement | Noun phrase, `PascalCase` (`MaxMassLimit`) |
| State | Noun, `camelCase` (`idle`, `running`) |
| Constants / enum members | `PascalCase` |
| Files | Match the name of the contained top-level package |

These mirror the conventions used throughout the OMG specification examples and the Pilot Implementation.
