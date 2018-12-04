//
//  PresentMaskScene.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/10/31.
//  Copyright © 2018 nanhu. All rights reserved.
//

import Foundation

/// mask present弹出遮罩 base
open class BaseMaskScene: BaseScene {
    /// vars
    private weak var fatherScene: UIView?
    private var topOffset: CGFloat = 0
    private var availableHeight: CGFloat = 0///info scene
    private var whetherDisplay: Bool = false
    
    /// lazy vars
    public lazy var scene: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    public lazy var closeBtn: BaseButton = {
        let color = AppColor.COLOR_TITLE_GRAY
        let font = AppFont.iconFont(AppFont.SIZE_LARGE_TITLE)
        let b = BaseButton(type: .custom)
        b.titleLabel?.font = font
        b.setTitleColor(color, for: .normal)
        b.setTitle("\u{e605}", for: .normal)
        b.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        return b
    }()
    
    /* init
     public class func mask(_ father: UIView, top offset: CGFloat, with bottom: CGFloat=0) -> BaseMaskScene {
     return BaseMaskScene(father, top: offset, with: bottom)
     }
     */
    public init(_ father: UIView?, top offset: CGFloat, with bottom: CGFloat=0) {
        super.init(frame: .zero)
        fatherScene = father
        topOffset = offset
        availableHeight = AppSize.HEIGHT_SCREEN - offset - bottom
        /// custom
        isHidden = true
        backgroundColor = ClearBgColor
        father?.addSubview(self)
        self.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        /// subviews
        addSubview(scene)
        scene.addSubview(closeBtn)
        let of = fetchEndFrame()
        scene.frame = of
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// getter
    private func fetchEndFrame() -> CGRect {
        let top = whetherDisplay ? topOffset : AppSize.HEIGHT_SCREEN
        return CGRect(x: 0, y: top, width: AppSize.WIDTH_SCREEN, height: availableHeight)
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        closeBtn.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(HorizontalOffset)
            m.right.equalToSuperview().offset(-HorizontalOffset)
        }
    }
    /// events
    open func show() {
        whetherDisplay.toggle()
        isHidden = false
        fatherScene?.bringSubviewToFront(self)
        updateScenePosition()
    }
    @objc public func dismiss() {
        whetherDisplay.toggle()
        updateScenePosition()
        didDisappear()
    }
    open func didDisappear() {
        
    }
    private func updateScenePosition() {
        let to = fetchEndFrame()
        UIView.animate(withDuration: Macros.APP_ANIMATE_INTERVAL, animations: {[weak self] in
            self?.scene.frame = to
        }) { [weak self](f) in
            self?.isHidden = !(self?.whetherDisplay ?? true)
        }
    }
}
