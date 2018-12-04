//
//  AudioIndicator.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/27.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import SBComponents

fileprivate let kMinBaseOscillationPeriod: CFTimeInterval = 0.6
fileprivate let kMaxBaseOscillationPeriod: CFTimeInterval = 0.8
fileprivate let kOscillationAnimationKey: String = "oscillation"

fileprivate let kDecayDuration: CFTimeInterval = 0.3
fileprivate let kDecayAnimationKey: String = "decay"

public enum IndicatorState {
    case idle
    case pause
    case playing
}

/// Indicator Style
struct IndicatoeStyle {
    public var barCount: UInt = 4
    public var barWidth: CGFloat = 2
    public var maxBarSpacing: CGFloat = 4
    public var idleBarHeight: CGFloat = 12
    public var minPeakbarHeight: CGFloat = 10
    public var maxPeakBarHeight: CGFloat = 22
    public func actualBarSpacing() -> CGFloat {
        let tmp = (maxBarSpacing + barWidth) * AppSize.SCALE_SCREEN
        return floor(tmp)/AppSize.SCALE_SCREEN - barWidth
    }
}

/// Indicator Animation
class IndicatorContent: UIView {
    
    /// Variables
    private lazy var barLayers: [CALayer] = {
        let s = [CALayer]()
        return s
    }()
    private var hasInstalledConstraints = false
    
    private lazy var style: IndicatoeStyle = {
        let s = IndicatoeStyle()
        return s
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        prepareBarLayers()
        tintColorDidChange()
        setNeedsUpdateConstraints()
    }
    
    private func prepareBarLayers() {
        barLayers.removeAll()
        var xOffset: CGFloat = 0
        let c = UIColor.white
        for i in 0..<style.barCount {
            let l = createLayer(xOffset, with: i, style: style)
            l.backgroundColor = c.cgColor
            barLayers.append(l)
            layer.addSublayer(l)
            xOffset = l.frame.maxX + style.actualBarSpacing()
        }
    }
    private func createLayer(_ offset: CGFloat, with Index: UInt, style: IndicatoeStyle) -> CALayer {
        let l = CALayer()
        l.anchorPoint = CGPoint(x: 0, y: 1.0)//bottom-left corner
        l.position = CGPoint(x: offset, y: style.maxPeakBarHeight) //super's coordinate
        let height = (Index % 2 == 0) ? style.idleBarHeight : style.maxPeakBarHeight
        l.bounds = CGRect(x: 0, y: 0, width: style.barWidth, height: height)//its own coodinate
        l.allowsEdgeAntialiasing = true
        return l
    }
    
    /// auto-layout
    override var intrinsicContentSize: CGSize {
        var unionFrame: CGRect = .zero
        barLayers.forEach { (l) in
            unionFrame = unionFrame.union(l.frame)
        }
        return unionFrame.size
    }
    override func updateConstraints() {
        if hasInstalledConstraints == false {
            let size = self.intrinsicContentSize
            let widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: size.width)
            self.addConstraint(widthConstraint)
            let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: size.height)
            self.addConstraint(heightConstraint)
            hasInstalledConstraints = true
        }
        
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// animations
    fileprivate func isOscillation() -> Bool {
        let animate = barLayers[0].animation(forKey: kOscillationAnimationKey)
        return animate != nil
    }
    fileprivate func stopOscillation() {
        barLayers.forEach { (l) in
            l.removeAnimation(forKey: kOscillationAnimationKey)
        }
    }
    fileprivate func startOscillation() {
        let basePeriod = kMinBaseOscillationPeriod + (drand48() * (kMaxBaseOscillationPeriod - kMinBaseOscillationPeriod))
        barLayers.forEach { (l) in
            startOscillation(l, base: basePeriod)
        }
    }
    private func startOscillation(_ layer: CALayer, base period: CFTimeInterval) {
        let tmp = style.maxPeakBarHeight - style.minPeakbarHeight + 1
        let peekHeight = style.minPeakbarHeight + CGFloat(arc4random_uniform(UInt32(tmp)))
        var to = layer.bounds
        to.size.height = peekHeight
        let animation = CABasicAnimation(keyPath: "bounds")
        animation.fromValue = layer.bounds
        animation.toValue = to
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.autoreverses = true
        animation.duration = (period/2.0)*Double((style.maxPeakBarHeight/peekHeight))
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: kOscillationAnimationKey)
    }
    
    fileprivate func stopDecay() {
        barLayers.forEach { (l) in
            l.removeAnimation(forKey: kDecayAnimationKey)
        }
    }
    fileprivate func startDecay() {
        barLayers.forEach { (l) in
            startDecaying(l)
        }
    }
    private func startDecaying(_ layer: CALayer) {
        let animation = CABasicAnimation(keyPath: "bounds")
        animation.fromValue = layer.presentation()?.bounds
        animation.toValue = layer.bounds
        animation.duration = kDecayDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: kDecayAnimationKey)
    }
    public func updateLineColor(_ color: UIColor) {
        barLayers.forEach { (l) in
            l.backgroundColor = color.cgColor
        }
    }
}

/// 音乐指示器
public class AudioIndicator: UIView {
    
    /// Variabales
    public var pState: IndicatorState = .idle {
        didSet {
            if pState == .idle {
                stopAnimating()
            } else {
                if pState == .playing {
                    startAnimating()
                } else if pState == .pause {
                    stopAnimating()
                }
            }
        }
    }
    private lazy var content: IndicatorContent = {
        let c = IndicatorContent(frame: .zero)
        return c
    }()
    private var hasInstalledConstraints = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.masksToBounds = true
        addSubview(content)
        
        prepareLayoutProperties()
        setNeedsUpdateConstraints()
        
        pState = .idle
        
        NotificationCenter.default.addObserver(self, selector: #selector(__applicationDidForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func __applicationDidForeground() {
        if pState == .playing {
            startAnimating()
        }
    }
    
    private func prepareLayoutProperties() {
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    override public func updateConstraints() {
        if hasInstalledConstraints == false {
            let xConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: self.content, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            addConstraint(xConstraint)
            let yConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: self.content, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            addConstraint(yConstraint)
            hasInstalledConstraints = true
        }
        super.updateConstraints()
    }
    override public var forLastBaselineLayout: UIView {
        return self.content
    }
    override public var intrinsicContentSize: CGSize {
        return self.content.intrinsicContentSize
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.intrinsicContentSize
    }
    
    private func startAnimating() {
        guard content.isOscillation() == false else{
            return
        }
        content.stopDecay()
        content.startOscillation()
    }
    private func stopAnimating() {
        guard content.isOscillation() else {
            return
        }
        content.stopOscillation()
        content.startDecay()
    }
    public func updateColor(_ color: UIColor) {
        content.updateLineColor(color)
    }
}
