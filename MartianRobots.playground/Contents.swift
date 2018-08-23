//: Martial Robots: Red Badger Coding Test

import Foundation

/// Struct that represents an area with an integer size width and height
struct Size {
    /// The width of the area
    let width: Int

    /// Height of the area
    let height: Int
}

/// Struct for representing integer position on a 2d rectangular grid
struct Coordinate {
    /// X-axis component
    let x: Int

    /// Y-axis component
    let y: Int
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

    func stringRepresentation() -> String {
        switch self {
        case .north:
            return "N"
        case .south:
            return "S"
        case .east:
            return "E"
        case .west:
            return "W"
        }
    }
}

/// Transform node - Represents a position and orientation
struct Transform {
    /// Current position
    var position: Coordinate

    /// Current orientation
    var orientation: CompassOrientation
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
enum Instruction {
    case turnRight
    case turnLeft
    case moveForwards
}

/// Robot representation
struct Robot {
    /// The robot's current transform (position and orientation)
    let transform: Transform

    /// Current status of the robot - is it ok, or is it lost?
    var status: Status

    /// Instructions the robot has been programmed to execute
    let program: [Instruction]
}

/// Planet representation
struct Planet {
    /// The size of the plantet's 2d surface area
    let area: Size

    /// Robots currently on the planet's surface
    let robots: [Robot]

    /// Locations of coordinates known to be on the edge of the area
    var scentLocations: [Coordinate]


    /// Output the robot positions
    ///
    /// - Returns: The current robot positions
    func robotPositions() -> String {
        var lines = String()
        robots.forEach { (robot) in
            lines.append("\(robot.transform.position.x) \(robot.transform.position.y) \(robot.transform.orientation.stringRepresentation())\n")
        }
        return lines
    }
}

func parseInput(input: String) -> Planet? {
    let splitInput = input.split(separator: "\n", maxSplits: 1)
    guard let firstLine = splitInput.first else {
        print("Error, input is malformed")
        return nil
    }
    guard let size = parsePlanetSize(string: String(firstLine)) else {
        print("Invalid planet definition")
        return nil
    }

    let remainingLines = String(splitInput[1])

    let robots = parseRobotPositions(string: remainingLines)
    if robots.count == 0 {
        print("No valid robots found in input.")
        return nil
    }

    return Planet(area: size, robots: robots, scentLocations: [Coordinate]())
}

func parsePlanetSize(string: String) -> Size? {
    let sizeCharacters = string.split(separator: " ")
    guard let width = Int(sizeCharacters[0]), let height = Int(sizeCharacters[1]) else {
        return nil
    }

    // Coordinates cannot be larger than 50, as per specification
    guard width <= 50, height <= 50 else {
        return nil
    }
    return Size(width: width, height: height)
}

func parseRobotPositions(string: String) -> [Robot] {
    enum InputState {
        case position
        case instructions
    }

    var robots = [Robot]()
    var state = InputState.position
    var transform: Transform? = nil
    var program = [Instruction]()

    string.enumerateLines { (line, result) in
        switch(state) {
        case .position:
            transform = parseTransform(line: line)
            if transform != nil {
                state = .instructions
            }
        case .instructions:
            program = parseInstructions(line: line)
            if program.count > 0 {
                if let transform = transform {
                    robots.append(Robot(transform: transform, status: .ok, program: program))
                }
                state = .position
            } else {
                print("Invalid instructions encountered, skipping")
                state = .position
            }
        }
    }
    return robots
}

func parseTransform(line: String) -> Transform? {
    let elements = line.split(separator: " ")
    if elements.count < 3 {
        return nil
    }
    guard let x = Int(elements[0]), let y = Int(elements[1]) else {
        print("Failed to parse transform")
        return nil
    }

    if x > 50 || y > 50 {
        print("Coordinates out of bounds")
        return nil
    }

    let orientationCharacter = String(elements[2])
    let orientation: CompassOrientation
    switch orientationCharacter {
    case "N":
        orientation = .north
    case "E":
        orientation = .east
    case "S":
        orientation = .south
    case "W":
        orientation = .west

    default:
        print("Invalid orientation encountered, skipping robot")
        return nil
    }
    return Transform(position: Coordinate(x: x, y: y), orientation: orientation)
}

func parseInstructions(line: String) -> [Instruction] {
    var instructions = [Instruction]()
    for (_, char) in line.enumerated() {
        switch char {
        case "F":
            instructions.append(.moveForwards)
        case "R":
            instructions.append(.turnRight)
        case "L":
            instructions.append(.turnLeft)
        default:
            print("Invalid instruction detected, skipping")
        }
    }
    return instructions
}

func runProgram(planet: Planet, robot: Robot) {

}

func runRobots(planet: Planet) {
    planet.robots.forEach { (robot) in
        runProgram(planet: planet, robot: robot)
    }
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

func main() {
    print("Reading input")
    guard let planet = parseInput(input: sampleInput) else {
        print("Failed to read planet definition from inpute")
        return
    }
    print("Read \(planet.robots.count) robots")

    let output = planet.robotPositions()
    print(output)

    if output == expectedOutput {
        print("Output matches expected output")
    }
}

main()



