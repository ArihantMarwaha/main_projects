//
//  EntryViewController.swift
//  NTCC
//
//  Created by Arihant Marwaha on 24/06/24.
//

import UIKit

class EntryViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    
    
    @IBOutlet weak var noteField: UITextView!
    
    
    public var completion: ((String, String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
    }

    @objc func didTapSave() {
        if let text = titleField.text, !text.isEmpty, !noteField.text.isEmpty {
            completion?(text, noteField.text)
        }
    }

}
