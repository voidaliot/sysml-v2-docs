# SysML v2 — Graphical Notation Reference

A complete, corrected reference for the SysML v2 **graphical notation**. Every rule and diagram is grounded in the OMG SysML v2.0 Language Specification (September 2025) and cross-checked against the SodiusWillert/IBM SysML V2 Cheat Sheet v1.0 (CC BY-NC-ND 4.0) and the Friedenthal *"Intro to the SysML v2 Language — Graphical Notation"* training material (CC BY 4.0).

> ⚠️ **Critical framing — model vs text vs diagram**: The **model** is the single source of truth — not the `.sysml` text file and not the diagram. The textual notation and every graphical diagram are equally valid *views* of the same underlying model. Tools may be model-first (diagram edits → model), text-first (text edits → model), or fully bi-directional. Neither representation has semantic priority. Round-tripping between text and model is usually possible; the text omits layout, derived relationships, and internal element IDs.

---

## Part 1 — Universal Rules

### 1.1 The fundamental visual rule: corners encode def vs usage

Every SysML v2 element appears in one of two rectangle forms. This is the most important graphical rule in the language and the sharpest break from v1:

```
  ┌───────────────────┐         ╭───────────────────────╮
  │  «part def»       │         │  «part»               │
  │  Vehicle          │         │  myCar : Vehicle      │
  │                   │         │                       │
  └───────────────────┘         ╰───────────────────────╯

  SHARP CORNERS = Definition    ROUNDED CORNERS = Usage
  A reusable type / blueprint   An occurrence in a specific context
```

This rule applies uniformly to every element kind:

| Element kind | Definition (sharp) | Usage (rounded) |
|---|---|---|
| `part def` / `part` | Sharp rectangle | Rounded rectangle |
| `item def` / `item` | Sharp rectangle | Rounded rectangle |
| `port def` / `port` | Sharp small square stub | Rounded small square stub |
| `attribute def` / `attribute` | Sharp rectangle | Rounded rectangle |
| `action def` / `action` | Sharp rectangle | Rounded rectangle |
| `state def` / `state` | Sharp rectangle | Rounded rectangle |
| `constraint def` / `constraint` | Sharp rectangle | Rounded rectangle |
| `requirement def` / `requirement` | Sharp rectangle | Rounded rectangle |
| `use case def` / `use case` | Sharp rectangle | Rounded rectangle |
| `connection def` / `connection` | Sharp rectangle | Rounded rectangle |
| `interface def` / `interface` | Sharp rectangle | Rounded rectangle |
| `enum def` / `enum` | Sharp rectangle | Rounded rectangle |
| `occurrence def` / `occurrence` | Sharp rectangle | Rounded rectangle |

> ⚠️ **SysML v1 used ovals for use cases, «block» stereotypes for structure, and «activity» for behavior.** None of these shapes exist in v2. Everything is a rectangle — corner radius carries the definition/usage distinction.

> ✅ **Parts are specializations of items** that additionally exhibit behavior. `«item def»` is the root structural element in SysML v2; `«part def»` is the specialization that adds behavior. Both appear in diagrams.

---

### 1.2 Inherited features: the `^` prefix

When a usage inherits a feature from its typed definition, that feature is displayed in diagrams with a `^` (caret) prefix. This is the standard graphical signal that the feature was not declared locally in that usage — it comes from the definition or a parent.

```
  ┌────────────────────────────┐        ╭────────────────────────────────╮
  │  «part def»                │        │  «part»                        │
  │  Part1                     │        │  part1 : Part1                 │
  │  ────────────────────────  │        │  ───────────────────────────── │
  │  parts                     │        │  parts                         │
  │  part11 : Part11           │        │  ^part11 : Part11              │ ← inherited
  │  ────────────────────────  │        │  ───────────────────────────── │
  │  attributes                │        │  attributes                    │
  │  attribute1 : Attribute1   │        │  ^attribute1 : Attribute1      │ ← inherited
  │  ────────────────────────  │        │  ───────────────────────────── │
  │  actions                   │        │  actions                       │
  │  action1 : Action1         │        │  ^action1 : Action1            │ ← inherited
  └────────────────────────────┘        ╰────────────────────────────────╯
```

When a specializing usage redefines a feature (`:>>`), the redefined entry loses the `^` prefix; other inherited features keep it:

```
  ╭───────────────────────────────────────╮
  │  «part»                               │
  │  part1S : Part1S :> part1             │
  │  ─────────────────────────────────    │
  │  parts                                │
  │  part11R :>> part11  ← redefined      │  no ^ (locally overridden)
  │  part12                               │
  │  ─────────────────────────────────    │
  │  attributes                           │
  │  attribute2 : Attribute2              │  no ^ (locally declared)
  │  ^attribute1 : Attribute1             │ ← ^ (still inherited)
  │  ─────────────────────────────────    │
  │  actions                              │
  │  ^action1 : Action1                   │ ← ^ (still inherited)
  │  ^action2 : Action2                   │ ← ^ (still inherited)
  ╰───────────────────────────────────────╯
```

---

### 1.3 The diagram frame

Every diagram lives in a **frame** rectangle with a pentagon notch in the top-left corner. The notch contains the diagram header.

