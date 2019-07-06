//
//  CommentOnScene.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/10/31.
//  Copyright © 2018 nanhu. All rights reserved.
//

import SBComponents
import AlamofireImage
import IQKeyboardManagerSwift

fileprivate let kInputFont = UIFont.systemFont(ofSize: 13)
fileprivate let kOffsetVertical: CGFloat = 7
fileprivate let kOffsetHorizontal: CGFloat = 5
fileprivate let kChatActionBarOriginalHeight: CGFloat = 50      //ActionBar orginal height
fileprivate let kChatActionBarTextViewMaxHeight: CGFloat = 120   //Expandable textview max height

/// 全局评论scene（回复、评论）
public class CommentOnScene: BaseScene {
    /// vars
    public var callback: StringClosure?
    //private var fatherView: UIView?
    private var inputBarHeight: CGFloat = kChatActionBarOriginalHeight
    private var inputBarBottomOffsetActive: CGFloat = 0 /// 激活状态offset
    private var inputBarBottomOffsetNormal: CGFloat = AppSize.HEIGHT_INVALID_BOTTOM()///正常情况offset
    //private var inputBarActived: Bool = false
    /// 是否主动触发评论（是则可以响应键盘事件，否则不响应）
    private var activeTriggered: Bool = false
    /// lazy vars
    private lazy var inputBar: ComInputBar = {
        let s = ComInputBar(frame: .zero)
        return s
    }()
    private lazy var maskScene: BaseScene = {
        let s = BaseScene(frame: .zero)
        s.backgroundColor = ClearBgColor
        return s
    }()
    private lazy var bottomScene: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    
    /// getters
    public class func com(_ father: UIView?, bottom offset: CGFloat) -> CommentOnScene {
        return CommentOnScene(father, bottom: offset)
    }
    fileprivate class func bundledImage(named: String) -> UIImage? {
        let image = UIImage(named: named)
        if image == nil {
            return UIImage(named: named, in: Bundle(for: CommentOnScene.classForCoder()), compatibleWith: nil)
        }
        return image
    }
    init(_ father: UIView?, bottom offset: CGFloat) {
        super.init(frame: .zero)
        inputBarBottomOffsetNormal = offset
        //addSubview(maskScene)
        addSubview(inputBar)
        addSubview(bottomScene)
        inputBar.input.delegate = self
        inputBar.callback = {[weak self] in
            self?.willRelease()
        }
        backgroundColor = ClearBgColor
        installKeyboardObserves()
    }
    deinit {
        unInstallKeyboardObserves()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        let bh = max(0, inputBarBottomOffsetNormal)
        bottomScene.snp.makeConstraints { (m) in
            m.left.bottom.right.equalToSuperview()
            m.height.equalTo(bh)
        }
        inputBar.snp.removeConstraints()
        let offset = activeTriggered ? inputBarBottomOffsetActive : inputBarBottomOffsetNormal
        inputBar.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.bottom.equalToSuperview().offset(-offset)
            m.height.equalTo(inputBarHeight)
        }
    }
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard newSuperview == nil else {
            IQKeyboardManager.shared.enable = false
            IQKeyboardManager.shared.enableAutoToolbar = false
            return
        }
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else {
            return
        }
        self.snp.removeConstraints()
        self.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
    }
    /// events
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        dismiss()
    }
    
    /// outter
    public func configure(_ uri: URL?, with placeholder: String?="说点什么吧...") {
        inputBar.update(uri, with: placeholder)
    }
    public func show() {
        guard activeTriggered == false else {
            return
        }
        activeTriggered = true
        inputBar.focusOn()
    }
    public func dismiss() {
        guard activeTriggered == true else {
            return
        }
        inputBar.focusOff()
    }
    
    private func willRelease() {
        let inputs = (inputBar.input.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard inputs.isEmpty == false else {
            Kits.makeToast("说点什么吧...")
            return
        }
        dismiss()
        callback?(inputs)
    }
}
// MARK: - Keyboard Observes
extension CommentOnScene {
    /// keyboard
    private func installKeyboardObserves() {
        NotificationCenter.default.addObserver(self, selector: #selector(__keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(__keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func unInstallKeyboardObserves() {
        NotificationCenter.default.removeObserver(self)
    }
    @objc private func __keyboardWillShow(_ notify: NSNotification) {
        guard activeTriggered == true else {
            debugPrint("this was inactived, should not respond for showing")
            return
        }
        __kbDidChanged(notify, with: true)
    }
    @objc private func __keyboardWillHide(_ notify: NSNotification) {
        guard activeTriggered == true else {
            debugPrint("this was inactived, should not respond for hiding")
            return
        }
        __kbDidChanged(notify, with: false)
    }
    private func __kbDidChanged(_ notify: NSNotification, with show: Bool) {
        if show {
            forewardHierarchy()
        } else {
            inputBar.input.text = nil
            inputBarHeight = kChatActionBarOriginalHeight
            activeTriggered  = false
        }
        
        var userInfo = notify.userInfo!
        let kbRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey]! as! CGRect
        let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]! as! UInt
        let convertedFrame = convert(kbRect, from: nil)
        let opts = UIView.AnimationOptions(rawValue: curve << 16 | UIView.AnimationOptions.beginFromCurrentState.rawValue)
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]! as! Double
        inputBarBottomOffsetActive = show ? (bounds.height - convertedFrame.origin.y) : 0
        /// animation
        UIView.animate(withDuration: duration, delay: 0, options: opts, animations: {[weak self] in
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }) { [weak self](f) in
            guard f == true, show == false else {
                return
            }
            self?.backwardHierarchy()
        }
    }
    private func backwardHierarchy() {
        superview?.sendSubviewToBack(self)
    }
    private func forewardHierarchy() {
        superview?.bringSubviewToFront(self)
    }
}

