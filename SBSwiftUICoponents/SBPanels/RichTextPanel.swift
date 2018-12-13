//
//  RichTextPanel.swift
//  SBSwiftComponents
//
//  Created by nanhu on 12/3/18.
//  Copyright © 2018 nanhu. All rights reserved.
//

import DTCoreText
import SDWebImage
import SBComponents

public let RichDefaultWidth: CGFloat = AppSize.WIDTH_SCREEN - HorizontalOffset*2
fileprivate let html = "<span style=\"color:#333;font-size:15px;\"><strong>砍价师服务介绍</strong></span><br/><span align=\"right\" style=\"color:#333;font-size:15px;\">我们不是中介。</span><br/> <span style=\"color:#333;font-size:15px;\">我们是一群愿意站在买房人一边的，地产业内人士。</span><br/><br/><span style=\"color:#333;font-size:15px;\"><strong>砍不下来，不要钱！</strong></span><br/><span style=\"color:#333;font-size:15px;\">类似你请个律师，完全站在你的立场，帮你谈判。我们发心，用立场和专业，改变中国买房人的被动、挨宰局面！</span><br/><br/><span style=\"color:#333;font-size:15px;\"><strong>服务流程：</strong></span><br/><span style=\"color:#333;font-size:15px;\">1.砍前培训。砍价师教你和中介、业主交流，哪些话能说，哪些话不能说；</span><br/><span style=\"color:#333;font-size:15px;\">2.选砍价师。和砍价师约见，确认服务，并做各方信息梳理，确定谈判策略。</span><br/><span style=\"color:#333;font-size:15px;\">3.现场谈判。砍价师陪你去现场，协助把控谈判进程；在你砍不动时，再继续全力争取最好价格。</span><br/><br/><span style=\"color:#333;font-size:15px;\"><strong>收费标准：</strong></span><br/><span style=\"color:#333;font-size:15px;\">记住！砍价是由你自己先砍，砍不动时再由砍价师继续砍；由砍价师多砍下的部分，才按照下列标准收费：</span><br/><span style=\"color:#333;font-size:15px;\"><img src=\"http://cn-qinqimaifang-uat.oss-cn-hangzhou.aliyuncs.com/img/specialist/upload/spcetiicwlz1v_54e2e00fa8a6faf66168571654dbfee2.jpg\" _src=\"http://cn-qinqimaifang-uat.oss-cn-hangzhou.aliyuncs.com/img/specialist/upload/spcetiicwlz1v_54e2e00fa8a6faf66168571654dbfee2.jpg\"></span><span style=\"color:#333;font-size:15px;\"><strong>砍不下来，不收费！</strong></span><br/><br/><span style=\"color:#333;font-size:15px;\"><strong>举个例子：</strong></span><br/><span style=\"color:#333;font-size:15px;\">李先生看好一套房子，经过自己努力将价格砍到300万，砍价师在李先生的基础上将价格谈到270万，成功砍下30万，其中0~5万元阶梯价格部分为5万元，5~10万元阶梯价格部分为5万元，10万元以上阶梯价格部分为20万元，则</span><br/><span style=\"color:#333;font-size:15px;\"><strong>应收服务费：5x30％+5x40%+20x50%=13.5万</strong></span><br/><br/><span style=\"color:#333;font-size:15px;\">百度:<a href=\"http://www.w3school.com.cn\">my testlink</a></span><br/><br/><span style=\"color:#333;font-size:15px;\">电话：<a href=\"tel:4008001234\">my phoneNum</a></span><br/><br/><span style=\"color:#333;font-size:15px;\">我邮箱:<a href=\"mailto:dreamcoffeezs@163.com\">my mail</a></span>"

/// 富文本panel
public class RichTextPanel: BaseScene {
    /// vars
    public var callback: VoidClosure?
    private var htmlString: String = ""
    private var maxBoundary: CGRect = .zero
    private var availableWidth: CGFloat = 0
    private var horizontalOffset: CGFloat = 0
    private var topOffset: CGFloat = 0
    private var bottomOffset: CGFloat = 0
    
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
    private lazy var label: DTAttributedLabel = {
        let l = DTAttributedLabel(frame: .zero)
        l.delegate = self
        return l
    }()
    
