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
    
    public var clickedOnData: ((_ string: String, _ dataType: DetectedDataType, _ range: NSRange) -> Void)?
    
    public var currentDetactedData: ((_ string: String, _ dataType: DetectedDataType, _ range: NSRange) -> Void)?
    
    var richTextStorage = RichTextStorage()
    
    var richLayoutManager = NSLayoutManager()
    
    var richTextContainer = NSTextContainer()
    
    public var placeHolderLabel = UILabel(frame: CGRect.zero)
    
    public var shouldUpdate = true
    
    public var linkGestureRecognizer: UITapGestureRecognizer?
    
    public let tapAreaInsets =  UIEdgeInsets(top: -2, left: -2, bottom: -2, right: -2)
    
    public var tapHighLightColor = UIColor.black.withAlphaComponent(0.2)
    
    public var placeholder: String? {
        didSet {
            var attributes = [NSAttributedString.Key: Any]()
            
            if typingAttributes.count > 0 && isFirstResponder {
                attributes = typingAttributes
            } else {
                if let font = font {
                    attributes[NSAttributedString.Key.font] = font
                }
                
                attributes[NSAttributedString.Key.foregroundColor] = UIColor(white: 0.7, alpha: 1.0)
                
                if textAlignment != NSTextAlignment.left {
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.alignment = textAlignment
                    attributes[NSAttributedString.Key.paragraphStyle] = paragraph
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

        placeHolderLabel.frame = placeholderRectForBounds(bounds: placeHolderLabel.bounds)
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

        placeHolderLabel.isHidden = false
        
        addSubview(placeHolderLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: self)
    }
    
    public override var isEditable: Bool {
        didSet {
            if isEditable {
                
                if let linkGestureRecognizer = linkGestureRecognizer {
                    self.removeGestureRecognizer(linkGestureRecognizer)
                }

            } else {
                linkGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(linkAction))
                linkGestureRecognizer?.delegate = self
                self.addGestureRecognizer(linkGestureRecognizer!)
            }
        }
    }
    
    @objc func linkAction(sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: self)
        
        enumerateLinkRangesContainingLocation(location: location, complete: { (range) -> Void in

            if let dataType = self.attributedText?.attribute(NSAttributedString.Key.init(RichTextViewDetectedDataHandlerAttributeName), at: range.location, effectiveRange: nil) as? Int {
                
                let textString: NSString = self.text! as NSString
                
                let valueText = textString.substring(with: range)
                
                self.handleClickedOnData(string: valueText, dataType: DetectedDataType(rawValue: dataType)!, range: range)
                
            } else if let dataType = self.attributedText?.attribute(NSAttributedString.Key.init(RichTextViewImageAttributeName), at: range.location, effectiveRange: nil) as? String {
                
                self.handleClickedOnData(string: dataType, dataType: DetectedDataType.Image, range: range)
            }
        })
    }
    
    func enumerateLinkRangesContainingLocation(location: CGPoint, complete: @escaping (NSRange) -> Void) {
        
        var found = false
        
        self.attributedText.enumerateAttribute(NSAttributedString.Key(rawValue: RichTextViewDetectedDataHandlerAttributeName), in: NSMakeRange(0, attributedText.length), options: [], using: { (value, range, stop) in
            
            if let _: AnyObject = value as AnyObject   {
                
                self.enumerateViewRectsForRanges([NSValue(range: range)], complete: { (rect, range, stop) -> Void in
                    
                    if !found {
                        
                        if rect.contains(location) {
                            
                            self.drawRoundedCornerForRange(range: range, rect: rect)
                            
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
            self.attributedText.enumerateAttribute(NSAttributedString.Key(rawValue: RichTextViewImageAttributeName), in: NSMakeRange(0, attributedText.length), options: [], using: { (value, range, stop) in
                
                if let _ = value   {
                    
                    self.enumerateViewRectsForRanges([NSValue(range: range)], complete: { (rect, range, stop) -> Void in
                        
                        if !found {
                            
                            if rect.contains(location) {
                                
                                self.drawRoundedCornerForRange(range: range, rect: rect)
                                
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
    
    func enumerateViewRectsForRanges(_ ranges: [NSValue], complete: @escaping (_ rect: CGRect, _ range: NSRange, _ stop: Bool) -> Void) {
        
        for rangeValue in ranges {
            
            let range = rangeValue.rangeValue
            
            let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            
            layoutManager.enumerateEnclosingRects(forGlyphRange: glyphRange, withinSelectedGlyphRange: NSMakeRange(NSNotFound, 0), in: textContainer, using: { (rect, stop) -> Void in
                var rect = rect
                
                rect.origin.x += self.textContainerInset.left
                rect.origin.y += self.textContainerInset.top
                rect = rect.inset(by: self.tapAreaInsets)
                
                complete(rect, range, true)
            })
            
        }
        
        return
    }
    
    func drawRoundedCornerForRange(range: NSRange, rect: CGRect) {

        let layer = CALayer()
        layer.frame = rect
        layer.backgroundColor = tapHighLightColor.cgColor
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
        self.layer.addSublayer(layer)
        
        delay(delay: 0.2, closure: { () -> () in
          layer.removeFromSuperlayer()
        })
        
    }
    
    @objc func textChanged() {
        if let _ = attributedPlaceholder {
            if (text as NSString).length == 0 {
                placeHolderLabel.isHidden = false
            } else {
                placeHolderLabel.isHidden = true
            }
        }

        self.setNeedsDisplay()
    }
    
    func handleClickedOnData(string: String, dataType: DetectedDataType, range: NSRange ){
        if let clickedOnData = clickedOnData {
            clickedOnData(string, dataType, range)
        }
    }
    
    func handleCurrentDetactedData(string: String, dataType: DetectedDataType, range: NSRange) {
        if let currentDetactedData = currentDetactedData {
            currentDetactedData(string, dataType, range)
        }
    }
    
    public func appendImage(imageName: String ,image: UIImage, width: CGFloat) {
        
        if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
            
            newAttributedText.append(NSAttributedString(string: "\n"))
            
            var _ = text.lengthOfBytes(using: String.Encoding.utf8)
            
            self.attributedText = newAttributedText
            
            let imageWidth = image.size.width
            
            let radio:CGFloat = width / imageWidth
            
            let size = CGSize(width: image.size.width*radio, height: image.size.height*radio)
            appendImage(imageName: imageName, image: image, size: size)
            
            appendNewLine()
        }
    }
    
    public func appendNewLine() {
        
        if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
            
            let newLineString = NSMutableAttributedString(string: "\n")
            
            newLineString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle(spacing: 0), range: NSRange(location: 0, length: newLineString.length))
            
            newAttributedText.append(newLineString)
            
            attributedText = newAttributedText
        }
        
    }
    
    public func appendImage(imageName: String ,image: UIImage, size: CGSize){
        
        let attachment = NSTextAttachment(data: nil, ofType: nil)
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y:0, width:size.width, height:size.height)
        
        if let attachmentAttributedString = NSAttributedString(attachment: attachment) as? NSMutableAttributedString {
            // sets the paragraph styling of the text attachment
            
            
            let attr: [NSAttributedString.Key: Any] = [NSAttributedString.Key.paragraphStyle: paragraphStyle(spacing: 0), NSAttributedString.Key(rawValue: RichTextViewImageAttributeName): imageName, NSAttributedString.Key(rawValue: RichTextViewDetectedDataHandlerAttributeName): DetectedDataType.Image.rawValue]
            
            attachmentAttributedString.addAttributes(attr, range: NSRange(location: 0, length: attachmentAttributedString.length))
            
            if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
                
                newAttributedText.append(attachmentAttributedString)
                
                self.attributedText = newAttributedText
            }
        }
    }
    
    public func findAllImageRange() -> [[String : NSRange]]?{
        
        var finalRange = [[String : NSRange]]()
        
        self.attributedText.enumerateAttribute(NSAttributedString.Key(rawValue: RichTextViewImageAttributeName), in: NSRange(location: 0, length: self.attributedText.length), options: [], using: { (value, range, finish) in
            
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
        
        self.attributedText.enumerateAttribute(NSAttributedString.Key(rawValue: RichTextViewImageAttributeName), in: NSRange(location: 0, length: self.attributedText.length), options: [], using: { (value, range, finish) in
            
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
        attachment.bounds = CGRect(x:0, y:0, width:size.width, height:size.height)
        
        if let attachmentAttributedString = NSAttributedString(attachment: attachment) as? NSMutableAttributedString {
            // sets the paragraph styling of the text attachment
            
            let paragraphStyle = NSMutableParagraphStyle()
            
            paragraphStyle.paragraphSpacing = 10
            
            paragraphStyle.paragraphSpacingBefore = 10
            
            let attr: [NSAttributedString.Key: Any] = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key(rawValue: RichTextViewImageAttributeName): imageName, NSAttributedString.Key(rawValue: RichTextViewDetectedDataHandlerAttributeName): DetectedDataType.Image.rawValue]
            
            attachmentAttributedString.addAttributes(attr, range: NSRange(location: 0, length: attachmentAttributedString.length))
            
            if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
                
                newAttributedText.insert(attachmentAttributedString, at: index)
                
                self.attributedText = newAttributedText
            }
        }
    }
    
    public func replaceImage(imageName: String, image: UIImage, size: CGSize, index: Int){
        
        let attachment = NSTextAttachment(data: nil, ofType: nil)
        attachment.image = image
        attachment.bounds = CGRect(x:0, y:0, width:size.width, height:size.height)
        
        if let attachmentAttributedString = NSAttributedString(attachment: attachment) as? NSMutableAttributedString {
            // sets the paragraph styling of the text attachment
            
            let paragraphStyle = NSMutableParagraphStyle()
            
            paragraphStyle.paragraphSpacing = 10
            
            paragraphStyle.paragraphSpacingBefore = 10
            
            let attr: [NSAttributedString.Key: Any] = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key(rawValue: RichTextViewImageAttributeName): imageName, NSAttributedString.Key(rawValue: RichTextViewDetectedDataHandlerAttributeName): DetectedDataType.Image.rawValue]
            
            attachmentAttributedString.addAttributes(attr, range: NSRange(location: 0, length: attachmentAttributedString.length))
            
            if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
                
                newAttributedText.replaceCharacters(in: NSRange(location: index, length: 1), with: attachmentAttributedString)
                
                self.attributedText = newAttributedText
            }
        }
    }
    
    func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        var rect = bounds
        
        if self.responds(to: #selector(getter: UITextView.textContainer)) {
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
    
    func delay(delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
}

extension RichTextView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
