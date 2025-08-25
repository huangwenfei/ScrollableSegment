//
//  ScrollableSegmentViewConfiguration.swift
//  ScrollableSegment
//
//  Created by windy on 2025/8/24.
//

import UIKit

public struct ScrollableSegmentViewConfiguration {
    
    // MARK: Properties
    public var count: Int = 0
    public var current: Int = 0
    
    public var itemSize: CGSize = .init(width: 50, height: 44)
    public var itemSpacing: CGFloat = 16
    public var itemOffset: CGFloat = 18
    
    public var itemScaleFactor: CGFloat = 1.0
    
    public var isShowMarkItem: Bool = true
    public var selectedMarkCornerRadius: CGFloat = 8
    public var selectedMarkColor: UIColor = .init(
        hue: 163/360.0, saturation: 31/100.0, brightness: 18/100.0, alpha: 1
    )
    
    public var selectedMarkOffsetY: CGFloat = 0
    
    // MARK: Init
    public init(
        count: Int = 0,
        current: Int = 0
    ) {
        self.count = count
        self.current = current
    }
    
}
