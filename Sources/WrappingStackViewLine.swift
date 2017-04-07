//
//  WrappingStackViewLine.swift
//  WrappingStackView
//
//  Created by Domas on 05/04/2017.
//  Copyright © 2017 Trafi. All rights reserved.
//

import UIKit

// MARK: - WrappingStackViewLineDelegate

protocol WrappingStackViewLineDelegate: class {
    func wrap(view: UIView, in line: WrappingStackView.Line)
    func useSpace(space: CGFloat, in line: WrappingStackView.Line)
}

// MARK: - WrappingStackView.Line

extension WrappingStackView {
    final class Line: UIStackView {
        
        // MARK: Delegate
        
        weak var delegate: WrappingStackViewLineDelegate?
        
        var availableSpaceForExtraItem: CGFloat {
            return availableSpace - spacing
        }
        
        private var availableSpace: CGFloat {
            guard let superview = superview else { return 0 }
        
            let sizeDifference = superview.frame.dimension(for: axis) - frame.dimension(for: axis)
            guard sizeDifference == 0 else { return sizeDifference }
        
            let subviewsStretch = arrangedSubviews.reduce(0) { $0.0 + $0.1.stretch(in: axis) }
            switch distribution {
            case .fill, .fillEqually, .fillProportionally:
                return subviewsStretch
            case .equalSpacing, .equalCentering:
                let naturalSpacing = spacing * CGFloat(arrangedSubviews.count - 1)
                let actualSpacing = frame.dimension(for: axis) - arrangedSubviews.reduce(0) { $0.0 + $0.1.frame.dimension(for: axis) }
                let spacingStretch =  actualSpacing - naturalSpacing
                return subviewsStretch + spacingStretch
            }
        }
        
        private var needsWrapping: Bool {
            return nil != arrangedSubviews.first { $0.isCompressed(in: axis) }
        }
        
        private func updateDelegate() {
            if needsWrapping, let view = arrangedSubviews.last {
                delegate?.wrap(view: view, in: self)
            } else {
                delegate?.useSpace(space: availableSpaceForExtraItem, in: self)
            }
        }
        
        // MARK: Overrides
        
        override func layoutSubviews() {
            super.layoutSubviews()
            updateDelegate()
        }
    }
}
