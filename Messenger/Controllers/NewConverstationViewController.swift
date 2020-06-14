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
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let searchBar: UISearchBar = {
       
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for friends...."
        return searchBar
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
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        // Do any additional setup after loading the view.
        searchBar.becomeFirstResponder()
    }
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }

}
extension NewConverstationViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
