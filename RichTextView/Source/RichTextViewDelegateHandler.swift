//
//  RichTextViewDelegateHandler.swift
//  
//
//  Created by kevinzhow on 15/7/9.
//
//

import UIKit

class RichTextViewDelegateHandler: NSObject {
    
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
            case DetectedDataType.Meation.rawValue:
                println("Click On Meation \(valueText)")
            case DetectedDataType.HashTag.rawValue:
                println("Click On HashTag \(valueText)")
            case DetectedDataType.Email.rawValue:
                println("Click On Email \(valueText)")
            case DetectedDataType.URL.rawValue:
                println("Click On URL \(valueText)")
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
