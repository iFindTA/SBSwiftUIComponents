//
//  TPShareProfile.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/11/8.
//  Copyright © 2018 nanhu. All rights reserved.
//

import SBComponents

// MARK: - 第三方平台UI选择
class TPShareProfile: BaseProfile {
    /// Callbacks
    public var platClosure: TPShareCallback?
    public var cancelClosure: VoidClosure?
    
    private var color = RGBA(r: 153, g: 153, b: 153, a: 1)
    private var font = AppFont.pingFangBold(AppFont.SIZE_SUB_TITLE)
    private lazy var scene: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    private lazy var btnScene: BaseScene = {
        let s = BaseScene()
        return s
    }()
    private lazy var cancelBtn: BaseButton = {
        let b = BaseButton(type: .custom)
        b.titleLabel?.font = AppFont.pingFangBold(AppFont.SIZE_SUB_TITLE+1)
        b.setTitleColor(color, for: .normal)
        b.setTitle("取消", for: .normal)
        b.layer.cornerRadius = AppSize.HEIGHT_SUBBAR*0.5
        b.layer.masksToBounds = true
        b.layer.borderWidth = AppSize.HEIGHT_LINE
        b.layer.borderColor = RGBA(r: 221, g: 221, b: 221, a: 1).cgColor
        b.addTarget(self, action: #selector(cancelShare), for: .touchUpInside)
        return b
    }()
    private lazy var qqBtn: BaseButton = {
        let b = BaseButton(type: .custom)
        let icon = UIImage(named: "icon_grant_qq")
        b.titleLabel?.font = font
        b.setTitleColor(color, for: .normal)
        b.setTitle("QQ好友", for: .normal)
        b.setImage(icon, for: .normal)
        b.addTarget(self, action: #selector(share2QQ), for: .touchUpInside)
        return b
    }()
    private lazy var wxBtn: BaseButton = {
        let b = BaseButton(type: .custom)
        let icon = UIImage(named: "icon_grant_wx")
        b.titleLabel?.font = font
        b.setTitleColor(color, for: .normal)
        b.setTitle("微信好友", for: .normal)
        b.setImage(icon, for: .normal)
        b.addTarget(self, action: #selector(share2WXSession), for: .touchUpInside)
        return b
    }()
    private lazy var dlBtn: BaseButton = {
        let b = BaseButton(type: .custom)
        let icon = UIImage(named: "icon_grant_dl")
        b.titleLabel?.font = font
        b.setTitleColor(color, for: .normal)
        b.setTitle("保存", for: .normal)
        b.setImage(icon, for: .normal)
        b.addTarget(self, action: #selector(save2Album), for: .touchUpInside)
        return b
    }()
    
    private var params: SBParameter?
    init(_ parameters: SBParameter?) {
        super.init(nibName: nil, bundle: nil)
        params = parameters
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        cancelShare()
    }
    @objc private func cancelShare() {
        SBSceneRouter.back(nil, excute: cancelClosure)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ClearBgColor
        
        /// scene
        let bottom = AppSize.HEIGHT_INVALID_BOTTOM()
        view.addSubview(scene)
        scene.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(bottom+TPShareSceneHeight)
        }
        
        scene.addSubview(cancelBtn)
        cancelBtn.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(HorizontalOffsetMAX)
            make.right.equalToSuperview().offset(-HorizontalOffsetMAX)
            make.bottom.equalToSuperview().offset(-bottom-HorizontalOffset)
            make.height.equalTo(AppSize.HEIGHT_SUBBAR)
        }
        
        /// btn scene
        scene.addSubview(btnScene)
        btnScene.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(HorizontalOffsetMAX)
            make.right.equalToSuperview().offset(-HorizontalOffsetMAX)
            make.bottom.equalTo(cancelBtn.snp.top).offset(-HorizontalOffset)
        }
        btnScene.addSubview(qqBtn)
        btnScene.addSubview(wxBtn)
        qqBtn.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.right.equalTo(wxBtn.snp.left)
            make.width.equalTo(wxBtn.snp.width)
        }
        wxBtn.snp.makeConstraints { (make) in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(qqBtn.snp.width)
        }
        let space = AppSize.WIDTH_DIS
        wxBtn.sb_fixImagePosition(.top, spacing: space)
        qqBtn.sb_fixImagePosition(.top, spacing: space)
    }
    @objc private func share2QQ() {
        share2(.qq)
    }
    @objc private func share2WXSession() {
        share2(.wxSession)
    }
    @objc private func share2WXTimeline() {
        share2(.wxTimeline)
    }
    @objc private func share2WXFavorite() {
        share2(.wxFavorite)
    }
    private func share2(_ platform: TPlatform) {
        let clousure: VoidClosure = {[weak self] in
            self?.platClosure?(platform)
        }
        SBSceneRouter.back(nil, excute: clousure)
    }
    @objc private func save2Album() {
        
    }
}
