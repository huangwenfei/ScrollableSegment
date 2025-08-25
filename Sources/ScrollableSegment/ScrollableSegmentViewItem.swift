//
//  ScrollableSegmentViewItem.swift
//  ScrollableSegment
//
//  Created by windy on 2025/8/24.
//

import UIKit

public protocol ScrollableSegmentViewItem: UIView {
    var isSelected: Bool { get set }
    var segmentIndex: Int { get set }
    
    func progress(_ value: CGFloat)
    func scaleProgress(_ value: CGFloat)
}

extension ScrollableSegmentViewItem {
    
    public func progress(_ value: CGFloat) {
        alpha = max(0.5, value)
    }
    
    public func scaleProgress(_ value: CGFloat) {
        transform = .init(scaleX: value, y: value)
    }
    
}


private struct ScrollableSegmentViewItemKeys {
    static var isSelected: UInt8 = 0
    static var segmentIndex: UInt8 = 1
}

extension ScrollableSegmentViewItem {
    public var isSelected: Bool {
        get {
            guard
                let value = objc_getAssociatedObject(self, &ScrollableSegmentViewItemKeys.isSelected) as? Bool
            else {
                return false
            }
            
            return value
        }
        set {
            objc_setAssociatedObject(
                self,
                &ScrollableSegmentViewItemKeys.isSelected,
                NSNumber(value: newValue),
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    public var segmentIndex: Int {
        get {
            guard
                let value = objc_getAssociatedObject(self, &ScrollableSegmentViewItemKeys.segmentIndex) as? Int
            else {
                return 0
            }
            
            return value
        }
        set {
            objc_setAssociatedObject(
                self,
                &ScrollableSegmentViewItemKeys.segmentIndex,
                NSNumber(value: newValue),
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
