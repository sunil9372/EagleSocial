//
//  ProfileCreationViewController.swift
//  EagleSocial
//
//  Created by Jody Bailey on 2/25/18.
//  Copyright © 2018 Jody Bailey. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol DismissedView {
    func dismissed()
}

class ProfileCreationViewController: UIViewController {
    var delegate:DismissedView?
    var ref : DatabaseReference?
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ref = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        
        let user = Auth.auth().currentUser
        
        if let userId = user?.uid {
            let username = self.firstNameTextField.text! + " " + self.lastNameTextField.text!
            
            let parameters = ["name": username]
            
            ref?.child("Users/\(userId)").setValue(parameters)
        }
        
        delegate?.dismissed()
//        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func firstNameDone() {
    }
    
    @IBAction func lastNameDone() {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}