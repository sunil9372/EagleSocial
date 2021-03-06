//
//  FriendsViewController.swift
//  EagleSocial
//
//  Created by Jody Bailey on 1/31/18.
//  Copyright © 2018 Jody Bailey. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var friendTableView: UITableView!
    
    var friends = [Person]()
    var friendRequests = [Person]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.friendRequests = friendList.friendRequests

        for friend in friendList.getFriendList() {
            if friend.userId == thisUser.userID {
                friendList.removeFriend(friend: friend)
            }
        }
        
        friends = friendList.getFriendList()
        friendList.updateList()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(doSomething), for: .valueChanged)
        
        // this is the replacement of implementing: "collectionView.addSubview(refreshControl)"
        friendTableView.refreshControl = refreshControl
        
        // Do any additional setup after loading the view.
        friendTableView.delegate = self
        friendTableView.dataSource = self
        
        friendTableView.register(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "friendCell")
        friendTableView.register(UINib(nibName: "FriendRequestCell", bundle: nil), forCellReuseIdentifier: "friendRequestCell")
        
        let ref = Database.database().reference()
        _ = ref.child("Requests").child(thisUser.userID).observe(.value, with: { (snapshot) in
            guard let snapDict = snapshot.value as? [String : [String : Any]] else { return }
            
            var userId : String?
            
            for snap in snapDict {
                for snip in snap.value {
                    if snip.key == "from" {
                        userId = (snip.value as! String)
                    }
                    if snip.value as? Bool == true {
                        for user in allUsers.people {
                            if user.userId == userId {
                                user.key = snap.key
                                self.friendRequests.append(user)
                            }
                        }
                    }
                }
            }
            self.friendTableView.reloadData()
            
        }, withCancel: {(err) in
            
            print(err)
        })
        
        
        let _ = ref.child("Friends").child(thisUser.userID).observe(.value, with: { (snapshot) in
            guard let snapDict = snapshot.value as? [String : [String : Any]] else { return }
            self.friends = [Person]()
            var alreadyFriends : Bool = false
            for snap in snapDict {
                print(snap)
                for snip in snap.value {
                    let friend = allUsers.getUser(userId: snip.value as! String)
                    for dude in self.friends {
                        if dude.userId == friend.userId {
                            alreadyFriends = true
                        }
                    }
                    if !alreadyFriends {
                        self.friends.append(friend)
                    }
                    
                }
            }
            self.friendTableView.reloadData()
        })
        
        configureTableView()
        
        friendTableView.reloadData()
    }
    
    @objc func doSomething(refreshControl: UIRefreshControl) {
        
        for friend in self.friends {
            friend.updateProfilePic()
        }
        
        let ref = Database.database().reference()
        let _ = ref.child("Friends").child(thisUser.userID).observe(.value, with: { (snapshot) in
            guard let snapDict = snapshot.value as? [String : [String : Any]] else { return }
            self.friends = [Person]()
            var alreadyFriends : Bool = false
            for snap in snapDict {
                print(snap)
                for snip in snap.value {
                    let friend = allUsers.getUser(userId: snip.value as! String)
                    for dude in self.friends {
                        if dude.userId == friend.userId {
                            alreadyFriends = true
                        }
                    }
                    if !alreadyFriends {
                        self.friends.append(friend)
                    }
                    
                }
            }
            self.friendTableView.reloadData()
        })

        friendTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        var ref : DatabaseReference?
        
        let alert = UIAlertController(title: "Send Friend Request", message: "Enter email", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Send", style: .default) { (action) in
            ref = Database.database().reference()
            
            let email = textField.text
            var userFound : Bool = false
            var person : Person?
            
            for user in allUsers.getAllUsers() {
                if user.email == email {
                    userFound = true
                    person = user
                }
            }
            
            if userFound {
                if person?.userId != thisUser.userID {
                    var alreadyFriends : Bool = false
                    for dude in self.friends {
                        if dude.userId == person?.userId {
                            alreadyFriends = true
                        }
                    }
                    if !alreadyFriends {
                        let params = ["from" : thisUser.userID,
                                      "active" : true] as [String : Any]
                        ref?.child("Requests").child((person?.userId)!).childByAutoId().setValue(params)
                        
                        self.friendTableView.reloadData()
                        friendList.updateFriendRequests()
                    } else {
                        textField.text = ""
                        textField.placeholder = "Already friends"
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    textField.text = ""
                    textField.placeholder = "Cannot add yourself"
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                textField.text = ""
                textField.placeholder = "User not found"
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "john.doe@usm.edu"
            textField.keyboardType = .default
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.performSegue(withIdentifier: "goToFriendProfile", sender: indexPath)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FriendProfileViewController {
            
            let vc = segue.destination as? FriendProfileViewController
            if let indexPath = sender as? IndexPath {
                vc?.friend = self.friends[indexPath.row]
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.friendRequests.count
        } else {
            return friends.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestCell", for: indexPath) as! FriendRequestCell
            
            cell.nameLabel.text = self.friendRequests[indexPath.row].name
            cell.profilePic.image = self.friendRequests[indexPath.row].photo
            cell.profilePic.layer.cornerRadius = 10
            cell.profilePic.layer.masksToBounds = true
            cell.acceptButton.addTarget(self, action: #selector(acceptRequest), for: UIControlEvents.touchUpInside)
            cell.declineButton.addTarget(self, action: #selector(declineRequest), for: UIControlEvents.touchUpInside)
            
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell
            
            cell.userName.text = self.friends[indexPath.row].name
            cell.profilePicture.image = self.friends[indexPath.row].photo
            // Configure the cell...
            cell.profilePicture.layer.cornerRadius = 10
            cell.profilePicture.layer.masksToBounds = true
            
            return cell
        } else {
            fatalError()
        }
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func configureTableView() {
        friendTableView.rowHeight = UITableViewAutomaticDimension
        friendTableView.estimatedRowHeight = 240.0
    }
    
    @objc func acceptRequest(sender: AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.friendTableView)
        let indexPath = self.friendTableView.indexPathForRow(at: buttonPosition)
        if indexPath != nil {
            friendList.addFriend(friend: Person(name: self.friendRequests[(indexPath?.row)!].name, userId: self.friendRequests[(indexPath?.row)!].userId, age: self.friendRequests[(indexPath?.row)!].age, major: self.friendRequests[(indexPath?.row)!].major, schoolYear: self.friendRequests[(indexPath?.row)!].schoolYear, email: self.friendRequests[(indexPath?.row)!].email))
            
            if self.friendRequests[(indexPath?.row)!].userId != thisUser.userID {
                let ref = Database.database().reference()
                ref.child("Friends").child(thisUser.userID).childByAutoId().setValue(["userId": self.friendRequests[(indexPath?.row)!].userId])
                ref.child("Friends").child(self.friendRequests[(indexPath?.row)!].userId).childByAutoId().setValue(["userId": thisUser.userID])
            }
           
        }
        
        let ref = Database.database().reference()
        ref.child("Requests").child(thisUser.userID).child(self.friendRequests[(indexPath?.row)!].key!).updateChildValues(["active" : false])
        self.friendRequests.remove(at: (indexPath?.row)!)
        self.friendTableView.reloadData()
        
    }
    
    @objc func declineRequest(sender: AnyObject) {
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.friendTableView)
        let indexPath = self.friendTableView.indexPathForRow(at: buttonPosition)
        if indexPath != nil {
            let ref = Database.database().reference()
            ref.child("Requests").child(thisUser.userID).child(self.friendRequests[(indexPath?.row)!].key!).updateChildValues(["active" : false])
            self.friendRequests.remove(at: (indexPath?.row)!)
            self.friendTableView.reloadData()
        }
    }

}
