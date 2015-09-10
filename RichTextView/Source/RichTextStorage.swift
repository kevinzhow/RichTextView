//
//  DiaryTextStorage.swift
//  Diary
//
//  Created by kevinzhow on 15/3/5.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

public let RichTextViewDetectedDataHandlerAttributeName = "RichTextViewDetectedDataHandlerAttributeName"
public let RichTextViewImageAttributeName = "RichTextViewImageAttributeName"
public let RichTextViewCustomDataAttributeName = "RichTextViewCustomDataAttributeName"

public enum DetectedDataType: Int, CustomStringConvertible{
    case Mention = 0
    case HashTag
    case URL
    case Email
    case Image
    case Custom
    
    public var description: String {
        switch self {
        case .Mention:
            return "Mention"
        case .HashTag:
            return "HashTag"
        case .URL:
            return "URL"
        case .Email:
            return "Email"
        case .Image:
            return "Image"
        case .Custom:
            return "Custom"
        }
    }
}

public class RichTextStorage: NSTextStorage {
    
    public var defaultTextStyle: [String: AnyObject]?
    
    var backingStore: NSMutableAttributedString = NSMutableAttributedString()
    
    var mentionRanges = [NSRange]()
    
    var hashTagRanges = [NSRange]()
    
    var emailRanges = [NSRange]()
    
    var urlRanges = [NSRange]()
    
    var tapAreaInsets = UIEdgeInsetsMake(-5, -5, -5, -5)
    
    public var customRanges = [NSRange]()
    
    override public var string: String {
        return backingStore.string
    }
    
    override public func attributesAtIndex(index: Int, effectiveRange range: NSRangePointer) -> [String : AnyObject] {
        return backingStore.attributesAtIndex(index, effectiveRange: range)
    }
    
    override public func replaceCharactersInRange(range: NSRange, withString str: String) {
        //        println("replaceCharactersInRange:\(range) withString:\(str)")z
        
        beginEditing()
        backingStore.replaceCharactersInRange(range, withString:str)
        edited([.EditedCharacters, .EditedAttributes], range: range, changeInLength: (str as NSString).length - range.length)
        endEditing()
    }
    
    override public func setAttributes(attrs: [String : AnyObject]!, range: NSRange) {
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.EditedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    override public func addAttributes(attrs: [String : AnyObject], range: NSRange) {
        beginEditing()
        backingStore.addAttributes(attrs, range: range)
        edited(.EditedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    override public func processEditing() {
        
        var paragraphRange = (self.string as NSString).paragraphRangeForRange(self.editedRange)
        
        self.removeAttribute(NSForegroundColorAttributeName, range: paragraphRange)
        self.removeAttribute(NSLinkAttributeName, range: paragraphRange)
        self.removeAttribute(RichTextViewDetectedDataHandlerAttributeName, range: paragraphRange)
        
        if let defaultTextStyle = defaultTextStyle {
            addAttributes(defaultTextStyle, range: paragraphRange)
        }
        
        mentionRanges = [NSRange]()
        
        hashTagRanges = [NSRange]()
        
        emailRanges = [NSRange]()
        
        urlRanges = [NSRange]()
        
        //For Mention
        
        var mentionPattern = "@[^\\s:：,，@]+$?"
        
        var mentionExpression = try? NSRegularExpression(pattern: mentionPattern, options: NSRegularExpressionOptions())
        
        if let mentionExpression = mentionExpression {
            mentionExpression.enumerateMatchesInString(self.string, options: NSMatchingOptions(), range: paragraphRange, usingBlock: { (result, flags, stop) -> Void in
                
                if let result = result {
                    var textValue = (self.string as NSString).substringWithRange(result.range)
                    
                    var textAttributes: [String : AnyObject]! = [NSForegroundColorAttributeName: UIColor.blueColor(), NSLinkAttributeName: textValue, RichTextViewDetectedDataHandlerAttributeName: DetectedDataType.Mention.rawValue]
                    
                    self.addAttributes(textAttributes, range: result.range )
                    
                    self.mentionRanges.append(result.range)
                }

                
            })
        }
        
        //For Link
        
        var linkPattern = "[a-zA-Z]+://[0-9a-zA-Z_.?&/=]+"
        
        var linkExpression = try? NSRegularExpression(pattern: linkPattern, options: NSRegularExpressionOptions())
        
        if let linkExpression = linkExpression {
            linkExpression.enumerateMatchesInString(self.string, options: NSMatchingOptions(), range: paragraphRange, usingBlock: { (result, flags, stop) -> Void in
                
                if let result = result {
                    var textValue = (self.string as NSString).substringWithRange(result.range)
                    
                    var textAttributes: [String : AnyObject]! = [NSForegroundColorAttributeName: UIColor.blueColor(), NSLinkAttributeName: textValue, RichTextViewDetectedDataHandlerAttributeName: DetectedDataType.URL.rawValue]
                    
                    self.addAttributes(textAttributes, range: result.range )
                    
                    self.urlRanges.append(result.range)
                }

                
            })
        }
        
        //For HashTag
        
        var hashTagPattern = "#.+?#"
        
        var hashTagExpression = try? NSRegularExpression(pattern: hashTagPattern, options: NSRegularExpressionOptions())
        
        if let hashTagExpression = hashTagExpression {
            hashTagExpression.enumerateMatchesInString(self.string, options: NSMatchingOptions(), range: paragraphRange, usingBlock: { (result, flags, stop) -> Void in
                
                if let result = result {
                    var textValue = (self.string as NSString).substringWithRange(result.range)
                    
                    var textAttributes: [String : AnyObject]! = [NSForegroundColorAttributeName: UIColor.blueColor(), NSLinkAttributeName: textValue, RichTextViewDetectedDataHandlerAttributeName: DetectedDataType.HashTag.rawValue]
                    
                    self.addAttributes(textAttributes, range: result.range )
                    
                    self.hashTagRanges.append(result.range)
                }
                
            })
        }
        
        //For Email
        
        var emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]+"
        
        var emailExpression = try? NSRegularExpression(pattern: emailPattern, options: NSRegularExpressionOptions())
        
        if let emailExpression = emailExpression {
            emailExpression.enumerateMatchesInString(self.string, options: NSMatchingOptions(), range: paragraphRange, usingBlock: { (result, flags, stop) -> Void in
                
                if let result = result {
                    var textValue = (self.string as NSString).substringWithRange(result.range)
                    
                    var textAttributes: [String : AnyObject]! = [NSForegroundColorAttributeName: UIColor.blueColor(), NSLinkAttributeName: textValue, RichTextViewDetectedDataHandlerAttributeName: DetectedDataType.Email.rawValue]
                    
                    self.addAttributes(textAttributes, range: result.range )
                    
                    self.emailRanges.append(result.range)
                }

            })
        }
        
        //For Custom Range
        
        for range in customRanges {
            var textAttributes: [String : AnyObject]! = [NSForegroundColorAttributeName: UIColor.blueColor(), NSLinkAttributeName: "CustomRange", RichTextViewDetectedDataHandlerAttributeName: DetectedDataType.Custom.rawValue]
            
            self.addAttributes(textAttributes, range: range )
        }
        
        super.processEditing()
    }
    
    
}
