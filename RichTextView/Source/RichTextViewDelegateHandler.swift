//
//  RichTextViewDelegateHandler.swift
//
//
//  Created by kevinzhow on 15/7/9.
//
//

import UIKit

public class RichTextViewDelegateHandler: NSObject {
}

extension RichTextViewDelegateHandler: UITextViewDelegate {
    

    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("Should interact with Attachment")
        return true
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let textString: NSString = textView.text! as NSString
        
        let valueText = textString.substring(with: characterRange)
        
        guard let textViewAttributedText = textView.attributedText else {return false}
        
        if let dataType = textViewAttributedText.attribute(NSAttributedString.Key(rawValue: RichTextViewDetectedDataHandlerAttributeName), at:  characterRange.location, effectiveRange: nil) as? Int {
            
            (textView as! RichTextView).handleClickedOnData(string: valueText, dataType: DetectedDataType(rawValue: dataType)!, range: characterRange)
            
        }
        
        return true
    }
    

    func textViewCurrentDetactedString(textView: UITextView, string: String, dataType: DetectedDataType, range: NSRange) {
        (textView as! RichTextView).handleCurrentDetactedData(string: string, dataType: dataType, range: range)
    }


    public func textViewDidChange(_ textView: UITextView) {

        if let textStorage = textView.layoutManager.textStorage as? RichTextStorage {

            let targetLocation = textView.selectedRange.location

            for range in textStorage.mentionRanges {
                if range.location >= targetLocation || range.location + range.length >= targetLocation {


                    let textValue = (textStorage.string as NSString).substring(with: range)

                    textViewCurrentDetactedString(textView: textView, string: textValue, dataType: DetectedDataType.Mention, range: range)

                    return
                }
            }

            for range in textStorage.emailRanges {
                if range.location >= targetLocation || range.location + range.length >= targetLocation {

                    let textValue = (textStorage.string as NSString).substring(with: range)

                    textViewCurrentDetactedString(textView: textView, string: textValue, dataType: DetectedDataType.Email, range: range)

                    return
                }
            }

            for range in textStorage.urlRanges {
                if range.location >= targetLocation || range.location + range.length >= targetLocation {

                    let textValue = (textStorage.string as NSString).substring(with: range)

                    textViewCurrentDetactedString(textView: textView, string: textValue, dataType: DetectedDataType.URL, range: range)

                    return
                }
            }

            for range in textStorage.hashTagRanges {
                if range.location >= targetLocation || range.location + range.length >= targetLocation {

                    let textValue = (textStorage.string as NSString).substring(with: range)

                    textViewCurrentDetactedString(textView: textView, string: textValue, dataType: DetectedDataType.HashTag, range: range)

                    return
                }
            }

        }
    }
}
