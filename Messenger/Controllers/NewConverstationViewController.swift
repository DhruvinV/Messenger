//
//  NewConverstationViewController.swift
//  Messenger
//
//  Created by Dhruvin Vekariya on 2020-06-11.
//  Copyright © 2020 Neural Inc. All rights reserved.
//

import UIKit
import JGProgressHUD

class NewConverstationViewController: UIViewController {
    
    public var completion: (([String:String]) -> (Void))?
    
    private let spinner = JGProgressHUD(style: .dark)
    private var users = [[String:String]]()
    private var hasFetched = false
    private var results = [[String:String]]()
    
    private let searchBar: UISearchBar = {
       
        let Bar = UISearchBar()
        Bar.placeholder = "Search for friends...."
        return Bar
    }()
    
    private  let tableView: UITableView = {
        let table = UITableView()
        table.isHidden  = true
        table.register(UITableViewCell.self,forCellReuseIdentifier: "cell")
        return table
    }()
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))

        searchBar.becomeFirstResponder()
//        becomeFirstResponder()
     
//         searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: 100,
                                      width: view.width/2,
                                    height: 200
                                    )
    }


@objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }

}

extension NewConverstationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell",for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = results[indexPath.row]
        dismiss(animated: true, completion: {[weak self] in
            self?.completion?(targetUserData)
        })
        
        
    }
    
}
extension NewConverstationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
            
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view)
        print("sdsdsd\(text)")
        self.searchUsers(query: text)
        
        
    }
    
    func searchUsers(query: String){
        if hasFetched{
            filterUsers(with: query)
        }else{
            
            DatabaseManager.shared.getAllUsers(completion: {[weak self] res in
                switch res {
                case.success(let fetchedUsers):
                    self?.hasFetched  = true
                    self?.users = fetchedUsers
                    self?.filterUsers(with: query)
                case.failure(let err):
                    print("Failed to fetche all users \(err)")
                }
            })
        }
    }
    
    func filterUsers(with term: String){
        guard hasFetched else{
            return
        }
        self.spinner.dismiss()
        let results: [[String:String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else{
                return false
            }
            return name .hasPrefix(term.lowercased())
        })
        
        self.results = results
        updateUI()
    }
    
    func updateUI(){
        if results.isEmpty {
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
        }
        else{
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
