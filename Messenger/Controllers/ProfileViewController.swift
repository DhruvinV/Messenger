//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Dhruvin Vekariya on 2020-06-11.
//  Copyright © 2020 Neural Inc. All rights reserved.
//

import UIKit

import FirebaseAuth

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var data = [ProfileViewModel]()
    override func viewDidLoad() {
        super.viewDidLoad()


//        print(UserDefaults.standard.value(forKey:"fullName"))
        
    }
    
    override func viewDidAppear(_ animated: Bool){
     super.viewDidAppear(animated)
        data = [ProfileViewModel]()
        
        tableView.register(ProfileTableViewCell.self,
                           forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.register(UITableViewCell.self,
                                   forCellReuseIdentifier: "cell")
         tableView.tableHeaderView = createTableHeader()
        
        data.append(ProfileViewModel(viewModelType: .info,
                                             title: "Email: \(UserDefaults.standard.value(forKey:"email") as! String)",
                    handler: nil))
    
        
        data.append(ProfileViewModel(viewModelType: .logout, title: "Log Out", handler: { [weak self] in

            guard let strongSelf = self else {
                return
            }

            let actionSheet = UIAlertController(title: "",
                                          message: "",
                                          preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title:"Log Out",
                                                        style: .destructive,
                                                        handler: { [weak self] _ in
                        guard let strongSelf = self else{
                            return
                        }
                                                            UserDefaults.standard.setValue(nil, forKey: "email")
                                                            UserDefaults.standard.setValue(nil, forKey: "firstName")
                                                            UserDefaults.standard.setValue(nil, forKey: "lastName")
                                                            UserDefaults.standard.setValue(nil, forKey: "fullName")
                                                            UserDefaults.standard.setValue(nil, forKey: "userUID")
                        do {
                            try FirebaseAuth.Auth.auth().signOut()
                            let vc = LoginViewController()
                            let nav = UINavigationController(rootViewController: vc)
                            
                            nav.modalPresentationStyle = .fullScreen
                            strongSelf.present(nav, animated: true)
                        } catch{
                        }
                
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))

            strongSelf.present(actionSheet, animated: true)
        }))
        
        tableView.delegate = self
        tableView.dataSource = self
           tableView.reloadData()
       
        
    }
    
    func createTableHeader() -> UIView? {
        guard let uid = UserDefaults.standard.value(forKey: "userUID") else{
            return nil
        }
        let fileName = uid as! String + "_profile_picture.png"
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
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier,
                                                 for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
}
class ProfileTableViewCell: UITableViewCell{
    static  let identifier = "ProfileTableViewCell"
    public func setUp(with viewModel: ProfileViewModel){
        DispatchQueue.main.async{
            print(viewModel.title)
         self.textLabel?.text = viewModel.title
            switch viewModel.viewModelType {
            case .info:
                self.textLabel?.textAlignment = .left
                self.selectionStyle = .none
            case .logout:
                self.textLabel?.textColor = .red
                self.textLabel?.textAlignment = .center
            }
        }
        

    }
}
