//
//  RichTextView.swift
//
//
//  Created by kevinzhow on 15/7/8.
//
//

import UIKit

public class RichTextView: UITextView {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    public var clickedOnData: ((string: String, dataType: DetectedDataType) -> Void)?
    
    public var currentDetactedData: ((string: String, dataType: DetectedDataType) -> Void)?
    
    public var placeholder: String? {
        didSet {
            var attributes =  NSMutableDictionary()
            
            if (isFirstResponder() && typingAttributes != nil) {
                attributes.addEntriesFromDictionary(typingAttributes)
            } else {
                if let font = font {
                    attributes[NSFontAttributeName] = font
                }
                
                attributes[NSForegroundColorAttributeName] = UIColor(white: 0.7, alpha: 1.0)
                
                if textAlignment != NSTextAlignment.Left {
                    var paragraph = NSMutableParagraphStyle()
                    paragraph.alignment = textAlignment
                    attributes[NSParagraphStyleAttributeName] = paragraph
                }
            }
            
            self.attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: attributes as [NSObject : AnyObject])
        }
    }
    
    
    public var attributedPlaceholder: NSAttributedString?
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initialize()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged", name: UITextViewTextDidChangeNotification, object: self)
    }
    
    func textChanged() {
        self.setNeedsDisplay()
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
    
    public func appendImage(image: UIImage, width: CGFloat) {
        
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
    
    public func appendNewLine() {
        
        if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
            
            var newLineString = NSMutableAttributedString(string: "\n")
            
            newLineString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle(0), range: NSRange(location: 0, length: newLineString.length))
            
            newAttributedText.appendAttributedString(newLineString)
            
            attributedText = newAttributedText
        }
        
    }
    
    public func appendImage(image: UIImage, size: CGSize){
        
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
    
    public func insertImage(image: UIImage, size: CGSize, index: Int){
        
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
    
    override public var delegate: UITextViewDelegate? {
        
        didSet {
            if let delegate  = delegate as? RichTextViewDelegateHandler {
                delegate.richTextView = self
            }
        }
        
    }
    
    func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        var rect = UIEdgeInsetsInsetRect(bounds, self.contentInset)
        
        if self.respondsToSelector("textContainer") {
            rect = UIEdgeInsetsInsetRect(rect, self.textContainerInset)
            var padding = self.textContainer.lineFragmentPadding
            rect.origin.x += padding
            rect.size.width -= padding * 2.0
        } else {
            if self.contentInset.left == 0.0 {
                rect.origin.x += 8.0
            }
            rect.origin.y += 8.0
        }
        
        return rect;
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let attributedPlaceholder = attributedPlaceholder {
            if self.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
                self.setNeedsDisplay()
            }
        }
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if let attributedPlaceholder = attributedPlaceholder {
            if self.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
                var placeholderRect = placeholderRectForBounds(self.bounds)
                attributedPlaceholder.drawInRect(placeholderRect)
            }
        }
    }
    
}
