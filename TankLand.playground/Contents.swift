import Foundation
var log = ""
var messager: [Int: String] = [:]

class constants {
    static let initialTankEnergy = 100000
    static let costOfRadarByUnitsDistance = [0, 100, 200, 400, 800, 1600, 3200, 6400, 12800]
    static let costOfSendingMessage = 100
    static let costOfRecievingMessage = 100
    static let costOfRealeasingMine = 250
    static let costOfRealeasingRover = 500
    static let costOfLaunchingMissle = 1000
    static let costOfFlyingMisslePerUnitDistance = 200
    static let costOfMovingTankPerUnitDistance = [100, 300, 600]
    static let costOfMovingRover  = 50
    static let costLifeSupportTank = 100
    static let costLifeSupportRover = 40
    static let costLifeSupportMine = 20
    static let missleStrikeMultiple = 10
    static let missleStrikeCollateral = 3
    static let mineStrikeMultiple = 5
    static let shieldPowerMultiple = 8
    static let missleStrikEnergyTransferFraction = 4
}

enum actions {
    case sendMessage
    case receiveMessage
    case runRadar
    case setShields
    case dropMine
    case dropRover
    case fireMissle
    case move
}

//The logger Section for the code
func add (input:String) {
    log += input
    log += "\n"
}

func erase () {
    log = ""
}


enum Direction : UInt32 {
    case north
    case south
    case east
    case west
    case northEast
    case northWest
    case southEast
    case southWest
    static func randomDirection() -> Direction {
        // pick and return a new value
        let rand = arc4random_uniform(8)
        return Direction(rawValue: rand)!
    }
}

class GameObject {
    var position: (Int,Int)
    var x: Int
    var y: Int
    var id: String
    var power: Int
    var shields: Int = 0
    var deactivated: Bool = false
    var name: String
    init (initialx: Int, initialy: Int, power: Int, type: String, name: String) {
        self.x = initialx
        self.y = initialy
        self.power = power
        self.name = name
        self.position = (initialx, initialy)
        self.id = type
    }
    
    func calculatePreactions() {}
    
    func calculatePostActions() {}
    
    func setLifeSupport() {}
    
    func sendMessage(message: String, id: Int) {
        messager[id] = message
        power -= constants.costOfSendingMessage
        if (power <= 0) {
            destroy()
        } else {
            log += "Sending Message \(message) from \(name)"
            log += "\n"
        }
        
    }
    
    func recieveMessage (id: Int) -> String? {
        var done: Bool = false
        for i in messager {
            if (i.0 == id) {
                power -= constants.costOfRecievingMessage
                log += "Recieving Message \(i.1) to \(name)"
                log += "\n"
                if (power <= 0) {
                    destroy()
                }
                done = true
                return (i.1)
            }
        }
        if (done == false) {
            return nil
        }
    }
    
    func runRadar (range: Int) -> [GameObject]  {
        var closeBy: [GameObject] = []
        if (power > 0) {
            for i in objects {
                if (i.x >= x - range && i.x <= x + range && i.y >= y - range && i.y <= y + range && i.id != "Missle") {
                    closeBy.append(i)
                }
            }
            power -= constants.costOfRadarByUnitsDistance[range]
            if (power <= 0) {
                destroy()
            }
            var tanks = 0
            var mines = 0
            var rovers = 0
            for i in closeBy {
                if (i.id == "Tank") {
                    tanks += 1
                }
                if (i.id == "Mine") {
                    mines += 1
                }
                if (i.id == "Rover") {
                    rovers += 1
                }
            }
            log += "\(name) has run a radar and has found \(tanks) Tanks, \(mines) Mines, and \(rovers) Rovers"
            log += "\n"
        }
        return(closeBy)
        
    }
    func calculateExplosions () {
        for i in objects {
            if i.position == position {
                if i.id == "Mine" {
                    print("hapennig")
                    log += "Mine detonated at \(position)"
                    if (shields < i.power) {
                        i.shields = 0
                        power -= i.power
                        if (power == 0) {
                            i.destroy()
                            log += "\(name) destroyed"
                            log += "\n"
                        }
                    }
                    if (shields == 0) {
                        power -= i.power
                        if (power == 0) {
                            i.destroy()
                            log += "\(name) destroyed"
                            log += "\n"
                        }
                    }
                    if (shields > i.power) {
                        shields -= i.power
                    }
                    
                }
            }
        }
    }
    
