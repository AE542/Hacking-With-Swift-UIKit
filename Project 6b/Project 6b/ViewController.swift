//
//  ViewController.swift
//  Project 6b
//
//  Created by Mohammed Qureshi on 2020/08/10.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        
        let label1 = UILabel()
        label1.translatesAutoresizingMaskIntoConstraints = false //because iOS generates these constraints automatically we want to disable this so we can add the constraints ourselves.
        label1.backgroundColor = UIColor.red
        label1.text = "THESE"
        label1.sizeToFit()// sized to fit the contents of the label.
        
        let label2 = UILabel()
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.backgroundColor = UIColor.cyan
        label2.text = "ARE"
        label2.sizeToFit()
        
        let label3 = UILabel()
        label3.translatesAutoresizingMaskIntoConstraints = false
        label3.backgroundColor = UIColor.yellow
        label3.text = "SOME"
        label3.sizeToFit()
        
        let label4 = UILabel()
        label4.translatesAutoresizingMaskIntoConstraints = false
        label4.backgroundColor = UIColor.green
        label4.text = "AWESOME"
        label4.sizeToFit()
        
        let label5 = UILabel()
        label5.translatesAutoresizingMaskIntoConstraints = false// you forgot to add this bool value for 5 so the label wouldn't show properly on the simulator. It just showed in the corner
        label5.backgroundColor = UIColor.orange
        label5.text = "LABELS"
        label5.sizeToFit()
        
        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(label3)
        view.addSubview(label4)
        view.addSubview(label5)
        
        // when trying to run the code, the labels were all crammed into the corner and off screen. This is because the labels are placed in their default positions in the corner of the screen, because we called sizeToFit()
        
//        let viewsDictionary = ["label1": label1, "label2": label2, "label3": label3, "label4": label4, "label5": label5] //this dictionary has strings as its keys and labels as its values. we can write viewsDictionary["label1"] to access label1.
//
//        //view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label1]", options: [], metrics: nil, views: viewsDictionary))
//        //view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label2]", options: [], metrics: nil, views: viewsDictionary))
//        //view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label3]", options: [], metrics: nil, views: viewsDictionary))
//        //view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label4]", options: [], metrics: nil, views: viewsDictionary))
//        //view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label5]", options: [], metrics: nil, views: viewsDictionary))
//        //can be refactored into this;
//
//        for label in viewsDictionary.keys {
//            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[\(label)]|", options: [], metrics: nil, views: viewsDictionary))
//            //view.addConstraints() is an array because the AutoLayout Visual Format Language (VFL) can generate multiple constraints.
//            //NSLayoutConstraint.constraints(withVF:) converts VFL into an array of constraints.
//            //empty array [] for options param and nil for metrics. We can customise the meaning of the VFL with these.
//            //"H|[label]|" is VFL itself. H: means that we're defining a horizontal layout. | means at the edge of the view. = adding these constraints to the edge of the view controller. [label1] means put label 1 here. [] are kind of the edge of the view.
//            //label1 seems simple but it actually is the dictionary key value that allows iOS to look for viewsDictonary to determning the key (label1) and generate the AutoLayout constraints.
        //}
        
        var previous: UILabel?
        
        for label in [label1, label2, label3, label4, label5] {
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            //this seemed to work for challenge 1 by replacing the width anchor with two new constants for leading and trailing anchors.
            //for challenge 2 adding view.safeAreaLayoutGuide.trailingAnchor/leadingAnchor put the labels at the edge of the safeview. Very simple at made sure they stayed within the safeArea. Try and remember this.
            label.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2, constant:-10).isActive = true
            //label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            //this didnt work for challenge 2 as the labels became gigantic
            
            //Very very hard, solution for challenge 3 change the equalToConstant from 88 to view.safeAreaLayoutGuide.heightAnchor, then add a multiplier as it said in HWS to make it equal to "1/5th" of the main view if 0.5 was 50% in the example, 0.2 = 20% then the constant should be -10 0.2 X -10 =
            
            if let previous = previous {
                //create a height constraint
                label.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 10).isActive = true
                
            } else {
                //this is the first label
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
                //adding -5 grouped the labels together and made them show up on landscape all together at least.
                // -10 reduced the size of the white space between the words but grouped them too close so it wasn't the solution
                
//            }
//                if previous != nil {
//                    label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
//                } else {
//                    label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 10).isActive = true
                //this was incorrect for challenge 2. It just created an extea if statement and caused more problems than it solved
                }
            previous = label
            
        }
        //}else {
        //label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide. bottomAnchor, constant: 10).isActive = true
    } //didn't work because can't convert NSLayout Y Axis anchor to X axis
        
        
        //let metrics = ["labelHeight": 88]
        
            //view.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1(labelHeight@999)]-[label2(label1)]-[label3(label1)]-[label4(label1)]-[label5(label1)]-(>=10)-|", options: [], metrics: metrics, views: viewsDictionary))
        //}//constraints are evaluated from highest priority to the lowest, but all are taken into account. Changing labelHeight to add @999 (v. important but not essential), and changing the other labels params to label1, we can give all the labels the same height.
        
        
    }





//}