```
╔══════════════════════════════════════════════╗
║  renderingKind [ElementType] Name [Label]    ║  ← header pentagon
╚═══════════════╗════════════════════════════ =╝
                ║ notch continues as diagram border
┌───────────────╨──────────────────────────────┐
│                                              │
│   diagram contents                           │
│                                              │
└──────────────────────────────────────────────┘
```

Header fields:

| Field | Meaning | Example |
|---|---|---|
| `renderingKind` | Which of the 8 standard renderings this is | `gv`, `iv`, `av`, `stv` |
| `ElementType` | Kind of the model element anchoring this view | `package`, `part def`, `action def` |
| `Name` | Qualified name of the anchoring element | `VehicleModel::Structure` |
| `Label` | Optional user-defined diagram title | `Top-level decomposition` |

---

### 1.4 The 8 standard rendering definitions

SysML v2 defines exactly **8 standard rendering definitions**, formally declared in the `Views` standard library. Every graphical diagram is an instance of one of these. There is no ninth.

| Abbreviation | Rendering name | Primary question | v1 closest |
|---|---|---|---|
| `gv` | **General View** | What types and definitions exist? What is the taxonomy? | BDD |
| `iv` | **Interconnection View** | How are the internal parts of X wired together? | IBD |
| `av` | **Action Flow View** | What are the steps and data flows of a behavior? | Activity Diagram |
| `stv` | **State Transition View** | What modes can X be in and what triggers transitions? | State Machine Diagram |
| `sv` | **Sequence View** | What messages do parts exchange in this scenario? | Sequence Diagram |
| `gev` | **Geometry View** | How are elements positioned in space? | (none in v1) |
| `grv` | **Grid View** | How do elements and relationships appear in table form? | Requirement Table |
| `bv` | **Browser View** | What is the hierarchical membership structure? | Model Explorer |

> ⚠️ **Abbreviation corrections vs common errors:**
> - Action Flow View is **`av`**, not `af`
> - State Transition View is **`stv`**, not `sm`
> - Sequence View is **`sv`**, not `seq`
> - There is no `par` (Parametric) rendering in v2

> ⚠️ **The SysML v1 Parametric Diagram does not exist as a standard rendering in v2.** Constraints and parametric relationships are expressed through `constraint def` elements and `binding` connectors within the General View or Interconnection View.

> ⚠️ **"Requirement diagram" and "Use case diagram" are informal shorthand.** In v2, these are General Views (`gv`) scoped to requirement or use-case elements. Tools may label them differently, but the underlying rendering is `gv` or `grv`.

---

### 1.5 Keyword labels (guillemets)

Every element carries its keyword in double angle brackets above the name. These are mandatory in conformant diagrams.

```
  «part def»                  «part»
  «item def»                  «item»
  «port def»                  «port»
  «attribute def»             «attribute»
  «action def»                «action»
  «state def»                 «state»
  «constraint def»            «constraint»
  «requirement def»           «requirement»
  «use case def»              «use case»
  «connection def»            «connection»
  «interface def»             «interface»
  «allocation def»            «allocation»
  «enum def»                  «enum»
  «occurrence def»            «occurrence»
  «metadata def»              «metadata»
  «verification case def»     «verification case»
  «analysis case def»         «analysis case»
  «package»                   (no usage form — namespace only)
  «library package»           (standard library packages)
```

---

### 1.6 Compartments

A box body is divided into named sections by horizontal rules. Each section has a label.

**Part definition compartments:**
```
  ┌──────────────────────────────────────┐
  │  «part def»                          │   name (always first)
  │  Vehicle                             │
  ├──────────────────────────────────────┤
  │  parts                               │
  │  engine : Engine                     │   owned sub-parts
  │  wheels : Wheel [4]                  │
  ├──────────────────────────────────────┤
  │  attributes                          │
  │  mass : MassValue                    │   value properties
  ├──────────────────────────────────────┤
  │  actions                             │
  │  action1 : Action1                   │   performed behaviors
  └──────────────────────────────────────┘
```

**Port definition — uses `items` compartment:**
```
  ┌──────────────────────────────────────┐
  │  «port def»                          │
  │  EnergyPort                          │
  ├──────────────────────────────────────┤
  │  items                               │
  │  out item energy : Energy            │
  └──────────────────────────────────────┘
```

**Interface definition — uses `ends` compartment:**
```
  ┌──────────────────────────────────────┐
  │  «interface def»                     │
  │  EnergyInterface                     │
  ├──────────────────────────────────────┤
  │  ends                                │
  │  end_1 : EnergyPort                  │
  │  end_2 : ~EnergyPort                 │
  └──────────────────────────────────────┘
```

**Requirement definition — uses these compartments in order:**
```
  ┌──────────────────────────────────────────────────┐
  │  «requirement def»                               │
  │  Requirement1                                    │
  ├──────────────────────────────────────────────────┤
  │  subject                                         │
  │  System                                          │   REQUIRED — what the req constrains
  ├──────────────────────────────────────────────────┤
  │  attributes                                      │
  │  attribute1                                      │
  ├──────────────────────────────────────────────────┤
  │  assume constraints                              │
  │  assumes assumption1 :> assumption1              │   preconditions
  ├──────────────────────────────────────────────────┤
  │  require constraints                             │
  │  requires constraint1 :> constraint1             │   normative conditions
  ├──────────────────────────────────────────────────┤
  │  frame concerns                                  │
  │  frames concern1 :> concern1                     │   addressed stakeholder interests
  └──────────────────────────────────────────────────┘
```

