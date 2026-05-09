# 03 — Keywords and Operators Reference

A definitive list for the syntax highlighter, the parser's keyword table, and the AI agent's reserved-word checker. **All keywords are lowercase.** Keywords that *appear* uppercase in models (e.g. `ISQ`, `Boolean`, `Vehicle`) are not keywords but library names or user-defined identifiers.

---

## 1. Element kind keywords

These introduce a model element. Many appear as a `def`-form (definition) or bare-form (usage).

```
package
namespace
library
standard

part            part def
item            item def
attribute       attribute def
port            port def
connection      connection def
interface       interface def
allocation      allocation def

action          action def
state           state def
calc            calc def
constraint      constraint def

requirement     requirement def
concern         concern def
use case        use case def
analysis case   analysis case def
verification case   verification case def

view            view def
viewpoint       viewpoint def
rendering       rendering def

metadata        metadata def
enum            enum def
occurrence      occurrence def
flow            flow def
succession      succession def
transition
event
```

---

## 2. Modifier keywords

Applied before an element-kind keyword:

```
abstract        — the element cannot be used directly; must be specialized.
variation       — declares a choice point (product-line variability).
variant         — one alternative under a variation.
derived         — value is computed; cannot be set externally.
readonly        — value can be set once, then frozen.
ref             — usage is a reference, not a composition.
individual      — denotes a single, identified individual occurrence.
snapshot        — a single point-in-time view of an occurrence.
timeslice       — a time-bounded slice of an occurrence's life.
const           — compile-time constant.
ordered         — collection has sequence semantics.
nonunique       — collection allows duplicates.
```

---

## 3. Direction keywords (ports, parameters)

```
in              — input direction.
out             — output direction.
inout           — bidirectional.
```

---

## 4. Visibility keywords

```
public          — exported to importers.
private         — local to the containing namespace.
protected       — visible to specializations.
```

---

## 5. Relationship keywords

Used in declarations and inside element bodies:

```
specializes     — alias of  :>
redefines       — alias of  :>>
subsets
chains
references
conjugates      — alias of  ~  (on ports)
defined by      — explicit typing form
typed by

connect         — used inside connection usages
to              — used in connect
from
of
by

bind / binding
flow
succession
allocate
satisfy
exhibit
perform
verify
include
expose
filter
```

---

## 6. Behavior / state / control keywords

```
entry           — entry action of a state.
exit            — exit action of a state.
do              — do action of a state.

first
then
when
accept
if
else
for
while
loop
return
break
continue

action
state
transition
```

---

## 7. Requirement / constraint keywords

```
requirement     requirement def
constraint      constraint def
require
assume
subject
stakeholder
actor
concern
satisfy
verify
framed by
assigned to
```

---

## 8. Import / namespace keywords

```
import
package
namespace
library
standard
as              — import aliasing
```

---

## 9. Expression / type keywords

```
true / false / null
and / or / not / xor
implies
istype          — runtime type check
hastype         — runtime type check
@               — metadata application / type test
@@              — meta type test
forall / exists
let / in
```

---

## 10. Operator and symbol summary

| Symbol | Role | Notes |
|---|---|---|
| `:` | Typing | `part car : Car` |
| `:>` | Specializes | `part def Sedan :> Car` |
| `:>>` | Redefines | `:>> mass = 1500 [kg]` |
| `::>` | (in connection ends) | `end ::> someFeature` |
| `::` | Namespace separator | `ISQ::LengthValue` |
| `.` | Feature access | `vehicle.engine.mass` |
| `~` | Conjugation | `port out : ~InPort` |
| `[ … ]` | Multiplicity OR unit literal | `[0..*]` vs. `30 [km/h]` |
| `#( … )` | Indexed access | `wheels#(1)` |
| `( … )` | Grouping / parameters | |
| `{ … }` | Body block | |
| `;` | Statement terminator | |
| `,` | List separator | |
| `=` | Initial value / binding | |
| `=>` | (in metadata, where, filter clauses) | |
| `..` | Range bound | `[0..*]`, `1..10` |
| `*` | Unbounded multiplicity / multiply | |
| `+ - * /` | Arithmetic | |
| `% ` | Modulo | |
| `< <= > >= == !=` | Comparison | |
| `&&` `\|\|` | NOT used — use `and` / `or` keywords instead | |
| `@` | Metadata attachment | `@Critical` |
| `?` | Reserved (no current use); avoid in identifiers | |

> ⚠️ **`==` not `=`** for equality in expressions. `=` is for initial values and bindings.

> ⚠️ **No `&&` / `||`.** Use the `and` / `or` keywords.

---

## 11. Special textual forms

| Form | Meaning |
|---|---|
| `'…'` | Escaped name literal (allows whitespace/special chars). |
| `"…"` | String literal in expressions. |
| `// …` | Line comment. |
| `/* … */` | Block comment. |
| `doc /* … */` | Documentation comment (modeled element, not a comment). |
| `comment about X /* … */` | Standalone comment attached to a specific element. |

---

## 12. Reserved but rarely written explicitly

Engineers most often see these as auto-completed or as part of imported library names:

```
feature                 — generic feature declaration (KerML-level).
classifier              — KerML-level type kind.
multiplicity            — KerML-level explicit multiplicity element.
member                  — explicit membership relationship.
end                     — end feature of a connector.
chains                  — feature chaining.
```

Unless writing KerML directly, an AI agent should avoid emitting raw KerML keywords (`feature`, `classifier`, `multiplicity`, etc.) in `.sysml` files. Use the SysML-specific keywords instead.
