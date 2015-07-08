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
    
    var clickOnMention: ((mention: String) -> Void)?
    
    var clickOnHashTag: ((hashtag: String) -> Void)?
    
    var clickOnEmail: ((email: String) -> Void)?
    
    var clickOnURL: ((url: String) -> Void)?
    
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

    func handleClickOnMention(mention: String) {
        if let clickOnMention = clickOnMention {
            clickOnMention(mention: mention)
        }
    }
    
    func handleClickOnHashTag(hashTag: String) {
        if let clickOnHashTag = clickOnHashTag {
            clickOnHashTag(hashtag: hashTag)
        }
    }
    
    func handleClickOnEmail(email: String) {
        if let clickOnEmail = clickOnEmail {
            clickOnEmail(email: email)
        }
    }
    
    func handleClickOnURL(url: String) {
        if let clickOnURL = clickOnURL {
            clickOnURL(url: url)
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
