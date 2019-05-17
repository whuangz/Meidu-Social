//
//  UsersVC.swift
//  Meidu
//
//  Created by William Huang on 9/6/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit
import Firebase

class UsersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        // Do any additional setup after loading the view.
        
        retrieveUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath ) as! UserCell
        
        cell.nameLbl.text = user.fullName
        cell.userId = user.userId
        cell.userImage.downloadImage(from: user.imagePath!)
        checkFollowing(indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollower = false
        
        ref.child("users").child(uid!).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let following = snapshot.value as? Dictionary<String,AnyObject> {
                for(ke, val) in following {
                    if val as! String == self.users[indexPath.row].userId {
                        isFollower = true
                        
                        ref.child("users").child(uid!).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.users[indexPath.row].userId).child("follower/\(ke)").removeValue()
                        
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            
            if !isFollower {
                let following = ["following/\(key)" : self.users[indexPath.row].userId]
                let followers = ["followers/\(key)" : uid!]
                
                ref.child("users").child(uid!).updateChildValues(following as Any as! [AnyHashable : Any])
                ref.child("users").child(self.users[indexPath.row].userId).updateChildValues(followers)
                
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
            
        })
        
        ref.removeAllObservers()
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadPressed(_ sender: Any) {
        self.goToUpload()
    }
    
    @IBAction func feedPressed(_ sender: Any) {
        self.goToFeed()
    }
    
    func checkFollowing(indexPath: IndexPath){
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        
        ref.child("users").child(uid!).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let following = snapshot.value as? Dictionary<String, AnyObject> {
                for (_,val) in following {
                    if val as! String == self.users[indexPath.row].userId {
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        })
    }
    
    func retrieveUser(){
        Database.database().reference().child("users").queryOrderedByKey().observe(.value, with: { (snapshot) in
            let users = snapshot.value as! Dictionary<String,AnyObject>
            
            self.users.removeAll()
            
            for(_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid != Auth.auth().currentUser?.uid {
                        let userToShow = User()
                        
                        if let fullName = value["fullname"] as? String, let imagePath = value["urlToImg"] as? String {
                            userToShow.fullName = fullName
                            userToShow.imagePath = imagePath
                            userToShow.userId = uid
                            
                            self.users.append(userToShow)
                        }
                    }
                }
            }
            
            self.tableView.reloadData()
        })
        
        Database.database().reference().removeAllObservers()
    }

  
    func goToUpload(){
        performSegue(withIdentifier: "UploadImg", sender: nil)
    }
    
    func goToFeed(){
        performSegue(withIdentifier: "Feeds", sender: nil)
    }
    
}

extension UIImageView {
    func downloadImage(from imgUrl: String!) {
        let url = URLRequest(url: URL(string: imgUrl)!)
        
        let task = URLSession.shared.dataTask(with: url) {
            (data,res,err) in
            
            if err != nil {
                print(err!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        
        task.resume()
    }
}
