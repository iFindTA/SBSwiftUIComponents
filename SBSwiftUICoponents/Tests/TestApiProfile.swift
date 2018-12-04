//
//  TestApiProfile.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/10/27.
//  Copyright © 2018 nanhu. All rights reserved.
//

import SBComponents

class TestApiProfile: BaseProfile {
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
        let item = UINavigationItem(title: "Api Cancel test")
        item.leftBarButtonItems = [spacer, backer]
        navigationBar.pushItem(item, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SBHTTPRouter.shared.fetch(SBHTTP.test) { (res, err, _) in
            if let e = err {
                Kits.handleError(e)
            }
        }
    }
}
extension TestApiProfile: SBSceneRouteable {
    static func __init(_ params: SBParameter?) -> UIViewController {
        return TestApiProfile(params)
    }
}