**Use case definition — must have `subject` and `actors`:**
```
  ┌──────────────────────────────────────┐
  │  «use case def»                      │
  │  PurchaseTicket                      │
  ├──────────────────────────────────────┤
  │  subject                             │
  │  kiosk : TicketKiosk                 │   REQUIRED per spec
  ├──────────────────────────────────────┤
  │  actors                              │
  │  passenger : Person                  │
  └──────────────────────────────────────┘
```

**Enumeration definition:**
```
  ┌──────────────────────────────────────┐
  │  «enum def»                          │
  │  DiameterChoices                     │
  ├──────────────────────────────────────┤
  │  enumerations                        │
  │  large = 100 [mm]                    │
  │  medium = 80 [mm]                    │
  │  small = 60 [mm]                     │
  └──────────────────────────────────────┘
```

---

### 1.7 Multiplicity

Multiplicity appears in square brackets after the name/type. The default is `*` (any number) when unspecified, though `[1]` is the practical default for single-valued features.

```
  engine : Engine            → default (any)
  engine : Engine [1]        → exactly one
  wheels : Wheel [4]         → exactly four
  passengers : Person [0..5] → zero to five
  airbags : Airbag [0..*]    → any number, zero allowed
  sensors : Sensor [1..*]    → at least one
```

---

### 1.8 Relationship lines

| Textual keyword | Line style | Label / annotation |
|---|---|---|
| `:>` specializes | `──────▷` solid, hollow triangle | (none) |
| `:>` subsets | `──────▷` solid, hollow triangle | `{subsets}` |
| `:>>` redefines | `══════▷` double-line, hollow triangle | `{redefines}` or none |
| `::>` references | `─ ─ ─ ▷` dashed, hollow triangle | (none) |
| composition (owned part) | `──────◆` solid, filled diamond at owner | (none) |
| `ref part` (reference) | `──────◇` solid, open diamond at referencing end | `{ref}` optional |
| `«satisfy»` | `─ ─ ─ ─▶` dashed, open arrowhead | `«satisfy»` |
| `«verify»` | `─ ─ ─ ─▶` dashed, open arrowhead | `«verify»` |
| `«allocate»` | `─ ─ ─ ─▶` dashed, open arrowhead | `«allocate»` |
| `«frame»` | `─ ─ ─ ─▶` dashed, open arrowhead | `«frame»` |
| `«require»` | `─ ─ ─ ─▶` dashed, open arrowhead | `«require»` |
| `«assume»` | `─ ─ ─ ─▶` dashed, open arrowhead | `«assume»` |
| `«include»` | `─ ─ ─ ─▶` dashed, open arrowhead | `«include»` |
| `«import»` / `«access»` | `─ ─ ─ ─▶` dashed, open arrowhead | `«import»` or `«access»` |
| plain `connect` | `──────` solid, no arrowhead | item type label optional |
| `bind` | `──────` solid, `=` at midpoint | `=` |
| item flow direction | `──────→` solid, filled arrowhead | item type and direction |

---

## Part 2 — General View (gv)

**Primary question**: What types and definitions exist? What is the specialization hierarchy and composition structure?

**Anchored in**: A `package` or a `part def`.

**v1 equivalent**: Block Definition Diagram (BDD), partially. Unlike the BDD, the General View can show both definitions and usages on the same canvas.

---

### 2.1 Core element appearances

```
  ┌─────────────────────────────┐
  │  «part def»                 │   sharp corners = definition
  │  *AbstractVehicle*          │   italic name = abstract
  │  ─────────────────────────  │
  │  attributes                 │
  │  mass : MassValue           │
  └─────────────────────────────┘

  ┌─────────────────────────────┐
  │  «part def»                 │
  │  Car                        │   non-italic = may be instantiated
  │  ─────────────────────────  │
  │  parts                      │
  │  engine : Engine            │
  │  wheels : Wheel [4]         │
  └─────────────────────────────┘

  ╭─────────────────────────────╮
  │  «part»                     │   rounded corners = usage
  │  myCar : Car                │
  │  ─────────────────────────  │
  │  attributes                 │
  │  :>> mass = 1500 [kg]       │   redefinition of inherited value
  ╰─────────────────────────────╯
```

---

### 2.2 Specialization and composition arrows

```
  ──────────▷   :>  specializes — "ElectricCar is a kind of Car"
                    hollow triangle arrowhead; solid line

  ──────────◆   composition — "Car owns Engine" (filled diamond at owner)

  ──────────◇   reference — ref part (open diamond; child not owned)

  ══════════▷   :>> redefines — "SportsCar redefines engine type"
                    double line; hollow triangle

  ──────────▷   :>  subsets — annotated {subsets}
```

---

### 2.3 ASCII example — taxonomy and composition

```
  gv [package] VehicleModel [Part Taxonomy]
  ┌─────────────────────────────────────────────────────────────┐
  │                                                             │
  │   ┌─────────────────────────────┐                          │
  │   │  «part def»                 │                          │
  │   │  *Vehicle*                  │   abstract               │
  │   │  ─────────────────────────  │                          │
  │   │  mass : MassValue           │                          │
  │   └──────────────┬──────────────┘                          │
  │                  │ ▷                                        │
  │          ┌───────┴────────┐                                 │
  │          ▼                ▼                                 │
  │  ┌──────────────┐  ┌──────────────────┐                    │
  │  │  «part def»  │  │  «part def»      │                    │
  │  │  Car         │  │  Truck           │                    │
  │  └──────┬───────┘  └──────────────────┘                    │
  │         │ ◆ (composition)                                   │
  │   ┌─────┴──────────────┐                                   │
  │   ▼                    ▼                                   │
  │  ┌──────────────┐  ┌──────────────────────────┐            │
  │  │  «part def»  │  │  «part def»              │            │
  │  │  Engine      │  │  Wheel [4]               │            │
  │  └──────────────┘  └──────────────────────────┘            │
  └─────────────────────────────────────────────────────────────┘
```

