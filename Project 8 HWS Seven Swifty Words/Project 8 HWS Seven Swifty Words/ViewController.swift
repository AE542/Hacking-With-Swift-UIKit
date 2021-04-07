//
//  ViewController.swift
//  Project 8 HWS Seven Swifty Words
//
//  Created by Mohammed Qureshi on 2020/08/18.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var cluesLabel: UILabel! //! = implicitly unwrapped
    var answersLabel: UILabel!
    var currentAnswer: UITextField!
    var scoreLabel: UILabel!
    var letterButtons = [UIButton]() //button array

    var activatedButtons = [UIButton]()//one array to handle buttons used for  spelling answers
    var solutions = [String]()//second array for all possible solutions
    
    var currentAnimations = 0
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"// we need to use a property observer to check our score is synchronised and updates correctly whenever the score value is changed using didSet. didSet is run after the code has changed. willSet is before.
        }
    }
    
    var finalScore = [String]()
    var level = 1

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false// you can write short hand 'tamic' and it will auto show the translates bool above
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)//be careful the subview couldn't be initialised because it was missing.
        
        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.text = "CLUES"
        cluesLabel.numberOfLines = 0 //means as many lines as needed to create text
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)//be careful UILayoutPriority:(1) is incorrect and throws up the cannot convert ui layoutpriority error to Int value.
        view.addSubview(cluesLabel)// this was why the error wouldn't go away you needed to have view.addSubView instead of cluesLabel.addSubview. Can't add cluesLabel to itself!

        
        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = UIFont.systemFont(ofSize: 24)//method for adding the size of font displayed in the UILabel (UIFont.systemFont(ofSize: 24) system font is standard font used in iOS.
        answersLabel.text = "ANSWERS"
        answersLabel.numberOfLines = 0
        answersLabel.textAlignment = .right
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answersLabel)
        //now we need to set anchors so the app looks good on all types of iPad.
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tap letters to guess"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = false
        view.addSubview(currentAnswer)
        
        //add the code to the view creation code inside the loadView.
         let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("SUBMIT", for: .normal)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submit)
        
        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("CLEAR", for: .normal)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clear)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        
        
        NSLayoutConstraint.activate([// accepts array of constraints and activates them all at the same time.
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            //add more constraints here for the UILabel
            
            //pin the top of the clues label to the bottom of the score label.
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            
            //pin the leading edge of the clues label to the leading edge of our layout margins, adding 100 for some space.
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            
            //make the clues label 60% of the width of our layout margins, minus 100.
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            //also pin the top of the answers label to the bottom of the score label
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            
            //make the answers label stick to the trailing edge of our layout margins, minus 100.
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            
            //make the answers label take up 40% of the available space, minus 100
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),//don't forget to seperate items in array with a comma
            
            //make the answers label match the height of the clues label
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
            
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),// we make the textfield centered in the view with centerXanchor but only 50% of the view using the multiplier then we give 20 points of spacing so the cluesLabel and the currentAnswer label don't touch.
            
            submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submit.heightAnchor.constraint(equalToConstant: 44),
            
            clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
            clear.heightAnchor.constraint(equalToConstant: 44),
            
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo:view.layoutMarginsGuide.bottomAnchor, constant: -20)
            
        ])
        
        //set some values for the width and height of each button
        let width = 150
        let height = 80
        //create 20 buttons as 4x5 grid. we'll be using nested loops to make these easier than individually creating them
        for row in 0..<4{
            for col in 0..<5 {
                //create a new button and give it a big font size
                let letterButton = UIButton(type: .system)
                
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)//systemFontSize(ofSize: is wrong use just systemFont as it can't call a CGFloat(CoreGraphics Float) value.
                //? means an optional representing the presence of a value or nil.
                //give the button some temporary text so it's visible on screen
                letterButton.setTitle("WWW", for: .normal)
                letterButton.layer.borderWidth = 0.5
                       letterButton.layer.borderColor = UIColor.lightGray.cgColor
                //Solution to Challenge 1: Adding letterButton.layer.borderWidth and borderColor we could add a layer around the buttons view.
                
                //calculate the frame of this button using its column and row
                //where x axis = column x width and y axis is row x height
                let frame = CGRect(x: col * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                
                //add it to the buttons view
                buttonsView.addSubview(letterButton)
                // and also to our letterButtons array
                letterButtons.append(letterButton)
                
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                
                
            }
        }
        
