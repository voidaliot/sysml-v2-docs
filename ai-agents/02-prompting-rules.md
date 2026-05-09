# 02 — AI Agent Prompting Rules

Hard invariants the AI assistant **must** respect when producing SysML v2 code. These are "must-not-break" rules; violating them produces invalid models. Use this file as the system-prompt fragment when wiring the agent into a tool.

---

## Rule 1 — Always use lowercase keywords

Every SysML keyword is lowercase: `part`, `port`, `requirement`, `def`, `state`, `action`, `connect`, `to`, `from`, `subject`, `import`, `package`, `private`, `public`, `abstract`, `variation`, `variant`, etc. Never write `Part def X` or `PUBLIC import …`.

---

## Rule 2 — Always end statements with `;` or `{ … }`

Every element declaration ends with a semicolon (when it has no body) or with a brace block. There is no third option. A bare line without one of these is a syntax error.

```sysml
part battery : Battery;            // ✅
part motor : Motor                  // ❌ missing terminator
part def Vehicle { … }             // ✅
```

---

## Rule 3 — Use `::` for namespaces and `.` for features

```sysml
import ISQ::LengthValue;            // ✅ namespace
attribute m = car.engine.mass;      // ✅ feature path
attribute m = car::engine::mass;    // ❌ wrong separator
import ISQ.LengthValue;             // ❌ wrong separator
```

---

## Rule 4 — Pick `def` vs usage deliberately

If the agent writes `part def myCar`, it is declaring a new *type* called `myCar`, not creating an instance. This is almost always wrong when the user said "my car". The right form is `part myCar : Car;` (where `Car` is a `part def`).

When in doubt, prefer the **Definition** for new vocabulary, then immediately add a sample **Usage** to demonstrate it.

---

## Rule 5 — Quantities require units in `[ ]`

A bare number with no unit is not a quantity. If the attribute type is a `*Value` from `ISQ`, you must supply a quantity literal:

```sysml
attribute mass : MassValue = 1500 [kg];     // ✅
attribute mass : MassValue = 1500;          // ❌ missing unit
attribute count : Integer = 42;             // ✅ Integer, no unit needed
```

Only `Integer`, `Real`, `Natural`, `Boolean`, `String`, `Rational` and user-defined non-quantity types take bare values.

---

## Rule 6 — Use `==`, not `=`, in expressions

Inside `require constraint { … }`, `assume constraint { … }`, and any Boolean expression, equality is `==`. The single `=` is reserved for value initialization and bindings.

```sysml
require constraint { v.mass <= 2500 [kg] }           // ✅
require constraint { v.color == "red" }              // ✅
require constraint { v.color = "red" }               // ❌ assignment in a Boolean position
```

---

## Rule 7 — No `&&` or `||`

SysML uses the keyword forms:

```sysml
require constraint { x > 0 and x < 100 }    // ✅
require constraint { x > 0 && x < 100 }     // ❌
require constraint { not done or finished } // ✅
```

---

## Rule 8 — Multiplicity goes in square brackets, after the name and type

```sysml
part wheels : Wheel [4];                // ✅
part wheels [4] : Wheel;                // ❌
part wheels<4> : Wheel;                 // ❌
```

---

## Rule 9 — Conjugate ports with `~`

To declare a port whose direction is the inverse of an existing port type, prefix with `~`:

```sysml
port def PowerOutPort  { out current : Electricity; }
port def PowerInPort   :> ~PowerOutPort;          // ✅ idiomatic
port def PowerInPort2  : ~PowerOutPort;           // ✅ inline conjugate type
```

Don't manually duplicate the port body with directions flipped — use `~`.

---

## Rule 10 — Use `:>` for specialization, `:>>` for redefinition

```sysml
part def SportsCar :> Car;                       // ✅ specialization
part def Tesla    :> Car { :>> drivetrain = electric; }   // ✅ redefinition
part def SportsCar :>> Car;                      // ❌
```

---

## Rule 11 — Requirements must have a `subject`

A `requirement def` without a `subject` is malformed. The subject names what the requirement is about and is referenced inside the constraints.

