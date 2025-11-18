//
//  ColorPicker.swift
//  Energy Stats
//
//  Created by Alistair Priest on 11/11/2025.
//

import SwiftUI
import UIKit

struct UIKitColorPicker: UIViewControllerRepresentable {
    @Binding var color: UIColor
    var supportsAlpha: Bool = true
    var onDismiss: (() -> Void)? = nil

    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let picker = UIColorPickerViewController()
        picker.delegate = context.coordinator
        picker.supportsAlpha = supportsAlpha
        picker.selectedColor = color
        return picker
    }

    func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) {
        uiViewController.selectedColor = color
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        var parent: UIKitColorPicker

        init(_ parent: UIKitColorPicker) {
            self.parent = parent
        }

        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            parent.color = viewController.selectedColor
        }

        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            parent.onDismiss?()
        }
    }
}

struct GraphVariableColourIndicator: View {
    let color: Color

    var body: some View {
        Circle()
            .foregroundColor(color)
            .frame(width: 15, height: 15)
    }
}
