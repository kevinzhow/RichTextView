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
    
    public var clickedOnData: ((string: String, dataType: DetectedDataType, range: NSRange) -> Void)?
    
    public var currentDetactedData: ((string: String, dataType: DetectedDataType, range: NSRange) -> Void)?
    
    var richTextStorage = RichTextStorage()
    
    var richLayoutManager = NSLayoutManager()
    
    var richTextContainer = NSTextContainer()
    
    public var placeHolderLabel = UILabel(frame: CGRectZero)
    
    public var shouldUpdate = true
    
    public var linkGestureRecognizer: UITapGestureRecognizer?
    
    public let tapAreaInsets =  UIEdgeInsetsMake(-2, -2, -2, -2)
    
    public var tapHighLightColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
    
    public var placeholder: String? {
        didSet {
            var attributes = [String: AnyObject]()
            
            if typingAttributes.count > 0 && isFirstResponder() {
                attributes = typingAttributes
            } else {
                if let font = font {
                    attributes[NSFontAttributeName] = font
                }
                
                attributes[NSForegroundColorAttributeName] = UIColor(white: 0.7, alpha: 1.0)
                
                if textAlignment != NSTextAlignment.Left {
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.alignment = textAlignment
                    attributes[NSParagraphStyleAttributeName] = paragraph
                }
            }
            
            self.attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: attributes)
        }
    }
    
    public var attributedPlaceholder: NSAttributedString? {
        didSet {
            setupPlaceHolderLabel()
        }
    }
    
    func setupPlaceHolderLabel() {
        placeHolderLabel.attributedText = attributedPlaceholder
        
        placeHolderLabel.sizeToFit()

        placeHolderLabel.frame = placeholderRectForBounds(placeHolderLabel.bounds)
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    init(frame: CGRect) {
        richTextStorage.addLayoutManager(richLayoutManager)
        richLayoutManager.addTextContainer(richTextContainer)
        
        super.init(frame: frame, textContainer: richTextContainer)
        
        initialize()
    }
    
    func initialize() {

        placeHolderLabel.hidden = false
        
        addSubview(placeHolderLabel)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged", name: UITextViewTextDidChangeNotification, object: self)
    }
    
    public override var editable: Bool {
        didSet {
            if editable {
                
                if let linkGestureRecognizer = linkGestureRecognizer {
                    self.removeGestureRecognizer(linkGestureRecognizer)
                }

            } else {
                linkGestureRecognizer = UITapGestureRecognizer(target: self, action: "linkAction:")
                linkGestureRecognizer?.delegate = self
                self.addGestureRecognizer(linkGestureRecognizer!)
            }
        }
    }
    
    func linkAction(sender: UITapGestureRecognizer) {
        
        let location = sender.locationInView(self)
        
        enumerateLinkRangesContainingLocation(location, complete: { (range) -> Void in

            if let dataType = self.attributedText.attribute(RichTextViewDetectedDataHandlerAttributeName, atIndex: range.location, effectiveRange: nil) as? Int {
                
                let textString: NSString = self.text
                
                let valueText = textString.substringWithRange(range)
                
                self.handleClickedOnData(valueText, dataType: DetectedDataType(rawValue: dataType)!, range: range)
                
            } else if let dataType = self.attributedText.attribute(RichTextViewImageAttributeName, atIndex: range.location, effectiveRange: nil) as? String {
                
                self.handleClickedOnData(dataType, dataType: DetectedDataType.Image, range: range)
            }
        })
    }
    
    func enumerateLinkRangesContainingLocation(location: CGPoint, complete: (NSRange) -> Void) {
        
        var found = false
        
        self.attributedText.enumerateAttribute(RichTextViewDetectedDataHandlerAttributeName, inRange: NSMakeRange(0, attributedText.length), options: [], usingBlock: { (value, range, stop) in
            
            if let _: AnyObject = value   {
                
                self.enumerateViewRectsForRanges([NSValue(range: range)], complete: { (rect, range, stop) -> Void in
                    
                    if !found {
                        
                        if CGRectContainsPoint(rect, location) {
                            
                            self.drawRoundedCornerForRange(range, rect: rect)
                            
                            found = true
                            
                            complete(range)
                        }
                    } else {
//                        println("Found")
                    }
                })
            }
        })
        
        if !found {
            self.attributedText.enumerateAttribute(RichTextViewImageAttributeName, inRange: NSMakeRange(0, attributedText.length), options: [], usingBlock: { (value, range, stop) in
                
                if let _ = value   {
                    
                    self.enumerateViewRectsForRanges([NSValue(range: range)], complete: { (rect, range, stop) -> Void in
                        
                        if !found {
                            
                            if CGRectContainsPoint(rect, location) {
                                
                                self.drawRoundedCornerForRange(range, rect: rect)
                                
                                found = true
                                
                                complete(range)
                            }
                            
                        } else {
//                            println("Found")
                        }
                    })
                }
            })
        }
        
        return
    }
    
    func enumerateViewRectsForRanges(ranges: [NSValue], complete: (rect: CGRect, range: NSRange, stop: Bool) -> Void) {
        
        for rangeValue in ranges {
            
            let range = rangeValue.rangeValue
            
            let glyphRange = layoutManager.glyphRangeForCharacterRange(range, actualCharacterRange: nil)
            
            layoutManager.enumerateEnclosingRectsForGlyphRange(glyphRange, withinSelectedGlyphRange: NSMakeRange(NSNotFound, 0), inTextContainer: textContainer, usingBlock: { (rect, stop) -> Void in
                var rect = rect
                
                rect.origin.x += self.textContainerInset.left
                rect.origin.y += self.textContainerInset.top
                rect = UIEdgeInsetsInsetRect(rect, self.tapAreaInsets)
                
                complete(rect: rect, range: range, stop: true)
            })
            
        }
        
        return
    }
    
    func drawRoundedCornerForRange(range: NSRange, rect: CGRect) {

        let layer = CALayer()
        layer.frame = rect
        layer.backgroundColor = tapHighLightColor.CGColor
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
        self.layer.addSublayer(layer)
        
        delay(0.2, closure: { () -> () in
          layer.removeFromSuperlayer()
        })
        
    }
    
    func textChanged() {
        if let _ = attributedPlaceholder {
            if (text as NSString).length == 0 {
                placeHolderLabel.hidden = false
            } else {
                placeHolderLabel.hidden = true
            }
        }

        self.setNeedsDisplay()
    }
    
    func handleClickedOnData(string: String, dataType: DetectedDataType, range: NSRange ){
        if let clickedOnData = clickedOnData {
            clickedOnData(string: string, dataType: dataType, range: range)
        }
    }
    
    func handleCurrentDetactedData(string: String, dataType: DetectedDataType, range: NSRange) {
        if let currentDetactedData = currentDetactedData {
            currentDetactedData(string: string, dataType: dataType, range: range)
        }
    }
    
    public func appendImage(imageName: String ,image: UIImage, width: CGFloat) {
        
        if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
            
            newAttributedText.appendAttributedString(NSAttributedString(string: "\n"))
            
            var _ = text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            
            self.attributedText = newAttributedText
            
            let imageWidth = image.size.width
            
            let radio:CGFloat = width / imageWidth
            
            appendImage(imageName, image: image, size: CGSize(width: image.size.width*radio, height: image.size.height*radio))
            
            appendNewLine()
        }
    }
    
    public func appendNewLine() {
        
        if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
            
            let newLineString = NSMutableAttributedString(string: "\n")
            
            newLineString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle(0), range: NSRange(location: 0, length: newLineString.length))
            
            newAttributedText.appendAttributedString(newLineString)
            
            attributedText = newAttributedText
        }
        
    }
    
    public func appendImage(imageName: String ,image: UIImage, size: CGSize){
        
        let attachment = NSTextAttachment(data: nil, ofType: nil)
        attachment.image = image
        attachment.bounds = CGRectMake(0, 0, size.width, size.height)
        
        if let attachmentAttributedString = NSAttributedString(attachment: attachment) as? NSMutableAttributedString {
            // sets the paragraph styling of the text attachment
            
            
            let attr: [String: AnyObject] = [NSParagraphStyleAttributeName: paragraphStyle(0), RichTextViewImageAttributeName: imageName, RichTextViewDetectedDataHandlerAttributeName: DetectedDataType.Image.rawValue]
            
            attachmentAttributedString.addAttributes(attr, range: NSRange(location: 0, length: attachmentAttributedString.length))
            
            if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
                
                newAttributedText.appendAttributedString(attachmentAttributedString)
                
                self.attributedText = newAttributedText
            }
        }
    }
    
    public func findAllImageRange() -> [[String : NSRange]]?{
        
        var finalRange = [[String : NSRange]]()
        
        self.attributedText.enumerateAttribute(RichTextViewImageAttributeName, inRange: NSRange(location: 0, length: self.attributedText.length), options: [], usingBlock: { (value, range, finish) in
            
            if let value = value as? String {
                finalRange.append([value :  range])
            }
            
        })
        
        if finalRange.count > 0 {
            return finalRange
        } else {
            return nil
        }
        
    }
    
    public func findImageRange(imageHash: String) -> NSRange?{
        
        var finalRange: NSRange?
        
        self.attributedText.enumerateAttribute(RichTextViewImageAttributeName, inRange: NSRange(location: 0, length: self.attributedText.length), options: [], usingBlock: { (value, range, finish) in
            
            if let value = value as? String {
                if value == imageHash {
                    finalRange = range
                }
            }

        })
        
        if let finalRange = finalRange {
            return finalRange
        }
        
        return nil
        
    }
    
    private func paragraphStyle(spacing: CGFloat) -> NSMutableParagraphStyle {
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.paragraphSpacing = spacing
        
        paragraphStyle.paragraphSpacingBefore = spacing
        
        return paragraphStyle
    }
    
    public func insertImage(imageName: String, image: UIImage, size: CGSize, index: Int){
        
        let attachment = NSTextAttachment(data: nil, ofType: nil)
        attachment.image = image
        attachment.bounds = CGRectMake(0, 0, size.width, size.height)
        
        if let attachmentAttributedString = NSAttributedString(attachment: attachment) as? NSMutableAttributedString {
            // sets the paragraph styling of the text attachment
            
            let paragraphStyle = NSMutableParagraphStyle()
            
            paragraphStyle.paragraphSpacing = 10
            
            paragraphStyle.paragraphSpacingBefore = 10
            
            let attr: [String: AnyObject] = [NSParagraphStyleAttributeName: paragraphStyle, RichTextViewImageAttributeName: imageName, RichTextViewDetectedDataHandlerAttributeName: DetectedDataType.Image.rawValue]
            
            attachmentAttributedString.addAttributes(attr, range: NSRange(location: 0, length: attachmentAttributedString.length))
            
            if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
                
                newAttributedText.insertAttributedString(attachmentAttributedString, atIndex: index)
                
                self.attributedText = newAttributedText
            }
        }
    }
    
    public func replaceImage(imageName: String, image: UIImage, size: CGSize, index: Int){
        
        let attachment = NSTextAttachment(data: nil, ofType: nil)
        attachment.image = image
        attachment.bounds = CGRectMake(0, 0, size.width, size.height)
        
        if let attachmentAttributedString = NSAttributedString(attachment: attachment) as? NSMutableAttributedString {
            // sets the paragraph styling of the text attachment
            
            let paragraphStyle = NSMutableParagraphStyle()
            
            paragraphStyle.paragraphSpacing = 10
            
            paragraphStyle.paragraphSpacingBefore = 10
            
            let attr: [String: AnyObject] = [NSParagraphStyleAttributeName: paragraphStyle, RichTextViewImageAttributeName: imageName, RichTextViewDetectedDataHandlerAttributeName: DetectedDataType.Image.rawValue]
            
            attachmentAttributedString.addAttributes(attr, range: NSRange(location: 0, length: attachmentAttributedString.length))
            
            if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
                
                newAttributedText.replaceCharactersInRange(NSRange(location: index, length: 1), withAttributedString: attachmentAttributedString)
                
                self.attributedText = newAttributedText
            }
        }
    }
    
    func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        var rect = bounds
        
        if self.respondsToSelector("textContainer") {
            let padding = self.textContainer.lineFragmentPadding
            rect.origin.x += padding
            rect.origin.y += padding * 1.5
        } else {
            if self.contentInset.left == 0.0 {
                rect.origin.x += 8.0
            }
            rect.origin.y += 8.0
        }
        
        return rect;
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}

extension RichTextView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
