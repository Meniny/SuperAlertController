//
//  ViewController.swift
//  Sample
//
//  Created by Meniny on 2018-01-21.
//  Copyright © 2018年 Meniny. All rights reserved.
//

import UIKit
import SuperAlertController

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func alert(_ sender: UIButton) {
        let contentController = TestContentViewController.init(nibName: "TestContentViewController", bundle: nil)
        let azure = #colorLiteral(red: 0.05, green:0.49, blue:0.98, alpha:1.00)
        let alertController = SuperAlertController.init(style: .alert, source: self.view, title: "Testing", message: "This is a testing alert controller", tintColor: azure)
        alertController.setContentViewController(contentController, height: 150)
        alertController.addAction(image: nil, title: "Done", color: azure, style: .cancel, isEnabled: true, handler: nil)
        alertController.show(animated: true, vibrate: true, serial: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

