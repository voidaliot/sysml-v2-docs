# SysML v2 — Keyword Glossary

A complete reference for every keyword in the SysML v2 textual notation. Each entry explains **what the keyword means**, **when to use it**, **all valid syntax forms**, and **concrete examples**. Entries are grouped by category and sorted alphabetically within each group.

**How to read an entry:**

```
keyword
  Category    : which group this keyword belongs to
  Form(s)     : the syntactic positions where it appears
  Pairs with  : related keywords that commonly appear alongside it
  Definition? : yes / no — whether a `def` variant exists
  ───────────────────────────────────────────────────────
  Explanation and examples
```

All keywords are **lowercase**. An uppercase name in a code block (e.g. `Vehicle`, `MassValue`) is always a user-defined identifier or a standard-library name — never a keyword.

---

## Part 1 — Element-Kind Keywords

These keywords introduce model elements. Most appear in two forms: a `*-def` form (the **Definition** — a reusable type) and a bare form (the **Usage** — an occurrence in a context). See `04-definition-vs-usage.md` for the core paradigm.

---

### `action` / `action def`

```
Category    : Behavioral
Form(s)     : action def <Name> { … }   ← defines a reusable behavior type
              action <name> : <Type>     ← creates one occurrence of an action
              perform action <name> : <Type>   ← a part declares it performs an action
              first <action> then <action>     ← sequencing inside another action
Definition? : yes
Pairs with  : in, out, inout, first, then, perform, return, calc def
```

An **action** is a unit of behavior — anything the system *does*. It consumes inputs, performs work, and produces outputs. Actions compose: a top-level action can decompose into sub-actions sequenced with `first … then …`.

Use `action def` for a reusable named behavior. Use `action` (bare) to declare that a specific occurrence of that behavior exists inside a part or a larger action.

```sysml
// ── Definition: what "Brake" means ───────────────────────────────────
action def Brake {
    in  pedalForce   : ForceValue;
    out wheelTorque  : TorqueValue;
}

// ── Inline decomposition: a multi-step procedure ─────────────────────
action def StartEngine {
    action checkFuel;
    action crankStarter;
    action waitForIdle;

    first checkFuel
    then  crankStarter
    then  waitForIdle;
}

// ── Usage on a part: the part performs this action ───────────────────
part def Vehicle {
    perform action brake : Brake {
        in pedalForce = brakePedal.force;
    }
}
```

> ✅ Use `action def` for any behavior that might be reused across multiple parts.
> ✅ Use `calc def` (not `action def`) when the behavior is a pure function with no side effects.
> ⚠️ Action parameters must carry a direction keyword (`in`, `out`, or `inout`); bare attributes without a direction are not parameters.

---

### `allocation` / `allocation def`

```
Category    : Structural / Cross-cutting
Form(s)     : allocation def <Name> { end …; end …; }
              allocation <name> : <Type> …
              allocate <source> to <target>
Definition? : yes
Pairs with  : allocate, to, end
```

An **allocation** is a mapping between two elements in different hierarchies — typically function-to-component, logical-to-physical, or requirement-to-part. It does not change the structure of either side; it just records the cross-cutting relationship.

```sysml
// ── Define the kind of mapping ────────────────────────────────────────
allocation def FunctionToHardware {
    end function  : ActionUsage;
    end hardware  : PartUsage;
}

// ── Declare specific mappings ─────────────────────────────────────────
allocate computePath  to navigationECU;
allocate renderFrame  to displayProcessor;

// ── Typed allocation ─────────────────────────────────────────────────
allocation nav : FunctionToHardware
    allocate computePath to navigationECU;
```

> ✅ Use allocations to answer the "what runs where?" and "what realizes what?" questions.
> ✅ Allocations complement, they do not replace, structural connections.

---

### `analysis case` / `analysis case def`

```
Category    : Analytical
Form(s)     : analysis case def <Name> { subject …; objective …; return …; }
              analysis case <name> : <Type> { subject = …; }
Definition? : yes
Pairs with  : subject, objective, return, actor, stakeholder
```

An **analysis case** is a formal evaluation of the model — a simulation, trade study, or computation that produces quantitative results. It is a specialised action whose outputs are `objective` values.

```sysml
// ── Definition: what the analysis computes ───────────────────────────
analysis case def ThermalAnalysis {
    doc /* Estimates peak junction temperature at maximum load. */
    subject chip : Processor;
    objective peakTemperature : TemperatureValue;

    return peakTemperature =
        chip.ambientTemp + (chip.powerDissipation * chip.thermalResistance);
}

// ── Usage: run the analysis on a specific processor ──────────────────
analysis case thermalCheck : ThermalAnalysis {
    subject = myProcessor;
}
```

> ✅ Use for "compute X" questions — mass rollup, power budget, thermal margin.
> ✅ Use `verification case` (not `analysis case`) when the goal is to prove a requirement is met.

---

### `attribute` / `attribute def`

```
Category    : Structural / Value
Form(s)     : attribute def <Name> :> <Type>;
              attribute <name> : <Type> = <value>;
              attribute <name> : <Type>;
              derived attribute <name> : <Type> = <expr>;
              :>> <name> = <value>;      ← redefinition of inherited attribute
Definition? : yes
Pairs with  : derived, readonly, :>>, =, [unit]
```

An **attribute** is a typed, value-holding feature of an element. Attributes have no identity beyond their value — they are not parts and cannot have ports. Use attributes for scalars, quantities, strings, and computed values.

```sysml
// ── Custom attribute type (usually not needed — use ISQ library types) ─
attribute def Priority :> Integer;

// ── Attributes on a part definition ──────────────────────────────────
part def Satellite {
    attribute mass         : MassValue;                    // physical quantity
    attribute orbitAltitude: LengthValue = 550 [km];      // with default value
    attribute callSign     : String;                       // text
    attribute operational  : Boolean = false;              // flag
    attribute launchYear   : Integer;                      // dimensionless integer

    derived attribute velocity : SpeedValue =              // computed from orbit
        sqrt(GM_Earth / (R_Earth + orbitAltitude));
}

// ── Redefine (narrow) an inherited attribute ─────────────────────────
part def LowOrbitSatellite :> Satellite {
    :>> orbitAltitude = 400 [km];                         // override the default
}
```

> ✅ Use `MassValue`, `LengthValue`, `TimeValue`, etc. from `ISQ::*` for physical quantities.
> ✅ Always pair a quantity with a unit literal: `1500 [kg]`, not `1500`.
> ⚠️ Do not use `attribute` for something that has structure, ports, or identity — use `part` instead.
> ⚠️ Use `==` for equality in expressions, never `=` (which is the assignment/binding operator).

---

### `calc` / `calc def`

```
Category    : Behavioral / Functional
Form(s)     : calc def <Name> { in …; return : <Type> = <expr>; }
              calc <name> : <Type> { … }
Definition? : yes
Pairs with  : in, return, action def
```

A **calc** is a pure function — an action that returns a value and has no side effects. Use `calc def` wherever a mathematical or logical expression is reusable across the model.

```sysml
// ── Pure computation ─────────────────────────────────────────────────
calc def AverageSpeed {
    in distance : LengthValue;
    in duration : TimeValue;
    return : SpeedValue = distance / duration;
}

calc def DecibelLevel {
    in power    : PowerValue;
    in ref      : PowerValue = 1 [mW];
    return : Real = 10 * log10(power / ref);
}

// ── Use a calc inside a constraint ───────────────────────────────────
requirement def NoiseBudget {
    subject src : NoiseSource;
    require constraint { DecibelLevel(src.power) <= 85 }
}
```

> ✅ Prefer `calc def` over raw expressions when the formula is complex or used in more than one place.
> ✅ `calc def` is the SysML equivalent of a mathematical function definition.
> ⚠️ A `calc def` must have a `return` statement. An `action def` without `return` is for procedures.

