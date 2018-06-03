//
//  ProductViewController.swift
//  OrderCoffee
//
//  Created by Warakorn Rungseangthip on 21/3/2561 BE.
//  Copyright © 2561 Warakorn Rungseangthip. All rights reserved.
//

import UIKit
import Firebase

class ProductViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var userID = Auth.auth().currentUser?.uid
    var databaseRef: DatabaseReference!
    var productList = [Product]()
    var filteredProduct = [Product]()
    let searchController = UISearchController(searchResultsController: nil)
    var showMenu = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        sideMenuConstraint.constant = -268
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search product by name"
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white], for: .normal)
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func loadData() {
        self.productList.removeAll()
        databaseRef = Database.database().reference().child("Product").child(userID!)
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let productDict = snapshot.value as? [String:AnyObject] {
                for (_,productElement) in productDict {
                    print(productElement);
                    let product = Product()
                    product.name = productElement["ProductName"] as? String
                    product.category = productElement["ProductCategory"] as? String
                    self.productList.append(product)
                }
            }
            self.productList.sort(by: {$0.name! < $1.name!})
            self.tableView.reloadData()
            
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
        
        loadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredProduct.count
        }
        
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        let product: Product
        if isFiltering() {
            product = filteredProduct[indexPath.row]
        } else {
            product = productList[indexPath.row]
        }
        
        cell.itemNameLbl.text = product.name
        cell.categoryLbl.text = "Category: " + product.category!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let DvC = Storyboard.instantiateViewController(withIdentifier: "EditItemViewController") as! EditItemViewController
        let product: Product
        if isFiltering() {
            product = filteredProduct[indexPath.row]
        } else {
            product = productList[indexPath.row]
        }
        
        DvC.getName = product.name!
        DvC.getCategory = product.category!
        self.navigationController?.pushViewController(DvC, animated: true)
    }
    
    //Search
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredProduct = productList.filter({( product : Product) -> Bool in
            return product.name!.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    @IBAction func menuBtn(_ sender: Any) {
        sideMenuConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        showMenu = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func productBtn(_ sender: Any) {
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

extension ProductViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
