//
//  ScanProfile.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/8.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import CoreGraphics
import AVFoundation
import SBComponents

// MARK: - QRScan Result
fileprivate struct QRScanResult {
    var codeInfo: String?
    var codeType: String?
}

// MARK: - Line AnimateView
fileprivate class QRLineAnimator: UIImageView {
    var num: Int = 0
    var down: Bool = false
    var timer: Timer?
    var isAnimat: Bool = false
    var animationRect: CGRect = .zero
    
    deinit {
        self.stopAnimating()
    }
    
    override func stopAnimating() {
        if isAnimat {
            isAnimat = false
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
            self.removeFromSuperview()
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    public func startAnimating(_ animationRect: CGRect, parentView: UIView, image:UIImage) {
        if isAnimat {
            return
        }
        isAnimat = true
        self.animationRect = animationRect
        down = true
        num = 0
        
        let centery = animationRect.minY + animationRect.height * 0.5
        let leftx = animationRect.origin.x + 5
        let width = animationRect.width - 10
        
        self.frame = CGRect(x: leftx, y: centery+CGFloat(2*num), width: width, height: 2)
        self.image = image
        
        parentView.addSubview(self)
        self.startUIViewAnimation()
    }
    
    private func startUIViewAnimation() {
        self.stepAnimation()
    }
    
    @objc private func stepAnimation() {
        if !isAnimat {
            return
        }
        let leftx = animationRect.origin.x + 5
        let width = animationRect.width - 10
        self.frame = CGRect(x: leftx, y: animationRect.origin.y + 8, width: width, height: 8)
        
        self.alpha = 0.0
        self.isHidden = false
        
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.alpha = 1.0
        }
        let maxY = self.animationRect.origin.y + self.animationRect.size.height
        UIView.animate(withDuration: 3, animations: {[weak self] in
            let leftx = (self?.animationRect.origin.x)! + 5
            let width = (self?.animationRect.width)! - 10
            self?.frame = CGRect(x: leftx, y: maxY - 8, width: width, height: 4)
        }) { [weak self](f: Bool) in
            self?.isHidden = true
            self?.perform(#selector(self?.stepAnimation), with: nil, afterDelay: 0.3)
        }
    }
}

// MARK: - Scan View
fileprivate class QRScanView: UIView {
    var scanRectangleRect: CGRect = .zero
    var activityView: UIActivityIndicatorView?
    
    var labelReadying: UILabel?
    var lineAnimator: QRLineAnimator?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let XRectangleLeft:CGFloat = 60
        let bounds = self.bounds
        var sizeRectangle = CGSize(width: bounds.width - XRectangleLeft*2, height: bounds.width - XRectangleLeft*2)
        let whRadio:CGFloat = 1
        //宽高比 正方形为1
        if whRadio != 1 {
            let w = sizeRectangle.width
            let h = w / whRadio
            sizeRectangle = CGSize(width: w, height: h)
        }
        
        //扫码区域Y轴最小坐标
        let centerUpOffset: CGFloat = 30
        let YMinRectangle = bounds.height * 0.5 - sizeRectangle.height * 0.5 - centerUpOffset
        let YMaxRectangle = YMinRectangle + sizeRectangle.height
        let XRectangleRight = bounds.width - XRectangleLeft
        
        //custom property
        let isNeedShowRectnagle = true
        let colorRectangleLine = UIColor.white
        let notRecoginitionArea = UIColor(white: 0, alpha: 0.5)
        
        let ctx = UIGraphicsGetCurrentContext()
        //非扫码区域半透明
        //        let components = notRecoginitionArea.cgColor.components
        //        let red_ = components![0]
        //        let green_ = components![1]
        //        let blue_ = components![2]
        //        let alpha_ = components![3]
        //        ctx?.setFillColor(red: red_, green: green_, blue: blue_, alpha: alpha_)
        ctx?.setFillColor(notRecoginitionArea.cgColor)
        //填充矩形
        //上边填充
        var rect = CGRect(x: 0, y: 0, width: bounds.width, height: YMinRectangle)
        ctx?.fill(rect)
        //左边填充
        rect = CGRect(x: 0, y: YMinRectangle, width: XRectangleLeft, height: sizeRectangle.height)
        ctx?.fill(rect)
        //右边填充
        rect = CGRect(x: XRectangleRight, y: YMinRectangle, width: XRectangleLeft, height: sizeRectangle.height)
        ctx?.fill(rect)
        //下边填充
        rect = CGRect(x: 0, y: YMaxRectangle, width: bounds.width, height: bounds.height-YMaxRectangle)
        ctx?.fill(rect)
        //执行绘画
        ctx?.strokePath()
        
        //中间画矩形（正方形）
        if isNeedShowRectnagle {
            ctx?.setStrokeColor(colorRectangleLine.cgColor)
            ctx?.setLineWidth(1)
            rect = CGRect(x: XRectangleLeft, y: YMinRectangle, width: sizeRectangle.width, height: sizeRectangle.height)
            ctx?.addRect(rect)
            ctx?.strokePath()
        }
        //扫描区域
        self.scanRectangleRect = rect
        
        //矩形框 四个角
        let wAngle:CGFloat = 18;let hAngle:CGFloat = 18;
        let linewidthAngle:CGFloat = 2;//角的线宽度
        var diffAngle:CGFloat = 0.0
        
        diffAngle = -linewidthAngle * 0.5
        let colorAngle = UIColor(red: 0.0, green: 200.0/255, blue: 20.0/255, alpha: 1.0)
        ctx?.setStrokeColor(colorAngle.cgColor)
        ctx?.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        ctx?.setLineWidth(linewidthAngle)
        
        let leftX = XRectangleLeft - diffAngle
        let topY = YMinRectangle - diffAngle
        let rightX = XRectangleRight + diffAngle
        let bottomY = YMaxRectangle + diffAngle
        
        //左上角水平线
        ctx?.move(to: CGPoint(x: leftX - linewidthAngle * 0.5, y: topY))
        ctx?.addLine(to: CGPoint(x: leftX + wAngle, y: topY))
        //左上角垂直线
        ctx?.move(to: CGPoint(x: leftX, y: topY - linewidthAngle * 0.5))
        ctx?.addLine(to: CGPoint(x: leftX, y: topY + hAngle))
        //左下角水平线
        ctx?.move(to: CGPoint(x: leftX - linewidthAngle * 0.5, y: bottomY))
        ctx?.addLine(to: CGPoint(x: leftX + wAngle, y: bottomY))
        //左下角垂直线
        ctx?.move(to: CGPoint(x: leftX, y: bottomY+linewidthAngle*0.5))
        ctx?.addLine(to: CGPoint(x: leftX, y: bottomY - hAngle))
        //右上角水平线
        ctx?.move(to: CGPoint(x: rightX+linewidthAngle*0.5, y: topY))
        ctx?.addLine(to: CGPoint(x: rightX-wAngle, y: topY))
        //右上角垂直线
        ctx?.move(to: CGPoint(x: rightX, y: topY-linewidthAngle*0.5))
        ctx?.addLine(to: CGPoint(x: rightX, y: topY+hAngle))
        //右下角水平线
        ctx?.move(to: CGPoint(x: rightX+linewidthAngle*0.5, y: bottomY))
        ctx?.addLine(to: CGPoint(x: rightX-wAngle, y: bottomY))
        //右下角垂直线
        ctx?.move(to: CGPoint(x: rightX, y: bottomY+linewidthAngle*0.5))
        ctx?.addLine(to: CGPoint(x: rightX, y: bottomY-hAngle))
        ctx?.strokePath()
    }
    
    public func startDeviceReadying(_ text: String) {
        let XRectangleLeft:CGFloat = 60
        let bounds = self.bounds
        let sizeRectangle = CGSize(width: bounds.width - XRectangleLeft*2, height: bounds.width - XRectangleLeft*2)
        //扫码区域Y最小坐标
        let centerUpOffset:CGFloat = -20
        let YMinRectangle = bounds.height * 0.5 - sizeRectangle.height * 0.5 - centerUpOffset
        //设备启动状态提示
        if activityView == nil {
            activityView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            activityView?.center = CGPoint(x: XRectangleLeft + sizeRectangle.width*0.5 - 50, y: YMinRectangle + sizeRectangle.height*0.5)
            activityView?.style = .whiteLarge
            self.addSubview(activityView!)
            let activityFrame = (activityView?.frame)!
            let labelBounds = CGRect(x: activityFrame.origin.x + activityFrame.width + 10, y: activityFrame.origin.y, width: 100, height: 30)
            labelReadying = UILabel(frame: labelBounds)
            labelReadying?.font = UIFont.systemFont(ofSize: 18)
            labelReadying?.text = text
            labelReadying?.textColor = UIColor.white
            self.addSubview(labelReadying!)
            activityView?.startAnimating()
        }
    }
    
    public func stopDeviceReadying() {
        if let act = activityView {
            act.stopAnimating()
            act.removeFromSuperview()
            labelReadying?.removeFromSuperview()
            activityView = nil
            labelReadying = nil
        }
    }
    
    public func startScanAnimation() {
        if lineAnimator == nil {
            lineAnimator = QRLineAnimator(frame: .zero);
        }
        let img = QRScanProfile.bundledImage(named: "qr_scan_line")
        self.lineAnimator?.startAnimating(self.scanRectangleRect, parentView: self, image: img!)
    }
    
    public func stopScanAnimation() {
        self.lineAnimator?.stopAnimating()
    }
}

// MARK: - QR Scan Engine
typealias scanEngileCallback = (_ error: Error?) -> Void
fileprivate class QRScanEngine: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var callback: scanEngileCallback?
    var bNeedScanResult: Bool = false
    public lazy var resultSets:[QRScanResult] = {
        let s = [QRScanResult]()
        return s
    }()
    
    /// 视频预览视图
    weak var videoPreview: UIView?
    
    private var scanRect: CGRect = .zero
    private var device: AVCaptureDevice?
    private var input: AVCaptureDeviceInput?
    private var output: AVCaptureMetadataOutput?
    private var session: AVCaptureSession?
    private var preview: AVCaptureVideoPreviewLayer?
    private var stillImageOutput: AVCapturePhotoOutput?//拍照
    
    override init() {
        super.init()
    }
    deinit {
        device?.removeObserver(self, forKeyPath: "adjustingFocus")
    }
    init(_ preview: UIView, scanRect: CGRect) {
        super.init()
        self.configure(preview, scanRect: scanRect)
    }
    
    private func configure(_ preview: UIView, scanRect: CGRect) {
        self.videoPreview = preview
        //device
        let tmpDevice = AVCaptureDevice.default(for: AVMediaType.video)
        guard let d = tmpDevice else {
            debugPrint("failed to create device!")
            return
        }
        device = d
        // auto focus
        d.addObserver(self, forKeyPath: "adjustingFocus", options: [.new, .old], context: nil)
        //input
        guard let tmpInput = try? AVCaptureDeviceInput(device: d) else {
            debugPrint("failed to create device input!")
            return
        }
        input = tmpInput
        bNeedScanResult = true
        //output
        output = AVCaptureMetadataOutput()
        output?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        //scan rect
        if scanRect.equalTo(.zero) == false {
            output?.rectOfInterest = scanRect
        }
        //setup still image file output
        stillImageOutput = AVCapturePhotoOutput()
        var outputSettings = [String: String]()
        outputSettings[AVVideoCodecKey] = AVVideoCodecJPEG
        let photoSetting = AVCapturePhotoSettings(format: outputSettings)
        stillImageOutput?.photoSettingsForSceneMonitoring = photoSetting
        
        //session
        session = AVCaptureSession()
        session?.sessionPreset = .high
        
        //add input/output
        if session!.canAddInput(input!) {
            session?.addInput(input!)
        }
        if session!.canAddOutput(output!) {
            session?.addOutput(output!)
        }
        if session!.canAddOutput(stillImageOutput!) {
            session?.addOutput(stillImageOutput!)
        }
        
        //码类型
        let codeTypes = self.metaDataObjectTypes()
        output?.metadataObjectTypes = codeTypes
        
        //preview
        self.preview = AVCaptureVideoPreviewLayer(session: session!)
        self.preview?.videoGravity = .resizeAspectFill
        //adjust frame
        let bounds = preview.bounds
        self.preview?.frame = bounds
        preview.layer.insertSublayer(self.preview!, at: 0)
        
        //capture connection
        //let videoConn = self.connection(AVMediaType.video, forConn: (stillImageOutput?.connections)!)
        //let scale = videoConn?.videoScaleAndCropFactor
        
        //先进行判断是否支持控制对焦,不开启自动对焦功能，很难识别二维码。
        if (device?.isFocusPointOfInterestSupported)! && (device?.isFocusModeSupported(.autoFocus))! {
            guard ((try? input?.device.lockForConfiguration()) != nil) else {
                return
            }
            input?.device.focusMode = .autoFocus
            input?.device.unlockForConfiguration()
        }
    }
    
    private func metaDataObjectTypes() -> [AVMetadataObject.ObjectType] {
        let types:[AVMetadataObject.ObjectType] = [
            .qr, .upce, .code39, .code39Mod43, .ean13, .ean8, .code93, .code128, .pdf417, .aztec]
        return types
    }
    
    private func connection(_ mediaType: AVMediaType, forConn:[AVCaptureConnection]) -> AVCaptureConnection? {
        var conn:AVCaptureConnection?
        forConn.forEach { (c) in
            let ports = c.inputPorts
            ports.forEach({ (p) in
                if p.mediaType == mediaType {
                    conn = c
                }
            })
        }
        return conn
    }
    
    public func startScan() {
        if let _ = input, self.session?.isRunning == false {
            self.session?.startRunning()
            bNeedScanResult = true
        }
        bNeedScanResult = true
    }
    
    public func stopScan() {
        bNeedScanResult = false
        if let _ = input, self.session?.isRunning == true {
            self.session?.stopRunning()
            bNeedScanResult = false
        }
    }
    
    /// Delegate for output
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if bNeedScanResult == false {
            return
        }
        bNeedScanResult = false
        //重置结果集
        self.resultSets.removeAll()
        //识别
        for (_, o) in metadataObjects.enumerated() {
            if o.isKind(of: AVMetadataMachineReadableCodeObject.self) {
                bNeedScanResult = false
                debugPrint("识别类型:\(o.type)")
                guard let scanned = o as? AVMetadataMachineReadableCodeObject, let ret = scanned.stringValue else {
                    return
                }
                var newRet = QRScanResult()
                newRet.codeInfo = ret
                newRet.codeType = scanned.type.rawValue
                self.resultSets.append(newRet)
            }
        }
        if self.resultSets.count == 0 {
            bNeedScanResult = true
            return
        }
        self.stopScan()
        //callback
        self.callback?(nil)
    }
    //MARK: - Observing
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "adjustingFocus" {
            debugPrint("adjustingFocus")
            guard let d = device else {
                debugPrint("empty device for focus")
                return
            }
            let width = scanRect.width
            let point = CGPoint(x: scanRect.minX+width*0.5, y: scanRect.minY+width*0.5)
            do {
                try d.lockForConfiguration()
                //对焦模式和对焦点
                if d.isFocusModeSupported(.autoFocus) {
                    d.focusPointOfInterest = point
                    d.focusMode = .autoFocus
                }
                //曝光模式 曝光点
                if d.isExposureModeSupported(.autoExpose) {
                    d.exposurePointOfInterest = point
                    d.exposureMode = .autoExpose
                }
                d.unlockForConfiguration()
            } catch {
                debugPrint("try lock error:\(error.localizedDescription)")
            }
        }
    }
}