---

### `concern` / `concern def`

```
Category    : Requirements
Form(s)     : concern def <Name> { doc …; stakeholder …; }
              concern <name> : <Type>;
Definition? : yes
Pairs with  : stakeholder, actor, doc, requirement def (:>)
```

A **concern** captures a stakeholder interest at a high level — the "why" behind one or more requirements. Requirements can specialise concerns (`:>`), providing the formal traceability chain from stakeholder interest to verifiable constraint.

```sysml
concern def SafetyConcern {
    doc /* Occupants and bystanders must not be harmed by the vehicle. */
    stakeholder regulatoryAuthority;
    stakeholder insuranceProvider;
    stakeholder driver;
}

// A requirement traces back to the concern via specialization
requirement def CrashSafety :> SafetyConcern {
    subject v : Vehicle;
    require constraint { v.frontalImpactRating >= 4 }
}
```

> ✅ Use concerns to capture why a requirement exists, not what it says.
> ✅ Concerns make the model's stakeholder traceability explicit and tool-navigable.

---

### `connection` / `connection def`

```
Category    : Structural
Form(s)     : connection def <Name> { end …; end …; }
              connection <name> : <Type> connect (a, b);
              connect a.port to b.port;        ← inline, anonymous
              connect a with b;                ← peer (no direction)
              connect from src to dst;         ← directed
Definition? : yes
Pairs with  : end, connect, to, from, with, interface def
```

A **connection** wires two (or more) elements together, typically through their ports. The inline `connect` shorthand is the most common form; a full `connection def` adds a type, properties, and can be reused.

```sysml
// ── Inline: the shortest form ─────────────────────────────────────────
part def Flashlight {
    part battery : Battery;
    part bulb    : Bulb;
    connect battery.supply to bulb.supply;
}

// ── Typed connection: the wire itself has properties ──────────────────
connection def WireHarness {
    end positive : PowerOutPort;
    end negative : PowerInPort;
    attribute resistance : ResistanceValue;
    attribute length     : LengthValue;
}

part def ControlPanel {
    part sensor : Sensor;
    part display : Display;
    connection wire : WireHarness
        connect (sensor.dataOut, display.dataIn) {
            attribute :>> length = 0.3 [m];
        }
}
```

> ✅ Use inline `connect` for simple wiring that needs no name or properties.
> ✅ Use `connection def` when the connection itself carries attributes or is reused.
> ✅ Use `interface def` instead when you need to specify a bilateral contract (conjugate ports).
> ⚠️ Port directions must be consistent: `out` connects to `in`, or both are conjugated via `~`.

---

### `constraint` / `constraint def`

```
Category    : Requirements / Analytical
Form(s)     : constraint def <Name> { in …; <BooleanExpr> }
              constraint { <BooleanExpr> }        ← anonymous inline
              require constraint { <BooleanExpr> }
              assume  constraint { <BooleanExpr> }
Definition? : yes
Pairs with  : require, assume, requirement def, forall, exists, and, or, not
```

A **constraint** is a Boolean expression that must hold. It is the atomic building block of formal requirements and assertions. The body of a constraint is a pure Boolean expression — no statements, no side effects.

```sysml
// ── Named, reusable constraint ────────────────────────────────────────
constraint def WithinBudget {
    in actual : MassValue;
    in limit  : MassValue;
    actual <= limit
}

// ── Anonymous inline constraint (inside a requirement) ────────────────
requirement def MaxMass {
    subject v : Vehicle;
    require constraint { v.mass <= 2500 [kg] }
}

// ── Constraint using quantifiers ──────────────────────────────────────
requirement def AllBeltsOn {
    subject v : Vehicle;
    require constraint {
        forall p in v.passengers {
            p.seatbelt.fastened
        }
    }
}

// ── Constraint with logical operators ─────────────────────────────────
requirement def SafeOperatingRange {
    subject s : Sensor;
    require constraint {
        s.temperature >= -40 [°C] and
        s.temperature <=  85 [°C]
    }
}
```

> ✅ Constraint bodies use `==`, `!=`, `<`, `<=`, `>`, `>=`, `and`, `or`, `not`, `xor`, `implies`.
> ⚠️ Never use `&&`, `||`, `!` — these are not valid in SysML expressions.
> ⚠️ Never use `=` inside a constraint body (that is assignment). Use `==` for equality.

---

### `enum` / `enum def`

```
Category    : Structural / Value
Form(s)     : enum def <Name> { <Member>; <Member>; … }
              attribute color : PaintColor;
Definition? : yes
Pairs with  : attribute
```

An **enumeration** defines a closed set of named values. Use for any attribute whose legal values are a fixed list.

```sysml
enum def OperatingMode {
    standby;
    active;
    degraded;
    safeMode;
}

enum def Colour {
    red;
    green;
    blue;
    white;
    black;
}

part def StatusLight {
    attribute mode   : OperatingMode = standby;
    attribute colour : Colour;
}

// ── Reference an enum value ───────────────────────────────────────────
part myLight : StatusLight {
    attribute :>> colour = Colour::red;
}
```

> ✅ Enum values are accessed via `EnumName::value` (namespace notation).
> ✅ Prefer enums over bare strings for any attribute with a small, fixed domain.

---

### `event`

```
Category    : Behavioral
Form(s)     : item def <Name>;                    ← events are usually items
              accept signal : <EventType>          ← in a transition
              accept <name> : <EventType>          ← with binding
Definition? : no (events are items or signals — use item def)
Pairs with  : transition, accept, state, action
```

An **event** is an occurrence that a state machine or action can receive. Events are not declared with a special keyword — they are typed as `item def`s and received via `accept` inside transitions.

```sysml
// ── Define the event types ─────────────────────────────────────────────
item def PowerButtonPress;
item def LowBatteryAlert { attribute level : Real; }

// ── Receive events in transitions ─────────────────────────────────────
state def DeviceState {
    state off;
    state on;
    state lowPower;

    transition turnOn   first off    accept p : PowerButtonPress  then on;
    transition turnOff  first on     accept p : PowerButtonPress  then off;
    transition battery  first on     accept e : LowBatteryAlert
                                     if e.level < 0.1             then lowPower;
}
```

---

### `flow` / `flow def`

```
Category    : Behavioral / Structural
Form(s)     : flow from <source> to <target>;
              succession flow <name> from <source> to <target>;
              flow def <Name> { … }
Definition? : yes
Pairs with  : from, to, succession, item
```

A **flow** transfers an item between two elements over time. It is the dynamic counterpart of a structural connection — while a connection describes a physical wire, a flow describes the transfer of material, energy, or information along it.

```sysml
part def WaterSystem {
    part pump   : Pump   { out item water : Water; }
    part filter : Filter { in  item water : Water; out item clean : Water; }
    part tank   : Tank   { in  item clean : Water; }

    flow from pump.water   to filter.water;
    flow from filter.clean to tank.clean;
}

// ── Succession flow: ordered transfer ─────────────────────────────────
action def DataPipeline {
    succession flow rawData    from sensor.out   to preprocessor.in;
    succession flow cleanData  from preprocessor.out to classifier.in;
}
```

---

### `interface` / `interface def`

```
Category    : Structural
Form(s)     : interface def <Name> { end <name> : <PortType>; end <name> : <PortType>; }
              interface <name> : <Type> connect (a, b);
Definition? : yes
Pairs with  : end, connect, port def, ~
```

An **interface** is a typed connection between exactly two elements, specifying a bilateral contract via conjugate ports. Use `interface` (over plain `connection`) when the interaction has a named, reusable protocol.

