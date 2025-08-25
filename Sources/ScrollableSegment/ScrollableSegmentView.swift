//
//  ScrollableSegmentView.swift
//  ScrollableSegment
//
//  Created by windy on 2025/8/24.
//

import UIKit

open class ScrollableSegmentView<Item: ScrollableSegmentViewItem>: UIView {
    
    // MARK: Types
    public typealias ItemProvider = (_ configs: ScrollableSegmentViewConfiguration, _ index: Int) -> Item
    public typealias ItemWidthProvider = (_ view: ScrollableSegmentView, _ item: Item) -> CGFloat
    public typealias MarkItemProvider = (_ view: ScrollableSegmentView) -> UIView
    public typealias CurrentChange = (_ view: ScrollableSegmentView, _ old: Int, _ new: Int) -> Void
    
    // MARK: Properties
    public lazy var container: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.alwaysBounceHorizontal = true
        view.alwaysBounceVertical = false
        return view
    }()
    
    public var itemProvider: ItemProvider = { _,_ in .init() }
    
    public var itemWidthProvider: ItemWidthProvider = { _, item in
        item.sizeToFit()
        return item.frame.width
    }
    
    public var markItemProvider: MarkItemProvider? = nil
    
    public var currentChange: CurrentChange = { _,_,_ in }
    
    open private(set) var items: [Item] = []
    
    private var selectedRects: [Int: CGRect] = .init()
    private lazy var selectedMarkView: UIView = {
        if let mark = markItemProvider?(self) {
            return mark
        } else {
            let result = UIView()
            result.backgroundColor = configuration.selectedMarkColor
            result.layer.cornerRadius = configuration.selectedMarkCornerRadius
            return result
        }
    }()
    
    public var count: Int {
        get { configuration.count }
        set {
            configuration.count = newValue
            initItems()
            layoutItems()
            change(by: currentMode, isAnimated: false, ignoreCurrentChange: true)
        }
    }
    
    public var currentMode: Int {
        get { configuration.current }
        set {
            configuration.current = newValue
            change(by: newValue, isAnimated: false, ignoreCurrentChange: true)
        }
    }
    
    public var configuration: ScrollableSegmentViewConfiguration
    
    // MARK: Init
    public init(
        frame: CGRect = .zero,
        configuration: ScrollableSegmentViewConfiguration,
        itemProvider: @escaping ItemProvider = { _,_ in .init() },
        itemWidthProvider: @escaping ItemWidthProvider = { _, item in
            item.sizeToFit()
            return item.frame.width
        },
        markItemProvider: MarkItemProvider? = nil,
        currentChange: @escaping CurrentChange = { _,_,_ in }
    ) {
        self.configuration = configuration
        self.itemProvider = itemProvider
        self.itemWidthProvider = itemWidthProvider
        self.markItemProvider = markItemProvider
        self.currentChange = currentChange
        super.init(frame: frame)
        commit()
    }
    
    public required init?(coder: NSCoder) {
        self.configuration = .init()
        super.init(coder: coder)
        commit()
    }
    
    open func commit() {
        addSubview(container)
        initItems()
        addGestureRecognizer({
            let tap = UITapGestureRecognizer()
            tap.addTarget(self, action: #selector(tapAction(sender:)))
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            return tap
        }())
    }
    
    deinit {
        itemProvider = { _,_ in .init() }
        itemWidthProvider = { _,_ in .zero }
        markItemProvider = nil
        currentChange = { _,_,_ in }
    }
    
    // MARK: Layout
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutItems()
        
        container.frame = bounds
        container.contentSize = .init(
            width: items.last?.frame.maxX ?? .zero,
            height: frame.height
        )
    }
    
    // MARK: Progress
    public func progress(_ factor: CGFloat, tendToMode: Int) {
        guard
            let current = self.items.first(where: { $0.segmentIndex == currentMode }),
            let other = self.items.first(where: { $0.segmentIndex == tendToMode })
        else {
            return
        }
        
        /// factor : -1 ... 0 ... 1
        
//        current.alpha = max(0.5, 1 - abs(factor))
//        other.alpha = max(0.5, abs(factor))
        
        let currentFactor = 1 - abs(factor)
        current.progress(currentFactor)
        
        let otherFactor = abs(factor)
        other.progress(otherFactor)
        
        
        let itemFactor = configuration.itemScaleFactor
        let minFactor = min(1, 1 / itemFactor)
        let maxFactor = max(1, 1 / itemFactor)
        let scaleLenght = maxFactor - minFactor
        
        let currentScaleFactor = maxFactor - (1 - currentFactor) * scaleLenght
        current.scaleProgress(currentScaleFactor)
        
        let otherScaleFactor = maxFactor - (1 - otherFactor) * scaleLenght
        other.scaleProgress(otherScaleFactor)
        
//        print(#function, #line, minFactor, maxFactor, (currentFactor, currentScaleFactor), (otherFactor, otherScaleFactor))
        
        guard configuration.isShowMarkItem else { return }
        
        let endRect = selectedTransX(tendToMode)
        let currentRect = selectedTransX(current.segmentIndex)
        
        let endOffsetX = endRect.minX
        let currentOffsetX = currentRect.minX
        
        let endWidth = endRect.width
        let currentWidth = currentRect.width
        
        let flag: CGFloat = factor > 0 ? -1 : 1
        
        let rect = CGRect(
            x: currentOffsetX - flag * (endOffsetX - currentOffsetX) * factor,
            y: endRect.minY,
            width: currentWidth - flag * (endWidth - currentWidth) * factor,
            height: endRect.height
        )
        
        self.selectedMarkView.frame = rect
    }
    
    /// - Tag: Segment
    private func initItems() {
        
        /// - Tag: Crear
        items.forEach({ $0.removeFromSuperview() })
        selectedMarkView.removeFromSuperview()
        
        /// - Tag: Add
        func item(mode: Int) -> Item {
            let item = itemProvider(configuration, mode)
            item.isSelected = false
            item.segmentIndex = mode
            return item
        }
        
        (0 ..< configuration.count).forEach { mode in
            let item = item(mode: mode)
            container.addSubview(item)
            items.append(item)
        }
        
        if configuration.isShowMarkItem {
            container.insertSubview(selectedMarkView, at: 0)
        }
        
    }
    
    private func layoutItems() {
        let height = configuration.itemSize.height
        let spacing = configuration.itemSpacing
        let offset = configuration.itemOffset
        
        selectedRects = [:]
        
        func setItemFrame(item: Item, preview: Item?, mode: Int) {
            let width = itemWidthProvider(self, item)
            item.frame.origin.x = (preview?.frame.maxX ?? 0) + (preview != nil ? spacing : offset )
            item.frame.size.width = width
            item.frame.size.height = height
        }
        
        var preview: Item? = nil
        items.forEach { item in
            let mode = item.segmentIndex
            setItemFrame(item: item, preview: preview, mode: mode)
            selectedRects[mode] = item.frame
            preview = item
        }
        
        change(by: currentMode, isAnimated: true, ignoreCurrentChange: true)
        
    }
    
    public func selectedMode(_ mode: Int) {
        change(by: mode, ignoreCurrentChange: false)
    }
    
    /// - Tag: Action
    @objc private func tapAction(sender: UITapGestureRecognizer) {
        
        let position = sender.location(in: self)
        let tapItems = items.filter { item in
            let point = convert(position, to: item)
            return item.layer.contains(point)
        }
        
        guard let tapItem = tapItems.first else {
            return
        }
        
        let currentMode = tapItem.segmentIndex
        change(by: currentMode, ignoreCurrentChange: false)
        
    }
    
    private func selectedTransX(_ mode: Int) -> CGRect {
        var rect = selectedRects[mode] ?? .zero
        rect.origin.x -= configuration.itemSpacing * 0.5
        rect.origin.y += configuration.selectedMarkOffsetY
        rect.size.width += configuration.itemSpacing
        return rect
    }
    
    private func change(by mode: Int, isAnimated: Bool = true, ignoreCurrentChange: Bool) {
        
        var selected: Item? = nil
        
        let factor = configuration.itemScaleFactor
        let scale = CGAffineTransform(scaleX: 1 / factor, y: 1 / factor)
        
        items.forEach({ item in
            
            item.isSelected = item.segmentIndex == mode
            item.progress(0.5)
            item.transform = scale
            
            if item.isSelected { selected = item }
            
        })
        
        if isAnimated {
            UIView.animate(withDuration: 0.25) {
                selected?.progress(1)
                selected?.transform = .identity
                if self.configuration.isShowMarkItem {
                    self.selectedMarkView.frame = self.selectedTransX(mode)
                }
            }
        } else {
            selected?.progress(1)
            selected?.transform = .identity
            if configuration.isShowMarkItem {
                self.selectedMarkView.frame = self.selectedTransX(mode)
            }
        }
        
        if configuration.isShowMarkItem {
            print(#function, #line, mode, selectedMarkView.frame)
        }
        
        guard ignoreCurrentChange == false else { return }
        
        let old = self.currentMode
        self.currentMode = mode
        self.currentChange(self, old, mode)
    }
    
}
