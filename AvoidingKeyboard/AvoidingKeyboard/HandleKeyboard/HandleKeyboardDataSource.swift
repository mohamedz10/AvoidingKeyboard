//
//  HandleKeyboardDataSource.swift
//  AvoidingKeyboard
//
//  Created by Mohamed on 9/05/17.
//  Copyright © 2017 mohamedz. All rights reserved.
//

import UIKit

protocol HandleKeyboardDataSource {
    func bottomInset(currentVC : UIViewController) -> CGFloat
}

@objc protocol HandleKeyboardDelegate {
    func whosNextResponder(currentVC : UIViewController?, currentResponder : UIView) -> UIView?
}


class HandleKeyboard: UIView, UITextFieldDelegate, UITextViewDelegate {
    
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var owner : UIViewController?
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            oldValue?.removeGestureRecognizer(tapGesture)
            scrollView.addGestureRecognizer(tapGesture)
        }
    }
    
    @IBOutlet weak var focusedView : UIView?
    
    //MARK: - Properties
    
    lazy var tapGesture : UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HandleKeyboard.dismissKeyBoardOnTap))
        tapGesture.cancelsTouchesInView = false
        return tapGesture
    }()
    
    var dataSource : HandleKeyboardDataSource?
    var delegate : HandleKeyboardDelegate?
    
    
    //MARK: - Lifecycle
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        NotificationCenter.default.addObserver(self, selector: #selector(HandleKeyboard.keyboardWillShow(notification:)), name:Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HandleKeyboard.keyboardWillHide(notification:)), name:Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: Keyboard notifications
    
    func keyboardWillShow(notification: NSNotification) {
        
        guard let scrollView = self.scrollView else { return }
        
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let focusedView = focusedView, let owner = self.owner {
            
            //Get keyboard rect
            let keyboardRect = owner.view.convert(keyboardFrame, from: nil)
            
            //Set the new inset
            var contentInset = scrollView.contentInset
            contentInset.bottom = keyboardRect.height + (dataSource?.bottomInset(currentVC: owner) ?? 0)
            
            //Calculate the rect that should be visible
            var visibleRect = focusedView.superview!.convert(focusedView.frame, to: owner.view)
            visibleRect = CGRect(x: 0, y: scrollView.frame.origin.y,  width: scrollView.frame.width, height: scrollView.frame.height - (scrollView.frame.height - visibleRect.origin.y - visibleRect.height))
            let intersectRect = visibleRect.intersection(keyboardRect)
            
            //If there is an intersection
            if intersectRect.height > 0
            {
                let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
                let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! UInt
                
                UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve).intersection(.beginFromCurrentState), animations: { () -> Void in
                    scrollView.contentInset = contentInset
                    scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + intersectRect.height + 8), animated: false)
                }, completion: nil)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        guard let scrollView = self.scrollView else { return }
        
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve).intersection(.beginFromCurrentState), animations: { () -> Void in
            var contentInset = scrollView.contentInset
            contentInset.bottom = (self.dataSource?.bottomInset(currentVC: self.owner!) ?? 0)
            self.scrollView.contentInset = contentInset
        }, completion: nil)
    }
    
    
    //MARK: UITextViewDelegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        focusedView = textView
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        focusedView = nil
        return true
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        focusedView = textField
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        focusedView = nil
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let focusedView = focusedView , let nextResponder = delegate?.whosNextResponder(currentVC: owner, currentResponder: focusedView) {
            textField.resignFirstResponder()
            nextResponder.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func dismissKeyBoardOnTap() {
        focusedView?.resignFirstResponder()
    }
    
}
