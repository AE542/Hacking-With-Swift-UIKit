//
//  ViewController.swift
//  Project 5 HWS
//
//  Created by Mohammed Qureshi on 2020/08/05.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var allWords = [String]()// holds all the words in the start.txt file
    var usedWords = [String]()//holds words already used by the player in the game.
    
    var restart = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(Restart))
      
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try?// optional try here remember it will call the code and if it throws an error it will send back nil instead without crashing the code.
                String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {// this is a useful property for an array that returns true if the array is empty. Same meaning as allWords == 0. However its preferable to use .isEmpty here as some collection types like string have to calculate their size by counting over all the elements they contain so its better to use isEmpty as its faster at calculating.
            allWords = ["silkworm"]
        }
        func startGame() {
            title = allWords.randomElement()
            usedWords.removeAll(keepingCapacity: true)// removes all values from the usedWords[] which we'll be using to store the player's answers so far.
            tableView.reloadData()
        }// this calls the reloadData method of tableView. The table view is given to us as a property here because our vc class comes from UITableViewController. and calling reloadData() forces it to call numberOfRowsInSection again. as well as calling cellForRowAt repeatedly. Basically it allows us to check we've loaded the data correctly.
        startGame()
    }
    func restartGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: false)
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {// same as project 1 _ represents an absence of a value and swift doesn't need to load it up.
        return usedWords.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell// again same as project 1
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {// trailing closure syntax at work here. rather than specifying a handler param, we pass the code we want to run in braces after the method call.
            [weak self, weak ac] action in// everything after this is the closure. action in = means that it accepts one param in, of type UIAlertAction. Can also do it like this _ in as we aren't using the action param
            //weak means that swift captures constants and vars that are used in a closure, based on the values of the closure's surrounding context. Here self (current vc) and UIAC to be captured as weak references inside the closure = the closure can use them, but won't create a strong reference cycle because we've made it clear the closure doesn't own either of them.
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)// submit() method is external to the closure. That is the closure can't call submit if it doesn't capture the vc. Using the weak self above.
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    @objc func Restart() {
    //let ac = UIAlertController(title: "Do you want to Restart?", message: nil, preferredStyle: .alert)
        //let restartAction = UIAlertAction(title: "Restart", style: .default) {
        
        //[weak self, weak ac] action in
        
            //guard let restart = ac?.s
            
        //ac.addAction(UIAlertAction(title: "Restart", style: .cancel))
        //present(ac, animated: true)
    
   restartGame()
        
    }
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()// this prevents the user from typing an answer in uppercased letters and lowercased mixed. It auto lowercases the answer. We want to use this many times.
        
        let errorTitle: String
        let errorMessage: String
       // let errors: [errorTitle: String, errorMessage: String]
        
        //var errors = [String]()
        //tried to make array called errors that didnt work
        // tried make a tuple to handle the errors didnt work
        
        //func showErrorMessage(word:String) {
             
            
            
            //let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
            //ac.addAction(UIAlertAction(title: "OK", style: .default))
            //present(ac, animated: true)
           //}
        
        
        if isPossible(word: lowerAnswer)
        {
            if isOriginal(word: lowerAnswer)
            {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)// we insert the new word into the array here at index 0. It adds the new word to the start of the array. New words will appear at the top of the tableView.
                    let indexPath = IndexPath(row: 0, section: 0)// a new row in tableView is inserted here tells the tableView that a new row has been placed at a specific place in the array so that it can animate the new cell appearing. This basically animates the new cell appearing and is easier than having to reload everything when a new answer is submitted.
                    
                    tableView.insertRows(at: [indexPath], with: .automatic)// with param lets you specify how the row should be animated in here its .automatic = do whatever is standard for Swift's animation change. (Slide the new row to the top)
                    return
                        
                //} else showErrorMessage(word: lowerAnswer) {
                    
                } else {// here we used nested statements by putting each if statement one after the other here. Only works if they're all true which is already stated in the funcs below as they return true.
                    errorTitle = "Word not recognised or too short"
                    errorMessage = "You can't just make them up you know!"
                    
            }
            } else {
                errorTitle = "Word already used"
                errorMessage = "Be more original! You can't use the same word as the title!"
            }
            } else {
                guard let title = title?.lowercased() else { return }
                errorTitle = "Word not possible"
                errorMessage = "You can't spell that word from \(title)"
        
        }
        
        //else usedWords {
            //errorTitle = "Too short!"
            //errorMessage = "That word is too short, try again!"
        //}
            let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
            }
    
    func isPossible(word: String) -> Bool {//takes a string as its only param and returns a Bool.
        guard var tempWord = title?.lowercased() else { return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)// if the letter was found in the string we use remove(at: position) to remove the used letter from the tempWord var.
            }
        }
        return true
    }
    func isOriginal(word: String) -> Bool {
        //return true replaced with below to check whether the usedWords array contains the word that was provided.
        
        if word == title {
            return false
        }// this also worked for challenge 1 but at the same time it comes up as word not recogised...maybe possible to give it its own error message.
        //} else {
        //return true
    
        //}
        return !usedWords.contains(word)//!usedWords remember its an operator that means NOT or opposite !usedWords is now false because of !. contains() is a method which checks the usedWords array to see if it contains the specified parameter (word).
        
    }
    func isReal(word: String) -> Bool {
    let checker = UITextChecker()// checks for spelling errors.
        let range = NSRange(location: 0, length: word.utf16.count)// we use this to store the string range and we start at 0 to examine the whole length of the string.
        //utf16 means 16 bit unicode transformation format where accents for letters are stored seperately. This is for backwards compatibility purposes.
        
        if word.utf16.count < 3 {
                   return false
               // This worked for challenge 1
        }
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")//rangeOfMisspelledWord checks in: the word selected, then the second is the range to scan (the whole string) and the last is setting the language en = English.

        return misspelledRange.location == NSNotFound//if there was no spelling errors it would return NSNotFound. It's also telling us the word is spelt correctly.
        //return used as part of the operation involving ==. == returns true or false depenidng on whether misspelledRange. location is
    
        
    }
   
    


}


