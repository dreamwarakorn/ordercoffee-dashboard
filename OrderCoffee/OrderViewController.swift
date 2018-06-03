//
//  OrderViewController.swift
//  OrderCoffee
//
//  Created by Warakorn Rungseangthip on 21/3/2561 BE.
//  Copyright © 2561 Warakorn Rungseangthip. All rights reserved.
//

import UIKit
import Firebase

struct Customer {
    let name : String
    let time : String
    let itemName : String
    let itemType : String
    let sweet: String
    let cream: String
    let syrup: String
    let qty : String
    let image : String
    let times : String
    let date : String
    let price : String
}

class OrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blankView: UIView!
    @IBOutlet weak var aivLoading: UIActivityIndicatorView!
    
    var databaseRef: DatabaseReference!
    var userID = Auth.auth().currentUser?.uid
    
    var customerList = [Customer]()
    var showMenu = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        sideMenuConstraint.constant = -268
        blankView.isHidden = true
        
        //ดึงค่าชื่อร้าน เวลาเปิด-ปิด และที่อยู่จาก Firebase
        databaseRef = Database.database().reference().child("Order").child(userID!).child(getTodayString())
        databaseRef.observe(DataEventType.value, with: {(DataSnapshot) in
            if DataSnapshot.childrenCount > 0 {
                self.customerList.removeAll()
                
                for customers in DataSnapshot.children.allObjects as! [DataSnapshot]{
                    
                    let customerObject = customers.value as? [String: AnyObject]
                    let customerName = customerObject?["CustomerID"]
                    let customerTime = customerObject?["OrderTimePick"]
                    let customerItemname = customerObject?["ProductNameShow1"]
                    let customerItemtype = customerObject?["ProductTypeShow1"]
                    let customerQty = customerObject?["TotalQtyShow1"]
                    let customerSweet = customerObject?["OptionSweetShow1"]
                    let customerCream = customerObject?["OptionCreamShow1"]
                    let customerSyrup = customerObject?["OptionSyrupShow1"]
                    let customerImage = customerObject?["CustomerImg"]
                    let customerDate = customerObject?["Date"]
                    let customerTimes = customerObject?["Time"]
                    let customerPrice = customerObject?["TotalPrice"]
                    
                    let customer = Customer(name: (customerName as! String?)!, time: (customerTime as! String?)!, itemName: (customerItemname as! String?)!, itemType: (customerItemtype as! String?)!, sweet: (customerSweet as! String?)!, cream: (customerCream as! String?)!, syrup: (customerSyrup as! String?)!, qty: (customerQty as! String?)!, image: (customerImage as! String?)!, times: (customerTimes as! String?)!, date: (customerDate as! String?)!, price: (customerPrice as! String?)!)
                    
                    self.customerList.append(customer)
                }
            }
            if self.customerList.isEmpty {
                self.blankView.isHidden = false
                print("empty")
            } else {
                self.customerList.sort(by: {$0.time < $1.time})
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
        return customerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? HomeTableViewCell else {
            return UITableViewCell()
        }
        let customer: Customer
        customer = customerList[indexPath.row]
        
        cell.nameLbl!.text = customer.name
        cell.pickTimeLbl!.text = "Pick up time \(customer.time)"
        cell.detailLbl!.text = "Order list \(customer.itemName) \(customer.itemType) \(customer.sweet) \(customer.cream) \(customer.syrup) \(customer.qty)"
        
        let url = URL(string: customer.image)
        let data = try? Data(contentsOf: url!)
        cell.imgView!.image = UIImage(data: data!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let DvC = Storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        let customer: Customer
        customer = customerList[indexPath.row]
        
        DvC.getName = customer.name
        DvC.getTime = customer.time
        DvC.getDate = customer.date
        DvC.getTimes = customer.times
        DvC.getPrice = customer.price
        DvC.getImageUrl = customer.image
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
    
    @IBAction func orderBtn(_ sender: Any) {
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
    
    func getTodayString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        
        let today_string = String(day!) + "-" + String(month!) + "-" + String(year!)
        
        return today_string
        
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
