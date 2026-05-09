# 03 — Common Patterns

A library of reusable SysML v2 templates. The AI agent should select and adapt these rather than improvising from scratch. Each pattern is annotated with when to use it.

---

## Pattern 1 — A new system from scratch

When the user says "model an X" with no existing model.

```sysml
package XModel {

    private import ISQ::*;
    private import SI::*;

    // ---- Definitions ----

    part def X {
        attribute name : String;
        // structural decomposition goes here
    }

    // ---- One concrete usage ----

    part myX : X;
}
```

Use this as the skeleton. Add structure under the comments.

---

## Pattern 2 — Specialization hierarchy

When the user describes a taxonomy ("a Sedan is a Car which is a Vehicle").

```sysml
abstract part def Vehicle {
    attribute mass : MassValue;
    attribute manufacturer : String;
}

part def Car :> Vehicle {
    attribute numDoors : Integer;
}

part def Sedan :> Car {
    attribute trunkVolume : LengthValue;       // (volume — use the right type from ISQ)
}

part def SUV :> Car {
    attribute groundClearance : LengthValue;
}
```

`abstract` on the top type prevents direct instantiation.

---

## Pattern 3 — Variation (product line)

When the user describes alternatives ("the engine can be combustion, electric, or hybrid").

```sysml
variation part def Engine {
    attribute peakPower : PowerValue;

    variant part def CombustionEngine {
        attribute fuelType : String;
    }
    variant part def ElectricEngine {
        attribute batteryVoltage : VoltageValue;
    }
    variant part def HybridEngine {
        part combustion : CombustionEngine;
        part electric   : ElectricEngine;
    }
}
```

A specific configuration picks one variant via constraints or analysis cases.

---

## Pattern 4 — Reusable port type with conjugates

When the user describes an interaction that goes both ways ("X sends commands, Y receives them").

```sysml
item def Command;

port def CommandOutPort {
    out cmd : Command;
}
port def CommandInPort :> ~CommandOutPort;     // automatic flip

part def Sender   { port out : CommandOutPort; }
part def Receiver { port in  : CommandInPort;  }

part def System {
    part sender   : Sender;
    part receiver : Receiver;
    connect sender.out to receiver.in;
}
```

---

## Pattern 5 — Power distribution

When components share a common supply.

```sysml
item def Electricity;

port def PowerOutPort { out current : Electricity; }
port def PowerInPort  :> ~PowerOutPort;

part def PowerSource { port supply : PowerOutPort;  }
part def PowerSink   { port supply : PowerInPort;   }

part def System {
    part battery : PowerSource;
    part loadA   : PowerSink;
    part loadB   : PowerSink;

    connect battery.supply to loadA.supply;
    connect battery.supply to loadB.supply;
}
```

---

## Pattern 6 — State machine on a part

When the user describes modes ("the device is on, off, or in error").

```sysml
part def Device {

    exhibit state mode {
        state off;
        state on;
        state error;

        transition powerOn  first off accept signal: PowerEvent then on;
        transition powerOff first on  accept signal: PowerEvent then off;
        transition fault    first on                            then error;
        transition reset    first error accept signal: ResetEvent then off;
    }
}
```

Naming convention: lowercase camelCase for state names; descriptive verb-based names for transitions.

---

## Pattern 7 — Sequential procedure

When the user describes a workflow ("first do A, then B, then C").

```sysml
action def StartupSequence {
    action selfTest;
    action calibrate;
    action loadConfig;
    action ready;

    first selfTest
    then  calibrate
    then  loadConfig
    then  ready;
}
```

---

## Pattern 8 — Pure computation

When the user describes a formula ("speed equals distance over time").

```sysml
calc def AverageSpeed {
    in  distance : LengthValue;
    in  duration : TimeValue;
    return : SpeedValue = distance / duration;
}
```

Use `calc def` (not `action def`) for any pure function.

---

## Pattern 9 — Formal requirement

The fundamental requirement template.

```sysml
requirement def TopLevelRequirement {
    doc /* Free-form sentence the user wrote, paraphrased. */

    subject thing : SystemOfInterest;

    attribute parameter : SomeValue = defaultValue;

    assume  constraint { /* preconditions */ }
    require constraint { /* the actual requirement */ }
}
```

If the requirement is composite, expand into sub-requirements:

```sysml
requirement def SafetyEnvelope {
    doc /* The system shall remain within its safety envelope. */
    subject s : System;

    requirement underTempLimit {
        require constraint { s.temperature <= 80 [°C] }
    }

    requirement underPressureLimit {
        require constraint { s.pressure <= 5 [bar] }
    }

    requirement responseTime {
        require constraint { s.alarmDelay <= 100 [ms] }
    }
}
```

