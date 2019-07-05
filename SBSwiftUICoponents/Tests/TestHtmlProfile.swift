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
    #if DEBUG
    lazy private var richPanel: RichHtmlPanel = {
        let p = RichHtmlPanel.panel()
        return p
    }()
    #else
    lazy private var htmlLabel: BaseLabel = {
        let s = BaseLabel(frame: .zero)
        s.backgroundColor = UIColor.sb_random()
        s.numberOfLines = 0
        s.lineBreakMode = .byCharWrapping
        return s
    }()
    #endif
    
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
        #if DEBUG
        layouter.addSubview(richPanel)
        #else
        layouter.addSubview(htmlLabel)
        #endif
        #if DEBUG
        richPanel.callback = {[weak self](height) in
            self?.updateRichPanel(height)
        }
        #endif
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
        #if DEBUG
        richPanel.snp.makeConstraints { (m) in
            m.edges.width.equalToSuperview()
        }
        #else
        htmlLabel.snp.makeConstraints { (m) in
            m.edges.width.equalToSuperview()
        }
        #endif
    }
    #if DEBUG
    private func updateRichPanel(_ height: Double) {
        richPanel.snp.removeConstraints()
        richPanel.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
            m.height.equalTo(height)
        }
    }
    #endif
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
        var htmlString = "<html><body> \(desc ?? "empty for displaying") </body></html>"
        #if DEBUG
        richPanel.update(desc ?? "")
        #else
        htmlString = "<html><body> \(desc ?? "empty for displaying") <style> section {margin: 0 !important; width: 100% !important;} p {margin: 0 !important; width: 100% !important;}</style></body></html>"
        let data = htmlString.data(using: String.Encoding.unicode)! // mind "!"
        let attrStr = try? NSAttributedString( // do catch
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        guard let attr = attrStr else {
            debugPrint("empty attr string")
            return
        }
        let tmpAttr = NSMutableAttributedString(attributedString: attr)
        let availableWidth = AppSize.WIDTH_SCREEN - HorizontalOffsetMid*2
        tmpAttr.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, attrStr?.length ?? 0), options: NSAttributedString.EnumerationOptions(rawValue: 0), using: { (value, range, stop) in
            if let attachment = value as? NSTextAttachment {
                let image = attachment.image(forBounds: attachment.bounds, textContainer: NSTextContainer(), characterIndex: range.location)
                guard let img = image else {
                    return
                }
                let imgSize = img.size
                let imgScale = imgSize.height / imgSize.width
                var imgWidth = imgSize.width
                var imgHeight = imgSize.height
                if imgSize.width > availableWidth {
                    imgWidth = availableWidth
                    imgHeight = imgWidth * imgScale
                    let newImg = img.sb_resize(CGSize(width: imgWidth, height: imgHeight))
                    let newAttribute = NSTextAttachment()
                    newAttribute.image = newImg
                    tmpAttr.addAttribute(NSAttributedString.Key.attachment, value: newAttribute, range: range)
                }
            }
        })
        // suppose we have an UILabel, but any element with NSAttributedString will do
        htmlLabel.attributedText = tmpAttr
        #endif
    }
}

extension TestHtmlProfile: SBSceneRouteable {
    static func __init(_ params: SBParameter?) -> UIViewController {
        return TestHtmlProfile(params)
    }
}
