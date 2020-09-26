	//
//  ViewController.swift
//  GoodealBBMembership
//
//  Created by GoodealBB on 20/07/2019.
//  Copyright © 2019 GoodealBB. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Foundation
import SDWebImage
import Kingfisher

class ViewController: UIViewController {
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var regView: UIView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var cPassword: UITextField!
    @IBOutlet weak var contact: UITextField!
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPw: UITextField!
    @IBOutlet weak var showName: UILabel?
    @IBOutlet weak var showEmail: UILabel?
    @IBOutlet weak var showStatus: UILabel?
    @IBOutlet weak var showVip: UIImageView?
    @IBOutlet weak var showContact: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Setting ScrollView Content Size to make it scrollable, image displayable
        annSV?.contentSize = CGSize(width: 600, height: 1200)
        self.displayAnn()
        eveSV?.contentSize = CGSize(width: 600, height: 1200)
        self.displayEve()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Setting ScrollView Content Size to fit image width properly
        var contentRect = CGRect.zero

        for view in self.annSV?.subviews ?? Array<UIView>() {
            contentRect = contentRect.union(view.frame)
        }
        self.annSV?.contentSize = contentRect.size

        for view in self.eveSV?.subviews ?? Array<UIView>() {
            contentRect = contentRect.union(view.frame)
        }
        self.eveSV?.contentSize = contentRect.size
        
