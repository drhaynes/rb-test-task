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

/// Represents a direction
///
/// - left: Left
/// - right: Right
enum Direction {
    case left
    case right
}

/// Robot representation
struct Robot {
    /// The robot's current transform (position and orientation)
    var transform: Transform

    /// Current status of the robot - is it ok, or is it lost?
    var status: Status

    /// Instructions the robot has been programmed to execute
    let program: [Instruction]

    /// Is the robot running its program?
    var running: Bool

    mutating func runProgram(planet: Planet) -> Coordinate {
        running = true
        program.forEach { (instruction) in
            if running {
                switch instruction {
                case .moveForwards:
                    moveForwards(distance: 1)
                    checkIfLost(planet: planet)
                    if status == .lost {
                        running = false
                    }
                case .turnLeft:
                    turn(direction: .left)
                case .turnRight:
                    turn(direction: .right)
                }
            }
        }
        running = false
        return transform.position
    }

    private mutating func checkIfLost(planet: Planet) {
        if (transform.position.x > planet.area.width ||
            transform.position.x < 0 ||
            transform.position.y > planet.area.height ||
            transform.position.y < 0) {
            moveForwards(distance: -1)
            status = .lost
        }
    }

    /// Move the robot one unit in the currently facing direction
    mutating func moveForwards(distance: Int) {
        let x = transform.position.x
        let y = transform.position.y
        switch transform.orientation {
        case .north:
            transform.position = Coordinate(x: x, y: y + distance)
        case .south:
            transform.position = Coordinate(x: x, y: y - distance)
        case .east:
            transform.position = Coordinate(x: x + distance, y: y)
        case .west:
            transform.position = Coordinate(x: x - distance, y: y)
        }
    }

    /// Turns the robot 90 degrees
    ///
    /// - Parameter direction: The direction to turn
    mutating func turn(direction: Direction) {
        switch direction {
        case .left:
            switch transform.orientation {
            case .north:
                transform.orientation = .west
            case .south:
                transform.orientation = .east
            case .east:
                transform.orientation = .north
            case .west:
                transform.orientation = .south
            }
        case .right:
            switch transform.orientation {
            case .north:
                transform.orientation = .east
            case .south:
                transform.orientation = .west
            case .east:
                transform.orientation = .south
            case .west:
                transform.orientation = .north
            }
        }
    }
}

/// Planet representation
struct Planet {
    /// The size of the plantet's 2d surface area
    let area: Size

    /// Robots currently on the planet's surface
    var robots: [Robot]

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

    /// Run all the planet's robots' programs
    mutating func runRobots() {
        for i in 0..<robots.endIndex {

            // Save the last known coordinate if the robot was lost
            let lastKnownCoordinate = robots[i].runProgram(planet: self)
            if robots[i].status == .lost {
                scentLocations.append(lastKnownCoordinate)
            }
        }
    }
}

/// Parses the input into planet definition
///
/// - Parameter input: Input definition string
/// - Returns: Planet or nil if definition was invalid
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

/// Parse the planet size from input string
///
/// - Parameter string: The input string containing size definition
/// - Returns: The size if valid, nil if not
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

/// Parse robot positions from input
///
/// - Parameter string: The robot definitions
/// - Returns: Array of valid robots parsed from the input (note: can be empty)
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
                    robots.append(Robot(transform: transform, status: .ok, program: program, running: false))
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

/// Parse a transform from a string
///
/// - Parameter line: the string input
/// - Returns: Transform as defined, or nil if invalid
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

/// Parse instructions from a string
///
/// - Parameter line: String containing the instructions
/// - Returns: Array of valid instructions found
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
    guard var planet = parseInput(input: sampleInput) else {
        print("Failed to read planet definition from inpute")
        return
    }
    print("Planet size: \(planet.area)")
    print("Read \(planet.robots.count) robots")

    planet.runRobots()

    let output = planet.robotPositions()
    print(output)

    if output == expectedOutput {
        print("Output matches expected output")
    }
}

main()