// MARK: - ==================================================================================================
// MARK: - QR Scan Profile
open class QRScanProfile: BaseProfile {
    /// - Variables
    lazy private var scanView: QRScanView = {
        let s = QRScanView(frame: self.view.bounds)
        return s
    }()
    lazy private var scanEngine: QRScanEngine = {
        let scanRect = CGRect.zero
        let videoView = UIView(frame: self.view.bounds)
        self.view.insertSubview(videoView, at: 0)
        let e = QRScanEngine(videoView, scanRect: scanRect)
        e.callback = { [weak self](err: Error?) in
            guard err == nil else {
                self?.alertError(err!.localizedDescription)
                return
            }
            self?.didScanResult()
        }
        return e
    }()
    //是否为自动扫描 否则为手动输入
    private var whetherAutoScan: Bool = true
    lazy private var inputScene: BaseScene = {
        let s = BaseScene(frame: .zero)
        s.isHidden = true
        s.backgroundColor = RGBA(r: 70, g: 70, b: 70, a: 1)
        return s
    }()
    lazy private var inputActive: BaseTextField = {
        let input = BaseTextField(frame: .zero)
        input.font = UIFont(name: AppFont.PF_SC, size: AppFont.SIZE_TITLE)
        input.placeholder = "请输入课程激活码"
        input.keyboardType = .phonePad
        input.sb_maxLength = Macros.LENGTH_MOBILE_CN
        input.returnKeyType = .go
        return input
    }()
    private var params: SBParameter?
    public init(_ parameters: SBParameter?) {
        super.init(nibName: nil, bundle: nil)
        params = parameters
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.scanEngine.stopScan()
        self.scanView.stopScanAnimation()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard whetherAutoScan else {
            debugPrint("should not start camera!")
            return
        }
        self.scanView.startDeviceReadying("相机启动中...")
        //不延时，可能会导致界面黑屏并卡住一会
        self.perform(#selector(startScanAction), with: nil, afterDelay: 0.25)
    }
    
    private func clearResource() {
        self.scanView.stopDeviceReadying()
    }
    
    private func alertError(_ error: String) {
        let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
        let action = UIAlertAction(title: "知道了", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func startScanAction() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        guard status == .authorized || status == .notDetermined else {
            self.clearResource()
            self.alertError("请到设置隐私中开启本程序相机权限!")
            return
        }
        self.clearResource()
        //start scan
        self.scanEngine.startScan()
        self.scanView.startScanAnimation()
    }
    
    @objc private func stopScanAction() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.scanEngine.stopScan()
        self.scanView.stopScanAnimation()
    }
    
    /// 扫描成功
    private func didScanResult() {
        self.scanView.stopScanAnimation()
        guard let ret = self.scanEngine.resultSets.first, let info = ret.codeInfo else {
            self.alertError("无法处理扫描结果！请选择其他应用扫码")
            return
        }
        stopScanAction()
        handle(info)
    }
    
    /// - Outter Actions
    @objc private func scanEvent() {
        guard whetherAutoScan == false else {
            return
        }
        whetherAutoScan = true
        inputScene.isHidden = true
        startScanAction()
    }
    @objc private func inputEvent() {
        guard whetherAutoScan == true else {
            return
        }
        whetherAutoScan = false
        inputScene.isHidden = false
        stopScanAction()
        self.inputActive.becomeFirstResponder()
    }
    @objc private func preActiceEvent() {
        guard let input = inputActive.text else {
            Kits.makeToast("请先输入激活码！")
            return
        }
        handle(input)
    }
    
    open func handle(_ code: String) {
        //TODO:需子类实现
    }
    public func restartScanEngine() {
        whetherAutoScan = true
        inputScene.isHidden = true
        startScanAction()
    }
}

// MARK: - UI-Layouts
extension QRScanProfile {
    class func bundledImage(named: String) -> UIImage? {
        let image = UIImage(named: named)
        if image == nil {
            return UIImage(named: named, in: Bundle(for: QRScanProfile.classForCoder()), compatibleWith: nil)
        } // Replace MyBasePodClass with yours
        return image
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        
        self.view.addSubview(self.navigationBar)
        let sapce = Kits.barSpacer()
        let back = Kits.defaultBackBarItem(self, action: #selector(defaultGobackStack))
        let Item = UINavigationItem(title: "扫一扫")
        Item.leftBarButtonItems = [sapce, back];
        navigationBar.pushItem(Item, animated: true)
        
        //add scan view
        view.insertSubview(self.scanView, belowSubview: navigationBar)
    }
    
