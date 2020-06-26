//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Dhruvin Vekariya on 2020-06-11.
//  Copyright © 2020 Neural Inc. All rights reserved.
//

import UIKit

import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
        
        // Do any additional setup after loading the view.
    }
    
    func createTableHeader() -> UIView? {
        guard let uid = UserDefaults.standard.value(forKey: "userUID") else{
            return nil
        }
        let fileName = uid as! String + "_profile_picture.png"
//        let safeEmail = "DatabaseManager.safeEmail(emai)
        print("\(fileName) IN CREATE TABLE HEADER")
        let path  = "images/" + fileName
        
        let headerView  = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        headerView.backgroundColor = UIColor(red: 0.56, green: 0.92, blue: 0.73, alpha: 1.00)
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.width - 150) / 2,y: 75,width: 150,height: 150))
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        headerView.addSubview(imageView)
        
        StorageManager.shared.donwloadURL(for: path, completion: { [weak self] result in
            switch result {
            case.success(let url):
                print(url,"in download url")
                self?.downloadImage(imageView: imageView, url: url)
            case.failure(let error):
                print(error)
            }
        })
        
        return headerView
    }
    
    func downloadImage(imageView: UIImageView, url :URL){
        
        URLSession.shared.dataTask(with: url, completionHandler: {data, _, error  in

        guard let data = data, error  == nil else {
            return
        }
        DispatchQueue.main.async{
            let image = UIImage(data: data)
            imageView.image = image
        }
    }).resume()
    
}
    
}
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actionSheet = UIAlertController(title:"Log Out",
                                            message:"Are you sure you want to leave :(",
                                            preferredStyle:.actionSheet)
        actionSheet.addAction(UIAlertAction(title:"Log Out",
                                            style: .destructive,
                                            handler: { [weak self] _ in
            guard let strongSelf = self else{
                return
            }
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            } catch {
                print("User Logged Out")
            }
    
}))
        actionSheet.addAction(UIAlertAction(title:"Cancel",
                                            style: .cancel,
                                            handler: nil))
present(actionSheet,animated: true)

    }
}
