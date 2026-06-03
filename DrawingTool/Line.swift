import Foundation
import UIKit

struct Line : Identifiable {
   
    let id                                          = UUID()
    var points                                      : [CGPoint]
    var color                                       : UIColor
    var width                                       : CGFloat
}

enum DrawingTool {
    
    case none
    case pen
    case eraser
    case marker
    case selection
    case moveSelection
}

extension Line {
    
    func isInside(_ rect: CGRect) -> Bool {
        
        for point in points {
           
            if rect.contains(point) {
                
                return true
            }
        }
        return false
    }
}
