//
//  ViewController.swift
//  SBSwiftUICoponents
//
//  Created by nanhu on 12/4/18.
//  Copyright © 2018 nanhu. All rights reserved.
//

import SBComponents

class ViewController: UIViewController {

    /// lazy vars
    private lazy var stepper: StepperPanel = {
        let s = StepperPanel(frame: .zero)
        return s
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(stepper)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }

}

