//
//  Post.swift
//  Meidu
//
//  Created by William Huang on 9/11/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit

class Post: NSObject {
    var author: String!
    var likes: Int!
    var pathToImg: String!
    var userId: String!
    var postId: String!
    
    var peopleWhoLike: [String] = [String]()
}
