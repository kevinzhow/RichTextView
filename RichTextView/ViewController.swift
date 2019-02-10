//
//  ViewController.swift
//  RichTextView
//
//  Created by kevinzhow on 15/7/8.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var CommentReplyTextViewStyle : [NSAttributedString.Key : Any] {
        get {
            
            let paraStyle = NSMutableParagraphStyle()
            
            paraStyle.lineBreakMode = .byWordWrapping
            
            return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0),
                NSAttributedString.Key.paragraphStyle: paraStyle
            ]
        }
    }
    
    @IBOutlet weak var replaceButton: UIButton!
    
    var richTextViewDelegate = RichTextViewDelegateHandler() //Subclass this to Modify your needs and Make sure it will retain

    
    lazy var richTextView: RichTextView = {
        let view = RichTextView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textContainer.lineBreakMode = .byWordWrapping
        
        view.delaysContentTouches = false
        
        //        richTextView.textContainer.lineFragmentPadding = 0
        
        view.font = UIFont.systemFont(ofSize: 15.0)
        
        view.isScrollEnabled = true
        view.textContainerInset = UIEdgeInsets.zero
        view.isEditable = true // true for realtime editing
        
        view.isSelectable = true
         (view.textStorage as! RichTextStorage).defaultTextStyle = CommentReplyTextViewStyle
        return view
    }()
    
    var currentRange: NSRange?
    
    func sizeHeightWithText(attrString: NSString, width: CGFloat, textAttributes: [NSAttributedString.Key : Any]) -> CGSize {
        
        //    var attributeString = NSAttributedString(string: attrString as String, attributes: textAttributes)
        
        //    var line = CTLineCreateWithAttributedString(attributeString)
        //    var bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseGlyphPathBounds)
        
        let rect = attrString.boundingRect(with: CGSize(width: width, height:CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: textAttributes, context: nil)
        
        return CGSize(width: ceil(rect.width), height: ceil(rect.height))
    }

    
    @IBAction func replaceWithUser(sender: AnyObject) {
        if let currentRange = currentRange {
            
            richTextView.textStorage.replaceCharacters(in: currentRange, with: "@kevinzhow")
            
            richTextView.selectedRange = NSMakeRange(currentRange.location + "@kevinzhow".count, 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        richTextView.delegate = richTextViewDelegate
        richTextView.text = "I am @kevinzhow and My email is kevinchou.c@gmail.com #Catch# \n you can find my blog at http://zhowkev.in"
        
        _ = sizeHeightWithText(attrString: richTextView.text! as NSString, width: 350, textAttributes: CommentReplyTextViewStyle)
        
        richTextView.currentDetactedData = { (string, dataType, range) in
            print("Current \(dataType.description) with \(string) at \(range)")
            
            self.currentRange = range
            
            self.view.bringSubviewToFront(self.replaceButton)
        }
        
        richTextView.clickedOnData = { (string, dataType, range) in
            print("Clicked On \(dataType.description) with \(string)")
        }
        
//        richTextView.insertImage("smallWatch", image: UIImage(named: "WatchBlack")!, size: CGSize(width: 10, height: 10), index: 2)
        
        let imageWidth = self.view.frame.width - 10
        richTextView.appendImage(imageName: "bigWatch", image: UIImage(named: "WatchBlack")!, width: imageWidth)
        
        print(richTextView.attributedText)
        let ranges = richTextView.findAllImageRange()
        
        print(ranges)

        view.addSubview(richTextView)
        
        richTextView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        richTextView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        richTextView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        richTextView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        

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

