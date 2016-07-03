//
//  ViewController.swift
//  MemeMe
//
//  Created by Shahbaz Javeed on 7/3/16.
//  Copyright © 2016 Shahbaz Javeed. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topCaption: UITextField!
    @IBOutlet weak var bottomCaption: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!

    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!

    var activeField: UITextField?
    
    @IBAction func takePhoto(sender: AnyObject) {
        showImagePicker(.Camera)
    }
    
    @IBAction func choosePhoto(sender: AnyObject) {
        showImagePicker(.PhotoLibrary)
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        let meme = saveMeme()
        let activityController = UIActivityViewController.init(activityItems: [meme.compositeImage], applicationActivities: nil)
        
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // Protocol Starts: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageView.image = image
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    // Protocol Ends
    
    // Protocol Starts: UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
    // Protocol Ends
    
    // Notification Starts: Keyboard
    func keyboardWillShow(notification: NSNotification) {
        if let fieldBeingEdited = activeField {
            if fieldBeingEdited == bottomCaption {
                self.view.frame.origin.y -= keyboardSize(notification)
            }
        }
    }
    
    func keyboardWillHide(info: NSNotification) {
        self.view.frame.origin.y = 0
    }
    // Notification Ends
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        shareButton.enabled = imageView.image != nil
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribeFromKeyboardNotifications()
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField(topCaption, withDefaultText: "TOP")
        configureTextField(bottomCaption, withDefaultText: "BOTTOM")
    }
    
    private
    
    func saveMeme() -> Meme {
        return Meme(topCaption: topCaption.text!, bottomCaption: bottomCaption.text!, chosenImage: imageView.image!, compositeImage: compositeMeme())
    }
    
    func compositeMeme() -> UIImage {
        navbar.hidden = true
        toolbar.hidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        toolbar.hidden = false
        navbar.hidden = false
        
        return compositeImage
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardSize(notification: NSNotification) -> CGFloat {
        if let rect = notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            return rect.CGRectValue().height
        } else {
            return CGFloat(0)
        }
    }
    
    func showImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = self
        
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func configureTextField(field: UITextField, withDefaultText defaultText: String) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0
        ]
        
        field.defaultTextAttributes = memeTextAttributes
        field.text = defaultText
        field.textAlignment = .Center
        field.borderStyle = .None
        field.backgroundColor = UIColor.clearColor()
        field.autocapitalizationType = .AllCharacters
        field.returnKeyType = .Done
        
        field.delegate = self
    }
}