---

### 2.4 Variation and variant in the General View

```
  ┌──────────────────────────────────────┐
  │  «variation»  «part def»             │
  │  Drivetrain                          │
  │  ────────────────────────────────    │
  │  ┌─────────────────────────────────┐ │
  │  │  «variant»  «part def»          │ │
  │  │  CombustionDrivetrain           │ │
  │  └─────────────────────────────────┘ │
  │  ┌─────────────────────────────────┐ │
  │  │  «variant»  «part def»          │ │
  │  │  ElectricDrivetrain             │ │
  │  └─────────────────────────────────┘ │
  └──────────────────────────────────────┘
```

Variants are nested inside the variation definition box, each carrying both `«variant»` and `«part def»` (or whichever element kind applies).

---

## Part 3 — Interconnection View (iv)

**Primary question**: How are the internal parts of a specific element wired together through their ports?

**Anchored in**: A `part def` or `part` usage.

**v1 equivalent**: Internal Block Diagram (IBD).

The outer container (the part being opened) is a large **rounded** rectangle — it is a usage. Its internal parts are also rounded usages. The ports on each part appear as small square stubs on the box boundary.

---

### 3.1 Port stubs and direction

```
  Port stubs on a part boundary:

  ─────[→]   out port: data flows OUT of the part
  ─────[←]   in port:  data flows IN to the part
  ─────[↔]   inout port
  ─────[■]   undirected port

  Label adjacent to the stub:
  portName : PortType
```

Conjugate ports (`~`) have all directions flipped. Tools may distinguish them visually by fill or a `~` annotation on the type label.

---

### 3.2 Connections, interfaces, and bindings

```
  Plain connection (connect a.portX to b.portY):
  ╭──────────╮                    ╭──────────────╮
  │ partA    │──[→]────────────[←]│ partB        │
  ╰──────────╯                    ╰──────────────╯

  Interface (typed connection linking conjugate ports):
  ╭──────────╮                    ╭──────────────╮
  │ partA    │──[→]──◇──◇──[←]──│ partB        │
  ╰──────────╯  «interface»       ╰──────────────╯
               EnergyInterface

  Binding (= sign): outer port IS the same physical connector
  as an inner port. Use instead of an interface when there is
  no separate connector — just a shared physical point.
  ╭──────────────────────────────────╮
  │  «part»  System           [→]   │  ← outer port
  │                            ║    │
  │  ╭───────────────────╮     = bind
  │  │ «part» Motor [→]──╝          │  ← same physical port
  │  ╰───────────────────╯          │
  ╰──────────────────────────────────╯
```

> ✅ Use **interface** to connect ports on two different parts.
> ✅ Use **binding** (`=`) when an outer port and an inner port are literally the same physical connector.

---

### 3.3 Item flows on connections

Item type and direction are labeled on the connection line:

```
  ╭──────────────╮                       ╭──────────────────╮
  │ battery      │[→]── Energy ─────────[←]│ motor            │
  │              │   ↑ item type label      │                  │
  ╰──────────────╯                       ╰──────────────────╯
```

---

### 3.4 ASCII example — Flashlight wiring

```
  iv [part def] Flashlight [Internal Wiring]
  ┌────────────────────────────────────────────────────────────────┐
  │                                                                │
  │  ╭──────────────────────────────────────────────────────────╮ │
  │  │  «part»  flashlight : Flashlight                         │ │
  │  │                                                          │ │
  │  │  ╭────────────────╮  Electricity  ╭──────────────────╮   │ │
  │  │  │ «part»         │  [→]────────[←] │ «part»          │   │ │
  │  │  │ battery:Battery│  supply       │ bulb : Bulb       │   │ │
  │  │  │                │               │                   │   │ │
  │  │  ╰────────────────╯               ╰──────────────────╯   │ │
  │  ╰──────────────────────────────────────────────────────────╯ │
  └────────────────────────────────────────────────────────────────┘
```

---

## Part 4 — Action Flow View (av)

**Primary question**: What are the steps of a behavior? How do data and items flow between steps?

**Anchored in**: An `action def` or `action` usage.

**v1 equivalent**: Activity Diagram.

---

### 4.1 Node shapes

```
  ●       Start node — filled black circle. REQUIRED. Every action starts here.

  ╭───────────────╮
  │  «action»     │   Action node — rounded rectangle.
  │  doSomething  │   May have a parameters compartment.
  │  ───────────  │
  │  parameters   │
  │  out item1    │
  ╰───────────────╯

  ⊙       Done node — filled circle inside ring. Normal completion.

  ⊗       Terminate node — X inside circle. Forced / abnormal termination.

  ═══╪═══  Fork — thick horizontal bar. Splits into parallel flows.

  ═══╪═══  Join — thick horizontal bar. Synchronises parallel flows.

  ◇       Decision — diamond. Guard labels on outgoing arrows.

  ◇       Merge — diamond. Passes through whichever flow arrives first.
```

