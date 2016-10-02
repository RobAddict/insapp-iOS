//
//  SplashScreenViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class SpashScreenViewController: UIViewController {
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let credentials = Credentials.fetch() {
            self.login(credentials)
        }else{
            self.signin()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lightStatusBar()
        self.loader.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5) { 
            self.imageView.frame.origin.y -= self.imageView.frame.width/2
            self.loader.alpha = 1
        }
    }
    
    func login(_ credentials:Credentials){
        APIManager.login(credentials, controller: self, completion: { (opt_cred) in
            guard let creds = opt_cred else { self.signin() ; return }
            APIManager.fetch(user_id: creds.userId, controller: self, completion: { (opt_user) in
                guard let _ = opt_user else { self.signin() ; return }
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.registerForNotification()
                self.displayTabViewController()
            })
        })
    }
    
    func signin(){
        DispatchQueue.main.async {
            self.loadViewController(name: "TutorialViewController")
        }
    }
    
    func displayTabViewController(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var completion: ((UIViewController) -> Void)? = nil
        if let notification = appDelegate.notification {
            completion = { viewController in
                if let event_id = notification["id"] as? String {
                    self.loadEventViewController(viewController as! UITabBarController, event_id: event_id)
                }
            }
        }
        self.loadViewController(name: "TabViewController", completion: completion)
    }
    
    func loadEventViewController(_ controller: UITabBarController, event_id: String){
        controller.selectedIndex = 1
        let navigationController = (controller.selectedViewController as! UINavigationController)
        let eventController = (navigationController.topViewController as! EventTableViewController)
        APIManager.fetchEvent(event_id: event_id, controller: eventController, completion: { (opt_event) in
            guard let event = opt_event else { return }
            DispatchQueue.main.async {
                eventController.loadEvent(event: event)
            }
        })
    }
    
    func loadViewController(name: String, completion: ((_ vc: UIViewController) -> Void)? = nil){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: name)
        if name == "TabViewController" {
            (vc as! UITabBarController).delegate = UIApplication.shared.delegate as! UITabBarControllerDelegate?
        }
        self.present(vc, animated: true) {
            guard let _ = completion else { return }
            completion!(vc)
        }
    }
}
