//
//  SignInViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 2/12/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var signInButton: UIButton!
    
    static private let segueIdentifier = "showTabBar"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set text field delegates
        usernameField.delegate = self
        passwordField.delegate = self
        
        // Hide the UI since we don't know if it needs to be displayed yet
        hideUI()
        
        // Attempt to sign in silently, show sign-in option if credentials are not stored
        
        User.signInSilently { (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: SignInViewController.segueIdentifier, sender: self)
            } else {
                // The user needs to sign in, show the UI
                self.showUI()
            }
            
            if let error = error {
                // TODO: Alert user of error
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        determineSignInButtonState()
        
        // Observe keyboard show and hide
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(keyboardWillShow),
                           name: .UIKeyboardWillShow,
                           object: nil)
        
        center.addObserver(self,
                           selector: #selector(keyboardWillHide),
                           name: .UIKeyboardWillHide,
                           object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let center = NotificationCenter.default
        center.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        center.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func didPressSignIn(_ sender: UIButton) {
        signIn()
    }

    
    fileprivate func signIn() {
        if let username = usernameField.text, let password = passwordField.text {
            
            User.signIn(username: username, password: password, { (user, error) in
                
                if user != nil {
                    self.performSegue(withIdentifier: SignInViewController.segueIdentifier, sender: self)
                }
                
                if let error = error {
                    // TODO: Alert user of error
                }
                
            })
            
        } else {
            // TODO: Alert user that they have not provided both fields
        }
    }
    
    private func hideUI() {
        scrollView.isHidden = true
        signInButton.isHidden = true
    }
    
    private func showUI() {
        scrollView.isHidden = false
        signInButton.isHidden = false
    }
    
    /// Handles the event in which the keyboard shows, 
    /// in which it moves the sign in button above the keyboard
    func keyboardWillShow(notification: Notification) {
        updateBottomLayoutConstraint(with: notification)
    }
    
    /// Handles the event in which the keyboard hides, 
    /// in which it moves the sign in button below the keyboard
    func keyboardWillHide(notification: Notification) {
        updateBottomLayoutConstraint(with: notification)
    }
    
    func updateBottomLayoutConstraint(with notification: Notification) {
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        bottomLayoutConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0.0,
                       options: [.beginFromCurrentState, animationCurve],
                       animations: { self.view.layoutIfNeeded() },
                       completion: nil)
        
    }
    
    func determineSignInButtonState() {
        if let usernameText = usernameField.text,
            let passwordText = passwordField.text,
            usernameText.characters.count > 0 && passwordText.characters.count > 0 {
            signInButton.isEnabled = true
            signInButton.backgroundColor = UIColor.cherry
        } else {
            signInButton.isEnabled = false
            signInButton.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func didPressSkip(_ sender: UIButton) {
        performSegue(withIdentifier: SignInViewController.segueIdentifier, sender: self)
    }

    @IBAction func unwindToSignInViewController(segue: UIStoryboardSegue) {
        usernameField.text = ""
        passwordField.text = ""
        User.signOut()
        showUI()
    }
    
    @IBAction func usernameTextFieldDidChange(_ sender: UITextField) {
        determineSignInButtonState()
    }
    
    @IBAction func passwordTextFieldDidChange(_ sender: UITextField) {
        determineSignInButtonState()
    }
    
}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField === usernameField {
            passwordField.becomeFirstResponder()
        } else if textField === passwordField {
            textField.resignFirstResponder()
            signIn()
        }
        
        return true
    }
    
}