```sysml
// ── Port pair ──────────────────────────────────────────────────────────
port def PowerOutPort { out current : Electricity; }
port def PowerInPort  :> ~PowerOutPort;

// ── Interface: the power supply contract ──────────────────────────────
interface def PowerSupplyInterface {
    end source : PowerOutPort;
    end sink   : PowerInPort;
}

part def System {
    part battery : Battery { port supply : PowerOutPort; }
    part motor   : Motor   { port power  : PowerInPort;  }

    interface power : PowerSupplyInterface
        connect (battery.supply, motor.power);
}
```

> ✅ Interfaces express "what this connection promises" at both ends.
> ✅ The two `end`s must be conjugate port types (one `out`, one `in`, or one `~` of the other).

---

### `item` / `item def`

```
Category    : Structural / Flow
Form(s)     : item def <Name> { … }
              item <name> : <Type>;
              out item <name> : <Type>;     ← directional item on a port
Definition? : yes
Pairs with  : port, flow, in, out
```

An **item** is something that flows, is exchanged, or is consumed — matter, energy, data, signals, or forces. Items are not parts (they have no structural location); they move through the system via ports and flows.

```sysml
// ── Physical items ─────────────────────────────────────────────────────
item def FuelLiquid;
item def ExhaustGas;
item def HeatEnergy;

// ── Data items ─────────────────────────────────────────────────────────
item def CommandPacket {
    attribute commandId : Integer;
    attribute payload   : String;
}

item def SensorReading {
    attribute timestamp : TimeValue;
    attribute value     : Real;
}

// ── Items on ports ─────────────────────────────────────────────────────
port def EngineExhaust {
    out item exhaust : ExhaustGas;
    out item heat    : HeatEnergy;
}
```

> ✅ If the thing *flows* or is *exchanged*, it's an `item`. If it *exists as a component*, it's a `part`.
> ✅ Items give ports their semantic meaning — a port without an item type is a bare connector.

---

### `metadata` / `metadata def`

```
Category    : Annotation
Form(s)     : metadata def <Name> { attribute …; }
              metadata <name> : <Type> { attribute :>> …; }
              @<Name>                         ← short-form marker (no attributes)
              @<Name> { attribute = value; }  ← short-form with attributes
Definition? : yes
Pairs with  : @, attribute
```

**Metadata** annotates any model element with tagged information — status, ownership, safety classification, review state. It is the SysML v2 equivalent of a stereotype in v1, but formally typed and queryable.

```sysml
// ── Marker (no attributes) ────────────────────────────────────────────
metadata def SafetyCritical;
metadata def COTS;              // commercial off-the-shelf

// ── Structured metadata ────────────────────────────────────────────────
metadata def Owner {
    attribute team    : String;
    attribute contact : String;
}

metadata def ReviewStatus {
    attribute status     : String;      // "draft" | "under-review" | "approved"
    attribute reviewDate : String;
}

// ── Applying metadata ─────────────────────────────────────────────────
@SafetyCritical
@Owner { team = "Avionics"; contact = "alice@example.com"; }
@ReviewStatus { status = "approved"; reviewDate = "2025-09-15"; }
part def FlightControlComputer { … }

// ── Long form (same result) ───────────────────────────────────────────
metadata owner : Owner {
    attribute :>> team    = "Avionics";
    attribute :>> contact = "alice@example.com";
}
```

> ✅ `@Name` is short for `metadata : Name;` and can appear directly above any element.
> ✅ Metadata is queryable by tools — use it for MBSE governance (traceability IDs, maturity levels, safety classifications).
> ⚠️ Metadata does not affect the model's formal semantics — it is annotation only.

---

### `namespace`

```
Category    : Organisational
Form(s)     : namespace <Name> { … }
Definition? : no
Pairs with  : package, import
```

A **namespace** is a lighter-weight organisational container than a `package`. Packages are namespaces; the `namespace` keyword introduces a namespace that does not import anything by default. Rarely used directly — prefer `package` in practice.

```sysml
namespace Utilities {
    calc def Clamp {
        in val : Real; in lo : Real; in hi : Real;
        return : Real = if val < lo then lo else if val > hi then hi else val;
    }
}
```

---

### `occurrence` / `occurrence def`

```
Category    : Semantic (KerML-level)
Form(s)     : occurrence def <Name>;
              occurrence <name> : <Type>;
Definition? : yes
Pairs with  : snapshot, timeslice, individual
```

An **occurrence** is the most general kind of thing that happens in space-time. `part def`, `action def`, `state def`, etc. are all specializations of `occurrence def`. In ordinary SysML work you rarely write `occurrence def` directly — use the more specific keyword that fits your concept.

```sysml
occurrence def SystemLifecycle {
    occurrence def Manufacturing :> SystemLifecycle;
    occurrence def Operations    :> SystemLifecycle;
    occurrence def Disposal      :> SystemLifecycle;
}
```

> ⚠️ If you find yourself writing `occurrence def`, ask whether `part def`, `action def`, or `state def` is more appropriate. `occurrence def` is for modelling abstract temporal extents with no more specific type.

---

### `package`

```
Category    : Organisational
Form(s)     : package <Name> { … }
              standard library package <Name> { … }   ← for library authors only
Definition? : no
Pairs with  : import, private, public, protected, namespace
```

A **package** is the primary namespace and containment unit. Every SysML model element lives inside a package. A `.sysml` file should contain exactly one top-level package.

```sysml
package VehicleModel {

    private import ISQ::*;
    private import SI::*;

    package Structure {
        part def Vehicle { … }
        part def Engine  { … }
    }

    package Requirements {
        requirement def Safe { … }
    }

    package Verification {
        verification case def SafetyTest { … }
    }
}
```

> ✅ Nest packages to organise a large model — `Structure`, `Behavior`, `Requirements`, `Verification` is a common split.
> ✅ One `.sysml` file = one top-level package (by convention; not a grammar rule).
> ⚠️ `standard library package` is used only inside `sysml.library/`. User code must never declare `standard` packages.

---

### `part` / `part def`

```
Category    : Structural
Form(s)     : part def <Name> { … }
              part <name> : <Type>;
              part <name> : <Type> [mult];
              ref part <name> : <Type>;
              abstract part def <Name>;
Definition? : yes
Pairs with  : abstract, ref, port, attribute, connection, perform, exhibit, :>, :>>
```

A **part** is the central structural element — anything that *exists* as a component of a system: hardware, software, people, organisations, subsystems. It is the replacement for SysML v1's `Block`.

```sysml
// ── Abstract base type ────────────────────────────────────────────────
abstract part def PowerSource {
    attribute nominalVoltage : VoltageValue;
    port supply : PowerOutPort;
}

// ── Concrete specializations ──────────────────────────────────────────
part def Battery   :> PowerSource { attribute capacity : ElectricChargeValue; }
part def FuelCell  :> PowerSource { attribute efficiency : Real; }

// ── Composition: the car owns its parts ───────────────────────────────
part def Car {
    part engine       : Engine;
    part body         : Body;
    part wheels       : Wheel [4];          // exactly four
    part seats        : Seat  [2..5];       // between two and five
    part airbags      : Airbag [0..*];      // any number
    ref part  driver  : Person;             // reference — driver is not owned by the car
}

// ── A concrete instance ───────────────────────────────────────────────
part myCar : Car {
    attribute :>> wheels.diameter = 0.65 [m];
}
```

> ✅ Composition (`part child : Type`) = the parent owns the child.
> ✅ Reference (`ref part child : Type`) = the parent points to a child owned elsewhere.
> ✅ `abstract` prevents direct instantiation; the type must be specialized.
> ⚠️ `part def myCar` defines a *type*; to create one specific car, write `part myCar : Car`.

---

### `port` / `port def`

```
Category    : Structural / Interaction
Form(s)     : port def <Name> { in/out item …; }
              port def <Name> :> ~<OtherPortDef>;   ← conjugate
              port <name> : <Type>;
              in port / out port / inout port …
Definition? : yes
Pairs with  : in, out, inout, ~, connect, interface, item
```

