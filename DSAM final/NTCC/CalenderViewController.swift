//
//  CalenderViewController.swift
//  NTCC
//
//  Created by Arihant Marwaha on 23/06/24.
//

import UIKit

class CalenderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        calender.preferredDatePickerStyle = .inline
        calender.isHidden = false
        task.isHidden = true
        heading.isHidden = true
    }
    
    @IBOutlet weak var calender: UIDatePicker!
    @IBOutlet weak var task: UITextView!
    
    @IBOutlet weak var segments: UISegmentedControl!
    @IBOutlet weak var heading: UILabel!
    
    
    @IBAction func control(_ sender: Any) {
        
        switch segments.selectedSegmentIndex{
            
        case 0 :
            calender.isHidden = false
            task.isHidden = true
            heading.isHidden = true
            break
           
        case 1 :
            calender.isHidden = true
            task.isHidden = false
            heading.isHidden = false
            break
            
        default:
            break
            
            
        }
        
    }
    
    
    

}
