//
//  PhotoViewController.swift
//  Messenger
//
//  Created by Dhruvin Vekariya on 2020-08-13.
//  Copyright © 2020 Neural Inc. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoViewController: UIViewController {
    private  let photoURL: URL
    
    init(with url: URL){
        self.photoURL = url
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .black
        view.addSubview(imageView)
        imageView.sd_setImage(with: photoURL, completed: nil)

        // Do any additional setup after loading the view.
    }
    private let imageView: UIImageView = {
          let imageView = UIImageView()
          imageView.contentMode = .scaleAspectFit
          return imageView
}()
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    

}
