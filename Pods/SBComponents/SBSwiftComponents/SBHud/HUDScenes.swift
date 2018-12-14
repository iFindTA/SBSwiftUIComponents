//
//  HUDScenes.swift
//  SBSwiftComponents
//
//  Created by nanhu on 11/17/18.
//  Copyright © 2018 nanhu. All rights reserved.
//

import UIKit

/// loading ball
fileprivate let ballSize: CGFloat = 13
fileprivate let ballScale: CGFloat = 1.5
fileprivate let ballMargin: CGFloat = 3
fileprivate let ballSceneSize: CGFloat = 100
fileprivate let ballSceneBounds = CGRect(x: 0, y: 0, width: 100, height: 100)

/// shared instance
fileprivate var instance: BallLoading?

/// 球球loading
public class BallLoading: UIView {
    /// vars lets
    private let animationDuration: CGFloat = 1.6
    private let ballBounds = CGRect(x: 0, y: 0, width: 13, height: 13)
    private let colorLeft = RGBA(r: 54, g: 136, b: 250, a: 1)
    private let colorMiddle = RGBA(r: 100, g: 100, b: 100, a: 1)
    private let colorRight = RGBA(r: 234, g: 67, b: 69, a: 1)
    private var stopAnimationByUser: Bool = false
    /// lazy vars
    private lazy var ballContainer: UIVisualEffectView = {
        let bf = CGRect(x: 0, y: 0, width: 100, height: 100)
        let style = UIBlurEffect(style: UIBlurEffect.Style.light)
        let s = UIVisualEffectView(effect: style)
        s.frame = bf
        s.center = CGPoint(x: ballSceneSize*0.5, y: ballSceneSize*0.5)
        s.layer.masksToBounds = true
        s.layer.cornerRadius = 10
        return s
    }()
    private lazy var ballLeft: UIView = {
        let s = UIView(frame: ballBounds)
        s.center = CGPoint(x: ballSize*0.5+ballMargin, y: ballSceneSize*0.5)
        s.layer.cornerRadius = ballSize*0.5
        s.backgroundColor = colorLeft
        return s
    }()
    private lazy var ballMiddle: UIView = {
        let s = UIView(frame: ballBounds)
        s.center = CGPoint(x: ballSceneSize*0.5, y: ballSceneSize*0.5)
        s.layer.cornerRadius = ballSize*0.5
        s.backgroundColor = colorMiddle
        return s
    }()
    private lazy var ballRight: UIView = {
        let s = UIView(frame: ballBounds)
        s.center = CGPoint(x: ballSceneSize - ballSize*0.5 - ballMargin, y: ballSceneSize*0.5)
        s.layer.cornerRadius = ballSize*0.5
        s.backgroundColor = colorRight
        return s
    }()
    //fileprivate static let shared = BallLoading(frame: ballSceneBounds)
    fileprivate class func shared() -> BallLoading {
        guard let ivar = instance else {
            let s = BallLoading(frame: ballSceneBounds)
            instance = s
            return s
        }
        return ivar
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(ballContainer)
        ballContainer.contentView.addSubview(ballMiddle)
        ballContainer.contentView.addSubview(ballLeft)
        ballContainer.contentView.addSubview(ballRight)
        
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func startAnimations() {
        ballLeft.layer.removeAllAnimations()
        ballRight.layer.removeAllAnimations()
        //-------第一个球的动画
        let width: CGFloat = ballContainer.bounds.size.width
        //小圆半径
        let r: CGFloat = ballSize * ballScale * 0.5
        //大圆半径
        let R: CGFloat = (width / 2 + r) * 0.5
        
        let path1 = UIBezierPath()
        path1.move(to: ballLeft.center)
        //画大圆
        path1.addArc(withCenter: CGPoint(x: R + r, y: width / 2), radius: R, startAngle: .pi, endAngle: .pi * 2, clockwise: false)
        //画小圆
        let path1_1 = UIBezierPath()
        path1_1.addArc(withCenter: CGPoint(x: width / 2, y: width / 2), radius: r * 2, startAngle: .pi * 2, endAngle: .pi, clockwise: false)
        path1.append(path1_1)
        //回到原处
        path1.addLine(to: ballLeft.center)
        //执行动画
        let animation1 = CAKeyframeAnimation(keyPath: "position")
        animation1.path = path1.cgPath
        animation1.isRemovedOnCompletion = true
        animation1.duration = CFTimeInterval(animationDuration)
        animation1.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        ballLeft.layer.add(animation1, forKey: "animation1")
        
        //-------第三个球的动画
        let path3 = UIBezierPath()
        path3.move(to: ballRight.center)
        //画大圆
        path3.addArc(withCenter: CGPoint(x: width - (R + r), y: width / 2), radius: R, startAngle: 2 * .pi, endAngle: .pi, clockwise: false)
        //画小圆
        let path3_1 = UIBezierPath()
        path3_1.addArc(withCenter: CGPoint(x: width / 2, y: width / 2), radius: r * 2, startAngle: .pi, endAngle: .pi * 2, clockwise: false)
        path3.append(path3_1)
        //回到原处
        path3.addLine(to: ballRight.center)
        //执行动画
        let animation3 = CAKeyframeAnimation(keyPath: "position")
        animation3.path = path3.cgPath
        animation3.isRemovedOnCompletion = true
        animation3.duration = CFTimeInterval(animationDuration)
        animation3.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation3.delegate = self
        ballRight.layer.add(animation3, forKey: "animation3")
    }
}

extension BallLoading: CAAnimationDelegate {
    public func animationDidStart(_ anim: CAAnimation) {
        let delay: CGFloat = 0.3
        let duration = CGFloat(animationDuration * 0.5) - delay
        let transform = CGAffineTransform(scaleX: ballScale, y: ballScale)
        let identity = CGAffineTransform.identity
        UIView.animate(withDuration: TimeInterval(duration), delay: TimeInterval(delay), options: [.curveEaseOut, .beginFromCurrentState], animations: {[weak self] in
            self?.ballLeft.transform = transform
            self?.ballMiddle.transform = transform
            self?.ballRight.transform = transform
        }) { finished in
            UIView.animate(withDuration: TimeInterval(duration), delay: TimeInterval(delay), options: [.curveEaseInOut, .beginFromCurrentState], animations: {[weak self] in
                self?.ballLeft.transform = identity
                self?.ballMiddle.transform = identity
                self?.ballRight.transform = identity
            })
        }
    }
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard stopAnimationByUser == false else {
            return
        }
        startAnimations()
    }
    
    fileprivate func start() {
        stopAnimationByUser = false
        startAnimations()
    }
    fileprivate func stop() {
        stopAnimationByUser = true
        ballLeft.transform = .identity
        ballLeft.layer.removeAllAnimations()
        ballRight.transform = .identity
        ballRight.layer.removeAllAnimations()
        ballMiddle.transform = .identity
    }
    public class func configure() {
        _ = BallLoading.shared()
    }
    public class func show() {
        let ballScene = BallLoading.shared()
        if ballScene.superview == nil {
            UIApplication.shared.keyWindow?.addSubview(ballScene)
            ballScene.snp.makeConstraints { (m) in
                m.center.equalToSuperview()
                m.width.height.equalTo(100)
            }
        }
        ballScene.start()
        ballScene.isHidden = false
    }
    public class func hide() {
        let ballScene = BallLoading.shared()
        ballScene.stop()
        ballScene.isHidden = true
    }
}
