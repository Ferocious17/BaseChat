//
//  ViewController.swift
//  BaseChat
//
//  Created by Caner Kaya on 07.01.21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

// Controller that gets loaded initially

class ConversationsViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversations"
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .lightGray
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(DidTapCompose))
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        SetupTableView()
        FetchConversations()
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        ValidateAuthentication()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    @objc func DidTapCompose()
    {
        let viewController = NewConversationViewController()
        let navViewController = UINavigationController(rootViewController: viewController)
        present(navViewController, animated: true, completion: nil)
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
    
    private func SetupTableView()
    {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func FetchConversations()
    {
        tableView.isHidden = false
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Cell Prototype"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = ChatViewController()
        viewController.title = "User name"
        viewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(viewController, animated: true)
    }
}