---

### 4.2 Arrow types

```
  ────▶   Control flow / succession (solid arrow — "then" sequencing)
  - -▶    Item flow (dashed arrow — "in item / out item" typed transfer)
```

---

### 4.3 Messages: send and accept

When parts communicate through ports, `send` and `accept` actions are placed in swim lanes. The communication runs through an interface connecting the ports:

```
  av [action def] Communication [Send/Accept Pattern]
  ┌────────────────────────────────────────────────────────────┐
  │ ┌──────────────────────┐ │ ┌──────────────────────────────┐│
  │ │ «part» sender        │ │ │ «part» receiver              ││
  │ │ ●                    │ │ │                              ││
  │ │ │                    │ │ │ ╭──────────────────────────╮ ││
  │ │ ╭──────────────────╮ │ │ │ │ «action»                │ ││
  │ │ │ «action»         │─╪─╪─▶│ listenToSender           │ ││
  │ │ │ sendMessage      │ │ │ │ │ accept m via commPort   │ ││
  │ │ │ send m via       │ │ │ │ ╰──────────────────────────╯ ││
  │ │ │ commPort         │ │ │ │                              ││
  │ │ ╰──────────────────╯ │ │ │                              ││
  │ │ ⊙                    │ │ │                              ││
  │ └──────────────────────┘ │ └──────────────────────────────┘│
  │                  commPortInterface (on boundary)            │
  └────────────────────────────────────────────────────────────┘
```

---

### 4.4 Sequential, parallel, and conditional flows

```
  Sequential (first → then → then):
  ● ──▶ ╭────╮ ──▶ ╭────╮ ──▶ ╭────╮ ──▶ ⊙
         │ a1 │     │ a2 │     │ a3 │
         ╰────╯     ╰────╯     ╰────╯

  Parallel (fork then join):
            ┌──▶ ╭────╮ ──┐
  ──▶ ═╪═   │    │ a1  │   │   ═╪═ ──▶ ⊙
            └──▶ ╭────╮ ──┘
                 │ a2  │
                 ╰────╯

  Conditional (decision with guards):
               [guard1] ──▶ ╭────╮ ─┐
  ──▶ ◇                     │ a1  │  │◇──▶
               [guard2] ──▶ ╭────╮ ─┘
                             │ a2  │
                             ╰────╯

  Loop (conditional with back-edge; requires parameters):
       ┌──────────────────────────────┐
       │                              │
  ──▶ ◇ [condition] ──▶ ╭────╮ ──────┘
        [else] ──▶ ⊙     │ a1  │
                          ╰────╯
```

---

## Part 5 — State Transition View (stv)

**Primary question**: What modes can an element be in? What triggers transitions?

**Anchored in**: A `state def`, or a `part def` that exhibits a state.

**v1 equivalent**: State Machine Diagram. The visual vocabulary is nearly identical.

---

### 5.1 Node shapes

```
  ●       Initial pseudo-state — filled black circle. REQUIRED.

  ╭──────────────────────────────╮
  │  state1                      │   State node — rounded rectangle.
  │  ────────────────────────    │   Entry/do/exit shown as labeled lines.
  │  entry / entryAction         │
  │  do    / doAction            │
  │  exit  / exitAction          │
  ╰──────────────────────────────╯

  ⊙       Final pseudo-state — circle inside ring. Optional.
```

---

### 5.2 Transition label anatomy

The trigger of a transition is an **accept action** — receiving an item or signal. Guards and effects are optional.

```
  ──[ trigger [guard] / effect ]──▶

  trigger  : an accept action (receiving an item/signal)
  [guard]  : boolean expression; must be true for transition to fire
  /effect  : action that executes as the transition fires

  Examples:
  ──[ PowerEvent ]──▶
  ──[ LockCmd [authToken.valid] / logLock ]──▶
  ──[ [temperature > 80 °C] / activateCooling ]──▶   guard only
  ──[  ]──▶   automatic / unconditional
```

---

### 5.3 Composite states

A composite (hierarchical) state is a larger rounded rectangle containing smaller ones:

```
  stv [part def] Vehicle [Vehicle Operating Modes]
  ┌──────────────────────────────────────────────────────────────────┐
  │                                                                  │
  │   ●                                                             │
  │   │                                                             │
  │   ▼   PowerEvent                                                │
  │  ╭─────────╮────────────────────────────────────────────────┐   │
  │  │   off   │                                                │   │
  │  ╰─────────╯◀──────────────────────────────────────────┐   │   │
  │                   PowerEvent                            │   │   │
  │  ╭──────────────────────────────────────────────────╮   │   │   │
  │  │  on  (composite state)                           │   │   │   │
  │  │   ●                                              │───┘   │   │
  │  │   │                                              │       │   │
  │  │   ▼                                              │       │   │
  │  │  ╭────────╮  StartCmd  ╭──────────╮  StopCmd    │       │   │
  │  │  │  idle  │───────────▶│ driving  │─────────────┼──▶    │   │
  │  │  ╰────────╯            ╰──────────╯             │       │   │
  │  ╰──────────────────────────────────────────────────╯       │   │
  └──────────────────────────────────────────────────────────────┘   │
```

---

## Part 6 — Requirements (in the General View)

