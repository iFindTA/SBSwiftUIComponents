//
//  StringExt.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/4.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import Foundation

fileprivate struct DateFmt {
    public let fmt: DateFormatter!
    static let shared = DateFmt()
    private init() {
        debugPrint("once for fmt!")
        fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
}
fileprivate struct DateYearFmt {
    public let fmt: DateFormatter!
    static let shared = DateYearFmt()
    private init() {
        debugPrint("once for year fmt!")
        fmt = DateFormatter()
        fmt.dateFormat = "yyyy"
    }
}
fileprivate struct DateFmtDay {
    public let fmt: DateFormatter!
    static let shared = DateFmtDay()
    private init() {
        debugPrint("once for fmt!")
        fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
    }
}
fileprivate struct DateFmtMonth {
    public let fmt: DateFormatter!
    static let shared = DateFmtMonth()
    private init() {
        debugPrint("once for fmt!")
        fmt = DateFormatter()
        fmt.dateFormat = "MM-dd HH:mm"
    }
}
fileprivate struct DateFmtYear {
    public let fmt: DateFormatter!
    static let shared = DateFmtYear()
    private init() {
        debugPrint("once for fmt!")
        fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm"
    }
}

// MARK: - String Extension
public extension String {
    public static func available(_ info: String?, replace: String="") -> String {
        guard let i = info, i.count > 0 else {
            return replace
        }
        return i
    }
    public func sb_matchRegex(_ p: String) -> Bool {
        guard self.isEmpty == false else {
            return false
        }
        let predicate = NSPredicate(format: "SELF MATCHES %@", p)
        return predicate.evaluate(with: self)
    }
    public func sb_size(_ width: CGFloat, font: UIFont) -> CGSize {
        guard self.count > 0 else {
            return .zero
        }
        let bounds = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return bounds.size
    }
    /// 时间转换（2018-10-09 12:29:30）
    public func sb_timeFormat() -> String {
        guard let date = DateFmt.shared.fmt.date(from: self) else {
            return "哈哈，穿越了"
        }
        let now = Date()
        let deltaSeconds = fabs(date.timeIntervalSince(now))
        let deltaMinutes: Double = deltaSeconds / 60
        if deltaSeconds < 60 {
            return "刚刚"
        } else if deltaMinutes < 60 {
            return String(format: "%d分钟前", Int(deltaMinutes))
        } else if deltaMinutes < 120 {
            return "1小时前"
        } else if deltaMinutes < (24 * 60.0) {
            let hours = Int(floor(deltaMinutes/60.0))
            return String(format: "%d小时前", hours)
        } else if deltaMinutes < (24 * 60.0 * 31) {
            let ds = Int(floor(deltaMinutes / (60.0 * 24)))
            return String(format: "%d天前", ds)
        } else if deltaMinutes < (24 * 60.0 * 365.25) {
            let ms = Int(floor(deltaMinutes / (60.0 * 24 * 30)))
            return String(format: "%d个月前", ms)
        }
        let years = Int(floor(deltaMinutes / (60.0 * 24 * 365)))
        return String(format: "%d年前", years)
    }
    public func sb_timeAgo() -> String {
        /// 转化为 NSDate
        guard let date = DateFmt.shared.fmt.date(from: self) else {
            return "哈哈，穿越了"
        }
        /// year judge
        guard isThisYear(date) else {
            /// 其他年
            return DateFmtYear.shared.fmt.string(from: date)
        }
        /// 今年
        let calendar = Calendar.current
        /// 今天
        if calendar.isDateInToday(date) {
            let interval:Int = abs(Int(date.timeIntervalSinceNow))
            
            if interval < 60{
                return "刚刚"
            } else if interval < 60 * 60{
                return "\(interval/60)分钟前"
            } else if interval < 60 * 60 * 24{
                return "\(interval/60/24)小时前"
            }
        }else if calendar.isDateInYesterday(date){
            /// 昨天
            return "昨天 \(DateFmtDay.shared.fmt.string(from: date))"
        } else {
            /// 本月的其他天
            return DateFmtMonth.shared.fmt.string(from: date)
        }
        return ""
    }
    private func isThisYear(_ date: Date) -> Bool{
        //1.获取当前年份字符串
        let currentYearStr = DateYearFmt.shared.fmt.string(from: Date())
        //2.获取微博年份字符串
        let statusYearStr = DateYearFmt.shared.fmt.string(from: Date())
        return currentYearStr == statusYearStr
    }
}
