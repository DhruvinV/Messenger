//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Dhruvin Vekariya on 2020-06-11.
//  Copyright © 2020 Neural Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
class RegisterViewController: UIViewController {
    
     private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollview  = UIScrollView()
        scrollview.clipsToBounds = true
        return scrollview
    }()
    
    private let imageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(red: 0.20, green: 0.29, blue: 0.32, alpha: 1.00).cgColor
        return imageView
    }()
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name"
        
        field.leftView = UIView(frame: CGRect(x: 0,
                                              y:0,
                                              width: 10,
                                              height:0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name"
        
        field.leftView = UIView(frame: CGRect(x: 0,
                                              y:0,
                                              width: 10,
                                              height:0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address...."
        
        field.leftView = UIView(frame: CGRect(x: 0,
                                              y:0,
                                              width: 10,
                                              height:0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password...."
        field.leftView = UIView(frame: CGRect(x: 0,
                                              y:0,
                                              width: 10,
                                              height:0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    private let passwordVerifyField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Confirm Password...."
        field.leftView = UIView(frame: CGRect(x: 0,
                                              y:0,
                                              width: 10,
                                              height:0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = UIColor(red: 0.40, green: 0.86, blue: 0.98, alpha: 1.00)
        button.setTitleColor(UIColor(red: 0.20, green: 0.29, blue: 0.32, alpha: 1.00),for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20,weight: .bold)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",style: .done, target: self, action: #selector(didTapRegister))
        
        
        
        registerButton.addTarget(self,action: #selector(registerButtonTapped),for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        //      subviews
        view.addSubview(scrollView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(passwordVerifyField)
        scrollView.addSubview(registerButton)
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self,
                                             action:#selector(didTapProfileChangePic))
        imageView.addGestureRecognizer(gesture)
    }
    @objc private func didTapProfileChangePic(){
        presentPhotoActionSheet()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y:20,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = imageView.width/2.0
        firstNameField.frame = CGRect(x: 30,
                                      y:imageView.bottom+10,
                                      width: scrollView.width - 60,
                                      height: 52)
        lastNameField.frame = CGRect(x: 30,
                                     y:firstNameField.bottom+10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        emailField.frame = CGRect(x: 30,
                                  y:lastNameField.bottom+10,
                                  width: scrollView.width - 60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y:emailField.bottom+10,
                                     width: scrollView.width - 60,
                                     height: 52)
        passwordVerifyField.frame = CGRect(x: 30,
                                           y:passwordField.bottom+10,
                                           width: scrollView.width - 60,
                                           height: 52)
        registerButton.frame = CGRect(x: 30,
                                      y:passwordVerifyField.bottom+10,
                                      width: scrollView.width - 60,
                                      height: 52)
        
        
    }
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func registerButtonTapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text,
            let firstName = firstNameField.text,
            let lastName = lastNameField.text,
            let password = passwordField.text,
            let confirmPass = passwordVerifyField.text,
            !email.isEmpty,
            !password.isEmpty,
            !firstName.isEmpty,
            !lastName.isEmpty,
            password == confirmPass,
            password.count >= 8 else {
                alertUserLoginError()
                return
        }
        spinner.show(in: view)
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                               return
                    }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard exists else{
                strongSelf.alertUserLoginError(message: "Looks like a user for that email address already exists")
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion:{authResult, error in
                guard authResult != nil, error == nil else{
                    return
                }
                let uid = (authResult?.user.uid ?? "") as String
  
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email,uID: uid))
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
        //        firbase login
        
        
    }
    func alertUserLoginError(message: String = "Please check information provided"){
        
        let alert = UIAlertController(title: "Whoops", message: message,preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
        
    }
    
}
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            registerButtonTapped()
        }
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet(){
        let actionSheet  = UIAlertController(title: "Profile Picture",
                                             message: "How would like to select profile picture?",
                                             preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title:"Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title:"Take Photo",
                                            style: .default,
                                            handler: { [weak self]
                                                _ in
                                                self?.presentCamera()
                                                
        }))
        actionSheet.addAction(UIAlertAction(title:"Choose Photo",
                                            style: .default,
                                            handler: { [weak self]
                                                _ in
                                                self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    func presentCamera(){
        let vc  = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true)
    }
    func presentPhotoPicker(){
        let vc  = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true,completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        self.imageView.image = selectedImage
    }
    
    
}
