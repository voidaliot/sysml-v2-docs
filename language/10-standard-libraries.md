# 10 — Standard Libraries

SysML v2 ships with a layered library stack. The parser, language server, and AI agent must all understand what is in scope without explicit user import — and what requires an `import` statement.

---

## 1. The library stack

```
sysml.library/
├── Domain Libraries/
│   ├── Cause and Effect Library/
│   ├── Quantities and Units Domain Library/
│   ├── Geometry Library/
│   └── Metadata Domain Library/
├── Systems Library/
│   ├── SysML.sysml
│   ├── Connections.sysml
│   ├── Parts.sysml
│   ├── Actions.sysml
│   ├── States.sysml
│   ├── Requirements.sysml
│   └── Analysis.sysml
└── Kernel Libraries/
    ├── Kernel Data Type Library/
    ├── Kernel Function Library/
    └── Kernel Semantic Library/
        ├── Base.kerml
        ├── Links.kerml
        ├── Occurrences.kerml
        ├── Performances.kerml
        ├── Transfers.kerml
        ├── Objects.kerml
        ├── Clocks.kerml
        └── …
```

`sysml.library/` is bundled with every conformant tool. It is the canonical source for `Real`, `Integer`, `MassValue`, `Vehicle`-base specializations, etc.

---

## 2. Kernel Library (KerML level)

The kernel libraries provide the universal modeling primitives. Most are imported automatically by the SysML library and re-exported, so user code rarely imports from them directly.

### 2.1 Kernel Data Type Library

Primitive value types:
- `Boolean`
- `Integer`
- `Natural` (non-negative integer)
- `Real`
- `Rational`
- `String`
- `NumericalFunctions` (`abs`, `floor`, `ceil`, `min`, `max`, …)

### 2.2 Kernel Semantic Library

Semantic primitives:
- `Anything`, `Nothing` (top and bottom types)
- `Base::Things`, `Base::Datums`
- `Occurrences::Occurrence`, `Occurrences::LifeClass`
- `Links::Link`, `Links::SelfLink`
- `Performances::Performance`
- `Objects::Object`
- `Transfers::Transfer`, `Transfers::ItemFlow`

### 2.3 Kernel Function Library

Mathematical and collection functions used inside expressions:
- `Sequences::SequenceFunctions` (`size`, `head`, `tail`, `select`, `forall`, `exists`)
- `MeasurementRefs` (unit and dimension primitives)
- `BaseFunctions` (`==`, `!=`, identity helpers)

---

## 3. Systems Library (SysML level)

This is what `import SysML::*;` (implicit in any `.sysml` file) actually brings into scope. Defines the metadata definitions for every SysML element kind:

- `Part`, `PartUsage`, `PartDefinition`
- `Port`, `PortUsage`, `PortDefinition`
- `Item`, `ItemUsage`, `ItemDefinition`
- `Action`, `ActionUsage`, `ActionDefinition`
- `State`, `StateUsage`, `StateDefinition`
- `Requirement`, `RequirementDefinition`, `RequirementUsage`
- `VerificationCaseDefinition`, `AnalysisCaseDefinition`, `UseCaseDefinition`
- `View`, `Viewpoint`, `Rendering`
- `Connection`, `Interface`, `Allocation`
- `Concern`, `Stakeholder`, `Actor`
- … and 70+ other element types.

User code does **not** typically reference these by name. They are the metadata behind the keywords.

---

## 4. Domain libraries

These are *not* implicitly imported. User code must `import` them explicitly.

### 4.1 Quantities and Units

The most-used domain library. Provides ISO 80000-aligned quantities and SI units.

```sysml
private import ISQ::*;       // International System of Quantities — VALUE types
private import SI::*;        // SI units — UNIT symbols
```

Common quantity value types from `ISQ`:

| Type | What it represents |
|---|---|
| `LengthValue` | length / distance |
| `MassValue` | mass |
| `TimeValue` | duration |
| `SpeedValue` | speed |
| `AccelerationValue` | acceleration |
| `ForceValue` | force |
| `EnergyValue` | energy |
| `PowerValue` | power |
| `TemperatureValue` | temperature |
| `PressureValue` | pressure |
| `ElectricCurrentValue` | electric current |
| `VoltageValue` | voltage |
| `ResistanceValue` | resistance |
| `LuminousIntensityValue` | luminous intensity |
| `ElectricChargeValue` | electric charge |
| `FrequencyValue` | frequency |
| … | (full ISO 80000 set) |

Common units from `SI`:

`m`, `kg`, `s`, `A`, `K`, `mol`, `cd`, plus derived units `N`, `Pa`, `J`, `W`, `V`, `Ω`, `Hz`, `km`, `mm`, `µm`, `g`, `mg`, `°C`, `min`, `h`, `km/h`, `m/s`, `m/s²`, …

```sysml
attribute v : SpeedValue = 100 [km/h];
attribute m : MassValue  = 1500 [kg];
attribute T : TemperatureValue = 20 [°C];
```

### 4.2 Geometry Library

Provides points, vectors, frames, transforms:

```sysml
private import Geometry::*;

attribute origin   : Point3D;
attribute axis     : Vector3D;
attribute frame    : CoordinateFrame;
```

### 4.3 Cause and Effect Library

Supports modeling cascading failures, root-cause analysis:

- `Cause`, `Effect`
- `CauseEffectRelation`
- `FailureMode`, `Trigger`, `Outcome`

Used heavily in safety/reliability modeling (FMEA, FMECA, FTA).

### 4.4 Metadata Library

Common metadata definitions for tagging models:

- `OperationalMetadata` (creation date, author, …)
- `RequirementMetadata` (priority, status, source)
- `ConcernMetadata`

```sysml
@Author { name = "J. Smith"; }
@Priority { level = "high"; }
requirement def MyReq { … }
```

---

## 5. Library resolution rules (for the language server)

When resolving a name, the language server walks the visibility scope in this order:

1. The current namespace (innermost first).
2. Enclosing namespaces, outward.
3. Explicitly imported names (in declaration order).
4. Names from `public import` chains (transitively).
5. The implicit `SysML::*` and `KerML::Kernel::*` standard library imports.
6. **Fail** with an "unresolved name" diagnostic if not found.

The language server must:

- Index the entire `sysml.library/` directory at startup.
- Treat library files as read-only.
- Provide hover/go-to-definition into library files.
- Allow the user to override the library path via a setting.

---

## 6. Package management — `.kpar` and Sysand

KerML clause 10 defines a **model interchange project** format: `.kpar` (a zipped bundle of `.sysml`/`.kerml` files plus a manifest). The reference package manager is **Sysand**, an open-source tool that:

- Creates an interchange project (`sysand new`).
- Resolves and downloads dependencies (`sysand add`, `sysand sync`).
- Builds a `.kpar` archive (`sysand build`).

A project's manifest (`.project.json`) lists the project name, version, and dependency IRIs:

```json
{
  "name": "my_project",
  "version": "0.0.1",
  "usages": [
    { "iri": "urn:kpar:function-library", "version": "1.0.0" }
  ]
}
```

