/*
 * vehicle-skeleton.sysml
 *
 * A larger, illustrative SysML v2 model that exercises every major construct.
 * Use as a reference template for AI agents and a multi-feature test fixture
 * for the language server.
 *
 * Constructs covered:
 *   - package, imports
 *   - abstract part def + specialization
 *   - variation / variant
 *   - port def with conjugation
 *   - item def
 *   - attribute with quantity types and units
 *   - part hierarchy with composition and reference
 *   - connection def + interface def
 *   - action def with parameters
 *   - calc def
 *   - state def with hierarchical states and transitions
 *   - requirement def with subject, assume, require, sub-requirements
 *   - satisfy and verify
 *   - analysis case
 *   - verification case
 *   - use case
 *   - allocation
 *   - view / viewpoint / rendering
 *   - metadata
 *   - concern / stakeholder
 */

package VehicleSkeleton {

    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;

    // ===== Items =====================================================

    item def Fuel;
    item def Electricity;
    item def Torque;
    item def MotionCommand;
    item def DiagnosticData;

    // ===== Ports =====================================================

    port def FuelPort       { in  flow : Fuel; }
    port def PowerOutPort   { out current : Electricity; }
    port def PowerInPort    :> ~PowerOutPort;
    port def TorqueOutPort  { out torque : Torque; }
    port def TorqueInPort   :> ~TorqueOutPort;
    port def OBDPort        { in  request : DiagnosticData; out reply : DiagnosticData; }
    port def CommandOutPort { out cmd : MotionCommand; }
    port def CommandInPort  :> ~CommandOutPort;

    // ===== Atomic parts ==============================================

    abstract part def Engine {
        doc /* Abstract base for any propulsion engine. */
        attribute peakPower : PowerValue;
        attribute mass      : MassValue;
        port torqueOut : TorqueOutPort;
    }

    variation part def EngineVariant :> Engine {
        variant part def CombustionEngine :> Engine {
            port fuelIn : FuelPort;
            attribute displacement : LengthValue; // (volume — see ISQ)
        }
        variant part def ElectricMotor :> Engine {
            port powerIn : PowerInPort;
            attribute kvRating : Real;
        }
    }

    part def Battery {
        doc /* Traction battery providing electrical energy. */
        port supply : PowerOutPort;
        attribute capacity : ElectricChargeValue;
        attribute mass     : MassValue;
    }

    part def Wheel {
        port driveIn : TorqueInPort;
        attribute diameter : LengthValue = 0.65 [m];
        attribute mass     : MassValue;
    }

    part def Transmission {
        port input  : TorqueInPort;
        port output : TorqueOutPort;
        attribute ratio : Real;
        attribute mass  : MassValue;
    }

    part def Body {
        attribute mass    : MassValue;
        attribute dragCoefficient : Real;
    }

    part def ECU {
        doc /* Electronic Control Unit — top-level vehicle controller. */
        port power     : PowerInPort;
        port diag      : OBDPort;
        port motorCmd  : CommandOutPort;

        perform action stabilize {
            in  state     : VehicleState;
            out command   : MotionCommand;
        }
    }

    // ===== Connection / interface ====================================

    connection def WireConnection {
        end source : PowerOutPort;
        end target : PowerInPort;
        attribute length : LengthValue;
    }

    interface def DrivetrainInterface {
        end engine       : TorqueOutPort;
        end transmission : TorqueInPort;
    }

    // ===== Vehicle (top-level part) ==================================

    abstract part def Vehicle {
        doc /* Abstract vehicle. */

        attribute mass        : MassValue;
        attribute topSpeed    : SpeedValue;
        attribute range       : LengthValue;
        attribute basePrice   : Real;

        part body         : Body;
        part transmission : Transmission;
        part wheels       : Wheel [4];
        part ecu          : ECU;

        ref part operator : Person;

        derived attribute totalMass : MassValue =
            body.mass + transmission.mass + sum(wheels.mass);
    }

    part def Car :> Vehicle {
        attribute numDoors : Integer = 4;
    }

    part def ElectricCar :> Car {
        part battery : Battery;
        part motor   : EngineVariant::ElectricMotor;

        connect battery.supply to motor.powerIn;
        interface drivetrain : DrivetrainInterface
            connect (motor.torqueOut, transmission.input);
        connect transmission.output to wheels.driveIn;
    }

    part def Person {
        attribute name : String;
        attribute licensed : Boolean;
    }

    // ===== Behavior ==================================================

    state def VehicleState {
        state parked;
        state driving {
            state accelerating;
            state cruising;
            state decelerating;
        }
        state charging;
        state error;

        transition start  first parked     accept signal: StartCmd then driving;
        transition stop   first driving    accept signal: StopCmd  then parked;
        transition charge first parked     accept signal: PlugIn   then charging;
        transition done   first charging   accept signal: Unplug   then parked;
        transition fault  first driving                            then error;
    }

    item def StartCmd;
    item def StopCmd;
    item def PlugIn;
    item def Unplug;

    action def Drive {
        in  destination : String;
        out arrived : Boolean;

        action plan;
        action navigate;
        action arrive;

        first plan then navigate then arrive;
    }

    calc def AverageSpeed {
        in  distance : LengthValue;
        in  duration : TimeValue;
        return : SpeedValue = distance / duration;
    }

    // ===== Concerns and requirements =================================

    concern def SafetyConcern {
        doc /* Stakeholders require the vehicle to be safe. */
        stakeholder regulator;
        stakeholder driver;
    }

    concern def CostConcern {
        stakeholder programManager;
        stakeholder finance;
    }

    requirement def MaxMassLimit {
        doc /* The vehicle's total mass shall not exceed the regulatory limit. */
        subject v : Vehicle;
        attribute limit : MassValue = 2500 [kg];
        assume  constraint { v.totalMass > 0 [kg] }
        require constraint { v.totalMass <= limit }
    }

    requirement def Safe :> SafetyConcern {
        doc /* The vehicle shall meet the regulatory safety envelope. */
        subject v : Vehicle;

        requirement crashWorthiness {
            attribute minRating : Integer = 4;
            require constraint { /* crash rating attribute would live on Vehicle in reality */ true }
        }

        requirement brakingDistance {
            attribute maxDistance : LengthValue = 38 [m];
            require constraint { /* braking attribute would live on Vehicle in reality */ true }
        }
    }

    requirement def UnitCost :> CostConcern {
        subject v : Vehicle;
        attribute maxPrice : Real = 50000;
        require constraint { v.basePrice <= maxPrice }
    }

    // ===== A concrete usage ==========================================

    part myEV : ElectricCar {
        attribute :>> mass      = 1800 [kg];
        attribute :>> topSpeed  = 200 [km/h];
        attribute :>> range     = 450 [km];
        attribute :>> basePrice = 45000;

        satisfy MaxMassLimit;
        satisfy UnitCost;
    }

    // ===== Allocation ================================================

    allocation def FunctionToComponent {
        end function  : ActionUsage;
        end component : PartUsage;
    }

    allocate Drive to myEV.ecu;

    // ===== Analysis case =============================================

    analysis case def MassRollup {
        doc /* Compute the total mass of an electric car. */
        subject v : ElectricCar;
        objective totalMass : MassValue;
        return totalMass = v.totalMass + v.battery.mass + v.motor.mass;
    }

    // ===== Verification case =========================================

    verification case def MassVerification {
        doc /* Weigh the vehicle and verify the mass requirement. */

        subject v : Vehicle;
        objective verifyMass {
            verify MaxMassLimit;
        }

        action putOnScale;
        action readScale;
        action recordResult;

        first putOnScale then readScale then recordResult;
    }

    verification case checkMyEV : MassVerification {
        subject = myEV;
    }

    // ===== Use case ==================================================

    use case def DriveToWork {
        doc /* Driver commutes from home to office in the vehicle. */
        subject v : Vehicle;
        actor   driver : Person;
        objective arriveAtOffice;

        action enter;
        action start;
        action drive;
        action park;
        action exit;

        first enter then start then drive then park then exit;
    }

    // ===== View / viewpoint ==========================================

    viewpoint def MassBudgetViewpoint {
        stakeholder programManager;
        concern     CostConcern;
    }

    view def MassBudgetView {
        frame MassBudgetViewpoint;
        expose myEV.body.mass,
               myEV.transmission.mass,
               myEV.battery.mass,
               myEV.motor.mass;
        render asTable;
    }

    rendering def asTable;

    // ===== Metadata ==================================================

    metadata def Critical;
    metadata def Owner { attribute team : String; }

    @Critical
    @Owner { team = "Powertrain"; }
    part def TractionInverter {
        port input  : PowerInPort;
        port output : PowerOutPort;
    }
}
