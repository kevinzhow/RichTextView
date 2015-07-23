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
    

    public func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        println("Should interact with Attachment")
        return true
    }

    public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {

        var textString: NSString = textView.text

        var valueText = textString.substringWithRange(characterRange)

        if let dataType = textView.attributedText.attribute(RichTextViewDetectedDataHandlerAttributeName, atIndex: characterRange.location, effectiveRange: nil) as? Int {

            (textView as! RichTextView).handleClickedOnData(valueText, dataType: DetectedDataType(rawValue: dataType)!, range: characterRange)

        }
        return true
    }

    func textViewCurrentDetactedString(textView: UITextView, string: String, dataType: DetectedDataType, range: NSRange) {
        (textView as! RichTextView).handleCurrentDetactedData(string, dataType: dataType, range: range)
    }


    public func textViewDidChange(textView: UITextView) {

        if let textStorage = textView.layoutManager.textStorage as? RichTextStorage {

            var targetLocation = textView.selectedRange.location

            for range in textStorage.mentionRanges {
                if range.location >= targetLocation || range.location + range.length >= targetLocation {


                    var textValue = (textStorage.string as NSString).substringWithRange(range)

                    textViewCurrentDetactedString(textView, string: textValue, dataType: DetectedDataType.Mention, range: range)

                    return
                }
            }

            for range in textStorage.emailRanges {
                if range.location >= targetLocation || range.location + range.length >= targetLocation {

                    var textValue = (textStorage.string as NSString).substringWithRange(range)

                    textViewCurrentDetactedString(textView, string: textValue, dataType: DetectedDataType.Email, range: range)

                    return
                }
            }

            for range in textStorage.urlRanges {
                if range.location >= targetLocation || range.location + range.length >= targetLocation {

                    var textValue = (textStorage.string as NSString).substringWithRange(range)

                    textViewCurrentDetactedString(textView, string: textValue, dataType: DetectedDataType.URL, range: range)

                    return
                }
            }

            for range in textStorage.hashTagRanges {
                if range.location >= targetLocation || range.location + range.length >= targetLocation {

                    var textValue = (textStorage.string as NSString).substringWithRange(range)

                    textViewCurrentDetactedString(textView, string: textValue, dataType: DetectedDataType.HashTag, range: range)

                    return
                }
            }

        }
    }
}
