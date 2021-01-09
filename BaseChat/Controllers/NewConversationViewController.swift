//
//  NewConversationViewController.swift
//  BaseChat
//
//  Created by Caner Kaya on 07.01.21.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search for users"
        
        return bar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let noUsersLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No users found"
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .lightGray
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        view.backgroundColor = .white
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(DismissNewChatController))
        
        searchBar.becomeFirstResponder()
    }
    
    @objc func DismissNewChatController()
    {
        dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController: UISearchBarDelegate
{
    //when user taps on search button on keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        
    }
}
