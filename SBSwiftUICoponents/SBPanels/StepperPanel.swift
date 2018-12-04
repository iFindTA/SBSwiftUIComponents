//
//  StepperPanel.swift
//  SBSwiftComponents
//
//  Created by nanhu on 12/3/18.
//  Copyright © 2018 nanhu. All rights reserved.
//

import SBComponents

/// 增减步进器
public class StepperPanel: BaseScene {
    /// vars
    private let minValid: Int = 1
    private var maxValid: Int = 99
    public var convertNum: Int = 1///兑换数量
    public var callback: TagClosure?
    /// lazy vars
    private let nColor = UIColor.black
    private let dColor = UIColor.lightGray
    private let font = AppFont.iconFont(AppFont.SIZE_TITLE)
    private lazy var minusBtn: BaseButton = {
        let b = BaseButton(type: .custom)
        b.isEnabled = false
        b.titleLabel?.font = font
        b.setTitle("\u{e6be}", for: .normal)
        b.setTitleColor(nColor, for: .normal)
        b.setTitleColor(dColor, for: .disabled)
        b.backgroundColor = AppColor.COLOR_BG_GRAY
        b.addTarget(self, action: #selector(didMinus), for: .touchUpInside)
        return b
    }()
    private lazy var plusBtn: BaseButton = {
        let b = BaseButton(type: .custom)
        b.titleLabel?.font = font
        b.setTitle("\u{e6bd}", for: .normal)
        b.setTitleColor(nColor, for: .normal)
        b.setTitleColor(dColor, for: .disabled)
        b.backgroundColor = AppColor.COLOR_BG_GRAY
        b.addTarget(self, action: #selector(didPlus), for: .touchUpInside)
        return b
    }()
    private lazy var numLab: BaseLabel = {
        let l = BaseLabel(frame: .zero)
        l.font = AppFont.pingFangMedium(AppFont.SIZE_SUB_TITLE+1)
        l.textColor = AppColor.COLOR_TITLE
        l.text = "\(minValid)"
        l.textAlignment = .center
        return l
    }()
    private lazy var scene: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(scene)
        scene.addSubview(plusBtn)
        scene.addSubview(numLab)
        scene.addSubview(minusBtn)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        scene.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
            m.height.equalTo(AppSize.HEIGHT_ICON).priority(UILayoutPriority.defaultHigh)
            m.width.equalTo(AppSize.HEIGHT_CELL*2).priority(UILayoutPriority.defaultHigh)
        }
        numLab.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
            m.width.equalToSuperview().multipliedBy(0.2)
        }
        plusBtn.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalTo(numLab.snp.right).offset(HorizontalOffset)
        }
        minusBtn.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.right.equalTo(numLab.snp.left).offset(-HorizontalOffset)
        }
    }
    
    ///j 加减
    @objc private func didMinus() {
        convertNum -= 1
        convertNum = max(convertNum, minValid)
        updateMinusPlusState()
        callback?(convertNum)
    }
    @objc private func didPlus() {
        convertNum += 1
        convertNum = min(convertNum, maxValid)
        updateMinusPlusState()
        callback?(convertNum)
    }
    private func updateMinusPlusState() {
        let minus_enable = convertNum > minValid
        let plus_enable = convertNum < maxValid
        minusBtn.isEnabled = minus_enable
        plusBtn.isEnabled = plus_enable
        numLab.text = "\(convertNum)"
    }
    public func update(_ cur: Int=1, with max: Int=99) {
        guard max > minValid && cur >= minValid && max > cur else {
            debugPrint("sku num 出错！")
            return
        }
        convertNum = cur
        updateMinusPlusState()
    }
}
