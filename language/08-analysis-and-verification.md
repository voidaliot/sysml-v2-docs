# 08 — Analysis, Verification, and Use Cases

SysML v2 promotes **analysis case**, **verification case**, and **use case** to first-class language constructs. Each is a kind of action with specialized semantics — they describe how the system is *evaluated*, *tested*, or *used*.

---

## 1. Analysis cases

An **analysis case** runs a calculation or simulation against the model to compute properties or trade-offs. It is an `action def` specialized for analytical purposes.

```sysml
analysis case def MassRollup {
    doc /* Computes the total mass of a vehicle from its parts. */
    subject veh : Vehicle;
    objective totalMass : MassValue;

    return totalMass = sum(veh.allParts.mass);
}
```

Key elements:

| Section | Role |
|---|---|
| `subject` | What is being analyzed |
| `objective` | What the analysis aims to compute |
| `return` | The computed result |

Multiple objectives:

```sysml
analysis case def PerformanceAnalysis {
    subject veh : Vehicle;
    objective topSpeed       : SpeedValue;
    objective acceleration0to60 : TimeValue;
    objective fuelEconomy    : FuelEfficiencyValue;
}
```

Analysis cases compose: one can call another, building chained analyses.

---

## 2. Verification cases

A **verification case** verifies that a part satisfies a requirement. It is the formal counterpart of a test case.

```sysml
verification case def CrashTest {
    doc /* Frontal-impact verification for a passenger vehicle. */
    subject veh : Vehicle;

    objective verifyCrash {
        verify VehicleSafety::crashWorthiness;
    }

    action setup;
    action runImpact;
    action measureRating;

    first setup
    then  runImpact
    then  measureRating;
}
```

`verify` inside a verification case is the link to a `requirement` (typically a single `require constraint`). The case **passes** when the verified requirement evaluates to `true` after the case runs.

---

## 3. Use cases

A **use case** describes a goal a stakeholder accomplishes by interacting with the system. Use cases are `action`-shaped.

```sysml
use case def DriveToDestination {
    doc /* Driver operates the vehicle from origin to destination. */

    subject veh : Vehicle;
    actor   driver : Person;

    objective arriveAtDestination;

    action enterVehicle;
    action startEngine;
    action drive;
    action stopEngine;
    action exitVehicle;

    first enterVehicle
    then  startEngine
    then  drive
    then  stopEngine
    then  exitVehicle;
}
```

Sub-use-cases via `include` (the v2 equivalent of UML's «include»):

```sysml
use case def Refuel {
    subject veh : Vehicle;
    actor   driver : Person;
}

use case def DriveLongTrip :> DriveToDestination {
    include Refuel;
}
```

---

## 4. Putting it together — verifying a requirement

```sysml
package VerificationExample {
    import ISQ::*;
    import SI::*;
    import VehicleRequirements::*;

    verification case def MassVerification {
        doc /* Weighs the vehicle and verifies the mass requirement. */

        subject v : Vehicle;
        objective verifyMass {
            verify Safe::mass;
        }

        action putOnScale;
        action readScale;
        action recordResult;

        first putOnScale then readScale then recordResult;
    }

    verification case checkMyCar : MassVerification {
        subject = myCar;
    }
}
```

A verification engine can:

1. Walk all `verification case` usages in the model.
2. For each, evaluate the linked `verify` target's `require` constraint against the bound subject.
3. Report pass/fail per case.

This is exactly the kind of pipeline a CI/CD system can run on every model commit.

---

## 5. Stakeholders and concerns in cases

Verification, analysis, and use cases all support `actor` (an external participant) and `stakeholder` (someone with an interest):

```sysml
analysis case def CostEstimate {
    subject  proj : Project;
    stakeholder finance;
    stakeholder programManager;
    objective totalCost : MoneyValue;
}
```

---

## 6. When to use what

| User intent | Use |
|---|---|
| "What is the total mass of the vehicle?" | `analysis case` |
| "Does this car meet the crash requirement?" | `verification case` |
| "How does a driver use the navigation feature?" | `use case` |
| "What is the trade-off between range and weight?" | `analysis case` (with multiple `objective`s) |
| "Run the test suite against the latest design." | a set of `verification case` usages |
| "Capture the stakeholders that care about safety." | `concern def` + `stakeholder` |
| "Represent a function the system performs internally." | `action def` (not `use case`; use cases are user-facing) |
