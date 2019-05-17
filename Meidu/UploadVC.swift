//
//  UploadVC.swift
//  Meidu
//
//  Created by William Huang on 9/7/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit
import Firebase

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var selectImage: UIButton!
    @IBOutlet weak var postBtn: UIButton!
    
    var picker = UIImagePickerController()
    
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
            self.previewImage.image = image
            selectImage.isHidden = true
            postBtn.isHidden = false
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func selectPressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func postPressed(_ sender: Any) {
        
        AppDelegate.instance().showActivityIndicator()
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let storage = Storage.storage().reference()
        
        let key = ref.child("posts").childByAutoId().key
        let imgRef = storage.child("posts").child(uid!).child("\(key).jpg")
        
        let data = UIImageJPEGRepresentation(self.previewImage.image!, 0.6)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let uploadTask = imgRef.putData(data!, metadata: metaData) { (metadata,err) in
            if err != nil {
                print(err?.localizedDescription as Any)
                AppDelegate.instance().dimissActivityIndicator()
                return
            }else {
                print("uploaded")
                let downloadUrl = metadata?.downloadURL()?.absoluteString
                
                if let url = downloadUrl {
                    let feed:[String:Any] = ["userId" : uid! , "pathToImage" : url, "likes" : 0, "author" : (Auth.auth().currentUser?.displayName)!, "postID" : key]
                    
                    let postFeed = ["\(key)" : feed]
                    
                    ref.child("posts").updateChildValues(postFeed)
                    
                    AppDelegate.instance().dimissActivityIndicator()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        uploadTask.resume()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
