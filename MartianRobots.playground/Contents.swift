//: Martial Robots: Red Badger Coding Test

import Foundation

/// Struct that represents an area with an integer size width and height
struct Size {

    /// The width of the area
    let width: Int32

    /// Height of the area
    let height: Int32
}

/// Struct for representing integer position on a 2d rectangular grid
struct Coordinate {

    /// X-axis component
    let x: Int32

    /// Y-axis component
    let y: Int32
}

/// Planet representation
struct Planet {

    /// The size of the plantet's 2d surface area
    let area: Size

    /// Robots currently on the planet's surface
    let robots: [Robot]

    /// Locations of coordinates known to be on the edge of the area
    var scentLocations: [Coordinate]
}

/// Compass orientation ordinal type
///
/// - north: Northern direction
/// - east: Eastern direction
/// - south: Southern direction
/// - west: Westerly direction
enum CompassOrientation {
    case north
    case east
    case south
    case west
}

/// Robot representation
struct Robot {

    /// Current position of the robot
    var position: Coordinate

    /// Current orientation of the robot
    var orientation: CompassOrientation

    /// Current status of the robot - is it ok, or is it lost?
    var status: Status
}

/// Status states
///
/// - ok: everything is ok
/// - lost: the object has been lost
enum Status {
    case ok
    case lost
}

/// Command representation
///
/// - turnRight: Command to turn right
/// - turnLeft: Command to turn left
/// - moveForwards: Command to move forwards one grid unit
enum command {
    case turnRight
    case turnLeft
    case moveForwards
}

let sampleInput = """
5 3
1 1 E
RFRFRFRF

3 2 N
FRRFLLFFRRFLL

0 3 W
LLFFFLFLFL
"""

let expectedOutput = """
1 1 E
3 3 N LOST
2 3 S
"""


