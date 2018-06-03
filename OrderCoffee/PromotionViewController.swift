//
//  PromotionViewController.swift
//  OrderCoffee
//
//  Created by Warakorn Rungseangthip on 11/4/2561 BE.
//  Copyright © 2561 Warakorn Rungseangthip. All rights reserved.
//

import UIKit
import Firebase

class PromotionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var promotionImage: UIImageView!
    @IBOutlet weak var promotionTextView: UITextView!
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    //ประกาศตัวแปร
    var userID = Auth.auth().currentUser?.uid
    var databaseRef: DatabaseReference!
    var rootRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    var selectedImage: UIImage?
    var showMenu = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        sideMenuConstraint.constant = -268
        
        databaseRef = Database.database().reference()
        databaseRef.child("Shop").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.promotionTextView.text = value?["PromotionDetail"] as? String ?? ""
            
            if(value?["PromotionImg"] != nil)
            {
                let promotionImage = value?["PromotionImg"] as? String ?? ""
                
                let url = URL(string: promotionImage)
                let data = try? Data(contentsOf: url!)
                self.promotionImage.image = UIImage(data: data!)
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //ตกแต่ง Status bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)){
            statusBar.backgroundColor = UIColor(named: "Status")!
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func savePromoBtn(_ sender: Any) {
        self.rootRef.child("Shop").child(userID!).child("PromotionDetail").setValue(self.promotionTextView.text!)
        
        let imageRef = storageRef.child("Shop").child(userID!).child("PromotionImg")
        if let itemPic = self.selectedImage, let imageData = UIImageJPEGRepresentation(itemPic, 0.1){
            imageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
                if error != nil{
                    return
                }
                
                let promoImageUrl = metadata?.downloadURL()?.absoluteString
                self.rootRef.child("Shop").child(self.userID!).child("PromotionImg").setValue(promoImageUrl)
            })
        }
        //แจ้งเตือน
        let saveFieldAlert = UIAlertController(title: "Save", message: "Success", preferredStyle: .alert)
        saveFieldAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(saveFieldAlert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        selectedImage = image
        promotionImage.image = image
        promotionImage.contentMode = .scaleAspectFill
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectPhoto(_ sender: UITapGestureRecognizer) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func menuBtn(_ sender: Any) {
        sideMenuConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        showMenu = true
    }
    
    @IBAction func logoutBtn(_ sender: Any) {
        do
        {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "goToLogin", sender: self)
        }
        catch let error as NSError
        {
            print (error.localizedDescription)
        }
    }
    
    @IBAction func promotionBtn(_ sender: Any) {
        sideMenuConstraint.constant = -268
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        showMenu = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sideMenuConstraint.constant = -268
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        showMenu = false
    }
}
