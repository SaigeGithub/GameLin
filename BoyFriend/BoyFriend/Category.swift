//
//  String+Category.swift
//  BoyFriend
//
//  Created by 谢冠章 on 2018/10/13.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit
import Foundation
import CommonCrypto
import Gifu


//  UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightMedium)
// 计算文字高度或者宽度与weight参数无关
extension String {
    func ga_widthForComment(fontSize: CGFloat, height: CGFloat = 15) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return ceil(rect.width)
    }
    
    func ga_heightForComment(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return ceil(rect.height)
    }
    
    func ga_heightForComment(fontSize: CGFloat, width: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return ceil(rect.height)>maxHeight ? maxHeight : ceil(rect.height)
    }
    //计算UILabel的高度(带有行间距的情况)
    func getSpaceLabelHeight(fontSize:CGFloat,width:CGFloat,lineSpace:CGFloat) -> CGFloat{
        let style =  NSMutableParagraphStyle()
        style.lineBreakMode = .byCharWrapping
        style.alignment = .left
        style.lineSpacing = lineSpace
        style.hyphenationFactor = 1.0
        style.firstLineHeadIndent = 0.0
        style.paragraphSpacingBefore = 0.0
        style.headIndent = 0
        style.tailIndent = 0
        let dic = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),NSAttributedStringKey.paragraphStyle:style]
        
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: dic as [NSAttributedStringKey : Any], context: nil).size
        
        
        return rect.height;
    }
    func localString() -> String{
        return NSLocalizedString(self, comment: "")
    }
    var md5 : String{
        
        let str = self.cString(using: Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: Encoding.utf8))
        
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result);
        
        let hash = NSMutableString();
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i]);
        }
        
        result.deallocate()
        
        return String(format: hash as String)
    }


    
}
extension UILabel{
    //给UILabel设置行间距和字间距
    func setLabelSpace(font:UIFont,str:String,lineSpace:CGFloat) -> Void{
        let style =  NSMutableParagraphStyle()
        style.lineBreakMode = .byCharWrapping
        style.alignment = .left
        style.lineSpacing = lineSpace
        style.hyphenationFactor = 1.0
        style.firstLineHeadIndent = 0.0
        style.paragraphSpacingBefore = 0.0
        style.headIndent = 0
        style.tailIndent = 0
        let dic = [NSAttributedStringKey.font: font,NSAttributedStringKey.paragraphStyle:style]
        
        let attr = NSAttributedString(string: str, attributes: dic)
        
        self.attributedText = attr
    }
    
    
    
    
}
extension Date{
    //计算时间距现在
    func dateToString() -> String {
        var timeStr = ""
        let startTime = self.timeIntervalSince1970
        let nowTime = Date().timeIntervalSince1970
        let time = nowTime - startTime
        if time <= 60{
            timeStr = "刚刚".localString()
        }
        else if time > 60 && time <= 3600{
            timeStr = "\(Int(time) / 60)" + "分钟前".localString()
        }else if time > 3600 && time <= 86400{
            timeStr = "\(Int(time) / 3600)" + "小时前".localString()
        }
        else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            timeStr = formatter.string(from: self)
        }
        return timeStr
    }
}

extension UIView{
    func heartAnimation() {
        // 动画由小变大
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            
        }) { (result) in
            UIView.animate(withDuration: 0.4, animations: {
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { (result) in
                self.transform = CGAffineTransform.identity
                
            }
        }
    }
}

extension UIColor {
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func colorWithHex(_ hex: UInt) -> UIColor {
        let r: CGFloat = CGFloat((hex & 0xff0000) >> 16)
        let g: CGFloat = CGFloat((hex & 0x00ff00) >> 8)
        let b: CGFloat = CGFloat(hex & 0x0000ff)
        
        return rgb(r, green: g, blue: b)
    }
}
extension UIImageView: GIFAnimatable {
    private struct AssociatedKeys {
        static var AnimatorKey = "gifu.animator.key"
    }
    
    override open func display(_ layer: CALayer) {
        updateImageIfNeeded()
    }
    
    public var animator: Animator? {
        get {
            guard let animator = objc_getAssociatedObject(self, &AssociatedKeys.AnimatorKey) as? Animator else {
                let animator = Animator(withDelegate: self)
                self.animator = animator
                return animator
            }
            
            return animator
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.AnimatorKey, newValue as Animator?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
