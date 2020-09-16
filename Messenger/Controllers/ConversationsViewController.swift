//
//  ViewController.swift
//  Messenger
//
//  Created by Dhruvin Vekariya on 2020-06-11.
//  Copyright © 2020 Neural Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let  latestMessage: LatestMessage
    let otherUserUID: String
}

struct LatestMessage {
    let date: String
    let text:String
    let isRead: Bool
    
}
final class ConversationsViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    private let tableView: UITableView  = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()
    
    private let noConversationsLabel: UILabel = {
            
        let label = UILabel()
        label.text = "No Conversations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
 
    }
    
    
    private func listenForNewConversations(){
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
            let UID = UserDefaults.standard.value(forKey: "userUID") as? String else{
            return
        }
        print("Start Listening for messages")
        let safeEmail = DatabaseManager.generateSafeEmail(emailAddress: email)
        
        
        DatabaseManager.shared.getAllConversation(for: safeEmail,uid: UID,completion: { [weak self] res in
            switch res{
            case.success(let conversations):
                print(conversations)
                guard !conversations.isEmpty else{
                 self?.noConversationsLabel.isHidden = false
                     self?.tableView.isHidden = true
                    return
                }
                self?.conversations = conversations
                self?.tableView.isHidden = false
               self?.noConversationsLabel.isHidden = true
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case.failure(let error):
                self?.noConversationsLabel.isHidden = false
                self?.tableView.isHidden = true
                print("Failed to load convertsations \(error)")
            }
            
        })
    }
    
    @objc func didTapComposeButton(){
        let vc = NewConverstationViewController()
        vc.completion = { [weak self]  res in
            
            guard let strongSelf = self else{
                return
            }
            let currentConversations = strongSelf.conversations
            if let targetConversation = currentConversations.first(where: {
                $0.otherUserEmail == DatabaseManager.generateSafeEmail(emailAddress: res["email"] ?? "")
            }){
                let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id, otherUserUid: targetConversation.otherUserUID, otherUserName: targetConversation.name)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }else{
                
               self?.createNewConversation(result: res)
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC,animated: true)
    }
    
    private func createNewConversation(result: [String:String])
    {
        guard let name = result["name"], let email = result["email"], let uid = result["uid"] else{
            return
    }
        DatabaseManager.shared.checkForExistingConversation(with: name, targetRecipientUID: uid,completion:{ [weak self] response in
            guard let strongself = self else{
                return
            }
            switch response{
            case.success(let convID):
                let vc = ChatViewController(with: email,id: convID,otherUserUid: uid,otherUserName: name)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongself.navigationController?.pushViewController(vc, animated: true)
                
            case.failure(_):
                let vc = ChatViewController(with: email,id: nil, otherUserUid: uid,otherUserName: name)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongself.navigationController?.pushViewController(vc, animated: true)
            }
        })
        
    }
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        listenForNewConversations()
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
    private func setupTableView(){
        tableView.delegate  = self
        tableView.dataSource = self
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame =  view.bounds
    }
    

}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,for: indexPath) as!  ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id, otherUserUid: model.otherUserUID, otherUserName: model.name)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