    func destroy() {
        if let index = objects.index(where: { (item) -> Bool in item.name == name }) {
            objects.remove(at: index)
        }
        c.grid[x,y] = nil
        
        log += "\(name) destroyed"
        log += "\n"
    }
    func setShields (amount: Int){
        shields += amount * constants.shieldPowerMultiple
        log += "setting shields to \(shields)"
        log += "\n"
        power -= amount
        log += "\(power) power remaining"
        log += "\n"
        if (power <= 0) {
            destroy()
        }
        
    }
    
    func fireMissle (energy: Int, position: (Int , Int)) {
        if (position.0 != 0 || position.0 != 14 || position.1 != 0 || position.1 != 14) {
            log += "Missle fired at \(position)"
            log += "\n"
            objects.append(GameObject(initialx: position.0, initialy: position.1, power: energy * 3, type: "Missle", name: "Missle"))
            power -= constants.costOfLaunchingMissle
        }
    }
    
    func computeNext (direction: Direction, distance: Int) -> (Int,Int) {
        var xNext = x
        var yNext = y
        
        switch direction {
        case .north:
            xNext -= distance
        case .south:
            xNext += distance
        case .east:
            yNext += distance
        case .west:
            yNext -= distance
        case .northEast:
            xNext -= distance
            yNext += distance
        case .northWest:
            xNext -= distance
            yNext -= distance
        case .southEast:
            xNext += distance
            yNext += distance
        case .southWest:
            xNext += distance
            yNext -= distance
        }
        return (xNext, yNext)
        
    }
    
}


struct Array2DInt: CustomStringConvertible {
    var rows: Int
    var cols: Int
    var array = [[GameObject?]]()
    subscript (row: Int, col: Int) -> GameObject? {
        get {
            assert(indexIsValid(row: row, column: col), "Index out of Range")
            return array [row][col]
        }
        set {
            assert(indexIsValid(row: row, column: col), "Index out of Range")
            array[row][col] = newValue
        }
    }
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < cols
    }
    
    init (rows:Int, cols:Int) { //Use 0 as default value
        self.rows = rows
        self.cols = cols
        array = [[GameObject?]]( repeating: [GameObject?](repeating: nil, count: cols), count: rows)
    }
    var description: String {
        var finale = ""
        finale = String(repeating: "_", count: cols * 9 + 1)
        finale += "\n"
        
        for var row in 0..<rows {
            for var col in 0..<cols {
                
                // print first row of cell
                var optionalGO = array[row][col]
                if optionalGO == nil {
                    finale += "|        "
                } else {
                    finale += String(format: "|%8d", optionalGO!.power)
                }
                
            }
            finale += "|\n"
            for col in 0..<cols {
                // print second row of cell
                var optionalGO = array[row][col]
                if optionalGO == nil {
                    finale += "|        "
                } else {
                    finale += "| " + optionalGO!.name.padding(toLength: 7, withPad: " ", startingAt: 0)
                }
                
            }
            finale += "|\n"
            for col in 0..<cols {
                // print third row of cell
                var optionalGO = array[row][col]
                if optionalGO == nil {
                    finale += "|        "
                } else {
                    var coord = "(" + String(optionalGO!.x) + "," + String(optionalGO!.y) + ")"
                    finale += "| " + coord.padding(toLength: 7, withPad: " ", startingAt: 0)
                }
            }
            finale += "|\n"
            for col in 0..<cols {
                // print fourth row of cell
                finale += "|________"
            }
            finale += "|\n"
        }
        return (finale)
    }
}


class tankWorld {
    var grid: Array2DInt
    var gameOver = false
    
    init (length: Int, width: Int) {
        self.grid = Array2DInt (rows: length, cols: width)
    }
    
    func place (gameObject: GameObject) {
        objects.append(gameObject)
        grid[gameObject.x,gameObject.y] = gameObject
        log += "((\(gameObject.x),\(gameObject.y)) \(gameObject.id) placed)"
        log += "\n"
    }
    
    func runTankWorld () {
        print(log)
        erase()
        while gameOver != true {
            doTurn()
        }
        print(log)
        erase()
    }
    
    func doTurn() {
        var tanks = 0
        for i in objects {
            i.setLifeSupport()
            i.calculatePreactions()
            i.calculatePostActions()
        }
        print (grid.description)
        print(log)
        erase()
        
        var winnerName : String = ""
        
        for i in objects {
            if i.id == "Tank" {
                winnerName = i.name
                tanks += 1
            }
        }
        
        if tanks == 1 {
            add (input: "and the winner is... \(winnerName)")
            gameOver = true
        }
        
        if tanks == 0 {
            add (input: "There is no winner")
            gameOver = true
        }
    }
}


