//
//  WrappingStackView.swift
//  WrappingStackView
//
//  Created by Domas on 05/04/2017.
//  Copyright © 2017 Trafi. All rights reserved.
//

import UIKit

open class WrappingStackView: UIStackView {
    
    // MARK: Arranged subviews
    
    override open var arrangedSubviews: [UIView] {
        get { return lines.flatMap { $0.arrangedSubviews } }
    }
    
    override open func insertArrangedSubview(_ view: UIView, at stackIndex: Int) {
        guard stackIndex != 0 else {
            lines[0].insertArrangedSubview(view, at: 0)
            return
        }
        
        let index = Int(stackIndex)
        let subviewAtIndex = arrangedSubviews[index]
        guard let line = subviewAtIndex.superview as? Line,
            let lineIndex = line.arrangedSubviews.index(of: subviewAtIndex) else { return }
        
        line.insertArrangedSubview(view, at: lineIndex)
    }
    
    override open func addArrangedSubview(_ view: UIView) {
        lines.last?.addArrangedSubview(view)
    }
    
    override open func removeArrangedSubview(_ view: UIView) {
        (view.superview as? Line)?.removeArrangedSubview(view)
    }
    
    // MARK: Lines
    
    fileprivate var lines: [Line] {
        let nonLineArrangedSubviews = super.arrangedSubviews.filter { !($0 is Line) }
        nonLineArrangedSubviews.forEach { $0.removeFromSuperview() }
        nonLineArrangedSubviews.forEach { addArrangedSubview($0) }
        
        if super.arrangedSubviews.isEmpty { addLine() }
        return super.arrangedSubviews.flatMap { $0 as? Line }
    }
    
    fileprivate func addLine() {
        let line = Line()
        super.addArrangedSubview(line)
        
        line.axis = axis
        line.distribution = distribution
        line.alignment = alignment
        line.spacing = spacing
        line.isBaselineRelativeArrangement = isBaselineRelativeArrangement
        line.delegate = self
    }
    
    // MARK: - Properties
    
    // MARK: Axis
    
    override open var axis: UILayoutConstraintAxis {
        get {
            switch super.axis {
            case .horizontal: return .vertical
            case .vertical:   return .horizontal
            }
        }
        set {
            switch newValue {
            case .horizontal: super.axis = .vertical
            case .vertical:   super.axis = .horizontal
            }
            lines.forEach { $0.axis = newValue }
        }
    }
    
    // MARK: Distribution
    
    override open var distribution: UIStackViewDistribution {
        get { return lines[0].distribution }
        set { lines.forEach { $0.distribution = newValue } }
    }
    public var distributionPerpendicular: UIStackViewDistribution {
        get { return super.distribution }
        set { super.distribution = newValue }
    }
    
    // MARK: Alignment
    
    override open var alignment: UIStackViewAlignment {
        get { return lines[0].alignment }
        set { lines.forEach { $0.alignment = newValue } }
    }
    public var alignementPerpendicular: UIStackViewAlignment {
        get { return super.alignment }
        set { super.alignment = newValue }
    }
    
    // MARK: Spacing
    
    override open var spacing: CGFloat {
        get { return lines[0].spacing }
        set { lines.forEach { $0.spacing = newValue } }
    }
    public var spacingPerpendicular: CGFloat {
        get { return super.spacing }
        set { super.spacing = newValue }
    }
    
    // MARK: IsBaselineRelativeArrangement
    
    override open var isBaselineRelativeArrangement: Bool {
        didSet { lines.forEach { $0.isBaselineRelativeArrangement = isBaselineRelativeArrangement } }
    }
}

// MARK: - WrappingStackViewLineDelegate

extension WrappingStackView: WrappingStackViewLineDelegate {
    
    func wrap(view: UIView, in line: WrappingStackView.Line) {
        guard let lineIndex = lines.index(of: line) else { return }
        if lines.last == line { addLine() }
        
        view.removeFromSuperview()
        lines[lineIndex + 1].insertArrangedSubview(view, at: 0)
        line.layoutIfNeeded()
    }
    
    func useSpace(space: CGFloat, in line: WrappingStackView.Line) {
        guard lines.last != line, let lineIndex = lines.index(of: line) else { return }
        
        let nextLine = lines[lineIndex + 1]
        let nextView = nextLine.arrangedSubviews[0]
        let nextViewSize: CGFloat
        switch axis {
        case .horizontal: nextViewSize = nextView.fittingSize.width
        case .vertical:   nextViewSize = nextView.fittingSize.height
        }
        guard nextViewSize <= space else { return }
        
        nextView.removeFromSuperview()
        line.addArrangedSubview(nextView)
        
        if nextLine.arrangedSubviews.isEmpty { nextLine.removeFromSuperview() }
    }
}
