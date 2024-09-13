import Foundation
import Observation

struct Tile: Identifiable {
    var id = UUID()
    var name: String
    
    var number: Int {
        // Extract number from name
        // Ignore the first three characters
               let nameWithoutPrefix = String(name.dropFirst(3))

               // Extract number from the remaining name
               if let number = Int(nameWithoutPrefix.filter { $0.isNumber }) {
                   return number
               }
               return 0
    }
    
    var letter: String {
        // Extract letter from name
        if name.hasPrefix("G3_Atom") || name.hasPrefix("G3_Charge") {
            return ""
        }
        if name.hasPrefix("G4_Atom") || name.hasPrefix("G4_sp") {
            return ""
        }
        return String(name.suffix(1)) // get the last letter if not Game 3 or game 4
    }
    
    var imageName: String {
            return name
    }
    
    var isAtom: Bool {
        if name.hasPrefix("G3_Atom") || name.hasPrefix("G4_Atom"){
            return true
        }
        else {
            return false
        }
    }
       
    
    
}
