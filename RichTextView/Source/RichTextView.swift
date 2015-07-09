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

    override var delegate: UITextViewDelegate? {
        
        didSet {
            (delegate as! RichTextViewDelegateHandler).richTextView = self
        }
        
    }
}