Requirements are displayed using the **General View** (`gv`) scoped to requirement elements. The **Grid View** (`grv`) is used for tabular display.

---

### 6.1 Requirement element shapes

```
  ┌─────────────────────────────────────────────────────┐
  │  «requirement def»   Requirement1                   │  sharp = definition
  │  ─────────────────────────────────────────────────  │
  │  subject                                            │  REQUIRED per spec
  │  System                                             │
  │  ─────────────────────────────────────────────────  │
  │  attributes                                         │
  │  attribute1                                         │
  │  ─────────────────────────────────────────────────  │
  │  assume constraints                                 │
  │  assumes assumption1 :> assumption1                 │
  │  ─────────────────────────────────────────────────  │
  │  require constraints                                │
  │  requires constraint1 :> constraint1                │
  │  ─────────────────────────────────────────────────  │
  │  frame concerns                                     │
  │  frames concern1 :> concern1                        │
  └─────────────────────────────────────────────────────┘

  ╭─────────────────────────────────────────────────────╮
  │  «requirement»   requirement1 : Requirement1        │  rounded = usage
  │  ─────────────────────────────────────────────────  │
  │  subject                                            │
  │  ^System                                            │  ^ = inherited from def
  │  ─────────────────────────────────────────────────  │
  │  attributes                                         │
  │  attribute2                                         │
  │  ^attribute1                                        │  ^ = inherited
  ╰─────────────────────────────────────────────────────╯
```

---

### 6.2 Traceability relationships

All four traceability links are dashed open arrows, distinguished only by their label:

```
  «satisfy»   part/occurrence ─ ─ ─▶ requirement
  «verify»    verification case ─ ─▶ requirement
  «require»   requirement ─ ─ ─ ─ ─▶ constraint  (what it imposes)
  «assume»    requirement ─ ─ ─ ─ ─▶ constraint  (its precondition)
  «frame»     requirement ─ ─ ─ ─ ─▶ concern     (stakeholder interest it addresses)
```

Full traceability example:

```
  ┌────────────────────┐  «require»  ┌────────────────────────────────┐
  │ «requirement def»  │─ ─ ─ ─ ─ ─▶│ «constraint»                   │
  │ Requirement1       │             │ constraint1                    │
  └────────┬───────────┘             │ { req.attribute == part.attr } │
           │«satisfy»                └────────────────────────────────┘
           │
  ╭────────┴────────────╮
  │ «part»  part1:Part1 │
  ╰─────────────────────╯
           │«verify»
           │
  ╭────────┴──────────────────╮
  │ «verification case»       │
  │ verificationCase1         │
  ╰───────────────────────────╯
```

---

### 6.3 Grid View (grv) — requirement tables

```
  grv [package] Requirements [Requirements Table]
  ┌─────┬──────────────────────────┬───────────────────────────┐
  │  #  │  Declared name           │  Nested attribute         │
  ├─────┼──────────────────────────┼───────────────────────────┤
  │  1  │  Requirement             │                           │
  │     │  verificationCase1       │                           │
  ├─────┼──────────────────────────┼───────────────────────────┤
  │  2  │  2.1  requirement1.1     │  ☐ attribute2             │
  │     │  2.2  requirement1.2     │  ☐ attribute1             │
  └─────┴──────────────────────────┴───────────────────────────┘
```

---

## Part 7 — Use Cases (in the General View)

Use cases are displayed using the General View (`gv`) scoped to use-case elements.

---

### 7.1 Mandatory structure

A `use case def` **must** have a `subject` — the system element the use case is about. This is a specification requirement, not a recommendation.

```
  ┌────────────────────────────────────┐
  │  «use case def»                    │  sharp = definition
  │  PurchaseTicket                    │
  │  ────────────────────────────────  │
  │  subject                           │  REQUIRED
  │  kiosk : TicketKiosk               │
  │  ────────────────────────────────  │
  │  actors                            │
  │  passenger : Person                │
  └────────────────────────────────────┘

  ╭────────────────────────────────────╮
  │  «use case»   useCase1 : UseCase1  │  rounded = usage
  ╰────────────────────────────────────╯
```

---

### 7.2 Actors

Human actors are shown as stick figures; system/non-human actors as `«actor»` labelled boxes:

```
  🧍  actor1         ╭───────────────────╮
  (human)             │  «actor»          │  (system actor)
                      │  ExternalSystem   │
                      ╰───────────────────╯

  Actors connect to use cases with a plain association line.
```

---

### 7.3 Include and specialization

```
  «include»: included use case always executes as part of including case
  ┌───────────────────────┐  «include»  ┌────────────────────────┐
  │ «use case def»        │─ ─ ─ ─ ─ ─▶│ «use case def»         │
  │ PurchaseMonthlyPass   │             │ VerifyIdentity         │
  └───────────────────────┘             └────────────────────────┘

  Specialization: a more specific case inherits a general one
  ┌───────────────────────┐
  │ «use case def»        │
  │ PurchaseMonthlyPass   │
  └──────────┬────────────┘
             │ ▷
  ┌──────────┴────────────┐
  │ «use case def»        │
  │ PurchaseTicket        │
  └───────────────────────┘
```

---

### 7.4 System boundary

Tools show a boundary rectangle labelled with the subject name, enclosing all use cases for that subject:

