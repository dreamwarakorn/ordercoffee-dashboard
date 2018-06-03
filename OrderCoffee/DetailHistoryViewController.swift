//
//  DetailHistoryViewController.swift
//  OrderCoffee
//
//  Created by Warakorn Rungseangthip on 8/5/2561 BE.
//  Copyright © 2561 Warakorn Rungseangthip. All rights reserved.
//

import UIKit
import Firebase

struct ItemDetail {
    let name: String
    let type: String
    let qty: String
    let sweet: String
    let cream: String
    let syrup: String
}

class DetailHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPriceLbl: UILabel!
    
    var userID = Auth.auth().currentUser?.uid
    var databaseRef: DatabaseReference!
    var itemList = [ItemDetail]()
    var getName = String()
    var getTime = String()
    var getDate = String()
    var getPrice = String()
    var getImageUrl = String()
    var getImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.clipsToBounds = true
        
        navigationItem.title = "Detail Order"
        
        imageView.image = getImage
        nameLbl.text = getName
        dateLbl.text = "Date \(getDate) time \(getTime)"
        totalPriceLbl.text = "Total \(getPrice) ฿"
        
        let date = getDate + " " + getTime
        
        databaseRef = Database.database().reference().child("OrderHistoryDetail").child(userID!).child(date)
        databaseRef.observe(DataEventType.value, with: {(DataSnapshot) in
            if DataSnapshot.childrenCount > 0 {
                self.itemList.removeAll()
                
                for products in DataSnapshot.children.allObjects as! [DataSnapshot]{
                    let productObject = products.value as? [String: AnyObject]
                    let productName = productObject?["ProductName"]
                    let productType = productObject?["ProductType"]
                    let productQty = productObject?["TotalQty"]
                    let productSweet = productObject?["OptionSweet"]
                    let productCream = productObject?["OptionCream"]
                    let productSyrup = productObject?["OptionSyrup"]
                    
                    let product = ItemDetail(name: (productName as! String?)!, type: (productType as! String?)!, qty: (productQty as! String?)!, sweet: (productSweet as! String?)!, cream: (productCream as! String?)!, syrup: (productSyrup as! String?)!)
                    self.itemList.append(product)
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
    
    // Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DetailHistoryTableViewCell
        let product: ItemDetail
        
        product = itemList[indexPath.row]
        
        cell.nameLbl.text = product.name
        cell.detailLbl.text = product.type + " " + product.sweet + " " + product.cream + " " + product.syrup
        cell.qtyLbl.text = product.qty
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
