//
//  PostCell.swift
//  Meidu
//
//  Created by William Huang on 9/10/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UICollectionViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var authorLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var unlikeBtn: UIButton!
    
    var postId: String!
    
    @IBAction func likePressed(_ sender: Any) {
        self.likeBtn.isEnabled = false
        
        let ref = Database.database().reference()
        let keyToPost = ref.child("posts").childByAutoId().key
        
        ref.child("posts").child(self.postId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let post = snapshot.value as? Dictionary<String,AnyObject> {
                let updateLike:[String : Any] = ["peopleWhoLikes/\(keyToPost)" : (Auth.auth().currentUser?.uid)!]
                
                ref.child("posts").child(self.postId).updateChildValues(updateLike, withCompletionBlock: { (error, reff) in
                    if error == nil {
                        ref.child("posts").child(self.postId).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let properties = snapshot.value as? Dictionary<String,AnyObject> {
                                if let likes = properties["peopleWhoLikes"] as? [String : AnyObject] {
                                    let count = likes.count
                                    self.likesLbl.text = "\(count) Likes"
                                    
                                    let update = ["likes" : count]
                                    ref.child("posts").child(self.postId).updateChildValues(update)
                                    
                                    self.likeBtn.isHidden = true
                                    self.unlikeBtn.isHidden = false
                                    self.likeBtn.isEnabled = true
                                }
                            }
                        })
                    }
                })
            }
            
        })
        
        ref.removeAllObservers()
        
    }
    
    @IBAction func unlikePressed(_ sender: Any) {
        self.unlikeBtn.isEnabled = false
        let ref = Database.database().reference()
        
        ref.child("posts").child(self.postId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let properties = snapshot.value as? [String: AnyObject] {
                if let peopleWhoLikes  = properties["peopleWhoLikes"] as? [String:AnyObject] {
                    for(id,person) in peopleWhoLikes {
                        if person as? String == Auth.auth().currentUser?.uid {
                            ref.child("posts").child(self.postId).child("peopleWhoLikes").child(id).removeValue(completionBlock: { (error, reff) in
                                if error == nil {
                                    ref.child("posts").child(self.postId).observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let prop = snapshot.value as? [String:AnyObject] {
                                            if let likes = prop["peopleWhoLikes"] as? [String:AnyObject] {
                                                let count = likes.count
                                                
                                                self.likesLbl.text = "\(count) Likes"
                                                let update = ["likes" : count]
                                                ref.child("posts").child(self.postId).updateChildValues(update)
                                            }else {
                                                self.likesLbl.text = "0 Likes"
                                                let update = ["likes" : 0]
                                                ref.child("posts").child(self.postId).updateChildValues(update)
                                            }
                                        }
                                    })
                                }
                            })
                            
                            self.likeBtn.isHidden = false
                            self.unlikeBtn.isHidden = true
                            self.unlikeBtn.isEnabled = true
                            break
                        }
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
}
