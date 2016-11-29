//
//  CreateGroupViewController.swift
//  ShareGroupLocation
//
//  Created by Duy Huynh Thanh on 11/12/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import Contacts
//import ContactsUI

class CreateGroupViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var contactList = [CNContact]()
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        // Do any additional setup after loading the view.
        
        
        loadContact()
    }

    @IBAction func cancelAction(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createGroupAction(_ sender: AnyObject) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loadContact() {
//        let cnPicker = CNContactPickerViewController()
//        cnPicker.delegate = self
//        present(cnPicker, animated: true, completion: nil)
        
        let contactStore = AppDelegate.getAppDelegate().contactStore
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
            
        
        switch authorizationStatus {
        case .authorized:
            self.completionHandler(accessGranted: true)
            
        case .denied, .notDetermined:
            contactStore.requestAccess(for: .contacts, completionHandler: { (access, error) in
                if access {
                    self.completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                            let message = "Please allow the app to access your contacts through the Settings."
                        self.showMessage(message: message)
                    }
                }
            })
            
            
        default:
            completionHandler(accessGranted: false)
        }
    }
    
    func completionHandler(accessGranted: Bool) {
        let contactStore = AppDelegate.getAppDelegate().contactStore
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactThumbnailImageDataKey, CNContactImageDataKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        
        do {
            try contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                self.contactList.append(contact)
            }
            print(contactList)
        }
        catch {
            print("unable to fetch contacts")
        }
    }
    
    func showMessage(message: String) {
        print(message)
    }
}
//
extension CreateGroupViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactViewCell") as! ContactViewCell
        if contactList.count > 0 {
            let person = contactList[indexPath.row]
            cell.nameLabel.text = person.givenName + " " + person.familyName
            if person.thumbnailImageData != nil {
              cell.avatarImg = UIImageView(image: UIImage(data: person.thumbnailImageData!))
            }
            
        }
        return cell
    }
}

extension CreateGroupViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

//extension CreateGroupViewController: CNContactPickerDelegate {
//    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
//        contacts.forEach { contact in
//            for number in contact.phoneNumbers {
//                let phoneNumber = number.value 
//                print("number is = \(phoneNumber)")
//            }
//        }
//    }
//}
