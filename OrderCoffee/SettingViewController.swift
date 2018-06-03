//
//  SettingViewController.swift
//  OrderCoffee
//
//  Created by Warakorn Rungseangthip on 1/5/2561 BE.
//  Copyright © 2561 Warakorn Rungseangthip. All rights reserved.
//

import UIKit
import Firebase

class Province2 {
    var province: String
    var district: [String]
    
    init(province:String, district:[String]){
        self.district = district
        self.province = province
    }
}

class SettingViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var provinceLbl: UILabel!
    @IBOutlet weak var districtLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var closeTextField: UITextField!
    @IBOutlet weak var openTextField: UITextField!
    @IBOutlet weak var provinceTextField: UITextField!
    @IBOutlet weak var districtTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    var databaseRef: DatabaseReference!
    var rootRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    var userID = Auth.auth().currentUser?.uid
    var provinces = [Province2]()
    var selectedImage: UIImage?
    var showMenu = false
    
    var provincePickerView = UIPickerView()
    var districtPickerView = UIPickerView()
    
    let pickerOpen = UIDatePicker()
    let pickerClose = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        sideMenuConstraint.constant = -268
        
        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.clipsToBounds = true
        //แต่ง Label
        nameLbl.layer.borderWidth = 1.0
        nameLbl.layer.borderColor = UIColor.gray.cgColor
        phoneLbl.layer.borderWidth = 1.0
        phoneLbl.layer.borderColor = UIColor.gray.cgColor
        addressLbl.layer.borderWidth = 1.0
        addressLbl.layer.borderColor = UIColor.gray.cgColor
        timeLbl.layer.borderWidth = 1.0
        timeLbl.layer.borderColor = UIColor.gray.cgColor
        provinceLbl.layer.borderWidth = 1.0
        provinceLbl.layer.borderColor = UIColor.gray.cgColor
        districtLbl.layer.borderWidth = 1.0
        districtLbl.layer.borderColor = UIColor.gray.cgColor
        codeLbl.layer.borderWidth = 1.0
        codeLbl.layer.borderColor = UIColor.gray.cgColor
        
        nameTextField.delegate = self
        addressTextField.delegate = self
        provinceTextField.delegate = self
        zipCodeTextField.delegate = self
        phoneTextField.delegate = self
        
        createDatePicker()
        setUp()
        self.provinces.sort(by: {$0.province < $1.province})
        
        provincePickerView.delegate = self
        provincePickerView.dataSource = self
        provincePickerView.tag = 1
        
        districtPickerView.delegate = self
        districtPickerView.dataSource = self
        districtPickerView.tag = 2
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClick))
        toolbar.setItems([done], animated: false)
        
        provinceTextField.inputAccessoryView = toolbar
        districtTextField.inputAccessoryView = toolbar
        
        provinceTextField.inputView = provincePickerView
        districtTextField.inputView = districtPickerView
        
        databaseRef = Database.database().reference()
        databaseRef.child("Shop").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.nameTextField.text = value?["ShopName"] as? String ?? ""
            self.addressTextField.text = value?["Address"] as? String ?? ""
            self.phoneTextField.text = value?["PhoneNumber"] as? String ?? ""
            self.openTextField.text = value?["OpenTime"] as? String ?? ""
            self.closeTextField.text = value?["CloseTime"] as? String ?? ""
            self.provinceTextField.text = value?["Province"] as? String ?? ""
            self.districtTextField.text = value?["District"] as? String ?? ""
            self.zipCodeTextField.text = value?["ZipCode"] as? String ?? ""
            
            if(value?["ShopImageLogo"] != nil)
            {
                let shopImage = value?["ShopImageLogo"] as? String ?? ""
                
                let url = URL(string: shopImage)
                let data = try? Data(contentsOf: url!)
                self.imageView.image = UIImage(data: data!)
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
    
    @IBAction func saveBtn(_ sender: Any) {
        
        if phoneTextField.text?.range(of: "^[0-9]{2,3}-?[0-9]{3}-?[0-9]{3,4}$", options: .regularExpression) != nil {
            if zipCodeTextField.text?.range(of: "^[0-9]{5}$", options: .regularExpression) != nil {
                self.rootRef.child("Shop").child(userID!).child("ShopName").setValue(self.nameTextField.text!)
                self.rootRef.child("Shop").child(userID!).child("PhoneNumber").setValue(self.phoneTextField.text!)
                self.rootRef.child("Shop").child(userID!).child("Address").setValue(self.addressTextField.text!)
                self.rootRef.child("Shop").child(userID!).child("OpenTime").setValue(self.openTextField.text!)
                self.rootRef.child("Shop").child(userID!).child("CloseTime").setValue(self.closeTextField.text!)
                self.rootRef.child("Shop").child(userID!).child("Province").setValue(self.provinceTextField.text!)
                self.rootRef.child("Shop").child(userID!).child("District").setValue(self.districtTextField.text!)
                self.rootRef.child("Shop").child(userID!).child("ZipCode").setValue(self.zipCodeTextField.text!)
                
                let imageRef = storageRef.child("Shop").child(userID!).child("ShopImageLogo")
                if let itemPic = self.selectedImage, let imageData = UIImageJPEGRepresentation(itemPic, 0.1){
                    imageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
                        if error != nil{
                            return
                        }
                        
                        let customerImageUrl = metadata?.downloadURL()?.absoluteString
                        self.rootRef.child("Shop").child(self.userID!).child("ShopImageLogo").setValue(customerImageUrl)
                    })
                }
                //แจ้งเตือน
                let saveFieldAlert = UIAlertController(title: "Save", message: "Success", preferredStyle: .alert)
                saveFieldAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(saveFieldAlert, animated: true, completion: nil)
            } else {
                let errorAlert = UIAlertController(title: "Oops!", message: "Error information, Please check zip code again.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
            
        } else {
            let errorAlert = UIAlertController(title: "Oops!", message: "Error information, Please check phone number again.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        selectedImage = image
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        
        dismiss(animated: true, completion: nil)
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return provinces.count
        }
        else {
            let selectedProvince = provincePickerView.selectedRow(inComponent: 0)
            return provinces[selectedProvince].district.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return provinces[row].province
        }
        else {
            let selectedProvince = provincePickerView.selectedRow(inComponent: 0)
            return provinces[selectedProvince].district[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadAllComponents()
        
        let selectedProvince = provincePickerView.selectedRow(inComponent: 0)
        let selectedDistrict = districtPickerView.selectedRow(inComponent: 0)
        let province = provinces[selectedProvince].province
        let district = provinces[selectedProvince].district[selectedDistrict]
        
        provinceTextField.text = province
        districtTextField.text = district
        
    }
    
    @objc func doneClick() {
        provinceTextField.resignFirstResponder()
        districtTextField.resignFirstResponder()
    }
    
    func createDatePicker() {
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: false)
        
        closeTextField.inputAccessoryView = toolbar
        openTextField.inputAccessoryView = toolbar
        closeTextField.inputView = pickerClose
        openTextField.inputView = pickerOpen
        
        // format picker for date
        pickerOpen.datePickerMode = .time
        pickerClose.datePickerMode = .time
    }
    
    @objc func donePressed() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let timeOpenString = formatter.string(from: pickerOpen.date)
        let timeCloseString = formatter.string(from: pickerClose.date)
        
        openTextField.text = "\(timeOpenString)"
        closeTextField.text = "\(timeCloseString)"
        self.view.endEditing(true)
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
    
    @IBAction func settingBtn(_ sender: Any) {
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
    
    func setUp() {
        provinces.append(Province2(province: "Yasothon", district: ["Kham Khuean Kaeo", "Kho Wang", "Kut Chum", "Loeng Nok Tha", "Maha Chana Chai", "Mueang Yasothon", "Pa Tio", "Sai Mun", "Thai Charoen"]))
        provinces.append(Province2(province: "Yala", district: ["Mueang Yala", "Betong", "Bannang Sata", "Than To", "Yaha", "Raman", "Kabang", "Krong Pinang"]))
        provinces.append(Province2(province: "Uttaradit", district: ["Ban Khok", "Fak Tha", "Laplae", "Mueang Uttaradit", "Nam Pat", "Phichai", "Tha Pla", "Thong Saen", "Khan  Tron"]))
        provinces.append(Province2(province: "Uthai Thani", district: ["Ban Rai", "Huai Khot", "Lan Sak", "Mueang Uthai Thani", "Nong Chang", "Nong Khayang", "Sawang Arom", "Thap Than"]))
        provinces.append(Province2(province: "Udon Thani", district: ["Ban Dung", "Ban Phue", "Chai Wan", "Ku Kaeo", "Kumphawapi", "Kut Chap", "Mueang Udon Thani", "Na Yung", "Nam Som", "Non Sa-at", "Nong Han", "Nong Saeng", "Nong Wua So", "Phen", "Phibun Rak", "Prachaksinlapakhom", "Sang Khom", "Si That", "Thung Fon", "Wang Sam Mo"]))
        provinces.append(Province2(province: "Ubon Ratchathani", district: ["Buntharik", "Det Udom", "Don Mot Daeng", "Khemarat", "Khong Chiam", "Khueang Nai", "Kut Khaopun", "Lao Suea Kok", "Muang Sam Sip", "Mueang Ubon Ratchathani", "Na Chaluai", "Na Tan", "Na Yia", "Nam Khun", "Nam Yuen", "Phibun Mangsahan", "Pho Sai", "Samrong", "Sawang Wirawong", "Si Mueang Mai", "Sirindhorn", "Tan Sum", "Thung Si Udom", "Trakan Phuet Phon", "Warin Chamrap"]))
        provinces.append(Province2(province: "Trat", district: ["Bo Rai", "Khao Saming", "Khlong Yai", "Ko Chang", "Ko Kut", "Laem Ngop", "Mueang Trat"]))
        provinces.append(Province2(province: "Trang", district: ["Hat Samran", "Huai Yot", "Kantang", "Mueang Trang", "Na Yong", "Palian", "Ratsada", "Sikao", "Wang Wiset", "Yan Ta Khao"]))
        provinces.append(Province2(province: "Tak", district: ["Ban Tak", "Mae Ramat", "Mae Sot", "Mueang Tak", "Phop Phra", "Sam Ngao", "Tha Song Yang", "Umphang", "Wang Chao"]))
        provinces.append(Province2(province: "Surin", district: ["Buachet", "Chom Phra", "Chumphon Buri", "Kap Choeng", "Khwao Sinarin", "Lamduan", "Mueang Surin", "Non Narai", "Phanom Dong Rak", "Prasat", "Rattanaburi", "Samrong Thap", "Sangkha", "Sanom", "Si Narong", "Sikhoraphum", "Tha Tum"]))
        provinces.append(Province2(province: "Surat Thani", district: ["Ban Na Doem", "Ban Na San", "Ban Ta Khun", "Chai Buri", "Chaiya", "Don Sak", "Kanchanadit", "Khian Sa", "Khiri Rat Nikhom", "Ko Pha-ngan", "Ko Samui", "Mueang Surat Thani", "Phanom", "Phrasaeng", "Phunphin", "Tha Chana", "Tha Chang", "Vibhavadi", "Wiang Sa"]))
        provinces.append(Province2(province: "Suphan Buri", district: ["Bang Pla Ma", "Dan Chang", "Doem Bang Nang Buat", "Don Chedi", "Mueang Suphanburi", "Nong Ya Sai", "Sam Chuk", "Si Prachan", "Song Phi Nong", "U Thong"]))
        provinces.append(Province2(province: "Sukhothai", district: ["Ban Dan Lan Hoi", "Khiri Mat", "Kong Krailat", "Mueang Sukhothai", "Sawankhalok", "Si Nakhon", "Si Samrong", "Si Satchanalai", "Thung Saliam"]))
        provinces.append(Province2(province: "Songkhla", district: ["Bang Klam", "Chana", "Hat Yai", "Khlong Hoi Khong", "Khuan Niang", "Krasae Sin", "Mueang Songkhla", "Na Mom", "Na Thawi", "Ranot", "Rattaphum", "Saba Yoi", "Sadao", "Sathing Phra", "Singhanakhon", "Thepha"]))
        provinces.append(Province2(province: "Sisaket", district: ["Benchalak", "Bueng Bun", "Huai Thap Than", "Kantharalak", "Kanthararom", "Khukhan", "Khun Han", "Mueang Chan", "Mueang Sisaket", "Nam Kliang", "Non Khun", "Phayu", "Pho Si Suwan", "Phrai Bueng", "Phu Sing", "Prang Ku", "Rasi Salai", "Si Rattana", "Sila Lat", "Uthumphon Phisai", "Wang Hin", "Yang Chum Noi"]))
        provinces.append(Province2(province: "Sing Buri", district: ["Bang Rachan", "In Buri", "Khai Bang Rachan", "Mueang Sing Buri", "Phrom Buri", "Tha Chang"]))
        provinces.append(Province2(province: "Satun", district: ["Khuan Don", "Khuan Kalong", "La-ngu", "Manang", "Mueang Satun", "Tha Phae", "Thung Wa"]))
        provinces.append(Province2(province: "Saraburi", district: ["Ban Mo", "Chaloem Phra Kiat", "Don Phut", "Kaeng Khoi", "Muak Lek", "Mueang Saraburi", "Nong Don", "Nong Khae", "Nong Saeng", "Phra Phutthabat", "Sao Hai", "Wang Muang", "Wihan Daeng"]))
        provinces.append(Province2(province: "Samut Songkhram", district: ["Amphawa", "Bang Khonthi", "Mueang Samut Songkhram"]))
        provinces.append(Province2(province: "Samut Sakhon", district: ["Ban Phaeo", "Krathum Baen", "Mueang Samut Sakhon"]))
        provinces.append(Province2(province: "Samut Prakan", district: ["Bang Bo", "Bang Phli", "Bang Sao Thong", "Mueang Samut Prakan", "Phra Pradaeng", "Phra Samut Chedi"]))
        provinces.append(Province2(province: "Sakon Nakhon", district: ["Akat Amnuai", "Ban Muang", "Charoen Sin", "Kham Ta Kla", "Khok Si Suphan", "Kusuman", "Kut Bak", "Mueang Sakon Nakhon", "Nikhom Nam Un", "Phang Khon", "Phanna Nikhom", "Phon Na Kaeo", "Phu Phan", "Sawang Daen Din", "Song Dao", "Tao Ngoi", "Wanon Niwat", "Waritchaphum"]))
        provinces.append(Province2(province: "Sa Kaeo", district: ["Aranyaprathet", "Khao Chakan", "Khlong Hat", "Khok Sung", "Mueang Sa Kaeo", "Ta Phraya", "Wang Nam Yen", "Wang Sombun", "Watthana Nakhon"]))
        provinces.append(Province2(province: "Roi Et", district: ["At Samat", "Changhan", "Chaturaphak Phiman", "Chiang Khwan", "Kaset Wisai", "Moei Wadi", "Mueang Roi Et", "Mueang Suang", "Nong Hi", "Nong Phok", "Pathum Rat", "Phanom Phrai", "Pho Chai", "Phon Sai", "Phon Thong", "Selaphum", "Si Somdet", "Suwannaphum", "Thawat Buri", "Thung Khao Luang"]))
        provinces.append(Province2(province: "Rayong", district: ["Ban Chang", "Ban Khai", "Khao Chamao", "Klaeng", "Mueang Rayong", "Nikhom Phatthana", "Pluak Daeng", "Wang Chan"]))
        provinces.append(Province2(province: "Ratchaburi", district: ["Ban Kha", "Ban Pong", "Bang Phae", "Chom Bueng", "Damnoen Saduak", "Mueang Ratchaburi", "Pak Tho", "Photharam", "Suan Phueng", "Wat Phleng"]))
        provinces.append(Province2(province: "Ranong", district: ["Kapoe", "Kra Buri", "La-un", "Mueang Ranong", "Suk Samran"]))
        provinces.append(Province2(province: "Prachuap Khiri Khan", district: ["Bang Saphan", "Bang Saphan Noi", "Hua Hin", "Kui Buri", "Mueang Prachuap Khiri Khan", "Pran Buri", "Sam Roi Yot", "Thap Sakae"]))
        provinces.append(Province2(province: "Prachin Buri", district: ["Ban Sang", "Kabin Buri", "Mueang Prachinburi", "Na Di", "Prachantakham", "Si Maha Phot", "Si Mahosot"]))
        provinces.append(Province2(province: "Phuket", district: ["Kathu", "Mueang Phuket", "Thalang"]))
        provinces.append(Province2(province: "Phrae", district: ["Den Chai", "Long", "Mueang Phrae", "Nong Muang Khai", "Rong Kwang", "Song", "Sung Men", "Wang Chin"]))
        provinces.append(Province2(province: "Phitsanulok", district: ["Bang Krathum", "Bang Rakam", "Chat Trakan", "Mueang Phitsanulok", "Nakhon Thai", "Noen Maprang", "Phrom Phiram", "Wang Thong", "Wat Bot"]))
        provinces.append(Province2(province: "Phichit", district: ["Bang Mun Nak", "Bueng Na Rang", "Dong Charoen", "Mueang Phichit", "Pho Prathap Chang", "Pho Thale", "Sak Lek", "Sam Ngam", "Taphan Hin", "Thap Khlo", "Wachirabarami","Wang Sai Phun"]))
        provinces.append(Province2(province: "Phetchaburi", district: ["Ban Laem", "Ban Lat", "Cha-am", "Kaeng Krachan", "Khao Yoi", "Mueang Phetchaburi", "Nong Ya Plong", "Tha Yang"]))
        provinces.append(Province2(province: "Phetchabun", district: ["Bueng Sam Phan", "Chon Daen", "Khao Kho", "Lom Kao", "Lom Sak", "Mueang Phetchabun", "Nam Nao", "Nong Phai", "Si Thep", "Wang Pong", " Wichian Buri"]))
        provinces.append(Province2(province: "Phayao", district: ["Chiang Kham", "Chiang Muan", "Chun", "Dok Khamtai", "Mae Chai", "Mueang Phayao", "Phu Kamyao", "Phu Sang", "Pong"]))
        provinces.append(Province2(province: "Phatthalung", district: ["Bang Kaeo", "Khao Chaison", "Khuan Khanun", "Kong Ra", "Mueang Phatthalung", "Pa Bon", "Pa Phayom", "Pak Phayun", "Si Banphot", "Srinagarindra", "Tamot"]))
        provinces.append(Province2(province: "Phang Nga", district: ["Kapong", "Khura Buri", "Ko Yao", "Mueang Phang Nga", "Takua Pa", "Takua Thung", "Thai Mueang", "Thap Put"]))
        provinces.append(Province2(province: "Pattani", district: ["Kapho", "Khok Pho", "Mae Lan", "Mai Kaen", "Mayo", "Mueang Pattani", "Nong Chik", "Panare", "Sai Buri", "Thung Yang Daeng", "Yarang", "Yaring"]))
        provinces.append(Province2(province: "Pathum Thani", district: ["Khlong Luang", "Lam Luk Ka", "Lat Lum Kaeo", "Mueang Pathum Thani", "Nong Suea", "Sam Khok", "Thanyaburi"]))
        provinces.append(Province2(province: "Amnat Charoen", district: ["Chanuman", "Hua Taphan", "Lue Amnat", "Mueang Amnat Charoen", "Pathum Ratchawongsa", "Phana", "Senanghanikhom"]))
        provinces.append(Province2(province: "Ang Thong", district: ["Chaiyo", "Mueang Ang Thong", "Pa Mok", "Pho Thong", "Samko", "Sawaeng Ha", "Wiset Chai Chan"]))
        provinces.append(Province2(province: "Ayutthaya", district: ["Ban Phraek", "Bang Ban", "Bang Pa In", "Bang Pahan", "Bang Sai 1404", "Bang Sai 1413", "Lat Bua Luang", "Maha Rat", "Nakhon Luang", "Phachi", "Phak Hai", "Phra Nakhon Si Ayutthaya", "Sena", "Tha Ruea", "Uthai", "Wang Noi"]))
        provinces.append(Province2(province: "Bueng Kan", district: ["Bueng Khong Long", "Bung Khla", "Mueang Bueng Kan", "Pak Khat", "Phon Charoen", "Seka", "Si Wilai", "So Phisai"]))
        provinces.append(Province2(province: "Buriram", district: ["Ban Dan", "Ban Kruat", "Ban Mai Chaiyaphot", "Chaloem Phra Kiat", "Chamni", "Huai Rat", "Khaen Dong", "Khu Mueang", "Krasang", "Lahan Sai", "Lam Plai Mat", "Mueang Buriram", "Nang Rong", "Na Pho", "Non Din Dang", "Nong Hong", "Nong Ki", "Non Suwan", "Pakham", "Phlapphla  Chai", "Phutthaisong", "Prakhon Chai", "Satuek"]))
        provinces.append(Province2(province: "Chachoengsao", district: ["Bang Khla", "Bang Nam Priao", "Bang Pakong", "Ban Pho", "Khlong Khuean", "Mueang Chachoengsao", "Phanom Sarakham", "Plaemg Yao", "Ratchasan", "Sanam Chai Khet", "Tha Takiap"]))
        provinces.append(Province2(province: "Chainat", district: ["Hankha", "Manorom", "Mueang Chinat", "Noen Kham", "Nong Mamong", "Sankhaburi", "Sapphaya", "Wat Sing"]))
        provinces.append(Province2(province: "Chaiyaphum", district: ["Bamnet Narong", "Ban Khwao", "Ban Thaen", "Chatturat", "Kaeng Khro", "Kaset Sombun", "Khon San", "Khon Sawan", "Mueang Chaiyaphum", "Noen Sa-nga", "Nong Bua Daeng", "Nong Bua Rawe", "Phakdi Chumphon", "Phu Khiao", "Sap Yai", "Thep Sathit"]))
        provinces.append(Province2(province: "Chanthaburi", district: ["Kaeng Hang Maeo", "Khao Khitchakut", "Khlung", "Laem Sing", "Makham", "Mueang Chanthaburi", "Na Yai Am",  "Pong Nam Ron", "Soi Dao", "Tha Mai"]))
        provinces.append(Province2(province: "Chiang Mai ", district: ["Chai Prakan", "Chiang Dao", "Chom Thong", "Doi Lo", "Doi Saket", "Doi Tao", "Fang", "Galyani Vadhana", "Hang Dong", "Hot", "Mae Ai", "Mae Chaem", "Mae On", "Mae Rim", "Mae Taeng", "Mae Wang", "Mueang Chiang Mai", "Omkoi", "Pharao", "Samoeng", "San Pa Tong", "San Sai", "Saraphi", "Wiang Haeng"]))
        provinces.append(Province2(province: "Chiang Rai", district: ["Chiang Khong", "Chiang Saen", "Doi Luang", "Khun Tan", "Mae Chan", "Mae Fa Luang", "Mae Lao", "Mae Sai", "Mae Suai", "Mueang Chiang Rai", "Pa Daet", "Phan", "Phaya Mengrai", "Thoeng", "Wiang Chai", "Wiang Chiang Rung", "Wiang Kean", "Wiang Pa Pao"]))
        provinces.append(Province2(province: "Chonburi", district: ["Ban Bueng", "Bang Lamung", "Bo Thong", "Ko Chan", "Ko Sichang", "Mueang Chonburi", "Nong Yai", "Phanat Nikhom", "Phan Thong", "Sattahip", "Si Racha"]))
        provinces.append(Province2(province: "Chumphon", district: ["Lamae", "Lang Suan", "Mueang Chumphon", "Pathio", "Phato", "Sawi", "Tha Sae", "Thung Tako"]))
        provinces.append(Province2(province: "Kalasin", district: ["Don Chan", "Huai Mek", "Huai Phueang", "Kamalasai", "Kham Muang", "Khao Wong", "Khong Chai", "Kuchinarai", "Mueang Kalasin", "Na Khu", "Na Mon", "Nong Kung Si", "Rong Kham", "Sahatsakhan", "Sam Chai", "Somdet", "Tha Khantho", "Yang Talat"]))
        provinces.append(Province2(province: "Kamphaeng Phet", district: ["Bueng Samakkhi", "Khanu Woralaksaburi", "Khlong Khiung", "Khlong Lan", "Kosamphi Nakhon", "Lan Krabue", "Mueang Kamphaeng Phet", "Pang Sila Thong", "Phran Kratai", "Sai Ngam", "Sai Thong Watthana"]))
        provinces.append(Province2(province: "Kanchanaburi", district: ["Bo Phloi", "Dan Makham Tia", "Mueang Chumphon", "Pathio", "Phato", "Sawi", "Tha Sae", "Thung Tako"]))
        provinces.append(Province2(province: "Khon Kaen", district: ["Ban Fang", "Ban Heat", "Ban Phai", "Chonnabot", "Chum Pae", "Khao Suan Kwang", "Khok Pho Chai", "Kranuna", "Mancha Khiri", "Mueang Khon Kaen", "Nam Phong", "Nong Na Kham", "Nong Ruea", "Nong Song Hong", "Non Sila", "Phon", "Phra Yuen", "Phu Pha Man", "Phu Wiang", "Sam Sung", "Si Chomphu", "Ubolratana", "Waeng Noi", "Waeng Yai", "Wiang Kao"]))
        provinces.append(Province2(province: "Krabi", district: ["Ao Luek", "Khao Phanom", "Khlong Thom", "Ko Lanta", "Mueang Krabi", "Nuea Khlong", "Plai Phraya"]))
        provinces.append(Province2(province: "Bangkok", district: ["Bang Bon", "Bang Kapi", "Bang Khae", "Bang Khen", "Bang Kho Laem", "Bang Khun Thian", "Bangkok Noi", "Bangkok Yai", "Bang Na", "Bang Phlat", "Bang Rak", "Bang Sue", "Bueng Kum", "Chatuchak", "Chom Thong", "Din Daeng", "Don Mueang", "Dusit", "Huai Khwang", "Khan Na Yao", "Khlong Sam Wa", "Khlong San", "Lak Si", "Lat Krabang", "Lat Phrao", "Min Buri", "Nong Chok", "Nong Khaem", "Pathum Wan", "Phasi Charoen", "Phaya Thai", "Pom Prap Sattru Phai", "Prawet", "Rat Burana", "Saimai", "SamPhanthawong", "Saphan Sung", "Sathon", "Suan Luang", "Taling Chan", "Thawi Wathana", "Thon Buri", "Thung Khru", "Wang Thonglang", "Watthana", "Yan Nawa"]))
        provinces.append(Province2(province: "Lampang", district: ["Chae Hom", "Hang Chat", "Ko Kha", "Mae Mo", "Mae Phrik", "Mae Tha", "Mueang Lampang", "Ngao", "Some Ngam", "Sop Prap", "Thoen", "Wang Nuea"]))
        provinces.append(Province2(province: "LamPhun", district: ["Ban Hong", "Ban Thi", "Li", "Mae Tha", "Mueang Lamphun", "Pa Sang", "Thung Hua Chang", "Wiang Nong Long"]))
        provinces.append(Province2(province: "Loei", district: ["Chiang Khan", "Dan Sai", "Erawan", "Mueang Loei", "Na Duang", "Na Haeo", "Nong Hin", "Pak Chom", "Pha Khao", "Phu Kradueng", "Phu Luang", "Phu Ruea", "Tha Li", "Wang Saphung"]))
        provinces.append(Province2(province: "Lopburi", district: ["Ban Mi", "Chai Badan", "Khok Charoen", "Khok Samrong", "Lam Sonthi", "Mueang Lopburi", "Nong Muang", "Phatthana Nikhom", "Sa Bot", "Tha Luang", "Tha Wung"]))
        provinces.append(Province2(province: "Mae Hong Son", district: ["Khun Yuam", "Mae La Noi", "Mae Sariang", "Mueang Mae Hong Son", "Pai", "Pang Mapha", "Sop Moei"]))
        provinces.append(Province2(province: "Maha Sarakham", district: ["Borabue", "Chiang Yuen", "Chuen Chom", "Kae Dam", "Kantharawichai", "Kosum Phisai", "Kut Rang", "Mueang Maha Sarakham", "Na Chueak", "Na Dun", "Phayakkhaphum Phisai", "Wapi Pathum", "Yang Sisurat"]))
        provinces.append(Province2(province: "Mukdahan", district: ["Dong Luang", "Don Tan", "Khamcha-i", "Nikhom Khom Soi", "Nong Sung", "Wan Yai"]))
        provinces.append(Province2(province: "Nakhon Nayok", district: ["Ban Na", "Mueang Nakhon Nayok", "Ongkharak", "Pak Phli"]))
        provinces.append(Province2(province: "Nakhon Pathom", district: ["Bang Len", "Don Tum", "KamPhaeng Saen", "Mueang Nakhon Pathom", "Nakhon Chai Si", "Phutthamonthon", "Sam Phran"]))
        provinces.append(Province2(province: "Nakhon Phanom", district: ["Ban Phaeng", "Mueang Nakhon Phanom", "Na Kae", "Na Thom", "Na Wa", "Phon Sawan", "Pla Pak", "Renu Nakhon", "Si SongKhram", "That Phanom", "Tha Uthen", "Wang Yang"]))
        provinces.append(Province2(province: "Nakhon Ratchasima", district: ["Ban Lueam", "Bua Lai", "Bua Yai", "Chakkarat", "Chaloem Phra Kiat", "Chok Chai", "Chum Phuang", "Dan Khun Thot", "Huai Thalaeng", "Kaeng Sanam Nang", "Kham Sakaesaeng", "Kham Thale So", "Khon Buri", "Khong", "Lam Thamenchai", "Mueang Nakhon Ratchasima", "Mueang Yang", "Non Daeng", "Nong Bun Mak", "Non Sung", "Non Thai", "Pak Thong Chai", "Pak Chong", "Pak Thong Chai", "Phimai", "Phra Thong Kham", "Prathai", "Sida", "Sikhio", "Soeng Sang", "Sung Noen", "Thepharak", "Wang Nam Khiao"]))
        provinces.append(Province2(province: "Nakhon Sawan", district: ["Banphot Phisai", "Chum Saeng", "Chum Ta Bong", "Kao Liao", "Kork Phra", "Lat Yao", "Mae Poen", "Mae Wong", "Mueang Nakhon Sawan", "Nong Bua", "Phaisali", "Phayuha Khiri", "Tak Fa", "Takhli", "Tha Tako"]))
        provinces.append(Province2(province: "Nakhon Si Thammarat", district: ["Bang Khan", "Chaloem Pha Kiat", "Chang Klang", "Cha-uat", "Chawang", "Chian Yai", "Chulabhorn", "Hua Sai", "Khanom", "Lan Saka", "Mueang Nakhon Si Thammarat", "Na Bon", "Nopphitam", "Pak Phanang", "Phipun", "Phara Phrom", "Phrom Khiri", "Ron Phibun", "Sichon", "Tham Phammara", "Tha Sala", "Thung Song", "Thung Yai"]))
        provinces.append(Province2(province: "Nan", district: ["Ban Luang", "Bo Kluea", "Chaloem Phra Kiat", "Chiang Klang", "Mae Charim", "Mueang Nan", "Na Muen", "Na Noi", "Phu Phiang", "Pua", "Santi Suk", "Song Khwae", "Tha Wang Pha", "Thung Chang", "Wiang Sa"]))
        provinces.append(Province2(province: "Narathiwat", district: ["Bacho", "Chanae", "Cho-airong", "Mueang Naratiwat", "Ra-ngae", "Rueso", "Si Sakhon", "Sukhirin", "Su-ngai Kolok", "Su-ngai Padi", "Tak Bai", "Waeng", "Yi-ngo"]))
        provinces.append(Province2(province: "Nong Bua Lamphu", district: ["Mueang Nongbua Lamphu", "Na Klang", "Na Wang", "Non Sang", "Si Bun Rueang", "Suwannakhuha"]))
        provinces.append(Province2(province: "Nong Khai", district: ["Mueang Nong Khai", "Phon Phisai", "Pho Tak", "Rattanawapi", "Sakhrai", "Sangkhom", "Si Chiang Mai", "Tha Bo", "Fao Rai"]))
        provinces.append(Province2(province: "Nonthaburi", district: ["Mueang Nonthaburi", "Bang Kruai", "Bang Yai", "Bang Bua Thong", "Sai Noi", "Pak Kret"]))
    }

}