```sysml
requirement def MaxMass {
    subject v : Vehicle;                        // ✅ required
    require constraint { v.mass <= 2500 [kg] }
}
```

---

## Rule 12 — `satisfy` and `verify` reference *requirements*, not parts

```sysml
satisfy MaxMassRequirement;                     // ✅ refers to a requirement def
satisfy myCar;                                   // ❌ a part is not a requirement
verify MaxMassRequirement;                      // ✅
verify checkMassAction;                         // ❌ an action is not a requirement
```

---

## Rule 13 — Keywords come in the canonical order

```
modifier* element-keyword 'def'? name multiplicity? specialization? body
```

```sysml
abstract part def Vehicle [1];                  // ✅
part abstract def Vehicle [1];                   // ❌
```

The acceptable modifier order: `private/public/protected`, `abstract`, `variation`, `variant`, `derived`, `readonly`, `ref`, `individual`, `snapshot`, `timeslice`, direction (`in`/`out`/`inout`), `def`-or-bare element keyword.

---

## Rule 14 — `doc` comments are model elements, not free comments

`doc /* … */` attaches documentation to the surrounding element. Place it as the **first child** of a definition body, or immediately above a sibling element it documents.

```sysml
requirement def Safe {
    doc /* The vehicle shall be safe. */          // ✅ at top of body
    subject v : Vehicle;
    /* … */
}
```

```sysml
// ❌ — free-floating doc with nothing to attach to:
package Foo {
    doc /* Some prose about Foo */
}
```

---

## Rule 15 — Don't invent library names

The standard library is fixed. Do not write `import StandardTypes::*;` or `import Math::*;` — those packages don't exist. The real ones are listed in `language/10-standard-libraries.md` (`ScalarValues`, `ISQ`, `SI`, `Geometry`, etc.).

Before referencing a name, confirm it is either declared in the user's model, declared above in the same file, or imported from a real library package.

---

## Rule 16 — Use SysML keywords, not KerML keywords, in `.sysml` files

In a `.sysml` file, use `part`, `port`, `connection`, etc. The lower-level KerML constructs (`feature`, `classifier`, `multiplicity` as a keyword, `step`, `behavior`) exist but are almost never the right choice in user-facing SysML code.

---

## Rule 17 — One top-level `package` per file

Don't mix multiple sibling top-level packages in a single file. If a file logically contains two unrelated packages, split them into two files.

---

## Rule 18 — Don't redefine library elements

Don't write `part def Real { … }` or `attribute def MassValue { … }`. The names belong to the standard library and shadowing them produces ambiguity errors.

---

## Rule 19 — Comments inside expressions are illegal

Constraint bodies, `if/then/else` expressions, and other expression contexts do not accept `//` or `/* */` mid-expression. Put any comment on its own line above the expression.

```sysml
// ✅
require constraint {
    // mass is below the budget
    v.mass <= 2500 [kg]
}

// ❌
require constraint { v.mass /* below budget */ <= 2500 [kg] }
```

---

## Rule 20 — Always run the validation checklist before output

This is **the** safety check. See `04-validation-checklist.md`. The agent must mentally walk through it for every model it produces, regardless of size.

---

## Summary — the agent's mental compile step

Before returning a `.sysml` block, the agent should silently ask:

1. Did I use lowercase keywords everywhere?
2. Does every statement end with `;` or `{ … }`?
3. Did I use `::` for namespaces and `.` for features?
4. Did I get the def/usage distinction right for every element?
5. Are quantity literals using `[ ]` units?
6. Are constraints using `==`, `and`, `or`, `not`?
7. Are multiplicities `[a..b]` after the name and type?
8. Did I conjugate inverse ports with `~`?
9. Did I use `:>` and `:>>` correctly?
10. Does every `requirement def` have a `subject`?
11. Do `satisfy`/`verify` point at *requirements*?
12. Is the modifier order correct?
13. Are `doc` comments attached to a real element?
14. Are all imports referencing real library packages?
15. Am I using SysML, not KerML, keywords?
16. Is there exactly one top-level package?
17. Am I avoiding library-name collisions?

If any answer is *no*, fix it before returning.