A **port** is an interaction point on a part — the place where a part connects to the world. Ports carry typed items in and out. A port definition describes the protocol; a port usage places it on a part.

```sysml
// ── Port definition with items ────────────────────────────────────────
port def HydraulicOutPort {
    out item fluid    : HydraulicFluid;
    out attribute pressure : PressureValue;
}

// ── Conjugate port: all directions are flipped ────────────────────────
port def HydraulicInPort :> ~HydraulicOutPort;

// ── Hierarchical port (a port containing sub-ports) ────────────────────
port def VehicleBus {
    port can  : CANPort;
    port lin  : LINPort;
    port eth  : EthernetPort;
}

// ── Port usages on a part ──────────────────────────────────────────────
part def HydraulicActuator {
    port supply : HydraulicInPort;     // receives fluid
    port return : HydraulicOutPort;    // returns fluid
    port control : CommandInPort;      // receives commands
}
```

> ✅ Define a port-type pair (out + conjugate in) for every distinct interaction protocol.
> ✅ Use `~` to derive the inverse port type automatically — do not duplicate the body.
> ⚠️ Ports with no items are legal but semantically thin; prefer typed items for clarity.

---

### `rendering` / `rendering def`

```
Category    : Presentation
Form(s)     : rendering def <Name>;
              rendering <name> : <Type>;
Definition? : yes
Pairs with  : view def, render
```

A **rendering** is a presentation specification — it tells tools how to display a view (as a table, tree, diagram, custom format). Rendering definitions are named so they can be referenced from multiple view definitions.

```sysml
rendering def TableRendering;
rendering def TreeRendering;
rendering def InterconnectDiagram;

view def MassBudget {
    expose vehicle.*.mass;
    render TableRendering;
}
```

---

### `requirement` / `requirement def`

```
Category    : Requirements
Form(s)     : requirement def <Name> { doc …; subject …; assume …; require …; }
              requirement <name> : <Type> { subject = …; }
Definition? : yes
Pairs with  : subject, doc, assume, require, constraint, satisfy, verify, stakeholder, concern
```

A **requirement** is a formal, machine-checkable constraint on a subject, plus supporting context (documentation, assumptions, stakeholders). Requirements are first-class model elements — not just text.

```sysml
// ── Atomic requirement ─────────────────────────────────────────────────
requirement def MaxResponseTime {
    doc /* The system shall respond to any user command within 200 ms. */

    subject sys : ControlSystem;
    attribute limit : TimeValue = 200 [ms];

    assume  constraint { sys.commandRate <= 100 [Hz] }   // pre-condition
    require constraint { sys.responseTime <= limit }      // the actual requirement
}

// ── Composite requirement (sub-requirements) ───────────────────────────
requirement def SystemSafety {
    doc /* The system shall be safe to operate under all conditions. */
    subject sys : System;

    requirement noExplosion {
        require constraint { sys.pressure <= sys.burstPressure * 0.75 }
    }
    requirement noOverheat {
        require constraint { sys.temperature <= 85 [°C] }
    }
    requirement failSafe {
        require constraint { sys.failSafeMode == true }
    }
}

// ── Usage: bind the requirement to a concrete instance ─────────────────
part mySystem : ControlSystem {
    satisfy MaxResponseTime;
}
```

> ✅ Every `requirement def` must have a `subject` — what the requirement is about.
> ✅ Every `requirement def` must have at least one `require constraint { … }`.
> ✅ A `doc` comment is mandatory by convention — without it the requirement is unreadable.
> ⚠️ Pre-conditions go in `assume`, not `require`. A false assumption invalidates (suspends) the requirement; it does not mean the system failed it.

---

### `state` / `state def`

```
Category    : Behavioral
Form(s)     : state def <Name> { state …; transition …; }
              state <name>;                          ← simple sub-state
              state <name> { entry …; do …; exit …; state …; }
              exhibit state <name> : <Type>          ← part declares it exhibits this state
Definition? : yes
Pairs with  : entry, do, exit, transition, exhibit, first, then, accept
```

A **state** is a stable mode of a part. States persist until a transition fires. A `state def` describes the state machine; `exhibit state` places it on a part.

```sysml
state def TrafficLightState {
    state green  { do action letTrafficThrough; }
    state yellow { do action warnTraffic; }
    state red    { do action stopTraffic; }

    transition g2y first green  then yellow;
    transition y2r first yellow then red;
    transition r2g first red    then green;
}

// ── Hierarchical states ────────────────────────────────────────────────
state def VehicleMode {
    state off;
    state on {
        state idle;
        state driving {
            state accelerating;
            state cruising;
            state braking;
        }
        state charging;
    }
    state fault;

    transition powerOn   first off  accept p : PowerEvent then on::idle;
    transition powerOff  first on   accept p : PowerEvent then off;
    transition faultDetected first on then fault;
}

// ── Attach to a part ──────────────────────────────────────────────────
part def Vehicle {
    exhibit state mode : VehicleMode;
}
```

> ✅ Use `entry`, `do`, `exit` to attach actions to a state's lifecycle.
> ✅ `first X then Y` inside a state body is shorthand for a simple succession.
> ✅ Hierarchical states: a transition to `on::idle` enters the `on` state and immediately enters its `idle` sub-state.

---

### `succession` / `succession def`

```
Category    : Behavioral
Form(s)     : succession first <a> then <b>;
              succession <name> first <a> then <b>;
              first <a> then <b> then <c>;         ← chained shorthand
Definition? : yes (rarely used)
Pairs with  : first, then, action, state, flow
```

A **succession** is an ordering constraint between two behaviors: *b* cannot start until *a* has completed. It is the behavioral counterpart of a structural connection.

```sysml
action def StartupProcedure {
    action selfTest;
    action loadFirmware;
    action initSensors;
    action reportReady;

    // Chained succession
    first selfTest
    then  loadFirmware
    then  initSensors
    then  reportReady;
}

// ── Explicit succession with a name ───────────────────────────────────
succession testBeforeFirmware first selfTest then loadFirmware;
```

---

### `transition`

```
Category    : Behavioral
Form(s)     : transition first <source> then <target>;
              transition first <source> accept <e> : <Type> then <target>;
              transition first <source> if <guard> then <target>;
              transition first <source> accept <e> : <Type> if <guard> do <action> then <target>;
Definition? : no
Pairs with  : first, then, accept, if, do, state
```

A **transition** fires when its source state is active, its trigger event (if any) is received, and its guard (if any) is true. On firing, its effect action (if any) runs and the target state becomes active.

```sysml
state def DoorState {
    state closed;
    state open;
    state locked;

    // ── No trigger: automatic (immediate) ─────────────────────────────
    transition autoClose first open then closed;

    // ── With event trigger ────────────────────────────────────────────
    transition openDoor first closed accept e : OpenCmd then open;

    // ── With trigger and guard ────────────────────────────────────────
    transition lockDoor
        first closed
        accept e : LockCmd
        if authToken.valid
        then locked;

    // ── With trigger, guard, and effect action ────────────────────────
    transition emergencyOpen
        first locked
        accept e : EmergencySignal
        if e.priority == 1
        do action logEmergency
        then open;
}
```

> ✅ Every transition must have both `first` (source) and `then` (target).
> ✅ `accept` receives an event item; bind it to a local name to access its attributes inside the guard.
> ✅ `if` is the guard — a Boolean expression; transition only fires if it evaluates to `true`.
> ✅ `do` is the effect — an action that runs atomically as the transition fires.
> ⚠️ The `do` keyword inside a transition is the *effect* action. Inside a state body, `do action …` is the *ongoing* behavior. These are different.

---

### `use case` / `use case def`

