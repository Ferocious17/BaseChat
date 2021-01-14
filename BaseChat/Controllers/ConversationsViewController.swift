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
    
    private var conversations = [Conversation]()
    
    private var loginObserver: NSObjectProtocol?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
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
        StartListeningForConversations()
        LoginObserver()
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
        
        noConversationsLabel.frame = CGRect(x: view.width/4,
                                      y: view.height/2-50,
                                      width: view.width/2,
                                      height: 100)
    }
    
    private func LoginObserver()
    {
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] (_) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.StartListeningForConversations()
        })
    }
    
    private func StartListeningForConversations()
    {
        guard let email = UserDefaults.standard.value(forKeyPath: "email") as? String else {
            return
        }
        
        if let observer = loginObserver
        {
            NotificationCenter.default.removeObserver(observer)
        }
        
        let safeEmail = DatabaseManager.SafeEmail(email: email)
        DatabaseManager.shared.GetAllConversations(for: safeEmail) { [weak self] (result) in
            switch result
            {
            case .success(let fetchedConversations):
                guard !fetchedConversations.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                
                self?.noConversationsLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.conversations = fetchedConversations
                
                DispatchQueue.main.async
                {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noConversationsLabel.isHidden = false
                print("Failed to get all conversations: \(error)")
            }
        }
    }
    
    @objc func DidTapCompose()
    {
        let viewController = NewConversationViewController()
        viewController.completion = { [weak self] result in
            
            let currentConversations = self?.conversations
            
            if let targetConversation = currentConversations?.first(where: {
                $0.otherUserEmail == DatabaseManager.SafeEmail(email: result.email)
            })
            {
                let viewController = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                viewController.isNewConversation = false
                viewController.title = targetConversation.name
                viewController.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
            else
            {
                self?.CreateNewConversation(result: result)
            }
        }
        let navViewController = UINavigationController(rootViewController: viewController)
        present(navViewController, animated: true, completion: nil)
    }
    
    private func CreateNewConversation(result: SearchResult)
    {
        let name = result.name
        let email = result.email
        
        //Check in database if conversation already exists
        let safeEmail = DatabaseManager.SafeEmail(email: email)
        DatabaseManager.shared.ConversationExists(with: safeEmail) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result
            {
            case .success(let conversationID):
                let viewController = ChatViewController(with: email, id: conversationID)
                viewController.isNewConversation = false
                viewController.title = name
                viewController.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(viewController, animated: true)
                
            case .failure(_):
                //Nil for conversationID because has no ID yet since it is being created now
                let viewController = ChatViewController(with: email, id: nil)
                viewController.isNewConversation = true
                viewController.title = name
                viewController.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(viewController, animated: true)
            }
        }
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
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        //cell.textLabel?.text = "Cell Prototype"
        cell.accessoryType = .disclosureIndicator
        cell.Configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        OpenConversation(model: model)
    }
    
    func OpenConversation(model: Conversation)
    {
        let viewController = ChatViewController(with: model.otherUserEmail, id: model.id)
        viewController.title = model.name
        viewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //print("View height: \(view.height)")
        return view.height/9.3
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            //delete
            let conversationID = conversations[indexPath.row].id
            tableView.beginUpdates()
            self.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            DatabaseManager.shared.DeleteConversation(conversationID: conversationID) { (success) in
                if !success
                {
                    print("Failed to delete conversation")
                }
            }
            tableView.endUpdates()
        }
    }
}

