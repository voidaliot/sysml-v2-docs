# 02 — Textual Notation Syntax Reference

This is the complete reference for the SysML v2 textual notation as it appears in `.sysml` files. Use this as the authoritative grammar checklist for the parser, the syntax highlighter, and any AI agent generating code.

---

## 1. Lexical structure

### 1.1 Comments

```sysml
// single line comment
/* block comment, may span multiple lines */
doc /* documentation comment, attached to the preceding/containing element */
```

`doc` comments are first-class: they are part of the model, not lexical noise, and are attached to the element they document. The parser must produce an AST node for them.

### 1.2 Names

A name is either:
- An **identifier**: `[A-Za-z_] [A-Za-z0-9_]*`
- An **escaped name**: a single-quoted string `'…'` — required if the name contains whitespace, special characters, or collides with a keyword.

```sysml
part flashlight;            // identifier
part 'LED Flashlight';      // escaped name with whitespace
part 'part';                // escaped name colliding with keyword
```

### 1.3 Qualified names

Use `::` (double colon) as the namespace separator. Single dots `.` are reserved for **feature paths** (member access), not namespaces.

```sysml
import ISQ::LengthValue;        // namespace path: package ISQ, member LengthValue
attribute m = vehicle.mass;     // feature path: member 'mass' of usage 'vehicle'
```

### 1.4 Literals

| Kind | Examples |
|---|---|
| Integer | `0`, `42`, `-7` |
| Real / decimal | `3.14`, `1.0e-3` |
| Boolean | `true`, `false` |
| String | `"hello"` |
| Null | `null` |

---

## 2. Element declaration shape

Every declarable element follows the same shape:

```
<modifiers>* <element-keyword> <name>? <multiplicity>? <specialization>? ( ; | { … } )
```

In strict order:

1. **Modifiers**: `abstract`, `variation`, `derived`, `readonly`, `ref`, `individual`, `snapshot`, `timeslice`, plus direction (`in`, `out`, `inout`) for ports/parameters.
2. **Element keyword(s)**: e.g. `part def`, `requirement`, `port def`.
3. **Name**: optional. Anonymous elements are legal.
4. **Multiplicity**: `[lower..upper]` (e.g. `[0..*]`, `[1]`, `[2..5]`).
5. **Specialization**: see §4.
6. **Body**: either `;` (empty) or `{ … }` (with members).

```sysml
abstract part def Vehicle;                              // (1)+(2)+(3)
part wheels : Wheel [4];                                // (2)+(3)+(4)+(5)
part def SportsCar :> Vehicle { /* … */ }               // (2)+(3)+(5)+(6)
ref part driver : Person;                               // (1)+(2)+(3)+(5)
in port command : CommandPort;                          // (1)+(2)+(3)+(5)
```

> ⚠️ **Keyword order matters.** `abstract part def X` parses; `part abstract def X` does not. The grammar enforces the order above.

---

## 3. The Definition / Usage families

For each base concept, the language provides a **definition** keyword (the type) and a **usage** keyword (an occurrence in a context). The full table:

| Concept | Definition | Usage |
|---|---|---|
| Package | `package` | `package` (nested) |
| Part | `part def` | `part` |
| Item | `item def` | `item` |
| Attribute | `attribute def` | `attribute` |
| Port | `port def` | `port` |
| Connection | `connection def` | `connection` |
| Interface | `interface def` | `interface` |
| Allocation | `allocation def` | `allocation` |
| Action | `action def` | `action` |
| State | `state def` | `state` |
| Calculation | `calc def` | `calc` |
| Constraint | `constraint def` | `constraint` |
| Requirement | `requirement def` | `requirement` |
| Concern | `concern def` | `concern` |
| Use case | `use case def` | `use case` |
| Analysis case | `analysis case def` | `analysis case` |
| Verification case | `verification case def` | `verification case` |
| View | `view def` | `view` |
| Viewpoint | `viewpoint def` | `viewpoint` |
| Rendering | `rendering def` | `rendering` |
| Metadata | `metadata def` | `metadata` (also `@`) |
| Enumeration | `enum def` | `enum` |
| Occurrence | `occurrence def` | `occurrence` |

---

## 4. Specialization, redefinition, subsetting

| Symbol | Long form | Means |
|---|---|---|
| `:>` | `specializes` | "is a kind of" — covariant subtype. |
| `:>>` | `redefines` | overrides an inherited feature with the same multiplicity location. |
| `:>` (on usages, with type only) | (typing) | `part myCar : Car` types a usage. |
| `:` | (typing) | the basic typing form on usages. |
| `subsets` | `subsets` | the values are a subset of the parent feature's. |
| `~` | (conjugation) | `port p : ~PortType` flips port direction. |
| `references` / `chains` | (used inside connectors) | binds connector ends to features. |

```sysml
part def SportsCar :> Vehicle;                       // specialization
part def Tesla     :> SportsCar { :>> drivetrain = electric; }   // redefinition
attribute heightInMeters subsets length;             // subsetting
port out : ~InPort;                                  // conjugation
```

---

## 5. Multiplicity

Multiplicity goes immediately after the name and type. Forms:

```sysml
[1]          // exactly one (often omitted; default depends on context)
[0..1]       // optional
[0..*]       // any number, zero allowed
[1..*]       // at least one
[3]          // exactly three
[2..5]       // bounded range
```

Two extra modifiers can precede the bracket:

```sysml
ordered part backlog : Task [0..*];   // sequence semantics
nonunique part scans : Image [0..*];  // duplicates allowed
```

---

## 6. Composition vs. reference

```sysml
part child : Wheel;        // COMPOSITION — owned by the enclosing part
ref part driver : Person;  // REFERENCE   — points to a part owned elsewhere
```

This distinction is enforced by the `ref` modifier. AI agents should default to composition; reference is correct only when the same element belongs to a different containment hierarchy.

---

## 7. Member access expressions

Inside expressions, use the dot operator for feature access:

```sysml
attribute totalMass = vehicle.body.mass + vehicle.engine.mass;
```

Collections:

```sysml
attribute first = wheels#(1);          // index (1-based) — bracket notation #
attribute count = wheels->size();      // method call on a sequence
attribute big   = wheels.select { in w | w.diameter > 50 [cm] };   // filter
```

> ⚠️ **`.` is feature access, `::` is namespace access.** Never use `.` to descend into packages.

---

## 8. Connectors, bindings, successions, flows

```sysml
// Connector usage forms
connect part1.port1 to part2.port2;
connect part1 with part2;                    // peer
connection conn : MyConnDef connect (a, b);
connection { end ::> a; end ::> b; }         // explicit ends

// Binding (semantically equivalent feature values)
bind a.x = b.y;
binding myBind of a.x = b.y;

// Succession (sequencing in behavior)
succession first then second;
succession state1 then state2;

// Item flow
flow lightOut.brightness to display.input;
succession flow command from controller.cmd to actuator.cmdIn;
```

---

## 9. Behavioral constructs

```sysml
action def Brake {
    in  pedalForce : Force;
    out wheelTorque : Torque;
}

state def DoorState {
    entry action openLatch;
    do    action displayStatus;
    exit  action closeLatch;
}

action drive {
    first start;
    then accelerate then cruise then brake;
    then done;
}

transition first idle accept signal: StartCmd then running;
```

Full coverage: see `06-behavioral-modeling.md`.

---

## 10. Requirements

```sysml
requirement def MaxMass {
    doc /* The vehicle shall not exceed the regulatory mass limit. */
    subject veh : Vehicle;
    attribute limit : MassValue = 2500 [kg];
    require constraint { veh.mass <= limit }
    assume  constraint { veh.mass > 0 [kg] }
}

requirement reqMass : MaxMass {
    subject = myCar;
}

part def Vehicle {
    /* … */
    satisfy MaxMass by myCar;
}
```

Full coverage: see `07-requirements-and-constraints.md`.

---

## 11. Imports and packages

```sysml
package MyModel {
    public  import ISQ::*;                  // public — re-exports
    private import OtherPackage::SomeDef;   // private — local use only
    import  ISQ::LengthValue;               // shorthand: defaults to private
    import  ISQ::*::**;                     // recursive wildcard

    // … model elements …
}
```

A file may contain **at most one top-level package**, but packages can be nested freely. Import aliasing:

```sysml
import ISQ::LengthValue as Length;
```

---

## 12. Metadata annotation

```sysml
metadata def Critical;
metadata def Owner { attribute name : String; }

@Critical                          // marker
@Owner { name = "Powertrain Team"; }
part def EngineControlUnit;
```

Metadata is also expressed via `metadata def` / `metadata` (definition/usage style). The `@` prefix is a shorthand applied to the *next* element.

---

## 13. Variation and variants

Product-line modeling is built into the language:

```sysml
variation part def Vehicle {
    variant part def CombustionVehicle;
    variant part def ElectricVehicle;
    variant part def HybridVehicle;
}
```

A `variation` element declares a choice point; the contained `variant` elements are the alternatives. A specific configuration is selected via constraints or analysis cases.

---

## 14. Operators and expressions

Order from highest to lowest precedence (abridged):

1. Member access `.`, index `#( )`, function call `( )`
2. Unary `+`, `-`, `not`, `~`
3. Multiplicative `*`, `/`, `%`
4. Additive `+`, `-`
5. Range `..`
6. Comparison `<`, `<=`, `>`, `>=`, `==`, `!=`
7. Type checks `istype`, `hastype`, `@`, `@@`
8. Logical `and`, `or`, `xor`, `implies`
9. Conditional `if cond then a else b`
10. Quantifiers `forall`, `exists`

Quantity literals use square brackets for units:

```sysml
attribute speed : SpeedValue = 30 [km/h];
attribute mass  : MassValue  = 1500 [kg];
```

Conditional expression:

```sysml
attribute label = if temperature > 30 [°C] then "hot" else "cool";
```

---

## 15. Reserved keywords (informational, full list in `03-keywords-and-operators.md`)

The grammar is large — see the dedicated keywords file. Always lowercase. Highlights:
`abstract action allocate analysis as assert assign assume attribute binding bind by calc case chains comment concern conjugates connect connection constraint def defined derived doc else end entry enum event exhibit exit expose feature filter first flow for from hastype if import in include individual inout interface item language meta metadata namespace nonunique not occurrence of or ordered out package part performance perform port portion private protected public readonly redefines ref references render rendering require requirement return satisfy snapshot specializes state subject subsets succession then timeslice to transition typed use variant variation verification verify view viewpoint when xor`.

---

## 16. End-of-file rule

A `.sysml` file is a sequence of one or more **package members** (or, optionally, a single top-level package containing them). Empty files are not legal SysML, though the parser should tolerate them with a single diagnostic.
