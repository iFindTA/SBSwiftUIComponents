//
//  RichPanel.swift
//  SBSwiftUICoponents
//
//  Created by nanhu on 12/17/18.
//  Copyright © 2018 nanhu. All rights reserved.
//

import WebKit
import SBComponents

/*
fileprivate let adjustImgScripts = """
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.text = function ResizeImages() {
        var myimg,oldwidth,oldHeight,scale;
        var maxwidth = \(AppSize.WIDTH_SCREEN-HorizontalOffset*2);
        for(i=0;i <document.images.length;i++){
            myimg = document.images[i];
            oldwidth = myimg.width;
            oldHeight = myimg.height;
            if(oldwidth > maxwidth){
                scale = oldHeight/oldwidth;
                oldwidth = maxwidth;
                oldHeight = oldwidth*scale;
                myimg.width = oldwidth;
                myimg.height = oldHeight;
            }
        }
    };
    document.getElementsByTagName('head')[0].appendChild(script);ResizeImages();
"""
*/
fileprivate func assembleAdjusts(_ offset: CGFloat = HorizontalOffset) -> String {
    let adjustImgScripts = """
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.text = function ResizeImages() {
        var myimg,oldwidth,oldHeight,scale;
        var maxwidth = \(AppSize.WIDTH_SCREEN-offset*2);
        for(i=0;i <document.images.length;i++){
            myimg = document.images[i];
            oldwidth = myimg.width;
            oldHeight = myimg.height;
            if(oldwidth > maxwidth){
                scale = oldHeight/oldwidth;
                oldwidth = maxwidth;
                oldHeight = oldwidth*scale;
                myimg.width = oldwidth;
                myimg.height = oldHeight;
            }
        }
    };
    document.getElementsByTagName('head')[0].appendChild(script);ResizeImages();
    """
    return adjustImgScripts
}

/// rich text panel for wk-webView
public class RichHtmlPanel: BaseScene {
    /// vars
    public  var callback: DoubleClosure?
    private var horizontalOffset: CGFloat = 10
    /// lazy vars
    public lazy var webView: WKWebView = {
        let cfg = WKWebViewConfiguration()
        cfg.preferences.minimumFontSize = 12
        cfg.preferences.javaScriptCanOpenWindowsAutomatically = true
        let s = WKWebView(frame: .zero, configuration: cfg)
        s.scrollView.bounces = false
//        s.scrollView.isScrollEnabled = false
        s.scrollView.showsVerticalScrollIndicator = false
        s.scrollView.showsHorizontalScrollIndicator = false
        return s
    }()
    
    public class func panel(_ hOffset: CGFloat=HorizontalOffset) -> RichHtmlPanel {
        return RichHtmlPanel(hOffset)
    }
    
    private init(_ offset: CGFloat=10) {
        super.init(frame: .zero)
        horizontalOffset = offset
        addSubview(webView)
        webView.navigationDelegate = self
    }
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        let insets = UIEdgeInsets(top: 0, left: horizontalOffset, bottom: 0, right: horizontalOffset)
        webView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview().inset(insets)
        }
    }
    private func updateContentSize() {
        let scripts = "document.body.scrollHeight"
        webView.evaluateJavaScript(scripts) { [weak self](response, err) in
            if let e = err {
                debugPrint(e.localizedDescription)
                return
            }
            if let realHeight = response as? Double {
                self?.handleReal(realHeight)
            }
        }
    }
    private func handleReal(_ height: Double) {
        callback?(height)
    }
    
    public func update(_ rich: String) {
        guard rich.isEmpty == false else {
            return
        }
        let header = "<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/><meta  name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\"/></head>"
        let body = "<body style='width:100%;background-color:white;padding:0px;margin:0px;display:block;'><style>p{margin:0 !important;}</style>"
        let div = "<div id='rootid' style = 'width:100%;height:10px;background-color:white;display:block'></div>"
        let html = String(format: "<html> %@ %@ %@ </body></html>", header, body, rich, div)
        webView.loadHTMLString(html, baseURL: nil)
        debugPrint("load start...")
    }
}

extension RichHtmlPanel: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(assembleAdjusts(horizontalOffset)) { [weak self](ret, err) in
            debugPrint(err ?? "load end")
            self?.updateContentSize()
        }
    }
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateContentSize()
    }
}
