
// The Navigation Controller manages transitions backward and forward through a series of view controllers. The storyboard entry point is set to the navigation controller because the navigation controller is now a container for the table view controller.

import UIKit

// A delegate is an object that acts on behalf of, or in combination with, another object
// Delegates are used to connect the Tile class with the ViewController
// The protocol is a blueprint of methods that suit a particular task or piece of functionality
protocol GameDelegate {
    func incrementScore()
    func endGame()
}

// Class for our View Controller, adopting the Collection View delegate and GameDelegate protocol
class ViewController: UIViewController, UICollectionViewDataSource, GameDelegate {
    // Called when the top view controller is created and loaded from storyboard
    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle the collection view's interactions through delegate callbacks. The 'self' refers to  the ViewController class. Now ViewController is the delegate for collectionView
        collectionView.dataSource = self
    }
    
    // Returns the amount of cells (number of sections) to show in the collection view
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    // DataSource Mehthod --> Only renders the amount of cells that the device can display at once
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: Tile = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! Tile
        // For the cells that are being displayed...
        cell.backgroundColor = UIColor.whiteColor()
        cell.delegate = self
        cell.makeActive()
        return cell
    }

    // Properties --> References to Storyboard Objects
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var scoreLabel: UILabel!
    
    // Variables
    var score = 0
    let identifier = "CellIdentifier"
    
    // Increments and displays the users score
    func incrementScore() {
        score += 1
        scoreLabel.text = String(score)
        print("Score is \(score)")
    }
    
    // Displays an alert, providing the user their score and the option to play again.
    func endGame() {
        print("Game Over")
        // Notification to run stopTimer(), cancelling the timers on each Tile instance
        NSNotificationCenter.defaultCenter().postNotificationName("stopTimerID", object: nil)
        
        let alert = UIAlertController(title: "You Missed!", message: "Your Final Score: \(score)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: {
            action in self.newGame()
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Runs new game (called when user clicks "Try Again" in alert after game ends))
    func newGame() {
        print("New Game")
        score = 0
        scoreLabel.text = String(score)
    }
}


// Tile Class is a subclass of the UICollectionViewCell
class Tile: UICollectionViewCell {
    // Variables
    var delegate: GameDelegate?
    var activeTile: Bool?
    var gameStopped: Bool?
    var timer: NSTimer?
    
    // Action for when tile is pressed
    @IBAction func buttonPressed(sender: Tile) {
        // If the tile is 'active', unactivate it and increase the score, otherwise end the game
        if (activeTile == true) {
            makeInactive()
            incrementScore()
        } else {
            endGame()
        }
    }
    
    // Method to 'activate' a tile, changing the cells background color and setting a timer to 'unactivate'
    func makeActive() {
        print("Active!")
        self.backgroundColor = UIColor.purpleColor()
        activeTile = true
        
        // Calls makeInactive() after 1.5 seconds, only if game hasn't been stopped
        if (!gameStopped!) {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(Tile.makeInactive), userInfo: nil, repeats: false)
        }
    }
    
    // Method to 'unactivate' a tile, changing the cells background color and setting a random timer to 'activate'
    func makeInactive() {
        print("Inactive!")
        // Holds a random number between 3 - 12
        let randomNumber = Int(arc4random_uniform(12) + 3)
        self.backgroundColor = UIColor.whiteColor()
        activeTile = false
        
        // Calls makeActive() after a the randomNumber of seconds, only if game hasn't been stopped
        if (!gameStopped!) {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(Double(randomNumber), target: self, selector: #selector(Tile.makeActive), userInfo: nil, repeats: false)
        }
    }
    
    // Calls the GameDelegate's incrementScore method in the ViewController
    func incrementScore() {
        delegate!.incrementScore()
    }
    
    // Sends a message to the delagate (GameDelegate) to run endGame method in the ViewController
    func endGame() {
        delegate!.endGame()
    }
    
    // Sets flag to stop tiles from functioning, stops the timer, inactivates the tiles
    func stopTimer() {
        gameStopped = true
        timer?.invalidate()
        makeInactive()
    }
    
    // Every UIView subclass that implements an initializer must include an implementation of 'init?(coder:).
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        gameStopped = false
        // Listener for the Tile.stopTimer function
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Tile.stopTimer), name: "stopTimerID", object: nil)
    }
}