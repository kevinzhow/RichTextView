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
            
            insertImage(image, size: CGSize(width: image.size.width*radio, height: image.size.height*radio), index: newLength + 1)
        }
    }
    
    func insertImage(image: UIImage, size: CGSize, index: Int){
        
        var attachment = NSTextAttachment(data: nil, ofType: nil)
        attachment.image = image
        attachment.bounds = CGRectMake(0, 0, size.width, size.height)
        
        var attachmentAttributedString = NSAttributedString(attachment: attachment)
        
        if let newAttributedText = self.attributedText.mutableCopy() as? NSMutableAttributedString {
            
            newAttributedText.insertAttributedString(attachmentAttributedString, atIndex: index)
            
            self.attributedText = newAttributedText
        }

    }

    override var delegate: UITextViewDelegate? {
        
        didSet {
            (delegate as! RichTextViewDelegateHandler).richTextView = self
        }
        
    }
}
