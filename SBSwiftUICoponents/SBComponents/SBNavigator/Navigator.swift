//
//  Navigator.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/10/8.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import SBComponents
import PPBadgeViewSwift

/// callback
public typealias NavigatorCallback = (Int, Int)->Void   //current/previous

/// defines
fileprivate let NavigatorTagStart: Int = 100
fileprivate let NavigatorFlagScale: CGFloat = 0.75
fileprivate let NavigatorColorNormal = AppColor.COLOR_TITLE_GRAY
fileprivate let NavigatorColorSelect = AppColor.COLOR_THEME

// MARK: - 固定宽度navigator
public class FixedNavigator: BaseScene {
    
    /// Callbacks
    public var callback: NavigatorCallback?
    
    /// Variables
    private var itemTitles: [String]?
    private var curIndex: Int = 0
    private var availableWidth: CGFloat = AppSize.WIDTH_SCREEN
    private var itemWidth: CGFloat = 0
    private var itemHeight: CGFloat = 0
    
    /// Lazy Vars
    private lazy var scroller: BaseScrollView = {
        let s = BaseScrollView(frame: .zero)
        s.bounces = true
        s.isPagingEnabled = false
        s.showsVerticalScrollIndicator = false
        s.showsHorizontalScrollIndicator = false
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    private lazy var layouter: BaseScene = {
        let s = BaseScene(frame: .zero)
        //s.backgroundColor = UIColor.sb_random()
        return s
    }()
    private lazy var flager: BaseScene = {
        let f = BaseScene(frame: .zero)
        f.backgroundColor = NavigatorColorSelect
        return f
    }()
    private lazy var itemBtns: [BaseButton] = {
        let s = [BaseButton]()
        return s
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public class func navigator(_ titles: [String]?, available width: CGFloat=AppSize.WIDTH_SCREEN, defaultSelect index:Int=0) -> FixedNavigator {
        return FixedNavigator(titles, available: width, defaultSelect: index)
    }
    private init(_ titles: [String]?, available width: CGFloat=AppSize.WIDTH_SCREEN, defaultSelect index: Int=0) {
        super.init(frame: .zero)
        itemTitles = titles
        availableWidth = width
        curIndex = index
        
        addSubview(scroller)
        scroller.addSubview(layouter)
        __reInitNavigatorSubviews()
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        scroller.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        layouter.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        var lastMargin: BaseButton?;let counts = itemBtns.count
        for (idx, item) in itemBtns.enumerated() {
            item.snp.remakeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(itemWidth)
                //make.height.equalTo(itemHeight)
                if let ref = lastMargin {
                    make.left.equalTo(ref.snp.right).offset(HorizontalOffset)
                } else {
                    make.left.equalToSuperview().offset(HorizontalOffsetMAX)
                }
                if idx == counts-1 {
                    make.right.equalToSuperview().offset(-HorizontalOffsetMAX)
                }
            }
            lastMargin = item
        }
    }
    private func __reInitNavigatorSubviews() {
        guard let titles = itemTitles else {
            debugPrint("got an empty titles for navigator")
            return
        }
        let counts = titles.count; itemBtns.removeAll()
        let reallyWidth = availableWidth - HorizontalOffset*2 - HorizontalOffset * CGFloat(counts-1)
        itemWidth = floor(reallyWidth / CGFloat(counts))
        itemHeight = AppSize.HEIGHT_NAVIGATIONBAR
        let font = AppFont.pingFangMedium(AppFont.SIZE_TITLE+1)
        //var lastMargin: BaseButton?
        for (idx, t) in titles.enumerated() {
            let fontColor = (idx == curIndex) ? NavigatorColorSelect : NavigatorColorNormal
            let item = BaseButton(type: .custom)
            item.tag = NavigatorTagStart + idx
            item.titleLabel?.font = font
            item.titleLabel?.adjustsFontSizeToFitWidth = true
            item.setTitleColor(fontColor, for: .normal)
            item.setTitle(t, for: .normal)
            //item.backgroundColor = UIColor.sb_random()
            item.addTarget(self, action: #selector(didTouchItem(_:)), for: .touchUpInside)
            layouter.addSubview(item)
            /// weak ref
            weak var ref = item
            itemBtns.append(ref!)
        }
        layouter.addSubview(flager)
        layoutIfNeeded()
    }
    
    /// events
    private func fetchCurrent() -> BaseButton? {
        guard curIndex < itemBtns.count else {
            debugPrint("array beyond index")
            return nil
        }
        return itemBtns[curIndex]
    }
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateFlager()
    }
    private func updateFlager() {
        guard let item = fetchCurrent() else {
            return
        }
        /// position
        flager.snp.remakeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.centerX.equalTo(item)
            make.height.equalTo(AppSize.HEIGHT_LINE*2)
            make.width.equalTo(item.snp.width).multipliedBy(NavigatorFlagScale)
        }
        /// color
        weak var destbtn: BaseButton?
        for (idx, b) in itemBtns.enumerated() {
            let hitted = curIndex == idx
            let color = hitted ? NavigatorColorSelect : NavigatorColorNormal
            b.setTitleColor(color, for: .normal)
            if hitted { destbtn = b }
        }
        guard let dest = destbtn else { return }
        /// scroll to visiable
        scroller.scrollRectToVisible(dest.frame, animated: true)
    }
    @objc private func didTouchItem(_ btn: BaseButton) {
        let __tag = btn.tag - NavigatorTagStart
        guard __tag != curIndex else {
            return
        }
        let preTag = curIndex
        curIndex = __tag
        updateFlager()
        callback?(__tag, preTag)
    }
    
    public func willSelect(_ index: Int) {
        guard index != curIndex else { return }
        curIndex = index
        updateFlager()
    }
}

// MARK: - badge
public extension FixedNavigator {
    /// badge 0 for hidden
    public func setBadge(_ badge: Int, for index: Int) {
        guard index>=0, index < itemBtns.count else {
            return
        }
        guard badge > 0 else {
            itemBtns[index].pp.hiddenBadge()
            return
        }
        let ref = itemBtns[index]
        let size = ref.bounds.size
        var xoffset = -AppSize.WIDTH_DIS
        let yoffset = HorizontalOffset*1.5
        if let lab = ref.titleLabel {
            let lsize = lab.bounds.size
            let absolute = (size.width-lsize.width)*0.5
            xoffset = -absolute+HorizontalOffset
        }
        itemBtns[index].pp.moveBadge(x: xoffset, y: yoffset)
        itemBtns[index].pp.addBadge(number: badge)
    }
}
