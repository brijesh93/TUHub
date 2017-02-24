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
    @IBOutlet weak var stackView: UIStackView!
    
    static private let segueIdentifier = "showTabBar"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideUI()
        
        // Attempt to sign in silently, show sign-in option if credentials are not stored
        
        User.signInSilently { (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: SignInViewController.segueIdentifier, sender: self)
            } else {
                self.showUI()
            }
            
            if let error = error {
                // TODO: Alert user of error
            }
        }
    }
    
    @IBAction func didPressSignIn(_ sender: UIButton) {
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
        stackView.isHidden = true
    }
    
    private func showUI() {
        stackView.isHidden = false
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
    
}