    /// 子类选择UI
    public func configure() {
        
    }
    /// 课程激活扫码
    public func configureCourseScanSubviews() {
        //input scene
        view.insertSubview(self.inputScene, belowSubview: navigationBar)
        inputScene.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let horizonOffset = AppSize.WIDTH_BOUNDARY
        var scene = BaseScene(frame: .zero)
        inputScene.addSubview(scene)
        scene.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(AppSize.HEIGHT_CELL*2.6)
            make.left.equalToSuperview().offset(horizonOffset)
            make.right.equalToSuperview().offset(-horizonOffset)
            make.height.equalTo(AppSize.HEIGHT_CELL)
        }
        scene.addSubview(self.inputActive)
        inputActive.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: AppSize.WIDTH_MARGIN, bottom: 0, right: AppSize.WIDTH_MARGIN))
        }
        let bgImage = UIImage.sb_imageWithColor(AppColor.COLOR_THEME)
        var btn = BaseButton(type: .custom)
        btn.titleLabel?.font = UIFont(name: AppFont.PF_BOLD, size: AppFont.SIZE_TITLE)
        btn.setTitle("激活", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setBackgroundImage(bgImage, for: .normal)
        btn.addTarget(self, action: #selector(preActiceEvent), for: .touchUpInside)
        inputScene.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(scene.snp.bottom).offset(AppSize.HEIGHT_ICON)
            make.left.equalToSuperview().offset(horizonOffset)
            make.right.equalToSuperview().offset(-horizonOffset)
            make.height.equalTo(AppSize.HEIGHT_CELL)
        }
        
        //add kit tool scene
        scene = BaseScene(frame: .zero)
        scene.backgroundColor = UIColor(white: 0, alpha: 0.55)
        view.addSubview(scene)
        scene.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-AppSize.HEIGHT_INVALID_BOTTOM())
            make.height.equalTo(AppSize.HEIGHT_CELL*2)
        }
        //vertival line
        let line = UIView(frame: .zero)
        scene.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(AppSize.HEIGHT_ICON)
        }
        //weichat
        let smallFont = AppFont.iconFont(AppFont.SIZE_SUB_TITLE)
        let iconColor = UIColor.white
        var icon = QRScanProfile.bundledImage(named: "qr_icon_scan")
        btn = BaseButton(type: .custom)
        btn.titleLabel?.font = smallFont
        btn.setTitleColor(iconColor, for: .normal)
        btn.setTitle("扫描二维码", for: .normal)
        btn.setImage(icon, for: .normal)
        btn.addTarget(self, action: #selector(scanEvent), for: .touchUpInside)
        scene.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.centerY.equalTo(line)
            make.right.equalTo(line.snp.left)
        }
        btn.sb_fixImagePosition(.top, spacing: AppSize.WIDTH_DIS)
        icon = QRScanProfile.bundledImage(named: "qr_icon_input")
        btn = BaseButton(type: .custom)
        btn.titleLabel?.font = smallFont
        btn.setTitleColor(iconColor, for: .normal)
        btn.setTitle("手动输入", for: .normal)
        btn.setImage(icon, for: .normal)
        btn.addTarget(self, action: #selector(inputEvent), for: .touchUpInside)
        scene.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.centerY.equalTo(line)
            make.left.equalTo(line.snp.right)
        }
        btn.sb_fixImagePosition(.top, spacing: AppSize.WIDTH_DIS)
    }
}
