//
//  RichTextViewDelegateHandler.swift
//  
//
//  Created by kevinzhow on 15/7/9.
//
//

import UIKit

class RichTextViewDelegateHandler: NSObject {
    var richTextView: RichTextView!
}

extension RichTextViewDelegateHandler: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        println("Should interact with Attachment")
        return true
    }

    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        var textString: NSString = textView.text
        
        var valueText = textString.substringWithRange(characterRange)
        
        if let dataType = textView.attributedText.attribute(RichTextViewDetectedDataHandlerAttributeName, atIndex: characterRange.location, effectiveRange: nil) as? Int {
            
            switch dataType {
            case DetectedDataType.Mention.rawValue:
                println("Click On Mention \(valueText)")
                richTextView.handleClickOnMention(valueText)
                
            case DetectedDataType.HashTag.rawValue:
                println("Click On HashTag \(valueText)")
                richTextView.handleClickOnHashTag(valueText)
                
            case DetectedDataType.Email.rawValue:
                println("Click On Email \(valueText)")
                richTextView.handleClickOnEmail(valueText)
                
            case DetectedDataType.URL.rawValue:
                println("Click On URL \(valueText)")
                richTextView.handleClickOnURL(valueText)
                
            default:
                break
            }
            
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        println("new \(textView.text)")
    }
}
