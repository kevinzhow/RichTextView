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
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        delegateProxy = RichTextViewDelegateProxy(delegateProxy: delegateHandler)
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
