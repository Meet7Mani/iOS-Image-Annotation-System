
import Foundation
import UIKit

class CustomColorPickerView: UIView {

    let colorHexes                                                  : [String]
    var onColorPicked                                               : ((UIColor) -> Void)?

    init(colorHexes: [String]) {
       
        self.colorHexes                                             = colorHexes
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        
        let stack                                                   = UIStackView()
        stack.axis                                                  = .vertical
        stack.spacing                                               = 8
        stack.translatesAutoresizingMaskIntoConstraints             = false
        let itemsPerRow                                             = 7
        let rows = stride(from: 0, to: colorHexes.count, by: itemsPerRow).map {
           
            Array(colorHexes[$0..<min($0 + itemsPerRow, colorHexes.count)])
        }
        for row in rows {
            
            let rowStack                                            = UIStackView()
            rowStack.axis                                           = .horizontal
            rowStack.spacing                                        = 8
            rowStack.distribution                                   = .fillEqually

            for hex in row {
                
                guard let color = UIColor(hex: hex) else { continue }
                let button                                          = UIButton(type: .custom)
                button.backgroundColor                              = color
                button.layer.cornerRadius                           = 4
                button.layer.borderWidth                            = 1
                button.layer.borderColor                            = UIColor.black.withAlphaComponent(0.1).cgColor
                button.heightAnchor.constraint(equalToConstant: 32).isActive = true
                button.accessibilityLabel                           = hex
                button.addTarget(self, action: #selector(colorTapped(_:)), for: .touchUpInside)
                rowStack.addArrangedSubview(button)
            }
            stack.addArrangedSubview(rowStack)
        }
        backgroundColor                                             = .white
        layer.cornerRadius                                          = 10
        layer.borderColor                                           = UIColor.gray.withAlphaComponent(0.3).cgColor
        layer.borderWidth                                           = 1
        layer.shadowColor                                           = UIColor.black.cgColor
        layer.shadowOpacity                                         = 0.1
        layer.shadowOffset                                          = CGSize(width: 0, height: 4)
        layer.shadowRadius                                          = 8
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }

    @objc private func colorTapped(_ sender: UIButton) {
       
        guard let hex = sender.accessibilityLabel, let selectedColor = UIColor(hex: hex) else {
            return
        }
        onColorPicked?(selectedColor)
    }
}

extension UIColor {
    
    ///To Converting hex to UIColor
    convenience init?(hex: String) {
       
        var hexSanitized                                            = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            
            hexSanitized.removeFirst()
        }
        guard hexSanitized.count == 6 else { return nil }
        var rgb                                                     : UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r                                                       = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g                                                       = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b                                                       = CGFloat(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

