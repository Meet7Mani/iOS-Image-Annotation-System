
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

    @IBAction func btnAddMark(_ sender: UIButton) {
        
        drawingView.endSelectionMode()
        drawingView.isSelectionMovementMode = false
        drawingView.isEraserEnabled         = false
        drawingView.isAddingMarker          = true
        drawingView.isDrawingEnabled        = false
    }
    
    @IBAction func btnAddLine(_ sender: UIButton) {
        
        drawingView.isSelectionMovementMode = false
        drawingView.isEraserEnabled         = false
        drawingView.isAddingMarker          = false
        drawingView.endSelectionMode()
        drawingView.enableDrawingMode()
    }
    
    @IBAction func btnClear(_ sender: UIButton) {
        
        drawingView.isSelectionMovementMode = false
        drawingView.clearAll()
    }
    @IBAction func btnSelection(_ sender: UIButton) {
        
        drawingView.isSelectionMovementMode = false
        drawingView.isEraserEnabled         = false
        drawingView.isAddingMarker          = false
        drawingView.isDrawingEnabled        = false
        drawingView.startSelectionMode()
    }
    @IBAction func btnUndo(_ sender: UIButton) {
        
        drawingView.isSelectionMovementMode = false
        drawingView.undoLastDrawing()
    }
    @IBAction func btnEraser(_ sender: UIButton) {
        
        drawingView.isSelectionMovementMode = false
        drawingView.enableEraserMode()
    }
    
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
    
    @IBAction func btnMove(_ sender: UIButton) {
        
        drawingView.isEraserEnabled         = false
        drawingView.isAddingMarker          = false
        drawingView.isDrawingEnabled        = false
        drawingView.isSelectionMode         = false
        drawingView.isSelectionMovementMode = true
    }
}
