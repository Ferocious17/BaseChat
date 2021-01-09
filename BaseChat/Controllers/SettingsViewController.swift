//
//  SettingsViewController.swift
//  BaseChat
//
//  Created by Caner Kaya on 07.01.21.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    private let signOutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign out", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signOutButton.addTarget(self, action: #selector(DidTapSignOut), for: .touchUpInside)
        view.addSubview(signOutButton)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        signOutButton.frame = CGRect(x: 30,
                                     y: view.bottom-150,
                                     width: view.width-60,
                                     height: 52)
    }
    
    @objc func DidTapSignOut()
    {
        let alert = UIAlertController(title: "Sign out", message: "Do you really want to sign out?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: { [weak self] (_) in
            
            guard let strongSelf = self else
            {
                return
            }
        
            strongSelf.SignOut()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func SignOut() -> Void
    {
        do
        {
            try FirebaseAuth.Auth.auth().signOut()
            //go back to login screen
            let viewController = LoginViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        }
        catch
        {
            print("Failed to log out")
        }
    }
}