```
  ┌─────────────────────────────────────────────────────┐
  │  system boundary: TicketKiosk                       │
  │                                                     │
  │   ┌───────────────────┐   ┌──────────────────────┐  │
  │   │ «use case def»    │   │ «use case def»       │  │
  │   │ PurchaseTicket    │   │ CheckBalance         │  │
  │   └───────────────────┘   └──────────────────────┘  │
  └─────────────────────────────────────────────────────┘
              │
  🧍 passenger─┘
```

---

## Part 8 — Sequence View (sv)

**Primary question**: What is the exact order of messages between parts in a specific scenario?

**Anchored in**: A `use case def` or `action def`.

**v1 equivalent**: Sequence Diagram. The visual vocabulary is nearly identical.

```
  sv [use case def] PurchaseTicket [Nominal Scenario]
  ┌──────────────────────────────────────────────────────────────────┐
  │                                                                  │
  │  ╭────────────╮     ╭──────────────╮     ╭───────────────╮      │
  │  │ :Passenger │     │ :Kiosk       │     │ :PaymentSvc   │      │
  │  ╰─────┬──────╯     ╰──────┬───────╯     ╰───────┬───────╯      │
  │        │                   │                     │              │
  │        │──selectRoute()───▶│                     │              │
  │        │                   ║ (activation)        │              │
  │        │◀─displayOptions()─║                     │              │
  │        │                   ║──chargeCard()───────▶             │
  │        │                   ║                     ║             │
  │        │                   ║◀─paymentConfirmed()─║             │
  │        │◀─printTicket()────║                     │              │
  │        │                   │                     │              │
  │        ▼                   ▼                     ▼              │
  └──────────────────────────────────────────────────────────────────┘

  Lifeline: named box at top + dashed vertical line below
  Activation box: thin rectangle on lifeline while active
  Synchronous message: filled arrowhead ──▶
  Reply: dashed arrow  ─ ─▶
```

---

## Part 9 — Grid View (grv) and Browser View (bv)

### Grid View (grv)

The Grid View presents elements and relationships in tabular form. It is the standard rendering for requirement tables, allocation matrices, and interface control documents. Three specializations:

- **Tabular View** — elements as rows, attributes/features as columns
- **Data Value Tabular View** — focused on attribute values
- **Relationship Matrix View** — elements on both axes, relationships in cells

### Browser View (bv)

The Browser View renders the hierarchical ownership structure as a navigable tree:

```
  bv [package] VehicleModel [Model Tree]
  ┌──────────────────────────────────────────────┐
  │                                              │
  │  ▼ VehicleModel                              │
  │    ▼ Structure                               │
  │      ├─ «part def»  Vehicle                  │
  │      ├─ «part def»  Engine                   │
  │      └─ «part def»  Wheel                    │
  │    ▼ Requirements                            │
  │      └─ «requirement def»  MaxMass           │
  │    ▼ Verification                            │
  │      └─ «verification case def»  MassTest   │
  └──────────────────────────────────────────────┘
```

---

## Part 10 — Geometry View (gev)

**Primary question**: How are elements positioned in physical or logical space?

The Geometry View uses spatial coordinates to position elements — for physical layout, deployment maps, sensor coverage areas, and satellite configuration. No direct v1 equivalent. Tool support is limited as of 2025.

---

## Part 11 — Packages and Allocation

### Package structures

```
  ┌─────────────────────────────────────────────────────┐
  │  «package»  Package1                                │
  │                                                     │
  │  ┌──────────────┐  ┌───────────────────┐  ╭──────╮ │
  │  │  «package»   │  │ «library package» │  │«part»│ │
  │  │  Package2    │  │  LibraryPackage   │  │part2 │ │
  │  └──────────────┘  └───────────────────┘  ╰──────╯ │
  └─────────────────────────────────────────────────────┘

  Import relationships:
  ┌──────────────────┐  «import»  ┌──────────┐
  │ «package» MyModel│─ ─ ─ ─ ─▶│ «package»│
  └──────────────────┘            │  ISQ     │
                                  └──────────┘
  «import»  = public (re-exported downstream)
  «access»  = private (local use only)
```

### Allocation

```
  The allocation relationship specifies that the target element
  is responsible for realizing the intent of the source element.
  It "maps" elements across structural hierarchies.

  ╭────────────────╮  «allocate»  ╭────────────────────╮
  │ «part»  part1  │─ ─ ─ ─ ─ ─▶│ «part»  part2      │
  ╰────────────────╯              ╰────────────────────╯

  Common patterns:
  function ──allocate──▶ hardware component
  logical element ──allocate──▶ physical element
  software ──allocate──▶ processor
```

---

## Part 12 — Occurrences: Individual, Timeslice, Snapshot

SysML v2 supports 4D modelling of how elements exist through time.

```
  ╭────────────────────────────────────────────────────╮
  │  «part»  individual1                               │
  │  (an individual — uniquely identified occurrence,  │
  │   e.g. serialized item, digital twin)              │
  │                                                    │
  │  «occurrence»         «occurrence»                 │
  │  timeslice1           timeslice2                   │  ← bounded time periods
  │       │                                            │
  │  «occurrence»                                      │
  │  snapshot1                                         │  ← zero-duration point
  ╰────────────────────────────────────────────────────╯
```

Timeslices and snapshots partition the individual's lifetime. Shown as nested occurrences connected by succession arrows.

---

## Part 13 — Visual Encoding Quick Reference

