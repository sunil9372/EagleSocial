//
//  Friend.swift
//  EagleSocial
//
//  Created by Jody Bailey on 3/27/18.
//  Copyright © 2018 Jody Bailey. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

class Friend {
    
    // Variables to store the friends name and email
    let name : String
    let userId : String
    var profilePic : UIImage
    
    // Initialize the friend with name and email
    init(name : String, userId : String) {
        let name : String = name
        let userId : String = userId
        
        self.name = name
        self.userId = userId
        self.profilePic = #imageLiteral(resourceName: "profile_icon")
        
        self.updateProfilePic()
    }
    
    public func updateProfilePic() {
        let storage = Storage.storage()
        let storageRef = storage.reference(withPath: "image/\(self.userId)/userPic.jpg")
        
        var image : UIImage?
        storageRef.getData(maxSize: 4 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error getting image from storage, \(error)")
            } else {
                // Data for "images/island.jpg" is returned
                print("image retreived successfully")
                image = UIImage(data: data!)
            }
            if image != nil {
                self.setProfilePic(image: image!)
            }
            //            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        }
    }
    
    public func setProfilePic(image: UIImage) {
        self.profilePic = image
    }
    
    public func getFriend() -> Friend {
        return self
    }
}