//
//  ViewController.swift
//  SS-Example
//
//  Created by windy on 2025/8/25.
//

import UIKit
import Yang

import ScrollableSegment

enum Index: Int, Hashable, CaseIterable {
    case item1, item2, item3
    
    public var preview: Self? {
        let value = self.rawValue - 1
        return .init(rawValue: value)
    }
    
    public var next: Self? {
        let value = self.rawValue + 1
        return .init(rawValue: value)
    }
    
    public var loopPreview: Self {
        let value = self.rawValue - 1
        return .init(rawValue: value) ?? .item3
    }
    
    public var loopNext: Self {
        let value = self.rawValue + 1
        return .init(rawValue: value) ?? .item1
    }
    
    public var title: String {
        switch self {
        case .item1: return "Item One"
        case .item2: return "Item Two"
        case .item3: return "Item Three"
        }
    }
}

class ViewController: UIViewController {
    
    public lazy var segment: ScrollableSegmentView = .init(
        frame: .zero,
        configuration: {
            var configs = ScrollableSegmentViewConfiguration(count: Index.allCases.count)
            configs.itemOffset = 16
            configs.itemSpacing = 8
            configs.itemScaleFactor = 1.15
            configs.isShowMarkItem = false
            return configs
        }()
    ) { configs, index in
        let factor = configs.itemScaleFactor
        let view = ScrollableSegmentTextItem()
        view.set(
            text: Index(rawValue: index)!.title,
            font: .systemFont(ofSize: 18 * factor, weight: .semibold)
        )
        return view
    } itemWidthProvider: { segment, item in
        item.size().width
    } currentChange: { [weak self] segment, old, new in
        print(#function, #line, old, new)
    }
    
    public var mode: Index {
        get { .init(rawValue: segment.currentMode) ?? .item1 }
        set { segment.currentMode = newValue.rawValue }
    }
    
    var timer: Timer?
    var progress: CGFloat = 0

    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .darkGray
        
        segment.yang.addToParent(view)
        segment.selectedMode(mode.rawValue)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.setNeedsUpdateConstraints()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let interval = 0.05
        timer = .scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self else { return }
            let tendTo = self.mode.loopNext
            self.segment.progress(self.progress, tendToMode: tendTo.rawValue)
            self.progress += interval * 0.4
            if self.progress > 1 {
                self.progress = 0
                self.mode = self.mode.loopNext
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        timer = nil
    }
    
    override func updateViewConstraints() {
        
        segment.yangbatch.remake { make in
            make.horizontal.equalToParent().offsetEdge(16)
            make.height.equal(to: 44)
            make.top.equalToParent(.topMargin).offset(20)
        }
        
        super.updateViewConstraints()
    }


}