```
Category    : Behavioral / Requirements
Form(s)     : use case def <Name> { subject …; actor …; objective …; action …; }
              use case <name> : <Type>;
              include <UseCase>;
Definition? : yes
Pairs with  : subject, actor, objective, include, first, then
```

A **use case** describes a user-visible goal: an interaction between an actor and the system that produces a result of value. Use cases are specialised actions with an explicit subject and actors.

```sysml
use case def PurchaseTicket {
    doc /* A passenger purchases a transit ticket using the kiosk. */

    subject kiosk   : TicketKiosk;
    actor passenger : Person;

    objective ticketIssued;

    action selectRoute;
    action selectTicketType;
    action makePayment;
    action printTicket;

    first selectRoute
    then  selectTicketType
    then  makePayment
    then  printTicket;
}

// ── Include: reuse another use case as a step ─────────────────────────
use case def PurchaseMonthlyPass :> PurchaseTicket {
    include VerifyIdentity;
}
```

> ✅ `subject` is the system-under-test; `actor` is the external participant.
> ✅ Use `include` (not `extend`) to embed one use case inside another.
> ✅ Use cases are user-facing; internal system behaviors are `action def`s.

---

### `verification case` / `verification case def`

```
Category    : Requirements / Analytical
Form(s)     : verification case def <Name> { subject …; objective { verify …; } }
              verification case <name> : <Type> { subject = …; }
Definition? : yes
Pairs with  : subject, objective, verify, first, then, satisfy
```

A **verification case** is a test, analysis, inspection, or demonstration that proves a requirement is satisfied. The `verify` keyword inside an `objective` links the case to the requirement it addresses.

```sysml
verification case def HydrostaticPressureTest {
    doc /* Fill the vessel to 1.5× design pressure and hold for 30 min. */

    subject v : PressureVessel;
    objective verifyBurst {
        verify MaxOperatingPressure;      // links to a requirement def
    }

    action fillToTestPressure;
    action holdFor30Minutes;
    action inspectForLeaks;
    action recordResult;

    first fillToTestPressure
    then  holdFor30Minutes
    then  inspectForLeaks
    then  recordResult;
}

// ── Specific run of the test ───────────────────────────────────────────
verification case tank1Test : HydrostaticPressureTest {
    subject = storageTank1;
}
```

---

### `view` / `view def`

```
Category    : Presentation
Form(s)     : view def <Name> { frame …; expose …; render …; }
              view <name> : <Type> { expose …; }
Definition? : yes
Pairs with  : viewpoint def, frame, expose, render, rendering def
```

A **view** is a curated projection of the model — a subset of elements, formatted for a specific purpose or audience. Views do not change the model; they select and present it.

```sysml
view def PowerBudgetView {
    doc /* Shows power consumption of every electrical component. */
    frame PowerBudgetViewpoint;

    expose vehicle.*.nominalPower,
           vehicle.battery.capacity;

    render TableRendering;
}

// ── Instantiate the view on a concrete model ──────────────────────────
view powerBudget : PowerBudgetView {
    expose myVehicle.*.nominalPower;
}
```

---

### `viewpoint` / `viewpoint def`

```
Category    : Presentation
Form(s)     : viewpoint def <Name> { stakeholder …; concern …; require …; }
              viewpoint <name> : <Type>;
Definition? : yes
Pairs with  : stakeholder, concern, view def, frame
```

A **viewpoint** captures the purpose and audience for a set of views — whose interests does it serve, what questions does it answer. Views reference a viewpoint via `frame`.

```sysml
viewpoint def SystemEngineerViewpoint {
    doc /* Addresses the system engineer's need to understand allocation and interfaces. */
    stakeholder systemEngineer;
    concern interfaceDefinition;
    concern allocationCompleteness;
    require renderViewAsDiagram;
}
```

---

## Part 2 — Modifier Keywords

Modifiers precede the element keyword and change its semantics. Order: `visibility → abstract → variation/variant → derived → readonly → ref → individual → snapshot → timeslice → direction`.

---

### `abstract`

```
Category    : Modifier
Applies to  : definitions only (part def, port def, action def, state def, …)
Position    : before the element keyword
```

Marks a definition as **incomplete** — it cannot be instantiated directly and must be specialized before use.

```sysml
abstract part def Vehicle;          // cannot write: part v : Vehicle;
part def Car :> Vehicle { … }       // can write: part c : Car;

abstract action def Transform {
    in  source : Data;
    out result : Data;
}
// Must be specialized; action a : Transform is invalid.
```

> ✅ Use `abstract` to declare a shared interface for a family of types.
> ✅ If a `part def` has required attributes that can only be filled by specializations, mark it `abstract`.

---

### `derived`

```
Category    : Modifier
Applies to  : attribute usages
Position    : before attribute keyword
```

Marks an attribute as **computed** from other features. A derived attribute cannot be set; it is always recalculated from its expression.

```sysml
part def Rectangle {
    attribute width  : LengthValue;
    attribute height : LengthValue;
    derived attribute area      : AreaValue   = width * height;
    derived attribute perimeter : LengthValue = 2 * (width + height);
    derived attribute aspectRatio : Real      = width / height;
}
```

> ⚠️ The `=` in a `derived attribute` declaration is not an initial value — it is the permanent expression that defines the attribute. It cannot be overridden in a usage.

---

### `individual`

```
Category    : Modifier
Applies to  : definitions and usages
Position    : before element keyword
```

Marks an element as a **specific, uniquely identified individual** — a single entity in the world, not a type. Used for modelling unique physical items or named persons.

```sysml
individual part def Sun;         // there is exactly one Sun
individual part earth : Planet;  // a specific planet, not just any planet
```

---

### `nonunique`

```
Category    : Modifier
Applies to  : usages with multiplicity > 1
Position    : before element keyword
```

Allows the same element instance to appear **multiple times** in the collection (relaxes the default set semantics to multiset semantics).

```sysml
nonunique part readings : SensorReading [0..*];  // same reading may appear twice
```

---

### `ordered`

```
Category    : Modifier
Applies to  : usages with multiplicity > 1
Position    : before element keyword
```

The collection is a **sequence** — order matters and is preserved. Combined with `nonunique` for a bag; alone for a list; neither for a set (the default).

```sysml
ordered part waypoints : Waypoint [1..*];          // path must be followed in order
ordered nonunique part log : Event [0..*];          // ordered log, duplicates allowed
```

---

### `readonly`

```
Category    : Modifier
Applies to  : attribute usages
Position    : before attribute keyword
```

The attribute can be set **once** (typically at creation time) and then never changed.

```sysml
part def Sensor {
    readonly attribute serialNumber : String;   // set at manufacture, never changed
    readonly attribute calibDate    : String;
    attribute reading : Real;                   // updated continuously
}
```

---

### `ref`

```
Category    : Modifier
Applies to  : usages (part, port, …)
Position    : before element keyword
```

The usage is a **reference** to an element owned elsewhere — not a composition. The referencing container does not own the referenced element; its lifetime is independent.

```sysml
part def Workshop {
    part bay [3];                          // OWNED by the workshop
    ref part scheduledVehicle : Vehicle;   // REFERENCED; the vehicle lives elsewhere
}
```

> ⚠️ The default (no `ref`) is composition. Composition means the child's lifetime is bounded by the parent's.
> ✅ Use `ref` when the same element is shared across multiple containment contexts.

---

### `snapshot`

```
Category    : Modifier
Applies to  : occurrences
Position    : before element keyword
```

A **snapshot** represents an element at a single instant in time — a zero-duration slice of its lifetime.

```sysml
snapshot part vehicleAtLaunch : Vehicle;  // the vehicle's state at the moment of launch
```

---

### `timeslice`

```
Category    : Modifier
Applies to  : occurrences
Position    : before element keyword
```

A **timeslice** represents an element over a bounded time interval — a portion of its lifetime.

