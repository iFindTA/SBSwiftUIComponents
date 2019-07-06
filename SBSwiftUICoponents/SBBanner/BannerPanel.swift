//
//  BannerPanel.swift
//  SBSwiftComponents
//
//  Created by nanhu on 11/18/18.
//  Copyright © 2018 nanhu. All rights reserved.
//

import FSPagerView
import SBComponents
import CHIPageControl
import AlamofireImage

fileprivate let BannerCellIdentifier = "banner-base-cell"
/// banner scale w/h
public let BannerWHScale: CGFloat = 2.34
public let BannerPageWidth: CGFloat = 15
public let BannerPageHeight: CGFloat = 2
public let BannerPageBgColor = AppColor.COLOR_BG_GRAY
public let BannerPageTintColor = RGBA(r: 64, g: 57, b: 58, a: 1)

/// banner cell基类
public class BannerCell: FSPagerViewCell {
    private lazy var iconView: UIImageView = {
        let i = UIImageView(frame: .zero)
        i.contentMode = .scaleAspectFill
        return i
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(iconView)
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        iconView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    public func update(_ img: String?) {
        guard let uriString = img else {
            return
        }
        guard let uri = URL(string: uriString) else {
            return
        }
        iconView.af_setImage(withURL: uri)
        //iconView.sd_setImage(with: uri, completed: nil)
    }
}

/// banner基类
open class BaseBanner: UIView {
    /// vars
    public var callback: TagClosure?
    /// lazy vars
    public lazy var banner: FSPagerView = {
        let b = FSPagerView(frame: .zero)
        b.automaticSlidingInterval = 3.0
        b.delegate = self
        b.dataSource = self
        b.register(BannerCell.self, forCellWithReuseIdentifier: BannerCellIdentifier)
        return b
    }()
    public lazy var pageControl: CHIPageControlJaloro = {
        let p = CHIPageControlJaloro(frame: .zero)
        p.radius = BannerPageHeight * 0.5
        p.padding = BannerPageHeight * 2
        p.elementWidth = BannerPageWidth
        p.elementHeight = BannerPageHeight
        p.tintColor = BannerPageBgColor
        p.currentPageTintColor = BannerPageTintColor
        return p
    }()
    public lazy var bannerScene: UIView = {
        let s = UIView(frame: .zero)
        s.backgroundColor = UIColor.white
        return s
    }()
    public lazy var pageScene: UIView = {
        let s = UIView(frame: .zero)
        return s
    }()
    
    private var source: [String]?
    public var shoouldResponseTouch: Bool = true    //是否需要响应点击事件
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bannerScene)
        bannerScene.addSubview(banner)
        addSubview(pageScene)
        pageScene.addSubview(pageControl)
        backgroundColor = UIColor.white
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
    public func update(_ imgs: [String]?, with infinite: Bool=false ) {
        source = imgs
        guard let l = imgs else {
            return
        }
        if infinite {
            banner.isInfinite = l.count > 1
        }
        pageControl.numberOfPages = l.count
        pageControl.set(progress: 0, animated: true)
        pageControl.isHidden = l.count <= 1
        banner.reloadData()
    }
}
// MARK: - Banner Delegate
extension BaseBanner: FSPagerViewDelegate, FSPagerViewDataSource {
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return source?.count ?? 0
    }
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: BannerCellIdentifier, at: index)
        if let c = cell as? BannerCell {
            c.update(source?[index])
        }
        return cell
    }
    public func pagerViewDidScroll(_ pagerView: FSPagerView) {
        let p = pagerView.currentIndex
        //pageIndecator.currentPage = p
        pageControl.set(progress: p, animated: true)
    }
    
    public func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        guard shoouldResponseTouch else {
            return
        }
        callback?(index)
    }
}
