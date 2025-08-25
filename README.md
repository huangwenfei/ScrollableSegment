
# ScrollableSegment

A segmented control that supports scrolling and progress control.

# Installation

```swift
dependencies: [
    .package(url: "https://github.com/huangwenfei/ScrollableSegment.git", .upToNextMajor(from: "0.0.2"))
]
```

# Usage

![Normal](https://github.com/user-attachments/assets/2642f9f4-6014-4d8d-a0eb-7eda1a7ccddb)
![Progress](https://github.com/user-attachments/assets/66f76ef1-70d7-49ac-bdf9-a4ec210bd56f)

Normal:

```swift
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
```

```swift
public enum Index: Int, Hashable, CaseIterable {
    case item1, item2, item3
    
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
```

Progress Controll:

```swift
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
```
