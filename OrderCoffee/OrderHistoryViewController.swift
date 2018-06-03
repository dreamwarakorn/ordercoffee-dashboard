//
//  OrderHistoryViewController.swift
//  OrderCoffee
//
//  Created by Warakorn Rungseangthip on 21/3/2561 BE.
//  Copyright © 2561 Warakorn Rungseangthip. All rights reserved.
//

import UIKit
import Firebase

struct History {
    let name : String
    let time : String
    let itemName : String
    let itemType : String
    let sweet: String
    let cream: String
    let syrup: String
    let qty : String
    let image : String
    let date : String
    let price : String
}

class OrderHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blankView: UIView!
    @IBOutlet weak var aivLoading: UIActivityIndicatorView!
    
    var databaseRef: DatabaseReference!
    var userID = Auth.auth().currentUser?.uid
    
    var historyList = [History]()
    var showMenu = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        sideMenuConstraint.constant = -268
        blankView.isHidden = true
        
        //ดึงค่าชื่อร้าน เวลาเปิด-ปิด และที่อยู่จาก Firebase
        databaseRef = Database.database().reference().child("OrderHistory").child(userID!)
        databaseRef.observe(DataEventType.value, with: {(DataSnapshot) in
            if DataSnapshot.childrenCount > 0 {
                self.historyList.removeAll()
                
                for customers in DataSnapshot.children.allObjects as! [DataSnapshot]{
                    
                    let customerObject = customers.value as? [String: AnyObject]
                    let customerName = customerObject?["CustomerName"]
                    let customerItemname = customerObject?["ProductNameShow"]
                    let customerItemtype = customerObject?["ProductTypeShow"]
                    let customerQty = customerObject?["TotalQtyShow"]
                    let customerSweet = customerObject?["OptionSweetShow"]
                    let customerCream = customerObject?["OptionCreamShow"]
                    let customerSyrup = customerObject?["OptionSyrupShow"]
                    let customerImage = customerObject?["CustomerImage"]
                    let customerDate = customerObject?["Date"]
                    let customerTimes = customerObject?["Time"]
                    let customerPrice = customerObject?["TotalPrice"]
                    
                    let customer = History(name: (customerName as! String?)!, time: (customerTimes as! String?)!, itemName: (customerItemname as! String?)!, itemType: (customerItemtype as! String?)!, sweet: (customerSweet as! String?)!, cream: (customerCream as! String?)!, syrup: (customerSyrup as! String?)!, qty: (customerQty as! String?)!, image: (customerImage as! String?)!, date: (customerDate as! String?)!, price: (customerPrice as! String?)!)
                    
                    self.historyList.append(customer)
                }
            }
            if self.historyList.isEmpty {
                self.blankView.isHidden = false
                print("empty")
            } else {
                self.historyList.sort(by: {$0.date > $1.date})
                self.aivLoading.stopAnimating()
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
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? HistoryTableViewCell else {
            return UITableViewCell()
        }
        let customer: History
        customer = historyList[indexPath.row]
        
        cell.nameLbl.text = customer.name
        cell.dateLbl!.text = "Date \(customer.date) time \(customer.time)"
        cell.detailLbl.text = "Order list \(customer.itemName) \(customer.itemType) \(customer.sweet) \(customer.cream) \(customer.syrup) \(customer.qty)"
        
        let url = URL(string: customer.image)
        let data = try? Data(contentsOf: url!)
        cell.inageView.image = UIImage(data: data!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let DvC = Storyboard.instantiateViewController(withIdentifier: "DetailHistoryViewController") as! DetailHistoryViewController
        let customer: History
        customer = historyList[indexPath.row]
        
        DvC.getName = customer.name
        DvC.getTime = customer.time
        DvC.getDate = customer.date
        DvC.getPrice = customer.price
        let url = URL(string: customer.image)
        let data = try? Data(contentsOf: url!)
        DvC.getImage = UIImage(data: data!)!
        self.navigationController?.pushViewController(DvC, animated: true)
    }
    
    @IBAction func menuBtn(_ sender: Any) {
        sideMenuConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        showMenu = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func orderHistoryBtn(_ sender: Any) {
        sideMenuConstraint.constant = -268
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        showMenu = false
        navigationController?.setNavigationBarHidden(false, animated: false)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sideMenuConstraint.constant = -268
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        showMenu = false
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

}