class Missle : GameObject {
    override init(initialx: Int, initialy: Int, power: Int, type: String, name: String) {
        super.init(initialx: initialx, initialy: initialy, power: power, type: type, name: name)
        var detonated = false
        for i in objects {
            if (i.position == position && i.id != "Missle"){
                destroy()
                if (i.shields < power && i.shields != 0) {
                    i.shields = 0
                    i.power -= power
                    if (i.power == 0) {
                        if (i.id != "Missle") {
                            i.destroy()
                            log += "\(i.name) destroyed at \(position)"
                            log += "\n"
                        }
                    }
                }
                if (i.shields == 0) {
                    i.power -= power
                    if (i.power == 0) {
                        if (i.id != "Missle") {
                            i.destroy()
                            log += "\(i.name) destroyed at \(position)"
                            log += "\n"
                        }
                    }
                }
                if (i.shields > power) {
                    i.shields -= power
                    log += "\(i.name) hit at \(position)"
                    log += "\n"
                }
                if (i.power > power) {
                    i.power -= power
                    log += "\(i.name) hit at \(position)"
                    log += "\n"
                }
                detonated = true
            }
        }
        destroy()
    }
}


class Mine : GameObject {
    init(initialx: Int, initialy: Int, power: Int) {
        super.init(initialx: initialx, initialy: initialy, power: power, type: "Mine", name: "R2D2")
    }
    override func setLifeSupport() {
        power -= constants.costLifeSupportMine
        if (power <= 0) {
            destroy()
        } else {
            log += "Setting life to mine... remaining power \(power)"
            log += "\n"
        }
    }
}

class SampleTank: GameObject {
    var turns: Int = 0
    var received: [GameObject] = []
    //Note: This class has not yet been debugged .
    
    init(initialx: Int, initialy: Int, power: Int,  name: String) {
        super.init(initialx: initialx, initialy: initialy, power: power, type: "Tank", name: name)
    }
    override func calculatePreactions() {
        
    }
    override func calculatePostActions() {
        dropMine(energy: 100, direction: Direction.randomDirection())
        move(direction: Direction.randomDirection(), distance: Int(arc4random_uniform(2))+1)
    }
    
    func dropMine (energy: Int, direction: Direction) {
        var (xNext, yNext) = computeNext(direction: direction, distance: 1)
        if (xNext >= 0 &&
            xNext < c.grid.rows  &&
            yNext >= 0 &&
            yNext < c.grid.cols &&
            c.grid[xNext, yNext] == nil) {
            
            c.place(gameObject: Mine(initialx: xNext, initialy: yNext, power: energy))
            power -= constants.costOfRealeasingMine
            
        }
    }
    
    
    func move (direction: Direction, distance: Int) {
        
        var (xNext, yNext) = computeNext(direction: direction, distance: distance)
        if (xNext >= 0 &&
            xNext < c.grid.rows  &&
            yNext >= 0 &&
            yNext < c.grid.cols &&
            distance <= 3 &&
            (c.grid[xNext, yNext] == nil || c.grid[xNext, yNext]!.id != "Tank")){
            
            if (c.grid[xNext, yNext] != nil && c.grid[xNext, yNext]!.id == "Mine") {
                var mine = c.grid[xNext, yNext]!
                mine.destroy()
                power -= mine.power * constants.mineStrikeMultiple
                if (power <= 0) {
                    destroy()
                } else {
                    add (input: "Tank stepped on Mine")
                }
            }
            c.grid[x, y] = nil
            c.grid[xNext, yNext] = self
            x = xNext
            y = yNext
            power -= constants.costOfMovingTankPerUnitDistance[distance]
            if (power <= 0) {
                destroy()
            }
        }
    }
    
    override func setLifeSupport() {
        power -= constants.costLifeSupportTank
        if (power <= 0) {
            destroy()
        } else {
            add (input: "Setting life to tank... remaining power \(power)")
        }
    }
}



var objects: [GameObject] = []
var c = tankWorld (length: 10, width: 10)

c.place(gameObject: SampleTank(initialx: 2, initialy: 4, power: 10000, name: "Tank1"))
c.place(gameObject: SampleTank(initialx: 5, initialy: 5, power: 1000,  name: "Tank2"))
c.place(gameObject: SampleTank(initialx: 8, initialy: 8, power: 10000, name: "Tank3"))

c.runTankWorld()

