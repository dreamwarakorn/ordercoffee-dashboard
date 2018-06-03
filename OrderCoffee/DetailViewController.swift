//
//  DetailViewController.swift
//  OrderCoffee
//
//  Created by Warakorn Rungseangthip on 1/5/2561 BE.
//  Copyright © 2561 Warakorn Rungseangthip. All rights reserved.
//

import UIKit
import Firebase

struct ProductDetail {
    let name: String
    let type: String
    let qty: String
    let sweet: String
    let cream: String
    let syrup: String
}

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timePickLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPriceLbl: UILabel!
    
    var userID = Auth.auth().currentUser?.uid
    var databaseRef: DatabaseReference!
    var productList = [ProductDetail]()
    var getName = String()
    var getTime = String()
    var getDate = String()
    var getTimes = String()
    var getPrice = String()
    var getImageUrl = String()
    var getImage = UIImage()
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.clipsToBounds = true
        
        navigationItem.title = "Detail Order"
        
        imageView.image = getImage
        nameLbl.text = getName
        timePickLbl.text = "Pick up time \(getTime)"
        totalPriceLbl.text = "Total \(getPrice) ฿"
        
        let date = getDate + " " + getTimes
        
        databaseRef = Database.database().reference().child("OrderDetail").child(userID!).child(date)
        databaseRef.observe(DataEventType.value, with: {(DataSnapshot) in
            if DataSnapshot.childrenCount > 0 {
                self.productList.removeAll()
                
                for products in DataSnapshot.children.allObjects as! [DataSnapshot]{
                    let productObject = products.value as? [String: AnyObject]
                    let productName = productObject?["ProductName"]
                    let productType = productObject?["ProductType"]
                    let productQty = productObject?["TotalQty"]
                    let productSweet = productObject?["OptionSweet"]
                    let productCream = productObject?["OptionCream"]
                    let productSyrup = productObject?["OptionSyrup"]
                    
                    let product = ProductDetail(name: (productName as! String?)!, type: (productType as! String?)!, qty: (productQty as! String?)!, sweet: (productSweet as! String?)!, cream: (productCream as! String?)!, syrup: (productSyrup as! String?)!)
                    self.productList.append(product)
                }
                self.tableView.reloadData()
            }
        })
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

    // Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DetailTableViewCell
        let product: ProductDetail
        
        product = productList[indexPath.row]
        
        cell.nameLbl.text = product.name
        cell.detailLbl.text = product.type + " " + product.sweet + " " + product.cream + " " + product.syrup
        cell.qtyLbl.text = product.qty
        return cell
    }
    
    @IBAction func completeBtn(_ sender: Any) {
        saveToHistory()
        deleteValue()
        self.performSegue(withIdentifier: "goToOrder", sender: self)
    }
    
    func deleteValue() {
        let date = getDate + " " + getTimes
        
        Database.database().reference().child("OrderDetail").child(userID!).child(date).removeValue()
        Database.database().reference().child("Order").child(userID!).child(getDate).child(getTimes).removeValue()
    }
    
    func saveToHistory() {
        let date = getDate + " " + getTimes
        
        for object in productList {
            count += 1
            Database.database().reference().child("OrderHistoryDetail").child(userID!).child(date).child("Item\(count)").child("ProductName").setValue(object.name)
            Database.database().reference().child("OrderHistoryDetail").child(userID!).child(date).child("Item\(count)").child("ProductType").setValue(object.type)
            Database.database().reference().child("OrderHistoryDetail").child(userID!).child(date).child("Item\(count)").child("OptionSweet").setValue(object.sweet)
            Database.database().reference().child("OrderHistoryDetail").child(userID!).child(date).child("Item\(count)").child("OptionCream").setValue(object.cream)
            Database.database().reference().child("OrderHistoryDetail").child(userID!).child(date).child("Item\(count)").child("OptionSyrup").setValue(object.syrup)
            Database.database().reference().child("OrderHistoryDetail").child(userID!).child(date).child("Item\(count)").child("TotalQty").setValue(object.qty)
            
            Database.database().reference().child("OrderHistory").child(userID!).child(date).child("ProductNameShow").setValue(object.name)
            Database.database().reference().child("OrderHistory").child(userID!).child(date).child("ProductTypeShow").setValue(object.type)
            Database.database().reference().child("OrderHistory").child(userID!).child(date).child("OptionSweetShow").setValue(object.sweet)
            Database.database().reference().child("OrderHistory").child(userID!).child(date).child("OptionCreamShow").setValue(object.cream)
            Database.database().reference().child("OrderHistory").child(userID!).child(date).child("OptionSyrupShow").setValue(object.syrup)
            Database.database().reference().child("OrderHistory").child(userID!).child(date).child("TotalQtyShow").setValue(object.qty)
        }
        
        Database.database().reference().child("OrderHistory").child(userID!).child(date).child("CustomerName").setValue(getName)
        Database.database().reference().child("OrderHistory").child(userID!).child(date).child("Date").setValue(getDate)
        Database.database().reference().child("OrderHistory").child(userID!).child(date).child("Time").setValue(getTimes)
        Database.database().reference().child("OrderHistory").child(userID!).child(date).child("CustomerImage").setValue(getImageUrl)
        Database.database().reference().child("OrderHistory").child(userID!).child(date).child("TotalPrice").setValue(getPrice)
    }
    
}
