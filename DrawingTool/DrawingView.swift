
import Foundation
import UIKit

class DrawingView: UIView {

    var drawingColor                                = UIColor.red
    var drawingWidth                                : CGFloat  = 3
    var currentTool                                 : DrawingTool = .none
                
    private var selectionBox                        : UIView?
    private var markerViews                         : [UIView]  = []
    private var lines                               : [Line]    = []
    var selectedLineIDs                             : Set<UUID> = []
    
    let eraserCursor: UIImageView = {
        
        let config                                  = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image                                   = UIImage(systemName: "eraser.line.dashed.fill", withConfiguration: config)
        let imageView                               = UIImageView(image: image)
        imageView.tintColor                         = .white
        imageView.frame                             = CGRect(x: 0, y: 0, width: 30, height: 30)
        imageView.contentMode                       = .scaleAspectFit
        imageView.isHidden                          = true
        return imageView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isMultipleTouchEnabled                      = false
        self.addSubview(eraserCursor)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
       
        isMultipleTouchEnabled                      = false
        self.addSubview(eraserCursor)
    }

    func enableDrawingMode() {
        currentTool                                 = .pen
        endSelectionMode()
    }
    
    func enableEraserMode() {
        currentTool                                 = .eraser
        endSelectionMode()
    }
    
    func startSelectionMode() {
        currentTool                                 = .selection
        selectionBox?.removeFromSuperview()
        selectionBox                                = nil
    }

    func endSelectionMode() {
        selectionBox?.removeFromSuperview()
        selectionBox                                = nil
    }

    func clearAll() {
       
        for view in markerViews {
            
            view.removeFromSuperview()
        }
        markerViews.removeAll()
        lines.removeAll()
        selectedLineIDs.removeAll()
        selectionBox?.removeFromSuperview()
        selectionBox                                = nil
        setNeedsDisplay()
    }