        // Display User Profile Info from Firestore
        let db = Firestore.firestore()
        db.collection("Users").whereField("email", isEqualTo: Auth.auth().currentUser?.email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.showName?.text = "Username: " + String (document.get("name") as? String ?? "")
                        self.showEmail?.text = "Email: " + String ( document.get("email") as? String ?? "")
                        self.showStatus?.text = "Status: " + String (document.get("vip") as? String ?? "")
                        self.showContact?.text = "Contact No.: " + String (document.get("hp") as? String ?? "")
                        if document.get("vip") as? String ?? "" == "VIP"{
                            self.showVip?.image = UIImage(named:"homevipimage")
                        }
                        else if document.get("vip") as? String ?? "" == "member"{
                            self.showVip?.image = UIImage(named:"cust")
                        }
                        else if document.get("vip") as? String ?? "" == "admin"{
                            self.showVip?.image = UIImage(named:"admin")
                        }
                        
                    }
                    
                }
        }
    }
    
    //Function to switch between Login view and Register view
    @IBAction func switchViews(sender: UISegmentedControl){
        switch sender.selectedSegmentIndex{
        case 0:
            loginView.alpha = 1
            regView.alpha = 0
            break
        default:
            loginView.alpha = 0
            regView.alpha = 1
            break
        }
    }

    //Function for User Registration
    @IBAction func register(_ sender: Any) {
        let regName = userName.text
        let regEmail = email.text
        let regPassword = password.text
        let regCPassword = cPassword.text
        let regContact = contact.text
        let db = Firestore.firestore()
        
        //validations
        if(regName=="" || regEmail=="" || regPassword=="" || regCPassword==""){
            let alert = UIAlertController(title: nil , message: "Please fill up all the required fields with * !", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)        }
            
        //if passwords don't match
        else if(regPassword!.elementsEqual(regCPassword!)==false){
            let alert = UIAlertController(title: nil , message: "Password Not Matched!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)         }
        //if validations allow
        else{
            // Register a new user with email for FirebaseAuth
            Auth.auth().createUser(withEmail: regEmail!, password: regPassword!) { authResult, error in
                // Add a new document with a generated id to Firestore
                var ref: DocumentReference? = nil
                ref = db.collection("Users").addDocument(data: [
                    "name": regName!,
                    "email": regEmail!,
                    "hp": regContact!,
                    "vip": "member"
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        let alert = UIAlertController(title: nil , message: "Register Failed! \(err)", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {//IF successful
                        print("Document added with ID: \(ref!.documentID)")
                        let alert = UIAlertController(title: nil , message: "Register Successful! ", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }
                
                }
            }
        }
    
    //Function for Field-filling validations
    @IBAction func login(_ sender: Any) {
        let loginMail = loginEmail.text
        let loginPW = loginPw.text
        
        //validations
        if(loginMail=="" || loginPW==""){
            let alert = UIAlertController(title: nil , message: "Please fill up all the required fields!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    var login = false

    //Function for Email&Password validations
    func canLogin() -> Bool{
        let loginMail = loginEmail.text
        let loginPW = loginPw.text
        
        Auth.auth().signIn(withEmail: loginMail!, password: loginPW!){
            (result, error) in
            if error != nil{
                let alert = UIAlertController(title: nil , message: "Invalid Email/Password!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.login = false
            }
            else{
                self.login = true
                let user = Auth.auth().currentUser
            }
        }
        return login
    }
    
    @IBOutlet weak var annSV: UIScrollView?
    //Function to load and display Announcements
    func displayAnn() -> Void{
        let db = Firestore.firestore()
        let storage = Storage.storage()
        let placeholderImage = UIImage(named: "GoodealBB@1Logo.jpg")
        var counter = 0
        db.collection("Announcements")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    
                } else {
                    for document in querySnapshot!.documents {
                        if (document.get("url") as? String != nil){
                            let image = UIImageView(frame: CGRect(x: Int(UIScreen.main.bounds.width/2)-(Int(UIScreen.main.bounds.width)-30)/2, y: counter, width: Int(self.annSV?.contentSize.width ?? 0), height: 400))
                            let downloadURL = URL(string: document.get("url") as? String ?? "")
                            // image.sd_setImage(with: downloadURL as? URL, placeholderImage: placeholderImage)
                            
                            image.kf.setImage(with: downloadURL)
                        
                            image.sizeThatFits(image.image?.size ?? CGSize())
                            
                            //self.view.addSubview(image)
                            self.annSV?.addSubview(image)
                            //image.center.x = self.annSV?.center.x ?? 0
                            counter = counter + 430
                        }
                            //TOPIC
                            let topics = UILabel()
                            
                            topics.font = UIFont.preferredFont(forTextStyle: .footnote)
                            
                            topics.font = UIFont.systemFont(ofSize: 36, weight: UIFont.Weight.thin)
                            
                            topics.textColor = .black
                            
                            topics.text = (document.get("title") as? String ?? "")
                            
                            topics.numberOfLines = 0
                            
                            topics.frame = CGRect(x: Int(UIScreen.main.bounds.width/2)-(Int(UIScreen.main.bounds.width)-30)/2, y: counter, width: Int(self.annSV?.contentSize.width ?? 0), height: 100)
                            
                            topics.sizeToFit()
                            
                            self.annSV?.addSubview(topics)
                            counter = counter + 115
                            
                            //CONTENT
                            let content = UILabel()
                            
                            content.font = UIFont.preferredFont(forTextStyle: .footnote)
                            
                            content.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.thin)
                            
                            content.textColor = .black
                            
                            content.text = (document.get("content") as? String ?? "")
                            
                            content.numberOfLines = 0;
                            
                            content.frame = CGRect(x: Int(UIScreen.main.bounds.width/2)-(Int(UIScreen.main.bounds.width)-30)/2, y: counter, width: Int(self.annSV?.contentSize.width ?? 0), height: Int(content.intrinsicContentSize.height))
                            
                            content.sizeToFit()
                            
                            self.annSV?.addSubview(content)
                            counter = counter + 115
                            
                    }
                }
        }

    }
    
    
    @IBOutlet weak var eveSV: UIScrollView?
    //Function to load and display Events
    func displayEve() -> Void{
        let db = Firestore.firestore()
        let storage = Storage.storage()
        let placeholderImage = UIImage(named: "GoodealBB@1Logo.jpg")
        var counter = 0
        db.collection("Events")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    
                } else {
                    for document in querySnapshot!.documents {
                        if (document.get("url") as? String != nil){
                            let image = UIImageView(frame: CGRect(x: Int(UIScreen.main.bounds.width/2)-(Int(UIScreen.main.bounds.width)-30)/2, y: counter, width: Int(self.eveSV?.contentSize.width ?? 0), height: 400))
                            let downloadURL = URL(string: document.get("url") as? String ?? "")
                            // image.sd_setImage(with: downloadURL as? URL, placeholderImage: placeholderImage)
                            
                            image.kf.setImage(with: downloadURL)
                            
                            image.sizeThatFits(image.image?.size ?? CGSize())
                            
                            //self.view.addSubview(image)
                            self.eveSV?.addSubview(image)
                            //image.center.x = self.annSV?.center.x ?? 0
                            counter = counter + 430
                        }
                            //TOPIC
                            let topics = UILabel()
                            
                            topics.font = UIFont.preferredFont(forTextStyle: .footnote)
                            
                            topics.font = UIFont.systemFont(ofSize: 36, weight: UIFont.Weight.thin)
                            
                            topics.textColor = .black
                            
                            topics.text = (document.get("title") as? String ?? "")
                            
                            topics.numberOfLines = 0
                            
                            topics.frame = CGRect(x: Int(UIScreen.main.bounds.width/2)-(Int(UIScreen.main.bounds.width)-30)/2, y: counter, width: Int(self.eveSV?.contentSize.width ?? 0), height: 100)
                            
                            topics.sizeToFit()
                            
                            self.eveSV?.addSubview(topics)
                            counter = counter + 115
                            
                            //CONTENT
                            let content = UILabel()
                            
                            content.font = UIFont.preferredFont(forTextStyle: .footnote)
                            
                            content.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.thin)
                            
                            content.textColor = .black
                            
                            content.text = (document.get("content") as? String ?? "")
                            
                            content.numberOfLines = 0;
                            
                            content.frame = CGRect(x: Int(UIScreen.main.bounds.width/2)-(Int(UIScreen.main.bounds.width)-30)/2, y: counter, width: Int(self.eveSV?.contentSize.width ?? 0), height: Int(content.intrinsicContentSize.height))
                            
                            content.sizeToFit()
                            
                            self.eveSV?.addSubview(content)
                            counter = counter + 115
                            
                        
                    }
                }
        }
        
    }
    
    //Overriding Function to check if Segue of Login Button should be performed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Pages"{
            
           // self.segueShouldOccur = true
            // self.segueShouldOccur = false
            let segueShouldOccur = canLogin()
            if !segueShouldOccur {
                
                return false
            }
            else {
                print("*** YEP, segue will occur")
            }
        }
        return true
    }
    
    //Sign Out Function
    @IBAction func signout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        
        var signoutAlert = UIAlertController(title: "Sign Out", message: "Are you sure you want to log out of this account?", preferredStyle: UIAlertController.Style.alert)
        
        signoutAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            do {
                try firebaseAuth.signOut()
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "startup")
                self.present(nextViewController, animated:true, completion:nil)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }))
        
        signoutAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Sign out canceled!")
        }))
        
        present(signoutAlert, animated: true, completion: nil)
    }
    
}