```sysml
timeslice part vehicleDuringTest : Vehicle;  // the vehicle's existence during the test phase
```

---

### `variation` / `variant`

```
Category    : Modifier / Variability
Applies to  : definitions
Position    : before element keyword
Pairs with  : each other
```

`variation` declares a **choice point** — a definition with multiple alternatives. `variant` marks each alternative. Exactly one variant is selected in any given configuration.

```sysml
variation part def Drivetrain {
    variant part def CombustionDrivetrain {
        part engine : CombustionEngine;
        part fuelTank : FuelTank;
    }
    variant part def ElectricDrivetrain {
        part motor   : ElectricMotor;
        part battery : TractionBattery;
    }
    variant part def HybridDrivetrain {
        part engine  : CombustionEngine;
        part motor   : ElectricMotor;
        part battery : HVBattery;
    }
}

variation attribute def WheelDriveConfig {
    variant attribute def FWD;
    variant attribute def RWD;
    variant attribute def AWD;
}
```

> ✅ Use `variation`/`variant` for product-line modelling — one model, many configurations.
> ✅ A constraint or analysis case selects among variants for a specific configuration.

---

## Part 3 — Visibility Keywords

### `public` / `private` / `protected`

```
Category    : Visibility
Applies to  : imports, members
Position    : before import or element keyword
```

| Keyword | Meaning |
|---|---|
| `public` | The member is visible to any element that imports this package. |
| `private` | The member is local to this package; importers cannot see it. |
| `protected` | Visible to specializations of this element. |

```sysml
package Vehicles {
    public  import ISQ::*;              // re-exported to importers of Vehicles
    private import InternalUtils::*;    // internal only

    public  part def Car { … }         // visible outside
    private part def InternalPart { … } // not visible outside
}

package Other {
    import Vehicles::*;
    // Car is visible here; InternalPart is not; ISQ::* is also visible (re-exported)
}
```

> ✅ Default import visibility is `private` — use `public` only when you intend to re-export.
> ✅ `public` on an import is a common source of unintended namespace pollution; use carefully.

---

## Part 4 — Direction Keywords

### `in` / `out` / `inout`

```
Category    : Direction
Applies to  : port items, action parameters, port usages
Position    : before item or attribute inside a port body; before action parameters
```

Direction from the perspective of the **containing element**.

```sysml
port def SensorPort {
    out item reading  : SensorData;    // data flows out of the sensor
    in  item command  : Command;       // commands flow into the sensor
    inout item config : Configuration; // bidirectional configuration channel
}

action def Filter {
    in  raw    : Signal;               // receives raw signal
    out result : Signal;               // produces filtered signal
    inout log  : LogBuffer;            // reads and writes a log
}
```

> ✅ `out` on a port means data flows *out of* the element owning the port.
> ✅ When connecting two ports, `out` connects to `in`; or use conjugation (`~`) to derive the matching port automatically.

---

## Part 5 — Relationship Keywords

### `accept`

```
Category    : Behavioral
Form(s)     : accept <name> : <Type>     ← inside a transition
Pairs with  : transition, event/item types
```

Declares that a transition fires in response to receiving an item of the given type. The item is bound to the local name and can be used in the guard.

```sysml
transition idle2running
    first idle
    accept cmd : StartCommand
    if cmd.priority >= 2
    then running;
```

---

### `allocate`

```
Category    : Structural / Cross-cutting
Form(s)     : allocate <source> to <target>;
Pairs with  : allocation def
```

The short form for declaring an allocation relationship.

```sysml
allocate processNavigation to navigationProcessor;
allocate renderHUD         to displayController;
```

---

### `assume`

```
Category    : Requirements
Form(s)     : assume constraint { <BoolExpr> }
Pairs with  : require, constraint, requirement def
```

A **pre-condition** on a requirement. If the `assume` expression is false, the requirement is **suspended** (neither passed nor failed). `assume` captures the valid operating domain of the requirement.

```sysml
requirement def Accurate {
    subject s : Sensor;
    assume  constraint { s.temperature >= -20 [°C] and s.temperature <= 60 [°C] }
    require constraint { s.accuracy <= 0.01 }
}
```

> ✅ `assume` is for preconditions that define when the requirement applies.
> ⚠️ A requirement with a false `assume` does not fail the system — it is inapplicable.

---

### `bind` / `binding`

```
Category    : Structural / Analytical
Form(s)     : bind a.x = b.y;
              binding <name> of a.x = b.y;
Pairs with  : =
```

Declares that two feature values are always equal — they are the same value, not just equal at one moment. A binding is stronger than a connection; it equates the feature values semantically.

```sysml
part def System {
    attribute totalBudget : Real;
    part subsystemA : SubA { attribute budget : Real; }
    part subsystemB : SubB { attribute budget : Real; }

    bind totalBudget = subsystemA.budget + subsystemB.budget;
}
```

---

### `by`

```
Category    : Requirements / Relationship
Form(s)     : satisfy <Req> by <usage>;
              defined by <Type>;
              typed by <Type>;
Pairs with  : satisfy, defined, typed
```

`by` qualifies a relationship — it names the element that performs or fulfils the indicated role.

```sysml
satisfy MaxMassLimit by myCar;       // myCar satisfies the requirement
attribute mass defined by MassValue; // alternative typing form
```

---

### `chains`

```
Category    : Structural (KerML-level)
Form(s)     : attribute a chains x.y.z;
Pairs with  : feature chaining
```

Declares that a feature is the composition (chain) of a sequence of feature accesses along a path. Rarely written explicitly in SysML — prefer direct feature access.

```sysml
attribute engineMass chains engine.core.mass;
```

---

### `connect`

```
Category    : Structural
Form(s)     : connect <a> to <b>;
              connect <a> with <b>;
              connect from <a> to <b>;
              connect (<a>, <b>, <c>);
Pairs with  : connection, to, from, with
```

Inline keyword for creating an anonymous connection between ports or parts.

```sysml
part def Plumbing {
    part valve  : Valve;
    part heater : Heater;
    part shower : Shower;

    connect valve.out     to heater.in;
    connect heater.out    to shower.in;
    connect shower with drain;          // peer: no single direction
}
```

---

### `defined by`

```
Category    : Structural
Form(s)     : attribute <name> defined by <Type>;
Pairs with  : typed by, attribute
```

An alternative to `: Type` for explicit typing. Rarely used — prefer `: Type`.

---

### `do`

```
Category    : Behavioral
Applies to  : state body (ongoing action) AND transition body (effect action)
```

Inside a **state body**: the action that runs continuously while the state is active.

```sysml
state def Monitoring {
    do action sampleSensors;    // runs while in Monitoring state
}
```

Inside a **transition**: the effect action that runs as the transition fires.

```sysml
transition
    first running
    accept e : FaultEvent
    do action logFault          // fires once during the transition
    then faulted;
```

---

### `end`

```
Category    : Structural
Form(s)     : end <name> : <PortType>;    ← in connection def / interface def
              end ::> <feature>;          ← explicit end binding
Pairs with  : connection def, interface def
```

Names and types the endpoints of a connection or interface definition.

```sysml
connection def Pipe {
    end inlet  : FluidInPort;
    end outlet : FluidOutPort;
    attribute diameter : LengthValue;
}
```

---

### `entry` / `exit`

```
Category    : Behavioral
Applies to  : state body
```

`entry` runs once when the state is entered. `exit` runs once when the state is exited.

```sysml
state def Heating {
    entry action turnOnHeater;      // called on entering Heating
    do    action monitorTemp;       // continuous while in Heating
    exit  action logHeatingDone;    // called on exiting Heating
}
```

---

### `exhibit`

```
Category    : Behavioral
Form(s)     : exhibit state <name> : <StateDef>;
              exhibit state <name> { … }
Pairs with  : state def, part def
```

