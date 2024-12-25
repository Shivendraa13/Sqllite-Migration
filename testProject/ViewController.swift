//
//  ViewController.swift
//  testProject
//
//  Created by Apple on 20/12/24.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let dbHelper = DatabaseManager()
    var results = [(Int, String, String, String?, String?, String?, String?, String?, String?)]()
    var servicesArr = ["service1", "service2"]
    
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var formTitle: UITextField!
    @IBOutlet weak var formDec: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var formPhone: UITextField!
    @IBOutlet weak var dataListCoolectionView: UICollectionView!
    @IBOutlet weak var dropCollectionView: UICollectionView!
    @IBOutlet weak var dropView: UIView!
    @IBOutlet weak var add3Text: UITextField!
    @IBOutlet weak var add2Text: UITextField!
    @IBOutlet weak var add1Text: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formView.isHidden = true
        setCollectionView()
        dataListCoolectionView.isHidden = true
        dropCollectionView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideTap))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(dropTap))
        tapGesture1.delegate = self
        dropView.addGestureRecognizer(tapGesture1)
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(formTap))
        tapGesture2.delegate = self
        formView.addGestureRecognizer(tapGesture2)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: dropCollectionView) {
            return false
        }
        return true
    }

    @objc func formTap() {
        formView.isHidden = false
    }
    
    @objc func hideTap() {
        resetData()
        formView.isHidden = true
        view.endEditing(true)
    }
    
    @objc func dropTap() {
        dropCollectionView.isHidden = !dropCollectionView.isHidden
    }
    
    func resetData() {
        dropCollectionView.isHidden = true
        formTitle.text = ""
        formDec.text = ""
        emailTextField.text = ""
        formPhone.text = ""
        serviceLabel.text = "SelectService"
        add1Text.text = ""
        add2Text.text = ""
        add3Text.text = ""
        view.endEditing(true)
    }
    
    func setCollectionView() {
        let cellNib = UINib(nibName: "dataCell", bundle: nil)
        dataListCoolectionView.register(cellNib, forCellWithReuseIdentifier: "dataCell")
        let cellNib1 = UINib(nibName: "dropCell", bundle: nil)
        dropCollectionView.register(cellNib1, forCellWithReuseIdentifier: "dropCell")
    }
    
    @IBAction func fetchAction(_ sender: Any) {
        formView.isHidden = true
        dataListCoolectionView.isHidden = !dataListCoolectionView.isHidden
        if !dataListCoolectionView.isHidden {
            results = dbHelper.fetchData()
            for (id, title, description, email, phone, service, add1, add2, add3) in results {
                print("ID: \(id), Title: \(title), Description: \(description), Email: \(email ?? ""), Phone: \(phone ?? "")")
            }
        }
        dataListCoolectionView.reloadData()
    }
    
    @IBAction func addAction(_ sender: Any) {
        dataListCoolectionView.isHidden = true
        formView.isHidden = !formView.isHidden
    }
    
    
    @IBAction func formSubmit(_ sender: Any) {
        
//        dbHelper.insertData(title: formTitle.text ?? "", description: formDec.text ?? "", email: emailTextField.text ?? "", phone: formPhone.text ?? "")
        dbHelper.insertData(title: formTitle.text ?? "", description: formDec.text ?? "", email: emailTextField.text ?? "", phone: formPhone.text ?? "", service: serviceLabel.text ?? "", add1: add1Text.text ?? "", add2: add2Text.text ?? "", add3: add3Text.text ?? "")
        resetData()
        formView.isHidden = true
    }
    
    deinit {
        dbHelper.close()
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == dataListCoolectionView {
            return results.count
        } else if collectionView == dropCollectionView {
            return servicesArr.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == dataListCoolectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dataCell", for: indexPath) as! dataCell
            cell.backView.backgroundColor = (indexPath.item % 2 == 0) ? UIColor.green : UIColor.lightGray
            cell.nameLabel.text = "Name: \(results[indexPath.item].1)"
            cell.descLabel.text = ("Desc: \(results[indexPath.item].2)")
            cell.emailLabel.text = "Email: \(results[indexPath.item].3 ?? "")"
            cell.phoneLabel.text = "Phone: \(results[indexPath.item].4 ?? "")"
            cell.serviceLabel.text = "Service: \(results[indexPath.item].5 ?? "")"
            cell.add1Label.text = "Add1: \(results[indexPath.item].6 ?? "")"
            cell.add2Label.text = "Add2: \(results[indexPath.item].7 ?? "")"
            cell.add3Label.text = "Add3: \(results[indexPath.item].8 ?? "")"
            return cell
        } else if collectionView == dropCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dropCell", for: indexPath) as! dropCell
            cell.serviceLabel.text = servicesArr[indexPath.item]
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == dropCollectionView {
            serviceLabel.text = servicesArr[indexPath.item]
            dropCollectionView.isHidden = true
        }
    }
}
