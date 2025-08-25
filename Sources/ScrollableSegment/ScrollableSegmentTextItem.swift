//
//  ScrollableSegmentTextItem.swift
//  ScrollableSegment
//
//  Created by windy on 2025/8/24.
//

import UIKit

open class ScrollableSegmentTextItem: UIView, ScrollableSegmentViewItem {
    
    // MARK: Properties
    open lazy var title: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = .systemFont(ofSize: 14)
        view.textAlignment = .center
        return view
    }()
    
    // MARK: Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commit()
    }
    
    open func commit() {
        addSubview(title)
    }
    
    // MARK: Layout
    open override func layoutSubviews() {
        super.layoutSubviews()
        title.frame = bounds
    }
    
    // MARK: Text
    open func set(text: NSAttributedString) {
        title.attributedText = text
    }
    
    open func set(attributedText text: String, font: UIFont, color: UIColor  = .white, kerning: CGFloat = 0.5) {
        title.attributedText = NSAttributedString(string: text, attributes: [
            .foregroundColor: color,
            .kern: NSNumber(value: kerning),
            .font: font
        ])
    }
    
    open func set(text: String) {
        title.attributedText = nil
        title.text = text
    }
    
    open func set(text: String, font: UIFont, color: UIColor = .white) {
        title.attributedText = nil
        title.font = font
        title.textColor = color
        title.text = text
    }
    
    // MARK: Size
    open func size() -> CGSize {
        
        if let text = title.attributedText {
            return text.size()
        }
        
        guard let text = title.text else { return .zero }
        
        return NSAttributedString(string: text, attributes: [
            .foregroundColor: title.textColor!,
            .font: title.font!
        ])
        .size()
        
    }
    
}