A part **exhibits** a state machine — the part's mode of operation is governed by the state.

```sysml
part def TrafficLight {
    exhibit state signal : TrafficLightState;
}
```

---

### `expose`

```
Category    : Presentation
Form(s)     : expose <feature>, <feature>, …;
              expose <usage>.*.<attribute>;
Pairs with  : view def, view
```

Selects which model elements appear in a view.

```sysml
view def InterfaceView {
    expose vehicle.engine.ports,
           vehicle.battery.ports,
           vehicle.connections;
}
```

---

### `first` / `then`

```
Category    : Behavioral
Form(s)     : first <a> then <b>;
              first <a> then <b> then <c> …;   ← chained
Pairs with  : action, state, succession, transition
```

Sequence two or more steps in an action, state machine, or succession declaration. `first` marks the start; each `then` marks the next step.

```sysml
action def DeploySequence {
    first extendSolarPanels
    then  pointAntenna
    then  beginTransmission;
}
```

Inside a `transition`, `first` names the source state and `then` names the target state:

```sysml
transition powerOn first off then idle;
```

---

### `frame`

```
Category    : Presentation
Form(s)     : frame <ViewpointName>;
Pairs with  : view def, viewpoint def
```

Links a view definition to the viewpoint it addresses.

```sysml
view def SafetyView {
    frame SafetyEngineerViewpoint;
    expose system.safetyConstraints;
}
```

---

### `if` / `else`

```
Category    : Expression / Behavioral
Form(s)     : if <cond> then <expr> else <expr>    ← conditional expression
              transition … if <guard> then …        ← transition guard
Pairs with  : transition, constraint, attribute
```

In expressions, `if/then/else` is a ternary conditional:

```sysml
derived attribute label : String =
    if temperature > 80 [°C] then "hot" else "normal";
```

In transitions, `if` is the guard:

```sysml
transition safe2warn first safe if pressure > 80 [bar] then warning;
```

---

### `import`

```
Category    : Organisational
Form(s)     : import <Pkg>::<Name>;
              import <Pkg>::*;                  ← wildcard
              import <Pkg>::*::**;              ← recursive wildcard
              public  import <Pkg>::*;          ← re-export
              private import <Pkg>::*;          ← local (default)
              import <Pkg>::<Name> as <Alias>;  ← aliased
Pairs with  : package, as, public, private
```

Brings names from another package into the current scope. The most important keyword for managing name resolution.

```sysml
package MyModel {
    private import ISQ::*;                     // quantity types, locally
    public  import SI::*;                      // unit symbols, re-exported
    private import OtherModel::Vehicle;        // a single name
    private import OtherModel::Vehicle as Car; // aliased to avoid clash
}
```

> ✅ Default is `private` — use `public` only if you intend for your consumers to automatically have access to what you imported.
> ✅ Wildcard `::*` is fine for small, well-known packages (`ISQ`, `SI`). Be explicit for large or unknown packages.

---

### `include`

```
Category    : Behavioral (use cases)
Form(s)     : include <UseCaseName>;
Pairs with  : use case def
```

Embeds one use case into another — the included use case is executed as part of the including one.

```sysml
use case def ComplexPurchase :> PurchaseTicket {
    include VerifyAge;        // always runs as part of ComplexPurchase
    include PrintReceipt;
}
```

---

### `objective`

```
Category    : Analytical / Requirements
Form(s)     : objective <name> : <Type>;                    ← analysis case result
              objective <name> { verify <Requirement>; }    ← verification case goal
Pairs with  : analysis case def, verification case def, verify, return
```

In an `analysis case`, an objective names the value being computed. In a `verification case`, an objective groups the requirements being verified.

```sysml
analysis case def PerformanceTrade {
    subject v : Vehicle;
    objective topSpeed    : SpeedValue;
    objective acceleration: TimeValue;
    objective range       : LengthValue;
}

verification case def FullSafetyVerification {
    subject s : System;
    objective verifySafety {
        verify SystemSafety;           // the composite requirement
    }
}
```

---

### `perform`

```
Category    : Behavioral
Form(s)     : perform action <name> : <Type>;
              perform action <name> { … }
Pairs with  : action def, part def
```

Declares that a **part** performs an action — it is responsible for executing that behavior.

```sysml
part def Engine {
    perform action combust : Combustion {
        in fuel = fuelLine.supply;
        out torque = shaft.torque;
    }
}
```

---

### `render`

```
Category    : Presentation
Form(s)     : render <RenderingName>;
Pairs with  : view def, rendering def
```

Specifies how a view should be presented.

```sysml
view def ComponentTree {
    expose system.*;
    render TreeRendering;
}
```

---

### `require`

```
Category    : Requirements
Form(s)     : require constraint { <BoolExpr> }
Pairs with  : requirement def, constraint, assume
```

Declares the **normative condition** inside a requirement — the Boolean expression that must hold for the system to satisfy the requirement.

```sysml
requirement def BatteryLife {
    subject d : Device;
    require constraint { d.batteryRuntime >= 8 [h] }
}
```

---

### `return`

```
Category    : Behavioral / Functional
Form(s)     : return : <Type> = <expr>;    ← in calc def
              return <name> : <Type> = <expr>;
Pairs with  : calc def
```

Specifies the output type and computation of a `calc def`.

```sysml
calc def SafetyMargin {
    in actual : Real;
    in limit  : Real;
    return : Real = (limit - actual) / limit;
}
```

---

### `satisfy`

```
Category    : Requirements
Form(s)     : satisfy <RequirementName>;
              satisfy <RequirementName> by <usage>;
Pairs with  : requirement def, part
```

Declares that the containing part (or the named usage) claims to meet the named requirement. A `satisfy` link is the assertion; a `verification case` with `verify` provides the evidence.

```sysml
part myVehicle : Vehicle {
    attribute :>> mass = 1800 [kg];
    satisfy MaxMassLimit;               // this vehicle claims to meet MaxMassLimit
}

// Or with explicit binding:
satisfy MaxMassLimit by myVehicle;
```

---

### `subject`

```
Category    : Requirements / Analytical
Form(s)     : subject <name> : <Type>;          ← in requirement / case definition
              subject = <usage>;                 ← in requirement / case usage
Pairs with  : requirement def, analysis case def, verification case def, use case def
```

Names the element that the requirement, analysis, verification, or use case is **about**. The subject name is in scope throughout the definition's body for use in constraints and calculations.

```sysml
requirement def MassLimit {
    subject vehicle : Vehicle;              // 'vehicle' is in scope below
    require constraint { vehicle.mass <= 2500 [kg] }
}

// In a usage, bind the subject to a concrete instance:
requirement massCheck : MassLimit {
    subject = myPrototype;
}
```

---

### `subsets`

```
Category    : Structural
Form(s)     : attribute <name> subsets <parent>;
Pairs with  : attribute, :>
```

Declares that the values of this feature are a **subset** of the values of the parent feature. The feature does not override the parent; both coexist.

```sysml
part def Vehicle {
    part wheels : Wheel [0..*];
    part driveWheels : Wheel [0..*] subsets wheels;   // driveWheels ⊆ wheels
}
```

---

### `verify`

```
Category    : Requirements
Form(s)     : verify <RequirementName>;    ← inside an objective block
Pairs with  : verification case def, objective
```

Links a verification case objective to the requirement it demonstrates.

```sysml
verification case def BrakeTest {
    subject v : Vehicle;
    objective verifyBraking {
        verify MaxBrakingDistance;
    }
}
```

---

## Part 6 — Expression Keywords

### `and` / `or` / `not` / `xor` / `implies`

```
Category    : Expression / Logic
Applies to  : Boolean expressions (constraints, guards, attribute values)
```

Logical connectives. **Never use** `&&`, `||`, `!` — only the keyword forms are valid.