---

## Pattern 10 — Satisfy + Verify pair

To complete the loop from requirement to evidence.

```sysml
// 1. The requirement
requirement def MaxLatency {
    subject s : System;
    require constraint { s.latency <= 50 [ms] }
}

// 2. The part claims to satisfy it
part mySystem : System {
    attribute :>> latency = 30 [ms];
    satisfy MaxLatency;
}

// 3. A verification case proves it
verification case def LatencyTest {
    subject s : System;
    objective verifyLatency {
        verify MaxLatency;
    }

    action sendRequest;
    action measureResponse;
    action recordLatency;

    first sendRequest then measureResponse then recordLatency;
}

// 4. A specific verification run
verification case latencyOnMySystem : LatencyTest {
    subject = mySystem;
}
```

---

## Pattern 11 — Use case

When the user describes how an actor uses the system.

```sysml
use case def WithdrawCash {
    doc /* The customer withdraws cash from the ATM. */

    subject atm : ATM;
    actor   customer : Person;

    objective cashDispensed;

    action insertCard;
    action enterPIN;
    action selectAmount;
    action dispenseCash;
    action returnCard;

    first insertCard
    then  enterPIN
    then  selectAmount
    then  dispenseCash
    then  returnCard;
}
```

---

## Pattern 12 — Analysis case (mass rollup)

When the user wants to compute something across the model.

```sysml
analysis case def MassRollup {
    doc /* Computes the total mass of a vehicle. */

    subject veh : Vehicle;
    objective totalMass : MassValue;

    return totalMass = veh.engine.mass
                     + veh.body.mass
                     + veh.transmission.mass
                     + sum(veh.wheels.mass);
}
```

For tree-walking analyses, use SysML's collection operations on multiplicity-`*` features.

---

## Pattern 13 — Allocation (function to component)

When the user describes which physical thing performs which function.

```sysml
package Functions {
    action def CaptureImage;
    action def DetectObstacle;
    action def PlanPath;
}

package Physical {
    part def Camera;
    part def ProcessingUnit;
    part def NavigationComputer;
}

package Allocations {
    import Functions::*;
    import Physical::*;

    allocation def FunctionToComponent {
        end function  : ActionUsage;
        end component : PartUsage;
    }

    allocate CaptureImage  to camera;
    allocate DetectObstacle to processor;
    allocate PlanPath       to navigator;
}
```

---

## Pattern 14 — View and viewpoint

When the user wants a specific report or projection.

```sysml
viewpoint def MassBudgetViewpoint {
    stakeholder programManager;
    concern     massBudget;
    require     renderViewAsTable;
}

view def MassBudgetView {
    frame MassBudgetViewpoint;
    expose veh.engine.mass,
           veh.body.mass,
           veh.transmission.mass;
    render asTable;
}
```

---

## Pattern 15 — Metadata tagging

When the user wants to mark elements ("this is safety-critical", "owner: team X").

```sysml
metadata def Critical;
metadata def Owner { attribute team : String; }

@Critical
@Owner { team = "Powertrain"; }
part def EngineControlUnit { /* … */ }
```

---

## Pattern 16 — Concern + stakeholder + requirement

When the user describes a stakeholder interest.

```sysml
concern def CostConcern {
    doc /* Stakeholders want to minimize lifecycle cost. */
    stakeholder programManager;
    stakeholder finance;
}

requirement def UnitCost :> CostConcern {
    subject prod : Product;
    require constraint { prod.bomCost <= 10000 [USD] }
}
```

---

## Pattern 17 — File header (recommended)

Start every non-trivial `.sysml` file with this skeleton:

```sysml
/*
 * Module:    StructuralModel
 * Purpose:   Top-level structural decomposition of the system.
 * Authors:   <names>
 * Updated:   <date>
 */

package StructuralModel {

    private import ISQ::*;
    private import SI::*;

    doc /* Top-level structural model. See Requirements.sysml for constraints. */

    /* … */
}
```

---

## How to use this catalogue

When responding to a request:

1. Identify which patterns apply.
2. Compose them in the order: imports → definitions → usages → behavior → requirements → verification → views.
3. Adapt names to the user's domain.
4. Add a brief `doc /* … */` to each top-level definition.
5. Run the validation checklist (`04-validation-checklist.md`).
6. Return only the `.sysml` content — minimal prose, the model speaks for itself.