    public class func panel(_ width: CGFloat=RichDefaultWidth, with top: CGFloat=HorizontalOffset, and bottom: CGFloat=HorizontalOffset) -> RichTextPanel {
        return RichTextPanel(width, with: top, and: bottom)
    }
    private init(_ width: CGFloat, with top: CGFloat=HorizontalOffset, and bottom: CGFloat=HorizontalOffset) {
        super.init(frame: .zero)
        assert(width <= AppSize.WIDTH_SCREEN, "could not set width beyond screen-width!")
        topOffset = top
        bottomOffset = bottom
        availableWidth = width
        horizontalOffset = (AppSize.WIDTH_SCREEN - availableWidth) * 0.5
        maxBoundary = CGRect(x: 0, y: 0, width: availableWidth, height: CGFloat(CGFLOAT_HEIGHT_UNKNOWN))
        addSubview(upOffset)
        addSubview(scene)
        addSubview(downOffset)
        scene.addSubview(label)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        upOffset.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
            m.height.equalTo(topOffset).priority(UILayoutPriority.defaultHigh)
        }
        scene.snp.makeConstraints { (m) in
            m.top.equalTo(upOffset.snp.bottom)
            m.left.equalToSuperview().offset(horizontalOffset)
            m.right.equalToSuperview()
            m.bottom.equalTo(downOffset.snp.top)
        }
        downOffset.snp.makeConstraints { (m) in
            m.left.bottom.right.equalToSuperview()
            m.height.equalTo(bottomOffset).priority(UILayoutPriority.defaultHigh)
        }
        label.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
    }
    /// getters
    /// Html->富文本NSAttributedString
    private func fetchAttributedString(_ html: String) -> NSAttributedString? {
        guard let data = html.data(using: .utf8) else {
            return nil
        }
        return NSAttributedString.init(htmlData: data, documentAttributes: nil)
    }
    /// 使用HtmlString,和最大左右间距，计算视图的高度
    private func fetchAttributedTextHeight(_ html: String, with boudary: CGRect) -> CGSize {
        //获取富文本
        guard let attrString = fetchAttributedString(html) else {
            return .zero
        }
        //获取布局器
        let layouter = DTCoreTextLayouter(attributedString: attrString)
        let entireString = NSRange(location: 0, length: attrString.length)
        //获取frame
        let layoutFrame = layouter?.layoutFrame(with: boudary, range: entireString)
        //得到大小
        let size = layoutFrame?.frame.size
        return size ?? .zero
    }
    
    public func update(_ html: String?) {
        guard let info = html else {
            return
        }
        htmlString = info
        let textSize = fetchAttributedTextHeight(info, with: maxBoundary)
        label.frame = CGRect(x: 0, y: 0, width: availableWidth, height: textSize.height)
        label.attributedString = fetchAttributedString(info)
    }
    public func updateTest() {
        update(html)
    }
}
extension RichTextPanel: DTAttributedTextContentViewDelegate {
    //图片占位
    public func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, viewFor attachment: DTTextAttachment!, frame: CGRect) -> UIView! {
        guard let imgAttach = attachment as? DTImageTextAttachment else {
            return UIView()
        }
        let imgUri = imgAttach.contentURL
        let xOffset = horizontalOffset - frame.minX
        let nf = frame.offsetBy(dx: xOffset, dy: 0)
        let imageView = DTLazyImageView(frame: nf)
        imageView.delegate = self
        imageView.contentMode = .scaleAspectFit
        imageView.image = imgAttach.image
        imageView.url = imgUri
        if let uri = imgUri?.absoluteString, uri.contains("gif") {
            SDWebImageDownloader.shared().downloadImage(with: imgUri, options: [], progress: nil) { (icon, data, err, fini) in
                if let img_data = data {
                    Macros.executeInMain {
                        imageView.image = DTAnimatedGIFFromData(img_data)
                    }
                }
            }
        }
        return imageView
    }
    public func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, viewForLink url: URL!, identifier: String!, frame: CGRect) -> UIView! {
        let btn = DTLinkButton(frame: frame)
        return btn
    }
    
    public func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, didDraw layoutFrame: DTCoreTextLayoutFrame!, in context: CGContext!) {
        callback?()
        debugPrint("did end draw,,,,,,,,,,")
    }
}
extension RichTextPanel: DTLazyImageViewDelegate {
    public func lazyImageView(_ lazyImageView: DTLazyImageView!, didChangeImageSize size: CGSize) {
        var shouldUpdate = false
        if let uri = lazyImageView.url {
            let imageSize = size
            if let attachs = label.layoutFrame?.textAttachments() as? [DTTextAttachment] {
                attachs.forEach { (atc) in
                    if atc.originalSize.equalTo(.zero) && atc.contentURL == uri {
                        atc.originalSize = imageSize
                        configureNoSizeImageView(uri.absoluteString, with: imageSize)
                        shouldUpdate = true
                    }
                }
            }
        }
        
        guard shouldUpdate == true else {
            return
        }
        let textSize = fetchAttributedTextHeight(htmlString, with: maxBoundary)
        label.frame = CGRect(x: 0, y: 0, width: availableWidth, height: textSize.height)
        label.attributedString = fetchAttributedString(htmlString)
        label.relayoutText()
    }
    //字符串中一些图片没有宽高，懒加载图片之后，在此方法中得到图片宽高
    //这个把宽高替换原来的html,然后重新设置富文本
    private func configureNoSizeImageView(_ uri: String, with size: CGSize) {
        let imgSizeScle = size.height / size.width
        var imgWidth = size.width
        var imgHeight = size.height
        let avalible = availableWidth - horizontalOffset*2
        if size.width > avalible {
            imgWidth = avalible
            imgHeight = imgWidth * imgSizeScle
        }
        let imageInfo = "src=\"\(uri)\""
        let sizeString = " style=\"width:\(imgWidth)px; height:\(imgHeight)px;\""
        let newImageInfo = "src=\"\(uri)\"\(sizeString)"
        if htmlString.contains(imageInfo) {
            let newHtml = htmlString.replacingOccurrences(of: imageInfo, with: newImageInfo)
            htmlString = newHtml
        }
    }
}
