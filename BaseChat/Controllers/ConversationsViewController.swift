//
//  ViewController.swift
//  BaseChat
//
//  Created by Caner Kaya on 07.01.21.
//

import UIKit
import FirebaseAuth

// Controller that gets loaded initially

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .link
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        ValidateAuthentication()
    }
    
    private func ValidateAuthentication()
    {
        // check if user is already logged in or not
        //if yes, stay in the conversations screen
        //if not go to the login screen
        if FirebaseAuth.Auth.auth().currentUser == nil
        {
            let viewController = LoginViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: false)
        }
    }
}

