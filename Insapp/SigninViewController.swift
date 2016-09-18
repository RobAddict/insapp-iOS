//
//  LoginViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/12/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class SigninViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var validateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lightStatusBar()
    }
    
    @IBAction func connectAction(_ sender: AnyObject) {
        guard let username = usernameTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        APIManager.signin(username: username, password: password) { (opt_cred) in
            guard let credentials = opt_cred else { self.triggerError("Wrong Credentials") ; return }
            APIManager.login(credentials, completion: { (opt_cred) in
                guard let creds = opt_cred else { self.triggerError("Wrong Credentials") ; return }
                Credentials.saveContext()
                APIManager.fetch(user_id: creds.userId, completion: { (opt_user) in
                    guard let _ = opt_user else { self.triggerError("Error When Fetching User") ; return }
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "TabViewController")
                        self.present(vc, animated: true, completion: nil)
                    }
                })
            })
        }
    }    
}