    func addMark(at point: CGPoint) {
       
        let markerSize                              : CGFloat = 30
        let deleteButtonSize                        : CGFloat = 20
        // Container view for the marker and delete button
        let container                               = UIView(frame: CGRect(x: point.x - markerSize / 2,
                                                                           y: point.y - markerSize / 2,
                                                                           width: markerSize,
                                                                           height: markerSize))
        container.backgroundColor                   = .clear
        container.isUserInteractionEnabled          = true
        container.clipsToBounds                     = false  // Allow delete button to show outside bounds
        // Marker image (replace with your actual image name)
        let imageView                               = UIImageView(frame: CGRect(x: 0, y: 0, width: markerSize, height: markerSize))
        imageView.image                             = UIImage(named: "marker")
        imageView.contentMode                       = .scaleAspectFit
        imageView.isUserInteractionEnabled          = false
        container.addSubview(imageView)
        // Delete button
        let deleteButton                            = UIButton(type: .custom)
        deleteButton.frame                          = CGRect(x: markerSize - deleteButtonSize / 2,
                                                             y: -deleteButtonSize / 2,
                                                             width: deleteButtonSize,
                                                             height: deleteButtonSize)
        deleteButton.setTitle("", for: .normal)
        deleteButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        deleteButton.tintColor                      = .white
        deleteButton.clipsToBounds                  = true
        deleteButton.addTarget(self, action: #selector(deleteMarker(_:)), for: .touchUpInside)
        container.addSubview(deleteButton)
        // Pan gesture for dragging marker
        let panGesture                              = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        container.addGestureRecognizer(panGesture)

        addSubview(container)
        markerViews.append(container)
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let point = touches.first?.location(in: self) else { return }

        switch currentTool {

        case .pen:
            let newLine                             = Line(points: [point],
                                                           color: drawingColor,
                                                           width: drawingWidth)
            lines.append(newLine)
            setNeedsDisplay()

        case .eraser:
            eraserCursor.center                     = point
            eraserCursor.isHidden                   = false
            // Immediately call erase to start processing.
            erase(at: point, radius: drawingWidth * 1.5)

        case .marker:
            addMark(at: point)

        case .selection:
            
            if let box = selectionBox, box.frame.contains(point) {
                return
            }
            beginSelection(at: point)

        case .moveSelection:
            finalizeSelectionBox()

        case .none:
            break
        }
    }


    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let point = touches.first?.location(in: self) else { return }

        if currentTool == .eraser {
            
            // Move the eraser cursor.
            eraserCursor.center                     = point
            // Call the eraser function repeatedly as the user moves their finger.
            erase(at: point, radius: drawingWidth * 1.5) // adjust radius as needed
            return
        }
        if currentTool == .selection {
           
            self.updateSelectionBox(to: point)
            return
        }

        if !lines.isEmpty && currentTool == .pen {
            
            lines[lines.count - 1].points.append(point)
            setNeedsDisplay()
            return
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentTool == .eraser {
            
            eraserCursor.isHidden                   = true
            return
        }
        
        if currentTool == .selection {
            self.finalizeSelectionBox()
            //self.addGestureToSelectionBox()
            return
        }
    }

    private func createSelectionBox(at point: CGPoint) -> UIView {
        
        let box                                     = UIView(frame: CGRect(origin: point, size: .zero))
        box.backgroundColor                         = .clear
        let dashed                                  = CAShapeLayer()
        dashed.strokeColor                          = UIColor.white.cgColor
        dashed.lineDashPattern                      = [4, 2]
        dashed.fillColor                            = nil
        dashed.path                                 = UIBezierPath(rect: box.bounds).cgPath
        dashed.frame                                = box.bounds
        box.layer.addSublayer(dashed)
        return box
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        guard let mark = gesture.view else { return }
        
        let translation                             = gesture.translation(in: self)
        mark.center                                 = CGPoint(x: mark.center.x + translation.x, y: mark.center.y + translation.y)
        gesture.setTranslation(.zero, in: self)
    }

    @objc private func deleteMarker(_ sender: UIButton) {
        
        guard let marker = sender.superview else { return }
        marker.removeFromSuperview()
        
        if let index = markerViews.firstIndex(of: marker) {
           
            markerViews.remove(at: index)
        }
    }
    
    func exportAsImage() -> UIImage? {
        
        // Hide selection box before exporting (optional)
        let originalSelectionBoxAlpha               = selectionBox?.alpha
        selectionBox?.alpha                         = 0
        // Render the view into an image
        let format                                  = UIGraphicsImageRendererFormat()
        format.scale                                = UIScreen.main.scale
        format.opaque                               = false
        let renderer                                = UIGraphicsImageRenderer(bounds: bounds,format: format)
        let image = renderer.image { context in
            
            layer.render(in: context.cgContext)
        }
        // Restore selection box visibility
        selectionBox?.alpha                         = originalSelectionBoxAlpha ?? 1
        return image
    }

    func undoLastDrawing() {
       
        if lines.count == 0 { return }
        lines.removeLast()
        setNeedsDisplay()
    }
    
    func getMarkerPointsOnImage() -> [CGPoint] {
        
        return markerViews.compactMap { marker in
            // Convert marker's center to DrawingView's coordinate space (which matches image space)
            return marker.center
        }
    }

    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        // Draw original lines
        for line in lines {
            
            let isSelected = selectedLineIDs.contains(line.id)
            drawLine(line, isSelected: isSelected, in: context)
        }
    }
    
    func drawLine(_ line: Line, isSelected: Bool = false, in context: CGContext) {

        guard line.points.count > 1 else {
            return
        }

        context.setStrokeColor(line.color.cgColor)
        context.setLineWidth(isSelected ? line.width + 2 : line.width)
        context.setLineCap(.round)
        context.beginPath()
        context.move(to: line.points[0])

        for point in line.points.dropFirst() {
            
            context.addLine(to: point)
        }
        context.strokePath()
    }

    func erase(at point: CGPoint, radius: CGFloat) {

        var updatedLines: [Line] = []
        var updatedSelectedIDs: Set<UUID> = []

        for line in lines {

            let erasedSegments = eraseSegments(from: line, around: point, radius: radius)
            updatedLines.append(contentsOf: erasedSegments)

            // Preserve selection state for split segments
            if selectedLineIDs.contains(line.id) {

                erasedSegments.forEach {
                    updatedSelectedIDs.insert($0.id)
                }
            }
        }

        lines = updatedLines
        selectedLineIDs = updatedSelectedIDs
        setNeedsDisplay()
    }


    func segmentIntersectsCircle(p1: CGPoint, p2: CGPoint, center: CGPoint, radius: CGFloat) -> Bool {
        
        let d                                       = distanceFromPointToSegment(point: center,
                                                                                 segmentStart: p1,
                                                                                 segmentEnd: p2)
        return d <= radius
    }

