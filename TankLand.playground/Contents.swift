import Foundation
enum Direction {
    case north
    case south
    case east
    case west
    case northEast
    case northWest
    case southEast
    case southWest
}

enum Actions{
    case Move
    
}

protocol Action: CustomStringConvertible {
    var action: Actions {get}
    var description: String {get}
}
protocol PreAction: Action {
}
protocol PostAction: Action {
}

struct MoveAction: PostAction{
    let action: Actions
    var description: String {
        return "\(action) \(distance) \(direction)"
    }
    let distance: Int
    let direction: Direction
    init(distance: Int, direction: Direction) {
        action = .Move
        self.distance = distance
        self.direction = direction
    }

}

class gameObject {
    var x: Int
    var y: Int
    var id: String
    var energy: Int
    init (initialx: Int, initialy: Int, type: String, energyz: Int) {
        self.x = initialx
        self.y = initialy
        self.id = type
        self.energy = energyz
    }
}

class tank: gameObject {
    
}

class missle: gameObject {
    
}

class rover: gameObject {
    
}
struct Array2DInt: CustomStringConvertible {
    var rows: Int
    var cols: Int
    var array = [[gameObject?]]()
    subscript (row: Int, col: Int) -> gameObject? {
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
        array = [[gameObject?]]( repeating: [gameObject?](repeating: nil, count: cols), count: rows)
    }
    var description: String {
        var finale = ""
        var counter = 0
        var col = 0
        var rowz: Int = 0
        finale = String(repeating: "_", count: cols * 9 + 1)
        finale += "\n"
        
        for var row in 0..<rows {
            
            
            
            for col in 0..<cols {
                
                // print first row of cell
                var optionalGO = array[row][col]
                if optionalGO == nil {
                    finale += "|        "
                } else {
                    finale += String(format: "|%8d", optionalGO!.energy)
                }
                
            }
            finale += "|\n"
            for col in 0..<cols {
                // print second row of cell
                var optionalGO = array[row][col]
                if optionalGO == nil {
                    finale += "|        "
                } else {
                    finale += "| " + optionalGO!.id.padding(toLength: 7, withPad: " ", startingAt: 0)
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
enum direction {
    case north
    case south
    case east
    case west
    case northEast
    case northWest
    case southEast
    case southWest
}

class tankWorld: CustomStringConvertible {
    var grid: Array2DInt
    init (length: Int, width: Int) {
        self.grid = Array2DInt (rows: length, cols: width)
    }
    func place (x: Int, y:Int, object: String, initialEnergy: Int) {
        grid[x,y] = (gameObject(initialx: x, initialy: y, type: object, energyz: initialEnergy))
        
    }
    func runTankLand (){
        
    }
    var description: String {
        return grid.description
    }

}

var c = tankWorld (length: 5, width: 5)

c.place(x: 2, y: 4, object: "Tank", initialEnergy: 1000)
c.place(x: 0, y: 3, object: "Tank2", initialEnergy: 5000)

print(c)





