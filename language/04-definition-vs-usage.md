# 04 — Definition vs. Usage: The Core Paradigm

If a developer or AI agent only reads one file in this knowledge base, **it should be this one**. Every modeling mistake in v2 traces back to confusing a Definition with a Usage.

---

## The rule, in one sentence

> A **Definition** says *what something is*. A **Usage** says *that an instance of that thing exists in this context*.

In SysML v1, a `Block` could play either role and the difference was inferred (badly) from context. In SysML v2, the two are different syntactic categories with different keywords.

---

## Side-by-side example

```sysml
// DEFINITION: describes the type Vehicle. Reusable. Has no location in the world.
part def Vehicle {
    attribute mass : MassValue;
    part engine : Engine;
    part wheels : Wheel [4];
}

// USAGE: there is one Vehicle here, called myCar, in this context.
part myCar : Vehicle;
```

After parsing, the model contains:
- One `PartDefinition` named `Vehicle` (and `Engine`, `Wheel`).
- One `PartUsage` named `myCar`, typed by `Vehicle`.

`myCar.engine` refers to the *Engine usage* nested inside `myCar` (which itself was created by virtue of `Vehicle` containing `part engine : Engine`).

---

## Both forms exist for every concept

| Concept | Definition keyword | Usage keyword |
|---|---|---|
| Part | `part def` | `part` |
| Port | `port def` | `port` |
| Item | `item def` | `item` |
| Attribute | `attribute def` | `attribute` |
| Connection | `connection def` | `connection` |
| Interface | `interface def` | `interface` |
| Action | `action def` | `action` |
| State | `state def` | `state` |
| Calculation | `calc def` | `calc` |
| Constraint | `constraint def` | `constraint` |
| Requirement | `requirement def` | `requirement` |
| Concern | `concern def` | `concern` |
| Use case | `use case def` | `use case` |
| Analysis case | `analysis case def` | `analysis case` |
| Verification case | `verification case def` | `verification case` |
| View / Viewpoint | `view def` / `viewpoint def` | `view` / `viewpoint` |
| Metadata | `metadata def` | `metadata` |
| Allocation | `allocation def` | `allocation` |
| Enum | `enum def` | `enum` |

---

## Decision rules

When deciding which form to write, an AI agent should ask, in order:

1. **Is this a reusable kind/type?** ("All Cars have four wheels.") → **Definition**.
2. **Is this a specific occurrence in a context?** ("This system has a Car called myCar.") → **Usage**.
3. **Is the user describing a class of things, but only one will ever exist?** ("the Sun") → still a **Definition**, optionally marked `individual`.
4. **Is the user describing a value/feature that belongs to something?** (mass of a car, a port on a part) → **Usage**, nested inside the enclosing definition.

> ❌ Common mistake: writing `part def myCar { … }` when you mean *one specific car*. That defines a *type* called `myCar`. Almost certainly not what you want.

> ✅ Correct: `part def Car { … }`  then  `part myCar : Car`.

---

## Why the language enforces this

A **Definition** has no implied existence — it's a blueprint. A **Usage** has identity, multiplicity, lifetime, and is owned by an enclosing context. Properties that only apply to one or the other:

| Property | Definition | Usage |
|---|---|---|
| Has multiplicity | no | yes |
| Has direction (`in`/`out`) | no | yes (when relevant) |
| Can be `abstract` | yes | no |
| Can be `variation` | yes | no |
| Can specialize others (`:>`) | yes | yes (rarely) |
| Can redefine inherited features (`:>>`) | typically inside | typically the form used |
| Can be `ref` | n/a | yes |
| Owns the things declared inside it | "by reference" — types are shared | "by composition" — instances are owned |

---

## Specialization works on Definitions

```sysml
part def Vehicle;
part def Car           :> Vehicle;
part def ElectricCar   :> Car { … };
part def TeslaModelS   :> ElectricCar { … };
```

Specialization on a usage looks the same syntactically but is much rarer; it usually appears as **redefinition** inside a more specific Definition:

```sysml
part def SportsCar :> Car {
    :>> wheels [4];                         // redefining inherited 'wheels'
    :>> engine : HighPerformanceEngine;     // narrowing the type
}
```

---

## Anonymous usages and definitions

Both can be anonymous:

```sysml
part : Vehicle;             // anonymous usage of Vehicle
part def : Vehicle;         // anonymous definition specializing Vehicle (rare, but legal)
```

Anonymous elements are mainly useful for one-off internal structure. AI agents should prefer named elements for anything the user might want to reference later.

---

## Quick mental cheat sheet

| User says… | You write… |
|---|---|
| "A Vehicle has a mass." | `part def Vehicle { attribute mass; }` |
| "There is a vehicle in our system." | `part theVehicle : Vehicle;` |
| "All Cars are Vehicles." | `part def Car :> Vehicle;` |
| "Sedans, SUVs, and trucks are kinds of Car." | `variation part def Car { variant part def Sedan; variant part def SUV; variant part def Truck; }` |
| "The car weighs 1500 kg." | `attribute :>> mass = 1500 [kg];` (inside the usage) |
| "There can be 1 to 4 passengers." | `part passengers : Person [1..4];` |
| "There is exactly one driver, who is a Person." | `part driver : Person [1];` |
| "Optionally, a trailer." | `part trailer : Trailer [0..1];` |
| "The driver is the same as the owner." | `bind driver = owner;` |
