//
//  RichTextViewDelegateHandler.swift
//  
//
//  Created by kevinzhow on 15/7/9.
//
//

import UIKit

public class RichTextViewDelegateHandler: NSObject {
    var richTextView: RichTextView!
}

extension RichTextViewDelegateHandler: UITextViewDelegate {
    
    public func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        println("Should interact with Attachment")
        return true
    }

    public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        var textString: NSString = textView.text
        
        var valueText = textString.substringWithRange(characterRange)
        
        if let dataType = textView.attributedText.attribute(RichTextViewDetectedDataHandlerAttributeName, atIndex: characterRange.location, effectiveRange: nil) as? Int {
            
            richTextView.handleClickedOnData(valueText, dataType: DetectedDataType(rawValue: dataType)!)
            
        }
        return true
    }
    
    func textViewCurrentDetactedString(string: String, dataType: DetectedDataType) {
        richTextView.handleCurrentDetactedData(string, dataType: dataType)
    }
    
    
    public func textViewDidChange(textView: UITextView) {
        
        if let textStorage = richTextView.layoutManager.textStorage as? RichTextStorage {
            
            var targetLocation = richTextView.selectedRange.location
            
            for range in textStorage.mentionRanges {
                if range.location >= targetLocation || range.location + range.length >= targetLocation {

                    
                    var textValue = (textStorage.string as NSString).substringWithRange(range)
                    
                    textViewCurrentDetactedString(textValue, dataType: DetectedDataType.Mention)
                    
                    return
                }
            }
            
            for range in textStorage.emailRanges {
                if range.location >= targetLocation || range.location + range.length >= targetLocation {
                    
                    var textValue = (textStorage.string as NSString).substringWithRange(range)
                    
                    textViewCurrentDetactedString(textValue, dataType: DetectedDataType.Email)
                    
                    return
                }
            }
            
            for range in textStorage.urlRanges {
                if range.location >= targetLocation || range.location + range.length >= targetLocation {
                    
                    var textValue = (textStorage.string as NSString).substringWithRange(range)
                    
                    textViewCurrentDetactedString(textValue, dataType: DetectedDataType.URL)
                    
                    return
                }
            }
            
            for range in textStorage.hashTagRanges {
                if range.location >= targetLocation || range.location + range.length >= targetLocation {

                    var textValue = (textStorage.string as NSString).substringWithRange(range)
                    
                    textViewCurrentDetactedString(textValue, dataType: DetectedDataType.HashTag)
                    
                    return
                }
            }
            
        }
    }
}
