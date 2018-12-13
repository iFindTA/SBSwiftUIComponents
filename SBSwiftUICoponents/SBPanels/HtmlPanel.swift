//
//  HtmlPanel.swift
//  SBSwiftUICoponents
//
//  Created by nanhu on 12/12/18.
//  Copyright © 2018 nanhu. All rights reserved.
//

import DTCoreText
import SBComponents

public let DefaultWidth: CGFloat = AppSize.WIDTH_SCREEN - HorizontalOffsetMid*2

/// rich html panel (do not support gif/video)
class HtmlPanel: BaseScene {
    /// vars
    private var horizontalOffset: CGFloat = HorizontalOffsetMid
    private var topOffset: CGFloat = HorizontalOffset
    private var bottomOffset: CGFloat = HorizontalOffset
    /// lazy vars
    private lazy var upOffset: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    private lazy var downOffset: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    private lazy var scene: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    private lazy var htmlLabel: BaseLabel = {
        let s = BaseLabel(frame: .zero)
        s.numberOfLines = 0
        s.lineBreakMode = .byCharWrapping
        return s
    }()
    
    public class func panel(_ width: CGFloat=DefaultWidth, with top: CGFloat=HorizontalOffset, and bottom: CGFloat=HorizontalOffset) -> HtmlPanel {
        return HtmlPanel(width, with: top, and: bottom)
    }
    private init(_ width: CGFloat, with top: CGFloat=HorizontalOffset, and bottom: CGFloat=HorizontalOffset) {
        super.init(frame: .zero)
        addSubview(upOffset)
        addSubview(scene)
        addSubview(downOffset)
        scene.addSubview(htmlLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        upOffset.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
            m.height.equalTo(topOffset)
        }
        scene.snp.makeConstraints { (m) in
            m.top.equalTo(upOffset.snp.bottom)
            m.left.right.equalToSuperview()
            m.bottom.equalTo(downOffset.snp.top)
        }
        downOffset.snp.makeConstraints { (m) in
            m.left.bottom.right.equalToSuperview()
            m.height.equalTo(bottomOffset)
        }
        let insets = UIEdgeInsets(top: 0, left: horizontalOffset, bottom: 0, right: horizontalOffset)
        htmlLabel.snp.makeConstraints { (m) in
            m.edges.equalToSuperview().inset(insets)
        }
    }
    
    public func update(_ html: String?) {
        guard let info = html else {
            return
        }
        guard let attr = info.sb_html2Attribute() else {
            debugPrint("empty attr string")
            return
        }
        let tmpAttr = NSMutableAttributedString(attributedString: attr)
        let availableWidth = AppSize.WIDTH_SCREEN - HorizontalOffsetMid*2
        tmpAttr.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, attr.length), options: NSAttributedString.EnumerationOptions(rawValue: 0), using: { (value, range, stop) in
            if let attachment = value as? NSTextAttachment {
                let image = attachment.image(forBounds: attachment.bounds, textContainer: NSTextContainer(), characterIndex: range.location)
                guard let img = image else {
                    debugPrint("empty img!")
                    return
                }
                /// method1
//                var tmpImg = img
//                if let extra = attachment.fileType, extra.hasSuffix("gif") == true {
//                    let randomImg = UIImage.sb_imageWithColor(.sb_random(), size: CGSize(width: availableWidth, height: availableWidth))
//                    tmpImg = randomImg
//                }
                
                /// method2
//                guard let extra = attachment.fileType, extra.hasSuffix("gif") == false else {
//                    let uri = URL(string: "http://pic.landun.tech/6cb5cb3524639f13e954ba1edb10aefd.gif")
//                    let data = NSData.init(contentsOf: uri!)
//                    if let gifData = data {
//                        let gif = UIImage.gifImageWithData(gifData as Data)
//                        //let gif = DTAnimatedGIFFromData(gifData as Data)
//                        let newAttribute = NSTextAttachment()
//                        newAttribute.image = gif
//                        let gf = CGRect(origin: .zero, size: img.size)
//                        let gifView = UIImageView(frame: gf)
//                        gifView.image = gif
//                        addSubview(gifView)
//                        tmpAttr.addAttribute(NSAttributedString.Key.attachment, value: newAttribute, range: range)
//                    }
//                    return
//                }
                let newAttribute = NSTextAttachment()
                newAttribute.image = resizeImage(img)
                tmpAttr.addAttribute(NSAttributedString.Key.attachment, value: newAttribute, range: range)
            }
        })
        // suppose we have an UILabel, but any element with NSAttributedString will do
        htmlLabel.attributedText = tmpAttr
    }
    
    /// utils
    private func resizeImage(_ img: UIImage) -> UIImage? {
        let imgSize = img.size
        let availableWidth = AppSize.WIDTH_SCREEN - HorizontalOffsetMid*2
        guard imgSize.width > availableWidth else {
            return img
        }
        let imgScale = imgSize.height / imgSize.width
        let imgWidth = availableWidth
        let imgHeight = imgWidth * imgScale
        let newImg = img.sb_resize(CGSize(width: imgWidth, height: imgHeight))
        return newImg
    }
}

fileprivate extension String {
    fileprivate func sb_html2Attribute() -> NSAttributedString? {
        let htmlString = "<html><body> \(self) <style> p,section {margin: 0 !important; width: 100% !important;}</style></body></html>"
        let data = htmlString.data(using: String.Encoding.unicode)! // mind "!"
        let attrStr = try? NSAttributedString( // do catch
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        return attrStr
    }
}
