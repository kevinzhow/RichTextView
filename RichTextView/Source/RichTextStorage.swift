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
    
    public var defaultTextStyle: [NSAttributedString.Key: Any]?
    
    var backingStore: NSMutableAttributedString = NSMutableAttributedString()
    
    var mentionRanges = [NSRange]()
    
    var hashTagRanges = [NSRange]()
    
    var emailRanges = [NSRange]()
    
    var urlRanges = [NSRange]()
    
    var tapAreaInsets = UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5)
    
    public var customRanges = [NSRange]()
    
    override public var string: String {
        return backingStore.string
    }
    
    
    override public func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }
    
    override public func replaceCharacters(in range: NSRange, with str: String) {
        //        println("replaceCharactersInRange:\(range) withString:\(str)")z
        
        beginEditing()
        backingStore.replaceCharacters(in: range, with:str)
        edited([.editedCharacters, .editedAttributes], range: range, changeInLength: (str as NSString).length - range.length)
        endEditing()
    }
    
    
    public override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    
    public override func addAttributes(_ attrs: [NSAttributedString.Key : Any] = [:], range: NSRange) {
        beginEditing()
        backingStore.addAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    override public func processEditing() {
        
        let paragraphRange = (self.string as NSString).paragraphRange(for: self.editedRange)
        
        self.removeAttribute(NSAttributedString.Key.foregroundColor, range: paragraphRange)
        self.removeAttribute(NSAttributedString.Key.link, range: paragraphRange)
        self.removeAttribute(NSAttributedString.Key(rawValue: RichTextViewDetectedDataHandlerAttributeName), range: paragraphRange)
        
        if let defaultTextStyle = defaultTextStyle {
            addAttributes(defaultTextStyle, range: paragraphRange)
        }
        
        mentionRanges = [NSRange]()
        
        hashTagRanges = [NSRange]()
        
        emailRanges = [NSRange]()
        
        urlRanges = [NSRange]()
        
        //For Mention
        
        let mentionPattern = "@[^\\s:：,，@]+$?"
        
        let mentionExpression = try? NSRegularExpression(pattern: mentionPattern, options: NSRegularExpression.Options())
        
        if let mentionExpression = mentionExpression {
            mentionExpression.enumerateMatches(in: self.string, options: NSRegularExpression.MatchingOptions(), range: paragraphRange, using: { (result, flags, stop) -> Void in
                
                if let result = result {
                    let textValue = (self.string as NSString).substring(with: result.range)
                    
                    let textAttributes: [NSAttributedString.Key : Any]! = [NSAttributedString.Key.foregroundColor: UIColor.blue, NSAttributedString.Key.link: textValue, NSAttributedString.Key(rawValue: RichTextViewDetectedDataHandlerAttributeName): DetectedDataType.Mention.rawValue]
                    
                    self.addAttributes(textAttributes, range: result.range )
                    
                    self.mentionRanges.append(result.range)
                }

                
            })
        }
        
        //For Link
        
        let linkPattern = "[a-zA-Z]+://[0-9a-zA-Z_.?&/=]+"
        
        let linkExpression = try? NSRegularExpression(pattern: linkPattern, options: NSRegularExpression.Options())
        
        if let linkExpression = linkExpression {
            linkExpression.enumerateMatches(in: self.string, options: NSRegularExpression.MatchingOptions(), range: paragraphRange, using: { (result, flags, stop) -> Void in
                
                if let result = result {
                    let textValue = (self.string as NSString).substring(with: result.range)
                    
                    let textAttributes: [NSAttributedString.Key : Any]! = [NSAttributedString.Key.foregroundColor: UIColor.blue, NSAttributedString.Key.link: textValue, NSAttributedString.Key(rawValue: RichTextViewDetectedDataHandlerAttributeName): DetectedDataType.URL.rawValue]
                    
                    self.addAttributes(textAttributes, range: result.range )
                    
                    self.urlRanges.append(result.range)
                }

                
            })
        }
        
        //For HashTag
        
        let hashTagPattern = "#.+?#"
        
        let hashTagExpression = try? NSRegularExpression(pattern: hashTagPattern, options: NSRegularExpression.Options())
        
        if let hashTagExpression = hashTagExpression {
            hashTagExpression.enumerateMatches(in: self.string, options: NSRegularExpression.MatchingOptions(), range: paragraphRange, using: { (result, flags, stop) -> Void in
                
                if let result = result {
                    let textValue = (self.string as NSString).substring(with: result.range)
                    
                    let textAttributes: [NSAttributedString.Key : Any]! = [NSAttributedString.Key.foregroundColor: UIColor.blue, NSAttributedString.Key.link: textValue, NSAttributedString.Key(rawValue: RichTextViewDetectedDataHandlerAttributeName): DetectedDataType.HashTag.rawValue]
                    
                    self.addAttributes(textAttributes, range: result.range )
                    
                    self.hashTagRanges.append(result.range)
                }
                
            })
        }
        
        //For Email
        
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]+"
        
        let emailExpression = try? NSRegularExpression(pattern: emailPattern, options: NSRegularExpression.Options())
        
        if let emailExpression = emailExpression {
            emailExpression.enumerateMatches(in: self.string, options: NSRegularExpression.MatchingOptions(), range: paragraphRange, using: { (result, flags, stop) -> Void in
                
                if let result = result {
                    let textValue = (self.string as NSString).substring(with: result.range)
                    
                    let textAttributes: [NSAttributedString.Key : Any]! = [NSAttributedString.Key.foregroundColor: UIColor.blue, NSAttributedString.Key.link: textValue, NSAttributedString.Key(rawValue: RichTextViewDetectedDataHandlerAttributeName): DetectedDataType.Email.rawValue]
                    
                    self.addAttributes(textAttributes, range: result.range )
                    
                    self.emailRanges.append(result.range)
                }

            })
        }
        
        //For Custom Range
        
        for range in customRanges {
            let textAttributes:[NSAttributedString.Key : Any]! = [NSAttributedString.Key.foregroundColor: UIColor.blue, NSAttributedString.Key.link: "CustomRange", NSAttributedString.Key(rawValue: RichTextViewDetectedDataHandlerAttributeName): DetectedDataType.Custom.rawValue]
            
            self.addAttributes(textAttributes, range: range )
        }
        
        super.processEditing()
    }
    
    
}
