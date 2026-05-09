# 06 — Behavioral Modeling

Covers `action`, `state`, `transition`, `flow`, `succession`, `calc`, `event`, and the relationships between them. These describe **what the system does**.

---

## 1. Actions

An **Action** is a step of behavior — a function with parameters, possibly with internal sub-steps. An action consumes its inputs, performs work, and produces outputs.

### 1.1 Action definitions

```sysml
action def Brake {
    in  pedalForce : ForceValue;
    out wheelTorque : TorqueValue;
}

action def ProcessImage {
    in  raw : Image;
    out result : ProcessedImage;
    out confidence : Real;
}
```

### 1.2 Action usages and execution

A part *performs* an action:

```sysml
part def Vehicle {
    perform action brake : Brake {
        in pedalForce = brakeSensor.force;
    }
}
```

### 1.3 Sub-actions (decomposition)

Actions can contain sub-actions, with sequencing via `first … then …`:

```sysml
action def Drive {
    first start;
    then  accelerate;
    then  cruise;
    then  brake;
    then  done;

    action start;
    action accelerate;
    action cruise;
    action brake;
    action done;
}
```

### 1.4 Calculations

A `calc` is an action that returns a value (a pure function):

```sysml
calc def SpeedFromDistanceTime {
    in  d : LengthValue;
    in  t : TimeValue;
    return : SpeedValue = d / t;
}
```

Calculations are first-class and can be used wherever an expression is needed.

---

## 2. States

A **State** is a mode in which the system can be. States can have entry, exit, and do actions, and they can contain nested states (substates).

### 2.1 State definitions

```sysml
state def VehicleState {
    entry action turnOnLights;
    do    action monitorSensors;
    exit  action turnOffLights;
}
```

### 2.2 State usages and `exhibit`

A part *exhibits* a state:

```sysml
part def Vehicle {
    exhibit state vehicleStates {
        state off;
        state on;
        state error;

        transition powerOn  first off then on;
        transition powerOff first on  then off;
        transition fault    first on  then error;
    }
}
```

### 2.3 Hierarchical states

States nest naturally:

```sysml
state def Operational {
    state idle;
    state running {
        state accelerating;
        state cruising;
        state braking;
    }
}
```

---

## 3. Transitions

A **Transition** moves the system from one state to another, optionally on receipt of an event.

```sysml
transition first idle then running;
transition first idle accept signal: StartCmd then running;
transition powerOff
    first running
    accept signal: StopCmd
    then idle;
```

Transitions can have **guards** (conditions) and **effects** (actions performed on transition):

```sysml
transition
    first running
    accept e: TempSensorReading
    if e.temperature > 100 [°C]      // guard
    do action cooldownProtocol       // effect
    then degraded;
```

> ⚠️ Inside a `transition`, the keywords `first` and `then` are required and identify source and target states.

---

## 4. Events

Events are received by transitions or wait nodes:

```sysml
action def WaitForCommand {
    accept signal : CommandSignal;
}
```

Events typically come from incoming items, time, or change in attribute values.

---

## 5. Item flows

A **flow** is the transfer of items between parts (or their ports) over time.

```sysml
part def Pump   { out item flow : Water; }
part def Tank   { in  item flow : Water; }

part def WaterSystem {
    part pump : Pump;
    part tank : Tank;

    flow from pump.flow to tank.flow;
}
```

Combined with sequencing, you can model timed transfers:

```sysml
succession flow command from controller.cmdOut to actuator.cmdIn;
```

---

## 6. Successions

A **succession** orders two behaviors / states in time. It is the behavioral analog of a connection in structure.

```sysml
succession start then warmup;
succession warmup then operate;
succession operate then shutdown;
```

`first … then …` inside an `action` or `state` body is shorthand for explicit successions.

---

## 7. Putting it together — flashlight controller

```sysml
package FlashlightBehavior {

    import FlashlightExample::*;

    state def FlashlightMode {
        state off;
        state on;

        transition pressOn  first off accept p: PressEvent then on;
        transition pressOff first on  accept p: PressEvent then off;
    }

    part def ControlledFlashlight :> Flashlight {
        exhibit state mode : FlashlightMode;
        perform action checkBattery;
        succession checkBattery then mode;
    }
}
```

---

## 8. When to use which behavior construct

| User intent | Use |
|---|---|
| "Compute X from Y." | `calc def` |
| "The system performs step A, then B, then C." | `action def` with `first … then …` |
| "The system is in mode X or Y." | `state def` with `state` members and `transition` |
| "Material/data moves from A to B." | `flow` |
| "Step A must happen before step B." | `succession` |
| "The system reacts to event E by going to state Y." | `transition first X accept e: E then Y` |
| "There is an action called Z that has these parameters." | `action def Z { in …; out …; }` |
| "This function returns a value." | `calc def` (not `action def`) |
