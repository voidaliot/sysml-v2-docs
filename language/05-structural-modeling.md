# 05 — Structural Modeling

Covers all the *physical / structural* constructs: `part`, `item`, `attribute`, `port`, `connection`, `interface`, `allocation`. These describe **what the system is made of and how the pieces are wired up**.

---

## 1. Parts

A **Part** represents a structural component of a system — anything that has identity, internal structure, and a place in the system's containment hierarchy. Parts replace SysML v1's *Block* (for the structural-component role).

### 1.1 Part definitions

```sysml
part def Vehicle {
    attribute mass : MassValue;
    attribute color : String;

    port  fuelInlet : FuelInletPort;
    port  obdPort   : OBDPort;

    part  engine        : Engine;
    part  transmission  : Transmission;
    part  wheels        : Wheel [4];

    perform action operate;
    exhibit state vehicleState;
}
```

### 1.2 Part usages

```sysml
part myCar : Vehicle;

part myCar : Vehicle {
    attribute :>> mass = 1500 [kg];
    attribute :>> color = "red";
}
```

### 1.3 Part hierarchy and composition

Nested `part` declarations create **composition** (the outer part owns the inner part). Use `ref part` for a reference rather than ownership:

```sysml
part def Workshop {
    part bay [3];                        // owned by the workshop
    ref part scheduledVehicle : Vehicle; // reference; the vehicle is owned elsewhere
}
```

### 1.4 Specialization

```sysml
part def Vehicle;
part def Car          :> Vehicle;
part def ElectricCar  :> Car  { … }
abstract part def AutonomousVehicle :> Vehicle;
```

`abstract` definitions cannot be instantiated directly; they exist only to be specialized.

---

## 2. Items

An **Item** is anything that *flows*, is *exchanged*, *consumed*, or *produced* by a system. Items represent matter, energy, or information moving through the system. Items are not parts — they have no fixed structural location.

```sysml
item def Fuel;
item def ElectricalCurrent;
item def CommandSignal { attribute value : Real; }
item def Photon;

part def Battery {
    out item current : ElectricalCurrent;
}
```

Items appear as the type carried by ports and on flow connections.

---

## 3. Attributes

An **Attribute** is a value-only feature of an element. Attributes have no identity beyond their value; they are not parts and cannot have ports.

```sysml
attribute def MassValue :> ScalarQuantityValue;   // (defined in standard library)

part def Vehicle {
    attribute mass         : MassValue;
    attribute maxOccupants : Integer = 5;
    attribute model        : String;
    derived attribute density = mass / volume;
}
```

Attributes typically use library types: `Integer`, `Real`, `Boolean`, `String`, plus the SI quantity types (`MassValue`, `LengthValue`, `TimeValue`, `SpeedValue`, …).

Quantity literals always carry units in square brackets:

```sysml
attribute :>> mass = 1500 [kg];
attribute pressure : PressureValue = 101325 [Pa];
```

---

## 4. Ports

A **Port** is an interaction point on a part. Ports carry items in or out and connect to other ports through connections or interfaces.

### 4.1 Port definitions

```sysml
port def PowerOutPort {
    out item current : ElectricalCurrent;
    out attribute voltage : VoltageValue;
}
```

### 4.2 Conjugate ports

A port can be *conjugated* (~) to flip the direction of every contained item:

```sysml
port def PowerInPort :> ~PowerOutPort;   // flips out→in
```

The `~` symbol on a port type reference also works inline:

```sysml
port supply : ~PowerOutPort;             // an inbound version of PowerOutPort
```

### 4.3 Port usages

```sysml
part def Bulb {
    port supply : PowerInPort;
}
part def Battery {
    port supply : PowerOutPort;
}
```

### 4.4 Nested ports

A port can contain sub-ports for hierarchical interfaces:

```sysml
port def DiagnosticBus {
    port can      : CANPort;
    port ethernet : EthernetPort;
}
```

---

## 5. Connections

A **Connection** wires two or more parts (typically through their ports) together. Connections are themselves typed and may carry their own structure.

### 5.1 Simple inline connection

```sysml
part def Flashlight {
    part battery : Battery;
    part bulb    : Bulb;
    connect battery.supply to bulb.supply;
}
```

### 5.2 Connection definitions

```sysml
connection def WireConnection {
    end source : PowerOutPort;
    end target : PowerInPort;
    attribute resistance : ResistanceValue;
}

part def Flashlight {
    part battery : Battery;
    part bulb    : Bulb;
    connection wire : WireConnection connect (battery.supply, bulb.supply);
}
```

### 5.3 Multi-end and binary forms

```sysml
connect a with b;                       // peer (no direction)
connect from src to dst;                // directed
connect (a, b, c);                      // multi-end
```

---

## 6. Interfaces

An **Interface** is a connection definition with conjugate ports — a typed contract between exactly two participating parts.

```sysml
interface def PowerSupply {
    end source : PowerOutPort;
    end sink   : PowerInPort;
}

part def Flashlight {
    part battery : Battery;
    part bulb    : Bulb;
    interface power : PowerSupply connect (battery.supply, bulb.supply);
}
```

Use an interface (over a plain connection) when you want to **specify the contract** between the two ends, not just the fact of a connection.

---

## 7. Allocation

`allocation` cross-cuts the structural hierarchy: it says "this functional element is realized by this physical element" without changing either.

```sysml
allocation def FunctionToComponent {
    end function : ActionUsage;
    end component : PartUsage;
}

allocation a1 : FunctionToComponent
    allocate processSignal to ecu;
```

Common uses: behavior-to-structure, requirement-to-component, logical-to-physical.

---

## 8. Putting it together — minimal flashlight

```sysml
package FlashlightExample {

    item def Light;
    item def Electricity;

    port def PowerOutPort  { out current : Electricity; }
    port def PowerInPort   :> ~PowerOutPort;
    port def LightOutPort  { out emitted  : Light; }

    part def Battery   { port supply : PowerOutPort;  attribute capacity : ElectricChargeValue; }
    part def Bulb      { port supply : PowerInPort;   port emit : LightOutPort; }
    part def Switch    { port in : PowerInPort; port out : PowerOutPort; attribute closed : Boolean = false; }

    part def Flashlight {
        part battery : Battery;
        part bulb    : Bulb;
        part switch  : Switch;

        connect battery.supply to switch.in;
        connect switch.out     to bulb.supply;
    }
}
```

This 25-line model exercises every structural construct in the right idiomatic shape — it is a good template for AI agents to use as a starting scaffold.
