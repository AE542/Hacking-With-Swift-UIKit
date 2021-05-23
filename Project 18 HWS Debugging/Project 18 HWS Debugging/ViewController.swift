//
//  ViewController.swift
//  Project 18 HWS Debugging
//
//  Created by Mohammed Qureshi on 2020/11/27.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // PRINT STATEMENTS
        print("I'm inside the viewDidLoad() function")
        //simplest debugging technique
        print(1,2,3,4,5, separator: "-")//variadic function here. Rememebr variadic functions = means it can accept lots of parameters. Prints - between each number.
        print("Some message", terminator: "")
        //both terminator and seperator are optionals can specify one or both of them
        
        //assert() forces your app to crash 1. sometimes this is the best option if something has gone wrong but will prevent data loss. 2. assertion crashes only happen while debugging. When you build a version for the app store, Apple removes the assertions
        
        //ASSERT
        assert(1 == 1, "Math failure!")// assert prints nothing because this is true
       // assert(1 == 2, "Math failure!") //error message comes up saying assertion failed ("math failure")because these two values are not equal. Also prints to the debugging console with more detail
        //print is removed from your code in a release build of your app.
        
        //assert(myReallySlowMethod() == true, "This really slow method returned false which is a bad thing.")// will cause a compiler error because no method.
        //assertions are really useful and perhaps better than print statements. Try putting them after funcs.
        
        //BREAKPOINTS
        for i in 1...100 { //for i NOT for 1
            print("Got number \(i)") // clicking the line number sets a breakpoint, you can click again to disable or right click and delete it
            //prints i = (int) 1 //press fn + F6 allows step over and allows to run through this loops items individually.
            //on the project navigator it shows the events leading up to the problem you have.
            //(lldb) can actually be interacted with by typing in the debug console next to (lld) p for print and i for the Integer value here. Returns (Int) $R0 = 3 which is the value of the integer up to the breakpoint
            
            //1.you can make breakpoints conditional. E.g. in a loop you can ask it to stop at certain points.
            //right click the breakpoint then added i % 10 == 0 to break every 10 numbers. Can issue debug commands automatically.
            
            //2.can be automatically triggered when an EXCEPTION is thrown. Select the breakpoint navigator on the project navigator on the left side. then the + button in the bottom left hand corner. Add Exception Breakpoint, make sure obj c is selected, and now it will trigger if an exception comes up.
        }
        
    }


}

