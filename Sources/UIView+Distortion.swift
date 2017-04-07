//
//  UIView+Distortion.swift
//  WrappingStackView
//
//  Created by Domas on 05/04/2017.
//  Copyright © 2017 Trafi. All rights reserved.
//

import UIKit

extension UIView {
    var fittingSize: CGSize {
        return systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    func stretch(in axis: UILayoutConstraintAxis) -> CGFloat {
        return frame.dimension(for: axis) - fittingSize.dimension(for: axis)
    }
    func isCompressed(in axis: UILayoutConstraintAxis) -> Bool {
        return fittingSize.dimension(for: axis) > frame.dimension(for: axis)
    }
}

extension CGRect {
    func dimension(for axis: UILayoutConstraintAxis) -> CGFloat {
        return size.dimension(for: axis)
    }
}

extension CGSize {
    func dimension(for axis: UILayoutConstraintAxis) -> CGFloat {
        switch axis {
        case .horizontal: return width
        case .vertical:   return height
        }
    }
}
