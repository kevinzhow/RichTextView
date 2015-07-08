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
    
    var delegateHandler = RichTextViewDelegateHandler()
    
    var delegateProxy: RichTextViewDelegateProxy!
    
    var clickedOnData: ((string: String, dataType: DetectedDataType) -> Void)?
    
    var currentDetactedData: ((string: String, dataType: DetectedDataType) -> Void)?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        delegateHandler.richTextView = self
        delegateProxy = RichTextViewDelegateProxy(delegateProxy: delegateHandler)
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
        
        get {
            return delegateProxy
        }
        
        set (newDelegate){
            if let newDelegate = newDelegate {
                delegateProxy.delegateTargets.addObject(newDelegate)
            }
        }
        
    }
}
