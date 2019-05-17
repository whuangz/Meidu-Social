//
//  LoginVC.swift
//  Meidu
//
//  Created by William Huang on 9/3/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    var userUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToCreateUser(){
        performSegue(withIdentifier: "SignUp", sender: nil)
    }
    
    @IBAction func loginPresed(_ sender: Any) {
        guard emailField.text != "", pwField.text != "" else {return}
        
        Auth.auth().signIn(withEmail: emailField.text!, password: pwField.text!) { (user, err) in
            if err != nil {
                print(err?.localizedDescription as Any)
            }else {
                if let user = user {
                    self.userUid = user.uid
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC")
                    
                    self.present(vc, animated: true, completion: nil)

                }
            }
        }
    }
    
    @IBAction func signUpPressed(_ sender: Any){
        self.goToCreateUser()
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