//        cluesLabel.backgroundColor = .red
//        answersLabel.backgroundColor = .blue// really simple to add a backgroundColor here.
//
//        buttonsView.backgroundColor = .green
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // override func viewDidLoad() should be below the override func loadView()
        //DispatchQueue.global(qos: .background).async {
        //didn't work for reloading the level with GCD challenge 2
            loadLevel()
        
        //creates the view that the controller manages
        //BE CAREFUL! It wouldn't load the loadLevel method because you called it loadView()
        
        
    }// be careful, when putting objc func or any code it must be below this bracket for it to connect to the functions above.
        @objc func letterTapped(_ sender: UIButton){
            
            guard let buttonTitle = sender.titleLabel?.text else { return
            }// guard let here to check if the tapped button has a title. It exits if it doesnt have one.
                                self.currentAnswer.text = self.currentAnswer.text?.appending(buttonTitle)// appends the button title to the player's current answer.
                                self.activatedButtons.append(sender)// appends the button to the activatedButtons array.
            //sender.isHidden = true//hides the button that was tapped.
            //for Project 15 Challenge 1
            UIButton.animate(withDuration: 0.5, animations: {
                switch self.currentAnimations {
                case 0:
                    sender.alpha = 0.1
                case 1:
                    sender.alpha = 1.0
                default:
                    sender.imageView?.transform = .identity
                }
                                
                })
        }
        
        @objc func submitTapped(_ sender: UIButton){
            guard let answerText = currentAnswer.text else { return }
            
            if let solutionPosition = solutions.firstIndex(of: answerText) {
                activatedButtons.removeAll()
                
                var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
                splitAnswers?[solutionPosition] = answerText
                answersLabel.text = splitAnswers?.joined(separator: "\n")
                
                currentAnswer.text = ""
                score += 1// add and append
                
            } else {
                score -= 1
                let ac = UIAlertController(title: "Whoops!", message: "Try Again!", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title:"Cancel", style: .cancel))
                                    present(ac, animated: true)
                
                //activatedButtons.append(sender)
                //sender.alpha = 1.0
                //sender.alpha = 1.0
                //didn't change the alpha back to 0 after getting the wrong answer.
            }
//            }else {
//                if let solutionPosition = (solutions.firstIndex(of: answerText) != nil) {
//                    let ac = UIAlertController(title: "Whoops!", message: "Try Again!", preferredStyle: .alert)
//                    ac.addAction(UIAlertAction(title:"Cancel", style: .cancel))
//                    present(ac, animated: true)
//                }
                //this didn't work for challenge 2
                
                if score % 7 == 0 {
                    //if score % 7 == 0 was original code to move by taking a remainder of seven and calculating the score.
                    //if score == finalScore didn't work for challenge 3
                    let ac = UIAlertController(title: "Well Done!", message: "Are you ready the next level?", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Let's go!",style: .default, handler: levelUp))
                        present(ac, animated: true)
                }// if score % 7 == score didnt work
                //if score == scoreLabel?.self didn't work
                //if score == score.self? didn't work
                // if score == finalScore("\(score)") changing finalScore to a string didn't work either.
            
    }
        
        @objc func clearTapped(_ sender: UIButton){
            currentAnswer.text = ""//empty string
            
            for btn in activatedButtons {//remember activatedButtons array holds all the buttons the player has tapped before submitting their answer.
                //btn.isHidden = false//btn = UIButton short hand we set bool to false here so the buttons becomes visible again.
                btn.alpha = 1.0
                //this turned the buttons back to being visible.
            }
            activatedButtons.removeAll()//removes all elements from the array so when we tap clear it will remove all the buttons in use.
        }
        
        func loadLevel() {
            //DispatchQueue.main.async {
                //this seemed to have solved the loading level challenge for project 9. Not quite...it doesn't load the next level text when completing the questions.
            var clueString = ""
            var solutionString = ""
            var letterBits = [String]()
            
                if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {//missing end parentheses after "txt")
                if let levelContents = try? String(contentsOf: levelFileURL) {
                    var lines = levelContents.components(separatedBy: "\n")
                    lines.shuffle()
                    
                    for (index, line) in lines.enumerated() {
                        let parts = line.components(separatedBy: ": ")
                        //separated not seperated. a not e
                        let answer = parts[0]
                        if answer == ""{ break }// THIS FIXED THE INDEX OUT OF RANGE ERROR FOR parts[1] below. The break function broke the loop and allowed the empty white space in the .txt file to be ignored and load the next txt file.
                        let clue = parts[1]
                        
                        clueString += "\(index + 1). \(clue)\n"
                        
                        let solutionWord = answer.replacingOccurrences(of: "|", with: "")//Occurrences with two rs. replaces | with a "" empty string.
                        solutionString += "\(solutionWord.count) letters\n"
                        solutions.append(solutionWord)
                        
                        let bits = answer.components(separatedBy: "|")
                        
                        letterBits += bits //add and append to bits
                    }
                }
            }
                cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
                answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
            //first set the cluesLabel and answersLabel text but adding trimmingCharacters so it deletes the white space at the start and end of the strings inc line breaks and spaces.
            
            letterBits.shuffle()
            //then we shuffle letterBits to shuffle the collection in place.
            
                if letterButtons.count == letterBits.count {
                //should have been letterButtons.count == NOT letterBits.count==
                for i in 0 ..<//for loop counts up from 0 but not including the no of buttons. This is useful because we have as many items in our letterBits array as our letterButtons array. looping from 0 to 19 inclusive means we can use the i variable to set a button to a letter group.
                    letterButtons.count {// counts elements in letters array
                        letterButtons[i].setTitle(letterBits[i], for: .normal)//sets title for letter buttons
                
            
                }
            }
            }
    func levelUp(action: UIAlertAction) {
            level += 1//add one to level var above.
            solutions.removeAll(keepingCapacity: true)// remove all items from solutions array
        
            loadLevel()
        //you can add level2.txt from here onwards. Might also create a level3.txt too just to practice how to do it.
        
            for button in letterButtons {
            button.isHidden = false//make sure our letterButtons are visible.
            }
        }
            
    }
    




