//
//  SB404.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/5.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import Foundation

public class SB404: BaseProfile {
    
    private lazy var label: BaseLabel = {
        let l = BaseLabel(frame: .zero)
        l.font = AppFont.pingFangSC(AppFont.SIZE_TITLE)
        l.textAlignment = .center
        l.textColor = AppColor.COLOR_TITLE
        l.text = "该服务飞到火星了，请稍后再来！"
        return l
    }()
    private lazy var backBarButtonItem: UIBarButtonItem =  {
        let icon = SB404.bundledImage(named: "scene_router_back")
        var tempBackBarButtonItem = UIBarButtonItem(image:icon,
                                                    style: UIBarButtonItem.Style.plain,
                                                    target: self,
                                                    action: #selector(defaultGobackStack))
        tempBackBarButtonItem.width = 18.0
        tempBackBarButtonItem.tintColor = nil
        return tempBackBarButtonItem
    }()
    
    init(_ parameters: SBParameter?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(navigationBar)
        let item = UINavigationItem(title: "Oops！")
        item.leftBarButtonItem = backBarButtonItem
        navigationBar.pushItem(item, animated: true)
        
        view.insertSubview(label, belowSubview: navigationBar)
        self.label.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    class func bundledImage(named: String) -> UIImage? {
        let image = UIImage(named: named)
        if image == nil {
            return UIImage(named: named, in: Bundle(for: SB404.classForCoder()), compatibleWith: nil)
        } // Replace MyBasePodClass with yours
        return image
    }
}

extension SB404: SBSceneRouteable {
    public static func __init(_ params: SBParameter?) -> UIViewController {
        return SB404(params)
    }
}
