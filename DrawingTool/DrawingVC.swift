
import UIKit

class DrawingVC: UIViewController {

    @IBOutlet weak var drawingView          : DrawingView!
    @IBOutlet weak var lblMarkerPoints      : UILabel!
    @IBOutlet weak var imgOutput            : UIImageView!
    @IBOutlet weak var viewOutput           : UIView!
    
    override func viewDidLoad() {  
        super.viewDidLoad()

        self.lblMarkerPoints.isHidden       = true
        self.viewOutput.isHidden            = true
    }

    // MARK: - Actions
    @IBAction func btnDrawing(_ sender: UIButton) {
        
        switch sender.tag {
        case 0 :
            drawingView.startSelectionMode()
        case 1 :
            drawingView.endSelectionMode()
            drawingView.enableDrawingMode()
        case 2 :
            drawingView.currentTool = .marker
        case 3 :
            drawingView.undoLastDrawing()
        case 4 :
            drawingView.enableEraserMode()
        case 5 :
            drawingView.clearAll()
            lblMarkerPoints.isHidden        = true
            viewOutput.isHidden             = true
        case 6 :
            drawingView.currentTool = .moveSelection
        default :
            break
        }
    }

    // MARK: - Export
    @IBAction func btnExport(_ sender: UIButton) {

        if let img = drawingView.exportAsImage() {
            
            self.imgOutput.image            = img
            self.viewOutput.isHidden        = false
        }
        if drawingView.getMarkerPointsOnImage().count > 0 {
            
            let points                      = drawingView.getMarkerPointsOnImage()
            let joinedString                = points.map { "(\($0.x), \($0.y))" }.joined(separator: ", ")
            self.lblMarkerPoints.text       = joinedString
            self.lblMarkerPoints.isHidden   = false
        }
    }
}