| Visual property | Meaning |
|---|---|
| Sharp rectangle corners | Definition (`part def`, `action def`, `requirement def`, …) |
| Rounded rectangle corners | Usage (`part`, `action`, `requirement`, …) |
| *Italic name* | `abstract` modifier — cannot be instantiated directly |
| `«keyword»` above name | Element kind — mandatory on every element |
| `^` prefix on a feature name | Inherited from parent definition |
| `:>>` on a feature | Redefinition of an inherited feature |
| Filled diamond `◆` at owner end | Composition — child owned by parent |
| Open diamond `◇` at referencing end | Reference (`ref`) — child not owned |
| Hollow arrowhead `▷` solid line | Specialization (`:>`) |
| Hollow arrowhead `▷` double line | Redefinition (`:>>`) |
| Dashed arrow with label | Dependency: `«satisfy»`, `«verify»`, `«allocate»`, `«frame»`, `«require»`, `«assume»`, `«include»`, `«import»`, `«access»` |
| Small square stub on box border | Port |
| `→` / `←` / `↔` inside port stub | Port direction (out / in / inout) |
| `~` on port type label | Conjugate port (all directions flipped) |
| `=` at connection midpoint | Binding — same physical connector |
| Filled black circle `●` | Initial pseudo-state |
| Circle-in-circle `⊙` | Done node / final state |
| X-in-circle `⊗` | Terminate node |
| Thick horizontal bar `═╪═` | Fork / join (parallel split or synchronize) |
| Diamond `◇` in a flow | Decision / merge (conditional branching) |
| Vertical dashed line | Lifeline (sequence view) |
| Thin rectangle on lifeline | Activation period (sequence view) |
| Dog-eared rectangle + dashed line | Note / comment attached to an element |
| `«variation»` + `«variant»` labels | Product-line choice point and alternatives |
| Compartment: `parts` | Owned sub-part usages |
| Compartment: `attributes` | Attribute usages and their values |
| Compartment: `actions` | Performed action usages |
| Compartment: `items` | Items declared on a port definition |
| Compartment: `ends` | Endpoints of an interface or connection definition |
| Compartment: `enumerations` | Literal values inside an `enum def` |
| Compartment: `subject` | What a requirement / case / use case is about |
| Compartment: `actors` | External participants in a use case or case |
| Compartment: `assume constraints` | Preconditions on a requirement |
| Compartment: `require constraints` | Normative conditions on a requirement |
| Compartment: `frame concerns` | Stakeholder concerns the requirement addresses |

---

## Part 14 — SysML v1 → v2 Diagram Mapping

| SysML v1 diagram | SysML v2 rendering | Key visual differences |
|---|---|---|
| Block Definition Diagram `bdd` | General View `gv` | `«block»` → `«part def»`; usages can now appear on same canvas; sharp/rounded corners distinguish def/usage |
| Internal Block Diagram `ibd` | Interconnection View `iv` | `«proxy port»`/`«flow port»` → typed first-class ports; part boxes are rounded (usage); item type labels on connections |
| Activity Diagram `act` | Action Flow View **`av`** | `«activity»` → `«action def»`; object flows → item flows (dashed, typed); start/done/terminate nodes identical |
| State Machine Diagram `stm` | State Transition View **`stv`** | Visual vocabulary nearly identical; trigger is now an explicit `accept action`; frame header changes |
| Sequence Diagram `sd` | Sequence View **`sv`** | Nearly identical; lifeline element types align with v2 part/usage model |
| Requirement Diagram `req` | General View `gv` (scoped) or Grid View `grv` | `«requirement»` → `«requirement def»`/`«requirement»`; richer compartments; `satisfy`/`verify`/`frame` arrows |
| Use Case Diagram `uc` | General View `gv` (scoped) | **Ovals → rectangles**; `subject` compartment now required; `«include»` preserved; `«extend»` → specialization |
| Package Diagram `pkg` | General View `gv` (package scope) | `«import»` vs `«access»` distinction explicit |
| Parametric Diagram `par` | **No equivalent standard rendering** | Expressed via `constraint def` + binding connectors within `gv` or `iv` |
| *(new in v2)* | Geometry View `gev` | Spatial positioning of elements |
| *(new in v2)* | Grid View `grv` | Tabular display |
| *(new in v2)* | Browser View `bv` | Hierarchical membership tree |

---

## Part 15 — Diagram Selection Guide

| Question | Use |
|---|---|
| What types / definitions exist? | General View `gv` |
| What is the specialization hierarchy? | General View `gv` with `▷` arrows |
| What variations and variants does this type have? | General View `gv` with variation notation |
| What does the inside of part X look like? | Interconnection View `iv` |
| How are ports wired and what items flow? | Interconnection View `iv` |
| What are the steps of this procedure? | Action Flow View `av` |
| How do parts communicate via messages? | Action Flow View `av` with swim lanes |
| What modes can X be in? What triggers them? | State Transition View `stv` |
| What messages are exchanged in this scenario? | Sequence View `sv` |
| What requirements must X satisfy? | General View `gv` scoped to requirements |
| How are requirements verified? | General View `gv` with `«verify»` links |
| Who uses the system and for what goal? | General View `gv` scoped to use cases |
| How are elements allocated? | General View `gv` with `«allocate»` links |
| Show requirements as a table | Grid View `grv` |
| What is the package / membership hierarchy? | Browser View `bv` |
| Where are elements positioned spatially? | Geometry View `gev` |

---
