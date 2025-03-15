//
//  NoteViewController.swift
//  NTCC
//
//  Created by Arihant Marwaha on 24/06/24.
//

import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet var titleLabel : UILabel!
    
    @IBOutlet weak var noteLabel: UITextView!
    

    public var noteTitle: String = ""
    public var note: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = noteTitle
        noteLabel.text = note
    }

}
