//
//  ListDetailViewController.swift
//  Checklists
//
//  Created by Shehab Saqib on 17/11/2015.
//  Copyright © 2015 Shehab Saqib. All rights reserved.
//

import UIKit

protocol ListDetailViewControllerDelegate: class {
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAddingChecklist checklist: Checklist)
     func listDetailViewController(_ controller: ListDetailViewController, didFinishEditingChecklist checklist: Checklist)
}

class ListDetailViewController: UITableViewController, UITextFieldDelegate, IconPickerViewControllerDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    weak var delegate: ListDetailViewControllerDelegate?
    
    var checklistToEdit: Checklist?
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    var iconName = "Folder"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let checklist = checklistToEdit {
            title = "Edit Checklist"
            textField.text = checklist.name
            doneBarButton.isEnabled = true
            iconName = checklist.iconName
        }
        iconImageView.image = UIImage(named: iconName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    @IBAction func cancel() {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        if let checklist = checklistToEdit {
            checklist.name = textField.text!
            checklist.iconName = iconName
            delegate?.listDetailViewController(self, didFinishEditingChecklist: checklist)
        } else {
            let checklist = Checklist(name: textField.text!, iconName: iconName)
            delegate?.listDetailViewController(self, didFinishAddingChecklist: checklist)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text! as NSString
        let newText: NSString = oldText.replacingCharacters(in: range, with: string) as NSString
        doneBarButton.isEnabled = (newText.length > 0)
        
        return true
    }
    
    func iconPicker(_ picker: IconPickerViewController, didPickIcon iconName: String) {
        self.iconName = iconName
        iconImageView.image = UIImage(named: iconName)
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickIcon" {
            let controller = segue.destination as! IconPickerViewController
            controller.delegate = self
        }
    }
}
