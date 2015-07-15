//
//  ViewController.swift
//  RichTextView
//
//  Created by kevinzhow on 15/7/8.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var textStorage = RichTextStorage()
    
    var layoutManager = NSLayoutManager()
    
    var textContainer = NSTextContainer()
    
    @IBOutlet weak var replaceButton: UIButton!
    
    var richTextViewDelegate =  RichTextViewDelegateHandler() //Subclass this to Modify your needs and Make sure it will retain
    
    var richTextView: RichTextView!
    
    var currentRange: NSRange?
    
    @IBAction func replaceWithUser(sender: AnyObject) {
        if let currentRange = currentRange {
            
            textStorage.replaceCharactersInRange(currentRange, withString: "@kevinzhow")
            
            richTextView.selectedRange = NSMakeRange(currentRange.location + "@kevinzhow".length, 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textStorage.addLayoutManager(layoutManager)
        
        layoutManager.addTextContainer(textContainer)
        
        richTextView = RichTextView(frame: CGRectZero, textContainer: textContainer)
        
        richTextView.delegate = richTextViewDelegate
        
        richTextView.text = "We are here so happy to make it #rock# with @kevinzhow \nhis blog is http://zhowkev.in and My email is kevinchou.c@gmail.com"
        
        richTextView.placeholder = "Hello"
        
        richTextView.editable = true // true for realtime editing
        
        richTextView.selectable = true
        
        richTextView.currentDetactedData = { (string, dataType, range) in
            println("Current \(dataType.description) with \(string) at \(range)")
            
            self.currentRange = range
            
            self.view.bringSubviewToFront(self.replaceButton)
        }
        
        richTextView.clickedOnData = { (string, dataType) in
            println("Clicked On \(dataType.description) with \(string)")
        }
        
        richTextView.insertImage(UIImage(named: "WatchBlack")!, size: CGSize(width: 10, height: 10), index: 2)
        
        richTextView.appendImage(UIImage(named: "WatchBlack")!, width: view.frame.width - 10)

        view.addSubview(richTextView)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        richTextView.frame = CGRect(x: 0, y: 20, width: view.bounds.width, height: view.bounds.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

