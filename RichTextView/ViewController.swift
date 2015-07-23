//
//  ViewController.swift
//  RichTextView
//
//  Created by kevinzhow on 15/7/8.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var CommentReplyTextViewStyle : [String : AnyObject] {
        get {
            
            let paraStyle = NSMutableParagraphStyle()
            
            paraStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
            
            return [NSFontAttributeName: UIFont.systemFontOfSize(15.0),
                NSParagraphStyleAttributeName: paraStyle
            ]
        }
    }
    
    @IBOutlet weak var replaceButton: UIButton!
    
    var richTextViewDelegate = RichTextViewDelegateHandler() //Subclass this to Modify your needs and Make sure it will retain
    
    var richTextView: RichTextView!
    
    var currentRange: NSRange?
    
    func sizeHeightWithText(attrString: NSString, width: CGFloat, textAttributes: [NSObject : AnyObject]) -> CGSize {
        
        //    var attributeString = NSAttributedString(string: attrString as String, attributes: textAttributes)
        
        //    var line = CTLineCreateWithAttributedString(attributeString)
        //    var bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseGlyphPathBounds)
        
        var rect = attrString.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: .UsesLineFragmentOrigin | .UsesFontLeading, attributes: textAttributes, context: nil)
        
        return CGSize(width: ceil(rect.width), height: ceil(rect.height))
    }

    
    @IBAction func replaceWithUser(sender: AnyObject) {
        if let currentRange = currentRange {
            
            richTextView.textStorage.replaceCharactersInRange(currentRange, withString: "@kevinzhow")
            
            richTextView.selectedRange = NSMakeRange(currentRange.location + "@kevinzhow".length, 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        richTextView = RichTextView(frame: CGRectZero)
        
        richTextView.textContainer.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        richTextView.delaysContentTouches = false
        
//        richTextView.textContainer.lineFragmentPadding = 0
        
        richTextView.textContainerInset = UIEdgeInsetsZero
        
        richTextView.delegate = richTextViewDelegate
        
        richTextView.font = UIFont.systemFontOfSize(15.0)
        
        richTextView.scrollEnabled = true
        
        richTextView.text = "I am @kevinzhow and My email is kevinchou.c@gmail.com #Catch# \n you can find my blog at http://zhowkev.in"
        
        (richTextView.textStorage as! RichTextStorage).defaultTextStyle = CommentReplyTextViewStyle
        
        var newSize = sizeHeightWithText(richTextView.text, width: 350, textAttributes: CommentReplyTextViewStyle)
        
        richTextView.frame = CGRect(x: 0, y: 20, width: 350 , height: newSize.height + 400)
        
//        richTextView.placeholder = "Hello"
        
        richTextView.editable = false // true for realtime editing
        
        richTextView.selectable = true
        
        richTextView.currentDetactedData = { (string, dataType, range) in
            println("Current \(dataType.description) with \(string) at \(range)")
            
            self.currentRange = range
            
            self.view.bringSubviewToFront(self.replaceButton)
        }
        
        richTextView.clickedOnData = { (string, dataType, range) in
            println("Clicked On \(dataType.description) with \(string)")
        }
        
//        richTextView.insertImage("smallWatch", image: UIImage(named: "WatchBlack")!, size: CGSize(width: 10, height: 10), index: 2)
        

        richTextView.appendImage("bigWatch", image: UIImage(named: "WatchBlack")!, width: view.frame.width - 10)
        println(richTextView.attributedText)
        var ranges = richTextView.findAllImageRange()
        
        println(ranges)

        view.addSubview(richTextView)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