// MARK: - Delegate
extension CommentOnScene: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            willRelease()
            return false
        }
        return true
    }
    public func textViewDidChange(_ textView: UITextView) {
        let contentH = textView.contentSize.height
        guard contentH < kChatActionBarTextViewMaxHeight else {
            return
        }
        let inputHeight = contentH + 17
        let fixedHeight = max(inputHeight, kChatActionBarOriginalHeight)
        guard fixedHeight != inputBarHeight else {
            return
        }
        inputBarHeight = fixedHeight
        UIView.animate(withDuration: Macros.APP_ANIMATE_INTERVAL) {[weak self] in
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }
    }
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        UIView.setAnimationsEnabled(false)
        let range = NSMakeRange(textView.text.count - 1, 1)
        textView.scrollRangeToVisible(range)
        UIView.setAnimationsEnabled(true)
        activeTriggered = true
        return true
    }
}

/// input panel
fileprivate class ComInputBar: BaseScene {
    /// vars
    public var callback: VoidClosure?
    /// lazy vars
    private lazy var scene: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    private lazy var releaseBtn: BaseButton = {
        let icon = CommentOnScene.bundledImage(named: "icon_scene_com_release")
        let b = BaseButton(type: .custom)
        b.setImage(icon, for: .normal)
        b.addTarget(self, action: #selector(willRelease), for: .touchUpInside)
        return b
    }()
    public lazy var input: IQTextView = {
        let i = IQTextView(frame: .zero)
        i.textColor = AppColor.COLOR_TITLE
        i.placeholderTextColor = AppColor.COLOR_TITLE_LIGHTGRAY
        i.placeholder = "说点什么吧..."
        i.font = kInputFont
        i.layer.borderColor = RGBA(r: 218, g: 218, b: 218, a: 1).cgColor
        i.layer.borderWidth = 1
        i.layer.cornerRadius = kOffsetHorizontal
        i.scrollsToTop = false
        i.textContainerInset = UIEdgeInsets(top: 9, left: kOffsetHorizontal, bottom: kOffsetHorizontal, right: kOffsetHorizontal)
        i.returnKeyType = .send
        i.enablesReturnKeyAutomatically = true
        i.layoutManager.allowsNonContiguousLayout = false
        return i
    }()
    private lazy var inputScene: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    private lazy var iconScene: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    private lazy var iconView: BaseImageView = {
        let i = BaseImageView(frame: .zero)
        i.backgroundColor = AppColor.COLOR_BG_GRAY
        return i
    }()
    private lazy var iconMask: UIImageView = {
        let i = UIImageView(frame: .zero)
        i.image = CommentOnScene.bundledImage(named: "icon_scene_com_usrmask")
        return i
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scene)
        scene.addSubview(iconScene)
        iconScene.addSubview(iconView)
        iconScene.addSubview(iconMask)
        scene.addSubview(releaseBtn)
        scene.addSubview(inputScene)
        inputScene.addSubview(input)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        scene.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        let isize = kChatActionBarOriginalHeight-kOffsetVertical*2
        iconScene.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(kOffsetHorizontal)
            m.width.height.equalTo(isize)
        }
        iconView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        iconMask.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        releaseBtn.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.right.equalToSuperview().offset(-kOffsetHorizontal)
            m.width.height.equalTo(isize)
        }
        inputScene.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalTo(iconScene.snp.right)
            m.right.equalTo(releaseBtn.snp.left)
        }
        let insets = UIEdgeInsets(top: kOffsetVertical, left: kOffsetVertical, bottom: kOffsetVertical, right: kOffsetVertical)
        input.snp.makeConstraints { (m) in
            m.edges.equalToSuperview().inset(insets)
        }
    }
    public func update(_ uri: URL?, with placeholder: String?="说点什么吧...") {
        input.placeholder = placeholder
        guard let url = uri else {
            return
        }
        //iconView.sd_setImage(with: uri, completed: nil)
        iconView.af_setImage(withURL: url)
    }
    public func focusOn() {
        input.becomeFirstResponder()
    }
    public func focusOff() {
        input.resignFirstResponder()
    }
    @objc private func willRelease() {
        callback?()
    }
}
