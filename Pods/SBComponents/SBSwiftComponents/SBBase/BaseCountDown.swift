//
//  BaseCountDown.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/15.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import Foundation

public typealias CountDownChanging = (Int)->String
public typealias CountDownFinished = (Int)->String
public typealias CountDownTriggerHandler = (Int)->Void

public class CountDownButton: UIButton {
    
    /// Variables
    private var seconds: Int = 0
    private var totalSeconds: Int = 0
    private var timer: Timer?
    
    /// Callbacks
    public var didTrigger: CountDownTriggerHandler?
    public var changing: CountDownChanging?
    public var finished: CountDownFinished?
    
    /// Overrides
    public init(type buttonType: UIButtonType) {
        super.init(frame: .zero)
        self.addTarget(self, action: #selector(didTouched), for: .touchUpInside)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func didTouched() {
        let __tag = self.tag
        DispatchQueue.main.async {[weak self] in
            self?.didTrigger?(__tag)
        }
    }
    deinit {
        clearTimer()
    }
    /// Methods
    private func clearTimer() {
        guard let t = timer else {
            return
        }
        if t.isValid {
            t.invalidate()
        }
        timer = nil
    }
    public func start(_ total: Int) {
        seconds = total
        totalSeconds = total
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fired), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .commonModes)
    }
    @objc private func fired() {
        seconds -= 1
        if seconds < 0 {
            stop()
        } else {
            var title: String?
            if let chan = changing {
                title = chan(seconds)
            } else {
                title = String(format: "%zd秒", seconds)
            }
            Macros.executeInMain {[weak self]in
                self?.setTitle(title, for: .normal)
                self?.setTitle(title, for: .disabled)
            }
        }
    }
    private func stop() {
        clearTimer()
        seconds = totalSeconds
        var title: String = "重新获取"
        if let chan = finished {
            title = chan(totalSeconds)
        }
        Macros.executeInMain {[weak self]in
            self?.setTitle(title, for: .normal)
            self?.setTitle(title, for: .disabled)
        }
    }
}
