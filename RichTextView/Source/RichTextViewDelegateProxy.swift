//
//  RichTextViewDelegateProxy.swift
//  
//
//  Created by kevinzhow on 15/7/9.
//
//

import UIKit
import Foundation

class RichTextViewDelegateProxy: NSObject {
   
    var delegateTargets = NSMutableArray()
    
    
    init(delegateProxy: NSObject) {
        super.init()
        delegateTargets.addObject(delegateProxy)
    }

    
    override func respondsToSelector(aSelector: Selector) -> Bool {
        for delegate in delegateTargets {

            if delegate.respondsToSelector(aSelector) {
                return true
            }
        }
        
        return super.respondsToSelector(aSelector)
    }
    
    override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        
        for delegate in delegateTargets {
            
            if delegate.respondsToSelector(aSelector) {
                return delegate
            }
        }
        
        return nil
    }
}

extension RichTextViewDelegateProxy: UITextViewDelegate {

}
