# 🖌️ iOS Image Annotation System (Swift)

A powerful and reusable **image annotation system for iOS** built with Swift.
Supports drawing, selection, movement, markers, and coordinate export — designed for real-world apps.

---

## 🚀 Features

* ✏️ Freehand drawing on images
* 📍 Add markers with draggable support
* 🔲 Select annotations using bounding box
* ↔️ Move selected drawings
* 🧽 Eraser with segment-level precision
* 🖼️ Export annotated image
* 📦 Export marker coordinates
* 🎨 Custom color picker support

---

## 📱 Demo

![Image Annotation Demo](./image-annotation-demo.png)

---

## 🧠 How It Works

The system is divided into modular components:

### 🔹 Drawing Engine

Handles touch input, line rendering, and erasing logic.

### 🔹 Selection System

Allows selecting drawn segments using a bounding box and moving them.

### 🔹 Marker System

Supports adding and dragging markers across the image.

### 🔹 Export Layer

* Converts drawing into an image
* Extracts coordinates for backend usage

---

## ⚙️ Usage

### 1. Setup

Add a `DrawingView` to your view controller:

```swift
@IBOutlet weak var drawingView: DrawingView!
```

---

### 2. Switch Modes

```swift
drawingView.enableDrawingMode()
drawingView.enableEraserMode()
drawingView.startSelectionMode()
```

---

### 3. Export Data

```swift
// Export image
let image = drawingView.exportAsImage()

// Export marker points
let points = drawingView.getMarkerPointsOnImage()
```

---

## 🎨 Color Picker

Includes a reusable hex-based color picker:

```swift
let picker = CustomColorPickerView(colorHexes: ["#FF0000", "#00FF00"])

picker.onColorPicked = { color in
    drawingView.drawingColor = color
}
```

---

## ⚠️ Improvement Note

Currently, drawing behavior is controlled using multiple flags:

* `isDrawingEnabled`
* `isEraserEnabled`
* `isSelectionMode`
* `isSelectionMovementMode`

👉 For better scalability, this can be replaced with a single mode-based approach:

```swift
enum DrawingMode {
    case draw
    case marker
    case eraser
    case selection
    case move
}
```

This avoids conflicting states and improves maintainability.

---

## 💡 Use Cases

* Inspection apps (mark damaged areas)
* Delivery/photo verification
* Image annotation tools
* AI/ML preprocessing

---

## 🔗 Medium Article

Read full explanation here:
👉 https://medium.com/@manpreet.s_92558/build-an-image-annotation-system-in-ios-draw-select-move-export-coordinates-00b319ec870e

---

## 🛠 Tech Stack

* Swift
* UIKit
* Core Graphics
* Touch Handling

---

## ✍️ Author

Built with 💙 by Manpreet Singh
