//
//  DiaryTextStorage.swift
//  Diary
//
//  Created by kevinzhow on 15/3/5.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

let RichTextViewDetectedDataHandlerAttributeName = "RichTextViewDetectedDataHandlerAttributeName"

enum DetectedDataType: Int {
    case Mention = 0
    case HashTag
    case URL
    case Email
}

class RichTextStorage: NSTextStorage {
    
    var backingStore: NSMutableAttributedString = NSMutableAttributedString()
    
    override var string: String {
        return backingStore.string
    }
    
    override func attributesAtIndex(index: Int, effectiveRange range: NSRangePointer) -> [NSObject : AnyObject] {
        return backingStore.attributesAtIndex(index, effectiveRange: range)
    }
    
    override func replaceCharactersInRange(range: NSRange, withString str: String) {
        //        println("replaceCharactersInRange:\(range) withString:\(str)")z
        
        beginEditing()
        backingStore.replaceCharactersInRange(range, withString:str)
        edited(.EditedCharacters | .EditedAttributes, range: range, changeInLength: (str as NSString).length - range.length)
        endEditing()
    }
    
    override func setAttributes(attrs: [NSObject : AnyObject]!, range: NSRange) {
        //        println("setAttributes:\(attrs) range:\(range)")
        
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.EditedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    override func processEditing() {
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        var paragraphRange = (self.string as NSString).paragraphRangeForRange(self.editedRange)
        self.removeAttribute(NSForegroundColorAttributeName, range: paragraphRange)
        //For Mention
        
        var mentionPattern = "@[^\\s:：,，@]+$?"
        
        var mentionExpression = NSRegularExpression(pattern: mentionPattern, options: NSRegularExpressionOptions.allZeros, error: nil)
        
        if let mentionExpression = mentionExpression {
            mentionExpression.enumerateMatchesInString(self.string, options: NSMatchingOptions.allZeros, range: paragraphRange, usingBlock: { (result, flags, stop) -> Void in
                
                var textValue = (self.string as NSString).substringWithRange(result.range)
                
                var textAttributes: [NSObject : AnyObject]! = [NSForegroundColorAttributeName: UIColor.blueColor(), NSLinkAttributeName: textValue, RichTextViewDetectedDataHandlerAttributeName: DetectedDataType.Mention.rawValue]
                
                self.addAttributes(textAttributes, range: result.range )

            })
        }
        
        //For Link
        
        var linkPattern = "[a-zA-Z]+://[0-9a-zA-Z_.?&/=]+"
        
        var linkExpression = NSRegularExpression(pattern: linkPattern, options: NSRegularExpressionOptions.allZeros, error: nil)
        
        if let linkExpression = linkExpression {
            linkExpression.enumerateMatchesInString(self.string, options: NSMatchingOptions.allZeros, range: paragraphRange, usingBlock: { (result, flags, stop) -> Void in
                
                var textValue = (self.string as NSString).substringWithRange(result.range)
                
                var textAttributes: [NSObject : AnyObject]! = [NSForegroundColorAttributeName: UIColor.blueColor(), NSLinkAttributeName: textValue, RichTextViewDetectedDataHandlerAttributeName: DetectedDataType.URL.rawValue]
                
                self.addAttributes(textAttributes, range: result.range )
                
            })
        }
        
        //For HashTag
        
        var hashTagPattern = "#.+?#"
        
        var hashTagExpression = NSRegularExpression(pattern: hashTagPattern, options: NSRegularExpressionOptions.allZeros, error: nil)
        
        if let hashTagExpression = hashTagExpression {
            hashTagExpression.enumerateMatchesInString(self.string, options: NSMatchingOptions.allZeros, range: paragraphRange, usingBlock: { (result, flags, stop) -> Void in
                
                var textValue = (self.string as NSString).substringWithRange(result.range)
                
                var textAttributes: [NSObject : AnyObject]! = [NSForegroundColorAttributeName: UIColor.blueColor(), NSLinkAttributeName: textValue, RichTextViewDetectedDataHandlerAttributeName: DetectedDataType.HashTag.rawValue]
                
                self.addAttributes(textAttributes, range: result.range )
                
            })
        }
        
        //For Email
        
        var emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]+"
        
        var emailExpression = NSRegularExpression(pattern: emailPattern, options: NSRegularExpressionOptions.allZeros, error: nil)
        
        if let emailExpression = emailExpression {
            emailExpression.enumerateMatchesInString(self.string, options: NSMatchingOptions.allZeros, range: paragraphRange, usingBlock: { (result, flags, stop) -> Void in
                
                var textValue = (self.string as NSString).substringWithRange(result.range)
                
                var textAttributes: [NSObject : AnyObject]! = [NSForegroundColorAttributeName: UIColor.blueColor(), NSLinkAttributeName: textValue, RichTextViewDetectedDataHandlerAttributeName: DetectedDataType.Email.rawValue]
                
                self.addAttributes(textAttributes, range: result.range )
                
            })
        }
        
        super.processEditing()
    }
    
    
}
