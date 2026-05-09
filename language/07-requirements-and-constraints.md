# 07 — Requirements and Constraints

Requirements in SysML v2 are **first-class, formal, and machine-checkable**. They are no longer stereotyped UML classes with free-form text — they are typed elements whose conditions can be evaluated by a solver.

---

## 1. Constraints — the building block

A **constraint** is a Boolean expression that may have parameters. Constraints are the foundation of formal requirements.

```sysml
constraint def WithinMassBudget {
    in actual    : MassValue;
    in maxMass   : MassValue;
    actual <= maxMass
}
```

Inline (anonymous) constraints are also allowed:

```sysml
constraint { vehicle.mass <= 2500 [kg] }
```

The body of a constraint is a single Boolean expression — no statements, no side effects.

---

## 2. Requirements

A **Requirement** is a constraint plus a *subject* (what the requirement is about), optional *assumptions*, optional *stakeholders*, and rich documentation.

### 2.1 Requirement definition

```sysml
requirement def MaxMassLimit {
    doc /* The vehicle's total mass shall not exceed the regulatory limit. */

    subject veh : Vehicle;

    attribute limit : MassValue = 2500 [kg];

    assume  constraint { veh.mass > 0 [kg] }    // pre-condition
    require constraint { veh.mass <= limit }    // the actual requirement
}
```

Sections of a requirement definition:

| Section | Meaning | Cardinality |
|---|---|---|
| `doc` | Free-form documentation | 0..1 (recommended) |
| `subject` | What the requirement constrains | exactly 1 |
| `actor` / `stakeholder` | Who cares | 0..* |
| `attribute` | Local parameters | 0..* |
| `assume constraint` | Pre-condition; if false, requirement is not violated | 0..* |
| `require constraint` | The condition that must hold | 1..* |
| Sub-`requirement` | Nested requirements (auto-grouped) | 0..* |

### 2.2 Requirement usage

```sysml
requirement myMassReq : MaxMassLimit {
    subject = myCar;
    attribute :>> limit = 2000 [kg];
}
```

A requirement *usage* binds the abstract requirement to a concrete subject.

### 2.3 Sub-requirements (composite requirements)

```sysml
requirement def VehicleSafety {
    subject veh : Vehicle;

    requirement crashWorthiness {
        require constraint { veh.frontalImpactRating >= 4 }
    }

    requirement brakingPerformance {
        require constraint { veh.brakingDistance100kmh <= 38 [m] }
    }
}
```

Sub-requirements share the parent's subject by default and contribute to the parent's overall satisfaction.

---

## 3. Satisfy — linking parts to requirements

A part *satisfies* a requirement when its features are bound to the requirement's subject:

```sysml
part def Vehicle {
    /* … */
    satisfy MaxMassLimit by myCar;
}
```

Or, more idiomatically, on the usage:

```sysml
part myCar : Vehicle {
    satisfy MaxMassLimit;     // 'by' defaults to the enclosing usage
}
```

A model is **valid** in the requirements sense when every `satisfy` link's `require` constraints evaluate to `true` (and no `assume` is `false`).

---

## 4. Verify — linking verification cases to requirements

Where `satisfy` says "this part claims to meet this requirement", `verify` says "this verification activity demonstrates that it does":

```sysml
verification case def CrashTest {
    subject veh : Vehicle;

    objective verifyCrashRequirement {
        verify VehicleSafety::crashWorthiness;
    }
}
```

See `08-analysis-and-verification.md` for the full treatment.

---

## 5. Concerns

A **concern** is a stakeholder interest that may be addressed by zero or more requirements:

```sysml
concern def SafetyConcern {
    doc /* The vehicle must be safe for occupants and pedestrians. */
    stakeholder regulator;
    stakeholder driver;
}

requirement def CrashSafety :> SafetyConcern {
    /* … */
}
```

Concerns provide traceability from stakeholder interests to formal requirements.

---

## 6. Working with constraints quantitatively

Constraints can use any expression supported by the SysML expression language. Some idiomatic patterns:

```sysml
// Range check
require constraint { veh.speed >= 0 [km/h] and veh.speed <= 250 [km/h] }

// Quantified
require constraint { forall p in passengers { p.seatbelt.fastened } }

// Existential
require constraint { exists w in wheels { w.diameter > 50 [cm] } }

// Implication
require constraint { (veh.speed > 60 [km/h]) implies (veh.headlights == on) }

// Function-based
require constraint { ComputeMassMargin(veh.mass, limit) > 0.10 }
```

---

## 7. Conventions and best practices

| Practice | Reason |
|---|---|
| Always provide a `doc` comment on `requirement def`. | Human readers need it; it appears in tooltips and reports. |
| Use a *named* `subject`, even if obvious. | Lets sub-requirements reference the same subject by name. |
| Prefer a single top-level `require constraint`; decompose with sub-requirements. | Keeps each constraint atomic and individually checkable. |
| Capture pre-conditions in `assume`, not `require`. | A failing `assume` invalidates the requirement, not the system. |
| Use library quantity types (`MassValue`, `LengthValue`, …) over raw `Real`. | Enables unit checking. |
| Don't smuggle behavior into constraint bodies. | Constraints must be pure Boolean expressions. |

---

## 8. Bringing it together

```sysml
package VehicleRequirements {
    private import ISQ::*;
    private import SI::*;

    part def Vehicle {
        attribute mass            : MassValue;
        attribute brakingDistance : LengthValue;
        attribute crashRating     : Integer;
    }

    requirement def Safe {
        doc /* The vehicle shall be safe for its occupants. */
        subject v : Vehicle;

        requirement mass {
            attribute limit : MassValue = 2500 [kg];
            require constraint { v.mass <= limit }
        }

        requirement braking {
            attribute maxDist : LengthValue = 38 [m];
            require constraint { v.brakingDistance <= maxDist }
        }

        requirement crash {
            require constraint { v.crashRating >= 4 }
        }
    }

    part myCar : Vehicle {
        attribute :>> mass            = 1500 [kg];
        attribute :>> brakingDistance = 35  [m];
        attribute :>> crashRating     = 5;

        satisfy Safe;
    }
}
```

This model is fully evaluable: a tool can determine whether `myCar` satisfies `Safe` by checking the three `require` constraints.
