//
//  ViewController.swift
//  AvoidingKeyboard
//
//  Created by Mohamed on 9/05/17.
//  Copyright © 2017 mohamedz. All rights reserved.
//

import UIKit

class ViewController: UIViewController  {

    @IBOutlet var handleKeyboard: HandleKeyboard!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.handleKeyboard.delegate = self
        self.handleKeyboard.owner = self
        self.handleKeyboard.scrollView = self.scrollView
        self.textField.delegate = self.handleKeyboard

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController : HandleKeyboardDelegate{
    
    func whosNextResponder(currentVC: UIViewController?, currentResponder: UIView) -> UIView? {
        return nil
    }
}
