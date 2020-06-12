//
//  ViewController.swift
//  Messenger
//
//  Created by Dhruvin Vekariya on 2020-06-11.
//  Copyright © 2020 Neural Inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .red
        // Do any additional setup after loading the view.
//        DatabaseManager.shared.test()
//        let nav = UINavigationController(loginViewController)
    }
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
//        let isLoggedIn = UserDefaults.standard.bool(forKey:"Logged_In")
//        if !isLoggedIn{
//            let vc = LoginViewController()
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .fullScreen
//            present(nav,animated: true)
//        }
        validateAuth()
    }
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }

}

