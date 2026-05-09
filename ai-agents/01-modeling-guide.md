# 01 — AI Agent Modeling Guide

This document tells an AI assistant **how to translate user intent into well-formed SysML v2 models**. Read it together with `02-prompting-rules.md` (hard invariants) and `04-validation-checklist.md` (pre-output check).

---

## 1. The agent's job

A user describes a system in natural language. The agent's job is to produce a **`.sysml` file (or set of files)** that:

1. Parses without syntax errors against the SysML v2 grammar.
2. Resolves all names against the standard library and the user's existing model.
3. Uses the **Definition / Usage** distinction correctly.
4. Picks the right element kind for the user's concept (`part` vs `item` vs `action` etc.).
5. Is *idiomatic* — follows the conventions in `language/09-packages-imports-and-views.md`.
6. Includes enough `doc` comments and structure that a human can read the file and recognize the user's domain.

The agent is **not** writing prose explaining the model; it is writing the model itself, with concise comments inside.

---

## 2. The thinking sequence the agent should follow

For every modeling request, run through these questions in order. Do not skip steps.

### Step 1 — Identify the system of interest

What is the bounded "thing" the user is talking about? It will become the top-level `part def` or the top-level `package`.

> User: "I want to model a coffee machine that has a water tank, a heater, a pump, and a control panel."
> System of interest: a `CoffeeMachine` part definition.

### Step 2 — Distinguish *kinds* from *occurrences*

For each noun the user mentions, ask: is this a **type of thing** (`part def`) or **a specific instance in this context** (`part`)?

A useful test: if the user could plausibly say "all X have …", X is a definition. If they say "the X in this system is …", X is a usage.

> "A coffee machine has a water tank" → `WaterTank` is a kind → `part def WaterTank`.
> "The water tank holds 2 litres" → that's the usage `tank` inside `CoffeeMachine` → `part tank : WaterTank` with attribute `:>> capacity = 2 [l]`.

### Step 3 — Pick the element kind for each concept

| User's noun describes… | Element |
|---|---|
| A physical/logical component | `part` |
| Something that flows or is exchanged | `item` |
| A measurable property | `attribute` |
| An interaction point on a component | `port` |
| A connection between components | `connection` (or `interface` if specifying contract) |
| A function the system performs | `action` |
| A pure computation returning a value | `calc` |
| A mode of operation | `state` |
| A condition that must hold | `constraint` (inside a `requirement`) |
| A "shall" statement / requirement | `requirement def` |
| An evaluation/simulation | `analysis case` |
| A test that proves a requirement | `verification case` |
| A user-system interaction goal | `use case` |
| A stakeholder concern | `concern` |
| A mapping/realization | `allocation` |
| A presentation of part of the model | `view` (with `viewpoint`) |
| A tag or annotation | `metadata` |
| A product variation/choice | `variation` + `variant` |

### Step 4 — Identify properties and quantities

For each attribute, decide:

- Is it a numeric quantity with units? → use a library quantity type (`MassValue`, `LengthValue`, `TimeValue`, …) and a quantity literal `value [unit]`.
- Is it a Boolean / String / Integer / Real? → use the corresponding scalar type.
- Is it an enum? → declare an `enum def` and reference it.

### Step 5 — Identify relationships and topology

- Composition (`part child : ChildKind`) — when X owns Y.
- Reference (`ref part child : ChildKind`) — when X uses Y but doesn't own it.
- Connection (`connect a.x to b.y`) — when two components are wired.
- Specialization (`:>` or `:>>`) — when X is-a Y.
- Allocation (`allocate function to component`) — for cross-hierarchy maps.

### Step 6 — Capture behavior

If the user described actions, modes, sequences, or events, model them:
- Sequential procedure → an `action def` with `first … then …`.
- Mode-based behavior → an `exhibit state` block with `state` and `transition`.
- Pure computation → a `calc def`.
- Reactive event response → a `transition` with `accept`.

### Step 7 — Capture requirements

For every "shall" / "must" / "should" the user wrote, produce a `requirement def` with:
- A `doc` comment paraphrasing the original sentence.
- A named `subject`.
- A `require constraint { … }` expressing the condition formally.
- (Optional) An `assume constraint { … }` for pre-conditions.
- (Optional) A `satisfy` link from the relevant part.

### Step 8 — Pick a package layout

If the model is small (< 30 elements), a single file with one top-level package is fine. If larger, split into `Structure.sysml`, `Behavior.sysml`, `Requirements.sysml`, `Verification.sysml` per `language/09-packages-imports-and-views.md`.

### Step 9 — Verify against the checklist

Run through `04-validation-checklist.md` before producing the answer. Do not skip.

---

## 3. Worked example — translating a request

> **User**: *"Model a simple drone with a battery, four motors, a flight controller, and a camera. The drone shall fly for at least 20 minutes on a full charge. The flight controller controls the motors based on input from the camera and an IMU."*

### Agent's reasoning (internal)

1. System of interest → `Drone`.
2. Kinds (definitions) → `Battery`, `Motor`, `FlightController`, `Camera`, `IMU`, `Drone`.
3. Usages inside `Drone` → `battery`, `motors [4]`, `controller`, `camera`, `imu`.
4. Quantities → battery capacity (`ElectricChargeValue`), endurance (`TimeValue`).
5. Relationships → controller has ports to motors, camera, IMU; battery powers everything.
6. Behavior → `Drone` has a `Fly` action with sub-steps; states `Idle`, `Flying`, `Landing`.
7. Requirement → `MinimumEndurance` with `require constraint { drone.endurance >= 20 [min] }`.
8. File layout → small enough for a single file.

