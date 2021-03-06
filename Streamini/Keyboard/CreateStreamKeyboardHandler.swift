//
//  CreateStreamKeyboardHandler.swift
//  Streamini
//
//  Created by Vasily Evreinov on 30/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class CreateStreamKeyboardHandler: NSObject
{
    var view: UIView
    var constraint: NSLayoutConstraint
    var pickerConstraint: NSLayoutConstraint
    
    init(view: UIView, constraint: NSLayoutConstraint, pickerConstraint: NSLayoutConstraint)
    {
        self.view           = view
        self.constraint     = constraint
        self.pickerConstraint = pickerConstraint
        super.init()
    }
    
    func register()
    {
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillBeShown), name:Notification.Name("UIKeyboardWillShowNotification"), object:nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name:Notification.Name("UIKeyboardWillHideNotification"), object:nil)
    }
    
    func unregister()
    {
        NotificationCenter.default.removeObserver(self, name:Notification.Name("UIKeyboardWillShowNotification"), object:nil)
        
        NotificationCenter.default.removeObserver(self, name:Notification.Name("UIKeyboardWillHideNotification"), object: nil)
    }
    
    func keyboardWillBeShown(_ notification: Notification) {
        let tmp : [AnyHashable: Any] = (notification as NSNotification).userInfo!
        let duration : TimeInterval = tmp[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let keyboardFrame : CGRect = (tmp[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.constraint.constant = keyboardFrame.size.height + 10
            self.pickerConstraint.constant = -216.0
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let tmp : [AnyHashable: Any] = (notification as NSNotification).userInfo!
        let duration : TimeInterval = tmp[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let keyboardFrame : CGRect = (tmp[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.constraint.constant = 240
            self.view.layoutIfNeeded()
        })
    }
}
