//
//  SignUpVC.swift
//  Meidu
//
//  Created by William Huang on 9/3/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confPwField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!

    let picker = UIImagePickerController()
    var userStorage: StorageReference!
    var userUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = image
            nextBtn.isHidden = false
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func selectImagePressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        guard nameField.text != "", emailField.text != "",  passwordField.text != "", confPwField.text != "" else {return}
        
        if passwordField.text == confPwField.text {
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if error != nil {
                    print("Can't create user \(String(describing: error!))")
                }else{
                    if let user = user {
                        self.userUid = user.uid
                        self.setUpUser()
                    }
                }
            })
        }else{
            print("Password doesn't match")
            print(passwordField.text!)
            print(confPwField.text!)
        }
    }
    
    func setUpUser(){
        userStorage = Storage.storage().reference().child("users")
        
        let changeReq = Auth.auth().currentUser?.createProfileChangeRequest()
        changeReq?.displayName = self.nameField.text!
        changeReq?.commitChanges(completion: nil)
        
        
        let imgRef = self.userStorage.child("\(userUid!).jpg")
        let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let uploadDataTask = imgRef.putData(data!, metadata: metaData, completion: { (metadata, err) in
            if err != nil {
                print(err?.localizedDescription as Any)
                return
            }else {
                print("uploaded")
                let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        let userData:[String : Any] = ["uid" : self.userUid, "fullname" : self.nameField.text!, "urlToImg" : url]
                        
                       Database.database().reference().child("users").child(self.userUid).setValue(userData)
                        
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC")
                        
                        self.present(vc, animated: true, completion: nil)
                    }
            }
        })
        
        uploadDataTask.resume()
        
        
    }
    
}
