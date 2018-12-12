//
//  TestHtmlProfile.swift
//  SBSwiftUICoponents
//
//  Created by nanhu on 12/12/18.
//  Copyright © 2018 nanhu. All rights reserved.
//

import SwiftyJSON
import SBComponents

class TestHtmlProfile: BaseProfile {
    /// lazy vars
    lazy private var scroller: BaseScrollView = {
        let s = BaseScrollView(frame: .zero)
        s.bounces = true
        s.isPagingEnabled = false
        s.showsVerticalScrollIndicator = false
        s.showsHorizontalScrollIndicator = false
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    lazy private var layouter: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    lazy private var richPanel: RichTextPanel = {
        let p = RichTextPanel.panel()
        return p
    }()
    
    private var params: SBParameter?
    init(_ parameters: SBParameter?) {
        super.init(nibName: nil, bundle: nil)
        params  = parameters
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(navigationBar)
        let spacer = Kits.barSpacer()
        let backer = Kits.defaultBackBarItem(self, action: #selector(defaultGobackStack))
        let item = UINavigationItem(title: "rich text test")
        item.leftBarButtonItems = [spacer, backer]
        navigationBar.pushItem(item, animated: true)
        
        /// ui hierarchy
        view.addSubview(scroller)
        scroller.addSubview(layouter)
        layouter.addSubview(richPanel)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scroller.snp.makeConstraints { (m) in
            m.top.equalTo(navigationBar.snp.bottom)
            m.left.bottom.right.equalToSuperview()
        }
        layouter.snp.makeConstraints { (m) in
            m.edges.width.equalToSuperview()
        }
        richPanel.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SBHTTPRouter.shared.fetch(SBHTTP.html(58)) { [weak self](res, err, _) in
            if let e = err {
                Kits.handleError(e)
                return
            }
            self?.handle(res)
        }
    }
    private func handle(_ json: JSON?) {
        let desc = json?["desc"].stringValue
        richPanel.update(desc)
    }
}

extension TestHtmlProfile: SBSceneRouteable {
    static func __init(_ params: SBParameter?) -> UIViewController {
        return TestHtmlProfile(params)
    }
}
