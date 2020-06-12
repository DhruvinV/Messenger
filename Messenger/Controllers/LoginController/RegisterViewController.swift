//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Dhruvin Vekariya on 2020-06-11.
//  Copyright © 2020 Neural Inc. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
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
        print("Change pic Called")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y:20,
                                 width: size,
                                 height: size)
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
        //        firbase login
        
    }
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Whoops", message: "Please check information provided",preferredStyle: .alert )
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

extension RegisterViewController: UIImagePickerControllerDelegate {
    func presentPhotoActionSheet(){
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        <#code#>
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        <#code#>
    }
}
