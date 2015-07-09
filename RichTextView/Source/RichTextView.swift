//
//  RichTextView.swift
//  
//
//  Created by kevinzhow on 15/7/8.
//
//

import UIKit

class RichTextView: UITextView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var clickedOnData: ((string: String, dataType: DetectedDataType) -> Void)?
    
    var currentDetactedData: ((string: String, dataType: DetectedDataType) -> Void)?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func handleClickedOnData(string: String, dataType: DetectedDataType ){
        if let clickedOnData = clickedOnData {
            clickedOnData(string: string, dataType: dataType)
        }
    }
    
    func handleCurrentDetactedData(string: String, dataType: DetectedDataType) {
        if let currentDetactedData = currentDetactedData {
            currentDetactedData(string: string, dataType: dataType)
        }
    }
    
    func appendImage(image: UIImage, width: CGFloat) {
        
        if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
            
            newAttributedText.appendAttributedString(NSAttributedString(string: "\n"))
            
            var newLength = text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            
            self.attributedText = newAttributedText
            
            var imageWidth = image.size.width
            
            var radio:CGFloat = width / imageWidth
            
            appendImage(image, size: CGSize(width: image.size.width*radio, height: image.size.height*radio))
            
            appendNewLine() 
        }
    }
    
    func appendNewLine() {
        
        if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
            
            var newLineString = NSMutableAttributedString(string: "\n")
            
            newLineString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle(0), range: NSRange(location: 0, length: newLineString.length))
            
            newAttributedText.appendAttributedString(newLineString)
            
            attributedText = newAttributedText
        }

    }
    
    func appendImage(image: UIImage, size: CGSize){
        
        var attachment = NSTextAttachment(data: nil, ofType: nil)
        attachment.image = image
        attachment.bounds = CGRectMake(0, 0, size.width, size.height)
        
        if let attachmentAttributedString = NSAttributedString(attachment: attachment) as? NSMutableAttributedString {
            // sets the paragraph styling of the text attachment
            
            attachmentAttributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle(0), range: NSRange(location: 0, length: attachmentAttributedString.length))
            
            if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
                
                newAttributedText.appendAttributedString(attachmentAttributedString)
                
                self.attributedText = newAttributedText
            }
        }
    }
    
    private func paragraphStyle(spacing: CGFloat) -> NSMutableParagraphStyle {
        
        var paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.paragraphSpacing = spacing
        
        paragraphStyle.paragraphSpacingBefore = spacing
        
        return paragraphStyle
    }
    
    func insertImage(image: UIImage, size: CGSize, index: Int){
        
        var attachment = NSTextAttachment(data: nil, ofType: nil)
        attachment.image = image
        attachment.bounds = CGRectMake(0, 0, size.width, size.height)
        
        if let attachmentAttributedString = NSAttributedString(attachment: attachment) as? NSMutableAttributedString {
            // sets the paragraph styling of the text attachment
            
            var paragraphStyle = NSMutableParagraphStyle()
            
            paragraphStyle.paragraphSpacing = 10
            
            paragraphStyle.paragraphSpacingBefore = 10
            
            attachmentAttributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: attachmentAttributedString.length))
            
            if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
                
                newAttributedText.insertAttributedString(attachmentAttributedString, atIndex: index)
                
                self.attributedText = newAttributedText
            }
        }
    }

    override var delegate: UITextViewDelegate? {
        
        didSet {
            (delegate as! RichTextViewDelegateHandler).richTextView = self
        }
        
    }
}