### Agent's output

```sysml
package DroneModel {

    private import ISQ::*;
    private import SI::*;

    item def Thrust;
    item def VideoStream;
    item def OrientationData;
    item def MotorCommand;

    port def PowerOutPort  { out current : ElectricChargeValue; }
    port def PowerInPort   :> ~PowerOutPort;
    port def CommandOutPort { out cmd : MotorCommand; }
    port def CommandInPort  :> ~CommandOutPort;
    port def VideoOutPort   { out video : VideoStream; }
    port def OrientationOutPort { out data : OrientationData; }

    part def Battery {
        port supply : PowerOutPort;
        attribute capacity : ElectricChargeValue;
    }

    part def Motor {
        port power : PowerInPort;
        port cmd   : CommandInPort;
        out item thrust : Thrust;
    }

    part def Camera {
        port power : PowerInPort;
        port video : VideoOutPort;
    }

    part def IMU {
        port power : PowerInPort;
        port data  : OrientationOutPort;
    }

    part def FlightController {
        port power     : PowerInPort;
        port motorCmd  : CommandOutPort [4];
        port videoIn   : ~VideoOutPort;
        port imuIn     : ~OrientationOutPort;

        perform action stabilize {
            in  attitude : OrientationData;
            in  imagery  : VideoStream;
            out commands : MotorCommand [4];
        }
    }

    part def Drone {
        attribute endurance : TimeValue;

        part battery    : Battery;
        part motors     : Motor [4];
        part camera     : Camera;
        part imu        : IMU;
        part controller : FlightController;

        // Power distribution
        connect battery.supply to controller.power;
        connect battery.supply to camera.power;
        connect battery.supply to imu.power;
        connect battery.supply to motors.power;

        // Sensing and control
        connect camera.video        to controller.videoIn;
        connect imu.data            to controller.imuIn;
        connect controller.motorCmd to motors.cmd;

        exhibit state operational {
            state idle;
            state flying;
            state landing;

            transition takeoff first idle    accept signal: TakeoffCmd then flying;
            transition land    first flying  accept signal: LandCmd    then landing;
            transition done    first landing then idle;
        }
    }

    requirement def MinimumEndurance {
        doc /* The drone shall fly for at least 20 minutes on a full charge. */
        subject d : Drone;
        attribute minimum : TimeValue = 20 [min];
        require constraint { d.endurance >= minimum }
    }

    part myDrone : Drone {
        attribute :>> endurance = 25 [min];
        satisfy MinimumEndurance;
    }

    verification case def EnduranceTest {
        subject d : Drone;
        objective verifyEndurance {
            verify MinimumEndurance;
        }
        action chargeFully;
        action flyUntilEmpty;
        action recordTime;
        first chargeFully then flyUntilEmpty then recordTime;
    }
}
```

### Why this output is good

- One top-level package, imports at the top.
- Definitions before usages.
- Every kind of physical concept used a fitting element kind: `Motor` is a `part`, `Thrust` is an `item`, `MotorCommand` is an `item`, `IMU` is a `part`.
- Ports use directionality and conjugation (`~`).
- Multiplicities are present (`Motor [4]`, `motorCmd : CommandOutPort [4]`).
- The requirement is formalized — not just a `doc` comment.
- A concrete `myDrone` usage demonstrates `satisfy`.
- A `verification case def` demonstrates `verify`.
- Idiomatic naming: `PascalCase` for definitions, `camelCase` for usages.

---

## 4. Common transformations from natural language

| User said… | Agent writes… |
|---|---|
| "X is a kind of Y." | `part def X :> Y;` |
| "X has a Y." | Inside `part def X { part y : Y; }`. |
| "X has 4 wheels." | Inside `part def X { part wheels : Wheel [4]; }`. |
| "X weighs 100 kg." | `attribute :>> mass = 100 [kg];` inside the usage. |
| "X has between 2 and 5 doors." | `part doors : Door [2..5];` |
| "X provides power to Y." | A `connection` from a power-out port on X to a power-in port on Y. |
| "X performs action A." | `perform action a : A;` inside `part def X`. |
| "X is in mode M1 or M2." | `exhibit state s { state m1; state m2; }` inside `part def X`. |
| "X shall do Y." | `requirement def XShallDoY { subject x : X; require constraint { … } }`. |
| "Verify that X meets requirement R." | `verification case def TestX { subject x : X; objective o { verify R; } }`. |
| "Optionally, X has a Y." | `part y : Y [0..1];` |
| "There may be many Ys." | `part ys : Y [0..*];` |

---

## 5. When to ask the user a clarifying question

The agent should *not* invent arbitrary attributes or numbers. If the user's request is missing information that materially changes the model, the agent should say so and either:

- Ask one focused question, or
- Make a clearly-marked assumption inside a `// ASSUMPTION:` comment in the output.

Examples requiring clarification:

- The user mentioned a quantity but no units ("a tank that holds water" — how much?).
- The user described a behavior without specifying its inputs/outputs.
- The user used a domain term that maps ambiguously to multiple SysML element kinds.

Do **not** ask about every minor detail. Make reasonable defaults and note them.
