//
//  FeedVC.swift
//  Meidu
//
//  Created by William Huang on 9/11/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts = [Post]()
    var following = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPost()
    }
    
    func fetchPost() {
        Database.database().reference().child("users").queryOrderedByKey().observe(.value, with: { (snapshot) in
            let users = snapshot.value as! Dictionary<String,AnyObject>
            
            for(_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid == Auth.auth().currentUser?.uid {
                        if let followingUsers = value["following"] as? [String:String]{
                            for (_,user) in followingUsers {
                                self.following.append(user)
                            }
                        }
                        
                        self.following.append((Auth.auth().currentUser?.uid)!)
                        
                        Database.database().reference().child("posts").queryOrderedByKey().observe(.value, with: { (snapshot) in
                            let posts = snapshot.value as! Dictionary<String,AnyObject>
                            
                            self.posts.removeAll()
                            
                            for(_, value) in posts {
                                if let userId = value["userId"] as? String {
                                    for each in self.following {
                                        if each == userId {
                                            let postToShow = Post()
                                            
                                            if let author = value["author"] as? String, let likes = value["likes"] as? Int, let pathToImg = value["pathToImage"] as? String, let postId = value["postID"] as? String {
                                                
                                                postToShow.author = author
                                                postToShow.likes = likes
                                                postToShow.pathToImg = pathToImg
                                                postToShow.postId = postId
                                                postToShow.userId = userId
                                                
                                                if let people = value["peopleWhoLikes"] as? [String:AnyObject] {
                                                    for(_, person) in people {
                                                        postToShow.peopleWhoLike.append(person as! String)
                                                    }
                                                }
                                                
                                                self.posts.append(postToShow)
                                                
                                            }
                                        }
                                    }
                                }
                                self.collectionView.reloadData()
                                
                            }
                        })
                    }
                }
            }
        })
        
        Database.database().reference().removeAllObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = posts[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCell
        
        cell.postImage.downloadImage(from: post.pathToImg!)
        cell.authorLbl.text = post.author
        cell.likesLbl.text = "\(post.likes!) likes"
        cell.postId = post.postId
        
        for person in post.peopleWhoLike {
            if person == (Auth.auth().currentUser?.uid)! {
                cell.likeBtn.isHidden = true
                cell.unlikeBtn.isHidden = false
                break
            }
        }
        
        return cell
    }
    
    @IBAction func userPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
