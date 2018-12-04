//
//  ViewController.swift
//  SBSwiftUICoponents
//
//  Created by nanhu on 12/4/18.
//  Copyright © 2018 nanhu. All rights reserved.
//

import SnapKit
import SBComponents

class ViewController: UIViewController {
    /// vars
    private var navigator: FixedNavigator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let topoffset = AppSize.HEIGHT_STATUSBAR()
        let titles = ["消息", "班聊", "小星阅读盒子"]
        //let availableWidth = AppSize.WIDTH_SCREEN - AppSize.HEIGHT_SUBBAR*2
        navigator = FixedNavigator.navigator(titles)
        view.addSubview(navigator!)
        navigator?.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topoffset)
            make.left.right.equalToSuperview()
            make.height.equalTo(AppSize.HEIGHT_NAVIGATIONBAR)
        }
        
        var btn = BaseButton(type: .custom)
        btn.setTitle("test api", for: .normal)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.addTarget(self, action: #selector(fetchTest), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.left.right.equalToSuperview()
            make.height.equalTo(AppSize.HEIGHT_SUBBAR)
        }
        
        let input = BaseTextField(frame: .zero)
        input.placeholder = "input something"
        view.addSubview(input)
        input.snp.makeConstraints { (make) in
            make.top.equalTo(btn.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(AppSize.HEIGHT_ICON)
        }
        
        btn = BaseButton(type: .custom)
        btn.setTitle("test browser", for: .normal)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.addTarget(self, action: #selector(testWebBrowser), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(input.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(AppSize.HEIGHT_SUBBAR)
        }
        
        let empty = BaseButton(type: .custom)
        empty.setTitle("test empty", for: .normal)
        empty.setTitleColor(UIColor.blue, for: .normal)
        empty.addTarget(self, action: #selector(testEmpty), for: .touchUpInside)
        view.addSubview(empty)
        empty.snp.makeConstraints { (make) in
            make.top.equalTo(btn.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(AppSize.HEIGHT_SUBBAR)
        }
        
        let wxShare = BaseButton(type: .custom)
        wxShare.setTitle("test share wechat", for: .normal)
        wxShare.setTitleColor(UIColor.blue, for: .normal)
        wxShare.addTarget(self, action: #selector(share2WeChat), for: .touchUpInside)
        view.addSubview(wxShare)
        wxShare.snp.makeConstraints { (make) in
            make.top.equalTo(empty.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(AppSize.HEIGHT_SUBBAR)
        }
        
        let snapKit = BaseButton(type: .custom)
        snapKit.setTitle("test snapkit", for: .normal)
        snapKit.setTitleColor(UIColor.blue, for: .normal)
        snapKit.addTarget(self, action: #selector(testSnapkit), for: .touchUpInside)
        view.addSubview(snapKit)
        snapKit.snp.makeConstraints { (make) in
            make.top.equalTo(wxShare.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(AppSize.HEIGHT_SUBBAR)
        }
        
        let load = BaseButton(type: .custom)
        load.setTitle("test baseloading", for: .normal)
        load.setTitleColor(UIColor.blue, for: .normal)
        load.addTarget(self, action: #selector(testBaseloading), for: .touchUpInside)
        view.addSubview(load)
        load.snp.makeConstraints { (make) in
            make.top.equalTo(snapKit.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(AppSize.HEIGHT_SUBBAR)
        }
        
        let mask = BaseButton(type: .custom)
        mask.setTitle("test mask center", for: .normal)
        mask.setTitleColor(UIColor.blue, for: .normal)
        mask.addTarget(self, action: #selector(testCenterMask), for: .touchUpInside)
        view.addSubview(mask)
        mask.snp.makeConstraints { (make) in
            make.top.equalTo(load.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(AppSize.HEIGHT_SUBBAR)
        }
        
        let badge = BaseButton(type: .custom)
        badge.setTitle("test badge", for: .normal)
        badge.setTitleColor(UIColor.blue, for: .normal)
        badge.addTarget(self, action: #selector(testBadge(_:)), for: .touchUpInside)
        view.addSubview(badge)
        badge.snp.makeConstraints { (make) in
            make.top.equalTo(mask.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(AppSize.HEIGHT_SUBBAR)
        }
        
        let comment = BaseButton(type: .custom)
        comment.setTitle("test comment", for: .normal)
        comment.setTitleColor(UIColor.blue, for: .normal)
        comment.addTarget(self, action: #selector(testComments), for: .touchUpInside)
        view.addSubview(comment)
        comment.snp.makeConstraints { (make) in
            make.top.equalTo(badge.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(AppSize.HEIGHT_SUBBAR)
        }
        
        let state = BaseButton(type: .custom)
        state.setTitle("test state", for: .normal)
        state.setTitleColor(UIColor.blue, for: .normal)
        state.addTarget(self, action: #selector(testState(_:)), for: .touchUpInside)
        view.addSubview(state)
        state.snp.makeConstraints { (make) in
            make.top.equalTo(comment.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(AppSize.HEIGHT_SUBBAR)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigator?.setBadge(2, for: 2)
    }
    
    @objc private func fetchTest() {
        let err = SBSceneRouter.route2(TestPaths.api)
        Kits.handleError(err)
    }
    @objc private func testWebBrowser() {
        var p = SBParameter()
        p["url"] = "https://baidu.com/"
        let browser = WebBrowser(p)
        self.navigationController?.pushViewController(browser, animated: true)
    }
    @objc private func testEmpty() {
        let err = SBSceneRouter.route2(TestPaths.empty)
        Kits.handleError(err)
    }
    
    @objc private func share2WeChat() {
        
        let title = "title for share"
        let desc = "这是一段精彩的描述文档，请具体查看文档"
        let link = "https://github.com/ifindTA/"
        let icon = "http://e.hiphotos.baidu.com/image/pic/item/72f082025aafa40fafb5fbc1a664034f78f019be.jpg"
        TPOpen.shared.shareLink([.qq, .wxSession], title: title, desciption: desc, icon: icon, hybrid: link, profile: self) { (error) in

        }
    }
    
    @objc private func testSnapkit() {
        let err = SBSceneRouter.route2(TestPaths.snapkit)
        Kits.handleError(err)
    }
    
    @objc private func testBaseloading() {
        BaseLoading.shared.showIn(view)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
            BaseLoading.shared.hide()
        }
    }
    
    @objc private func testCenterMask() {
        let s = BaseCenterMaskScene(view)
        s.show()
    }
    
    @objc private func testBadge(_ btn: BaseButton) {
        btn.isSelected.toggle()
        if btn.isSelected {
            navigator?.setBadge(12, for: 0)
        } else {
            navigator?.setBadge(0, for: 0)
        }
    }
    @objc private func testComments() {
        _ = SBSceneRouter.route2(TestPaths.comment)
    }
    
    @objc private func testState(_ btn: BaseButton) {
        btn.sb_busyState = true
        btn.appearState = .loading
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            btn.sb_busyState = false
            btn.appearState = .idle
        }
        Kits.makeToast("test for sb toaster")
    }

}