```sysml
require constraint { speed > 0 [km/h] and speed <= 250 [km/h] }
require constraint { not (door.open and speed > 5 [km/h]) }
require constraint { (licenseValid xor guestMode) implies accessGranted }
```

---

### `as`

```
Category    : Organisational
Form(s)     : import <Pkg>::<Name> as <Alias>;
Pairs with  : import
```

Renames an imported element locally to avoid name clashes.

```sysml
import ModelA::Vehicle as VehicleA;
import ModelB::Vehicle as VehicleB;

part car : VehicleA;   // unambiguous
```

---

### `exists` / `forall`

```
Category    : Expression / Logic
Form(s)     : forall <var> in <collection> { <BoolExpr> }
              exists <var> in <collection> { <BoolExpr> }
Pairs with  : constraint, require
```

Quantified Boolean expressions over collections.

```sysml
// All passengers must have fastened seatbelts
require constraint {
    forall p in vehicle.passengers { p.seatbelt.fastened }
}

// At least one sensor must be active
require constraint {
    exists s in system.sensors { s.active }
}
```

---

### `hastype` / `istype`

```
Category    : Expression / Type check
Form(s)     : <expr> hastype <Type>
              <expr> istype  <Type>
Pairs with  : constraint, if
```

Runtime type tests. `hastype` checks whether the element's type is exactly `Type`; `istype` checks whether it is a specialization of `Type`.

```sysml
require constraint { engine istype ElectricMotor }

derived attribute isElectric : Boolean = drivetrain istype ElectricDrivetrain;
```

---

### `let` / `in`

```
Category    : Expression
Form(s)     : let <name> = <expr> in <body>
Pairs with  : constraint, attribute expressions
```

Introduces a local binding inside an expression to avoid repetition.

```sysml
derived attribute normalizedScore : Real =
    let raw   = rawScore / maxScore
    let bonus = if fastCompletion then 0.1 else 0.0
    in  raw + bonus;
```

---

### `null`

```
Category    : Expression / Literal
Applies to  : Optional attributes
```

The absence of a value.

```sysml
attribute optionalName : String = null;
```

---

### `true` / `false`

```
Category    : Expression / Literal
Applies to  : Boolean attributes, constraint expressions
```

```sysml
attribute active    : Boolean = true;
attribute emergency : Boolean = false;
require constraint { system.safetyEnabled == true }
```

---

## Part 7 — Documentation and Comment Keywords

### `doc`

```
Category    : Documentation
Form(s)     : doc /* <text> */
Position    : first statement inside an element body, or before a member
```

A **documentation comment** that is part of the model — not a source-code comment. It is attached to the enclosing or following element and is queryable by tools. Hover cards, reports, and generated documentation all draw from `doc` comments.

```sysml
part def TractionMotor {
    doc /* Three-phase permanent magnet synchronous motor for EV traction.
          Rated 150 kW peak / 80 kW continuous, 400 V nominal.
          See design spec DS-2025-047 for full parameters. */

    attribute peakPower       : PowerValue = 150 [kW];
    attribute continuousPower : PowerValue =  80 [kW];
    attribute nominalVoltage  : VoltageValue = 400 [V];
}
```

> ✅ Every `requirement def`, `part def`, `action def`, and `verification case def` should have a `doc` comment.
> ⚠️ `doc /* … */` is different from `/* … */`. The latter is a lexical comment (ignored by the parser). `doc` is modelled and appears in the AST.

---

### `comment`

```
Category    : Documentation
Form(s)     : comment about <Name> /* <text> */
              comment /* <text> */            ← attached to enclosing element
Pairs with  : doc
```

A standalone model comment attached to a named element. Richer than `doc` — `doc` is the primary description; `comment` provides additional notes, rationale, or cross-references.

```sysml
part def Fuel;

comment about Fuel /* This model uses Fuel as an abstract flow item.
                      Specific fuel types (Jet-A, RP-1, LOX) are specializations. */
```

---

## Part 8 — Symbols and Operators

### `:` — typing

Types a usage. `part car : Car` creates a usage of type `Car`.

### `:>` — specialization (`specializes`)

`A :> B` means A is a specialization of B (A is-a B, A inherits everything from B).

```sysml
part def ElectricCar :> Car :> Vehicle;   // multiple inheritance chain
```

### `:>>` — redefinition (`redefines`)

Overrides an inherited feature. The redefined name must exist in the parent.

```sysml
part def LightCar :> Car {
    :>> mass = 900 [kg];           // override the inherited 'mass' attribute
    :>> engine : ElectricMotor;    // narrow the type of the inherited 'engine'
}
```

### `~` — conjugation

Derives a port type whose directions are all flipped.

```sysml
port def OutPort  { out item data : Data; }
port def InPort   :> ~OutPort;     // auto-flipped: out becomes in
```

### `::` — namespace separator

Separates package names in a qualified name.

```sysml
attribute m : ISQ::MassValue;
import Vehicles::Structure::Car;
```

### `.` — feature access

Member access along a feature path.

```sysml
attribute t = vehicle.engine.temperature;
```

### `#( )` — indexed access

1-based index into an ordered collection.

```sysml
attribute firstWheelMass = wheels#(1).mass;
```

### `[ ]` — multiplicity or unit

As multiplicity: `[0..*]`, `[1]`, `[2..5]`.
As unit literal: `30 [km/h]`, `1500 [kg]`.

The parser distinguishes by position — multiplicity always follows a name/type; unit always follows a number.

### `@` — metadata application

Short form for attaching metadata to the next element.

```sysml
@SafetyCritical
@Owner { team = "Propulsion"; }
part def RocketEngine { … }
```

### `=` — initial value or binding

Assigns a default or initial value. **Not** equality comparison (use `==` for that).

```sysml
attribute gravity : AccelerationValue = 9.81 [m/s²];
bind a.x = b.y;
```

### `==` — equality comparison

Used inside expressions and constraints. Never `=` in a Boolean position.

```sysml
require constraint { status == OperatingMode::active }
```

---

## Part 9 — Quick-Confusion Guide

These pairs look similar but mean completely different things. Refer here when uncertain.

| Pair | Left means | Right means |
|---|---|---|
| `part def X` vs `part x` | Declares the *type* X | Creates one *instance* x |
| `=` vs `==` | Assigns a value | Tests equality |
| `:>` vs `:>>` | Specializes (inherits) | Redefines (overrides) |
| `.` vs `::` | Feature access (`car.mass`) | Namespace access (`ISQ::MassValue`) |
| `require` vs `assume` | The normative condition | The precondition / valid domain |
| `satisfy` vs `verify` | Part *claims* to meet req | Test *demonstrates* it meets req |
| `action def` vs `calc def` | Procedure (side effects OK) | Pure function (must `return`) |
| `part` vs `item` | Structural component (exists) | Something that flows or is exchanged |
| `connection` vs `interface` | Wires ports together | Specifies a bilateral protocol |
| `flow` vs `connect` | Dynamic transfer (run-time) | Static wiring (structure) |
| `doc /* */` vs `/* */` | Model element (in AST) | Lexical comment (ignored) |
| `ref part` vs `part` | Reference (not owned) | Composition (owned) |
| `variation` vs `variant` | The choice point | One of the alternatives |
| `abstract` vs (none) | Cannot be instantiated | Can be instantiated |
| `derived` vs `readonly` | Value always computed | Value settable once |
| `exhibit` vs `perform` | Declares a state machine | Declares an action |
| `subject` vs `actor` | What the case is *about* | Who interacts with it |
| `@Foo` vs `metadata Foo` | Short-form annotation | Long-form annotation (same result) |
| `in` direction vs `in` keyword | Port/param input direction | Part of `forall x in coll` |
| `[0..*]` vs `0 [km]` | Multiplicity brackets | Unit literal brackets |
