//
//  CenterMaskScene.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/10/31.
//  Copyright © 2018 nanhu. All rights reserved.
//

import SBComponents

/// mask 缩放居中弹窗
open class BaseCenterMaskScene: BaseScene {
    /// vars
    private weak var fatherScene: UIView?
    private var availableHeight: CGFloat = 0///info scene
    private var whetherThisDisplay: Bool = false
    private var whetherShowClose: Bool = true///是否现实close&line
    /// lazy vars
    public lazy var scene: BaseScene = {
        let s = BaseScene(frame: .zero)
        s.clipsToBounds = true
        s.layer.masksToBounds = true
        s.layer.cornerRadius = AppSize.RADIUS_NORMAL
        return s
    }()
    private let lineColor = UIColor.white
    public lazy var closeBtn: BaseButton = {
        let font = AppFont.iconFont(AppFont.SIZE_TITLE*2)
        let b = BaseButton(type: .custom)
        b.isHidden = true
        b.titleLabel?.font = font
        b.setTitleColor(lineColor, for: .normal)
        b.setTitle("\u{e6c0}", for: .normal)
        b.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        return b
    }()
    public lazy var line: BaseScene = {
        let s = BaseScene(frame: .zero)
        s.isHidden = true
        s.backgroundColor = lineColor
        return s
    }()
    
    public init(_ father: UIView?, whether showClose: Bool=true, available height: CGFloat=AppSize.WIDTH_SCREEN) {
        super.init(frame: .zero)
        fatherScene = father
        availableHeight = height
        whetherShowClose = showClose
        /// custom
        isHidden = true
        backgroundColor = ClearBgColor
        father?.addSubview(self)
        self.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        /// subviews
        addSubview(scene)
        addSubview(line)
        addSubview(closeBtn)
        let of = fetchEndFrame()
        scene.frame = of
        scene.transform = CGAffineTransform(scaleX: 1, y: 0.01)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// getter
    private func fetchEndFrame() -> CGRect {
        let offset = HorizontalOffsetMAX*2
        let top = (AppSize.HEIGHT_SCREEN-availableHeight)*0.5
        return CGRect(x: offset, y: top, width: AppSize.WIDTH_SCREEN-offset*2, height: availableHeight)
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        let offset = AppSize.SIZE_OFFSET
        line.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(scene.snp.bottom)
            m.width.equalTo(1)
            m.height.equalTo(AppSize.HEIGHT_ICON)
        }
        closeBtn.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(line.snp.bottom).offset(-offset*3)
        }
    }
    /// events
    public func show() {
        whetherThisDisplay.toggle()
        isHidden = false
        fatherScene?.bringSubviewToFront(self)
        updateSceneTransform()
    }
    @objc public func dismiss() {
        whetherThisDisplay.toggle()
        updateHiddenStates()
        updateSceneTransform()
        didDisappear()
    }
    open func didDisappear() {
        
    }
    private func updateHiddenStates() {
        guard whetherShowClose == true else {
            return
        }
        self.line.isHidden = !whetherThisDisplay
        self.closeBtn.isHidden = !whetherThisDisplay
    }
    private func updateSceneTransform() {
        let to = whetherThisDisplay ? CGAffineTransform.identity : CGAffineTransform(scaleX: 1, y: 0.01)
        UIView.animate(withDuration: Macros.APP_ANIMATE_INTERVAL, animations: {[weak self] in
            self?.scene.transform = to
        }) { [weak self](f) in
            if f && self?.whetherThisDisplay == true {
                self?.updateHiddenStates()
            } else {
                self?.isHidden = true
            }
        }
    }
}
