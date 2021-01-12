//
//  NewConversationViewController.swift
//  BaseChat
//
//  Created by Caner Kaya on 07.01.21.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {

    public var completion: (([String:String]) -> (Void))?
    
    private let spinner = JGProgressHUD(style: .dark)
    
    //Firebase results --> Used to improve performance and save searched users
    private var users = [[String:String]]()
    //If the app only has one user, the array above will always be empty since the searching user will be filtered out
    private var hasFetched = false
    //results that are shown in tableView
    private var results = [[String:String]]()
    
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
    
    private let noResultsLabel: UILabel = {
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
        
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        //view.backgroundColor = .white
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(DismissNewChatController))
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: view.height/2-50,
                                      width: view.width/2,
                                      height: 100)
    }
    
    
    @objc func DismissNewChatController()
    {
        dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    //start conversation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //start the conversation
        let targetUserData = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
    }
}

extension NewConversationViewController: UISearchBarDelegate
{
    //when user taps on search button on keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else
        {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        
        self.SearchUsers(query: text)
    }
    
    func SearchUsers(query: String) -> Void
    {
        //Check if array has Firebase results
        if hasFetched
        {
            //if it does: filter results
            FilterUsers(with: query)
        }
        else
        {
            //if not: fetch, then filter
            DatabaseManager.shared.GetAllUsers { [weak self] (result) in
                switch result
                {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.FilterUsers(with: query)
                case .failure(let error):
                    print("Failed to get errors: \(error)")
                }
            }
        }
    }
    
    //Update UI: show results in tableView or noResultsLabel
    func FilterUsers(with term: String)
    {
        guard hasFetched else
        {
            return
        }
        
        self.spinner.dismiss()
        
        let results: [[String:String]] = self.users.filter { user -> Bool in
            guard let name = user["name"]?.lowercased() else
            {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        }
        
        self.results = results
        
        UpdateUI()
    }
    
    func UpdateUI()
    {
        if results.isEmpty
        {
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
        }
        else
        {
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
