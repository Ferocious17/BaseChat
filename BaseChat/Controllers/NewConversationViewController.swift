//
//  NewConversationViewController.swift
//  BaseChat
//
//  Created by Caner Kaya on 07.01.21.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {

    public var completion: ((SearchResult) -> (Void))?
    
    private let spinner = JGProgressHUD(style: .dark)
    
    //Firebase results --> Used to improve performance and save searched users
    private var users = [[String:String]]()
    //If the app only has one user, the array above will always be empty since the searching user will be filtered out
    private var hasFetched = false
    //results that are shown in tableView
    private var results = [SearchResult]()
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search for users"
        
        return bar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.identifier)
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
        view.backgroundColor = .systemBackground
        
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
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier, for: indexPath) as! SearchResultCell
        cell.Configure(with: model)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.height * 0.1
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
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else
        {
            return
        }
        
        let safeEmail = DatabaseManager.SafeEmail(email: currentUserEmail)
        
        self.spinner.dismiss()
        
        let results: [SearchResult] = self.users.filter {
            guard let email = $0["email"], email != safeEmail else
            {
                return false
            }
            
            guard let name = $0["name"]?.lowercased() else
            {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        }.compactMap({
            guard let email = $0["email"],
                  let name = $0["name"] else
            {
                return nil
            }
            
            return SearchResult(name: name, email: email)
        })
        
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