    func distanceFromPointToSegment(point: CGPoint, segmentStart: CGPoint, segmentEnd: CGPoint) -> CGFloat {
       
        let dx                                      = segmentEnd.x - segmentStart.x
        let dy                                      = segmentEnd.y - segmentStart.y

        if dx == 0 && dy == 0 {
            // Start and end are the same point
            return hypot(point.x - segmentStart.x, point.y - segmentStart.y)
        }

        let t                                       = max(0, min(1,
                                                                 ((point.x - segmentStart.x) * dx + (point.y - segmentStart.y) * dy) /
                                                                 (dx * dx + dy * dy)))
        let projX                                   = segmentStart.x + t * dx
        let projY                                   = segmentStart.y + t * dy
        return hypot(point.x - projX, point.y - projY)
    }


    func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
       
        return hypot(p1.x - p2.x, p1.y - p2.y)
    }
    
    private func updateEraserCursor(at point: CGPoint) {
       
        eraserCursor.center                         = point
        setNeedsDisplay()
    }
    
    func beginSelection(at startPoint: CGPoint) {
        
        let box                                     = UIView(frame: CGRect(origin: startPoint, size: .zero))
        let dashedBorder                            = CAShapeLayer()
        dashedBorder.strokeColor                    = UIColor.white.cgColor
        dashedBorder.lineDashPattern                = [6, 3] // 6pt line, 3pt gap
        dashedBorder.fillColor                      = UIColor.clear.cgColor
        dashedBorder.lineWidth                      = 2
        dashedBorder.name                           = "dashedBorder"
        box.layer.addSublayer(dashedBorder)
        addSubview(box)
        selectionBox                                = box
    }
    
    func updateSelectionBox(to currentPoint: CGPoint) {
       
        guard let box = selectionBox else { return }

        let startPoint                              = box.frame.origin
        let width                                   = currentPoint.x - startPoint.x
        let height                                  = currentPoint.y - startPoint.y
        box.frame                                   = CGRect(x: startPoint.x,
                                                             y: startPoint.y,
                                                             width: width,
                                                             height: height)
        // Update dashed border shape
        if let dashedBorder = box.layer.sublayers?.first(where: { $0.name == "dashedBorder" }) as? CAShapeLayer {
            
            dashedBorder.path                       = UIBezierPath(rect: box.bounds).cgPath
            dashedBorder.frame                      = box.bounds
        }
    }

    func finalizeSelectionBox() {

        guard let box = selectionBox else { return }
        selectedLineIDs.removeAll()

        // Build a precise UIBezierPath from selection box
        let selectionRect = box.frame.standardized

        for line in lines {

            let intersects = line.points.contains {
                selectionRect.contains($0)
            }

            if intersects {
                selectedLineIDs.insert(line.id)
            }
        }

        if box.gestureRecognizers?.isEmpty ?? true {

            let pan = UIPanGestureRecognizer(target: self, action: #selector(handleSelectedGroupPan(_:)))
            box.addGestureRecognizer(pan)
        }
        setNeedsDisplay()
    }
   
    @objc func handleSelectedGroupPan(_ gesture: UIPanGestureRecognizer) {
       
        guard currentTool == .moveSelection else { return }

        let translation                             = gesture.translation(in: self)
        gesture.setTranslation(.zero, in: self)

        // Loop using indices so we can mutate selectedSegments
        for index in lines.indices {

            guard selectedLineIDs.contains(lines[index].id) else {
                continue
            }

            for pointIndex in lines[index].points.indices {

                lines[index].points[pointIndex].x += translation.x
                lines[index].points[pointIndex].y += translation.y
            }
        }
        if let box = selectionBox {
            
            box.center                              = CGPoint(x: box.center.x + translation.x,
                                                              y: box.center.y + translation.y)
        }
        setNeedsDisplay()
    }
}
extension DrawingView {
    
    private func eraseSegments(from line: Line, around point: CGPoint, radius: CGFloat) -> [Line] {

        guard line.points.count > 1 else {
            return [line]
        }

        var newLines: [Line] = []
        var currentPoints: [CGPoint] = []

        let points = line.points

        for i in 0..<points.count - 1 {

            let p1 = points[i]
            let p2 = points[i + 1]

            if segmentIntersectsCircle(p1: p1, p2: p2, center: point, radius: radius) {

                if currentPoints.count > 1 {

                    newLines.append(Line(points: currentPoints, color: line.color, width: line.width))
                }
                currentPoints = []
            }
            else {

                if currentPoints.isEmpty {
                    currentPoints.append(p1)
                }
                currentPoints.append(p2)
            }
        }
        if currentPoints.count > 1 {

            newLines.append(Line(points: currentPoints, color: line.color, width: line.width))
        }
        return newLines
    }
}


