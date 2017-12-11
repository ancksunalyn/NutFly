//
//  ViewController.swift
//  NutDrive
//
//  Created by Evelyn Andrade on 17-11-29.
//  Copyright © 2017 Evelyn Andrade. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ship: UIView!
    
    var degrees: Double!
    var sin: Double!
    var cos: Double!
    
    var arrOfObst = [UIImageView]()
    var arrOfCos = [Double]()
    var arrOfSin = [Double]()
    
    var aTimer: Timer!
    var aTimerObst: Timer!
    var aTimerShoot: Timer!
    var distance = 0

    @IBOutlet weak var leftWall: UIView!
    @IBOutlet weak var rightWall: UIView!
    @IBOutlet weak var messages: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareAnimation()  
    }

    // ----------- Fonction qui prepare les objects pour que le jeu commence -----------
    func prepareAnimation () {
        // Positioner le ship au bottom de l'écran
        ship.center.x = UIScreen.main.bounds.width / 2
        ship.center.y = UIScreen.main.bounds.height - 45
        // Calculer le cos et le sin pour que le ship soit toujours guidé vers l'haut
        degrees = Double(-90)
        cos = __cospi(degrees/180)
        sin = __sinpi(degrees/180)
        messages.text = ""
    }
    
    // ------------ Méthode pour recommencer le jeu ----------
    func restartGame() {
        // Positioner le ship au bottom de l'écran
        ship.center.x = UIScreen.main.bounds.width / 2
        ship.center.y = UIScreen.main.bounds.height - 45
        //Remettre le slider à la moitié
        slider.value = -90
        //Faire reapparaître le bouton pour commencer le jeu
        startButton.alpha = 1.0
        
        //Faire disparaître les cibles
        for aObstacle in arrOfObst {
            aObstacle.removeFromSuperview()
        }
    }
    
    
    @IBAction func startGame(_ sender: UIButton) {
        prepareAnimation()
        aTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(fly), userInfo: nil, repeats: true)
        
        createObstacles(numOfObstacles: Int(arc4random_uniform(18)))
        addToCosAndSinArrays()
        createAndPlaceObstacles()
        startButton.alpha = 0.0
    }
    
    
    // ------- Méthode qui controle l'animation du ship et qui verifie si l'utilisateur a gagné ou perdu
    @objc func fly() {
        ship.center.x += CGFloat(cos)
        ship.center.y += CGFloat(sin)
        for i in 0..<arrOfObst.count {
            if ship.frame.intersects(leftWall.frame) || ship.frame.intersects(rightWall.frame) || ship.frame.intersects(arrOfObst[i].frame) {
                aTimer.invalidate()
                aTimer = nil
                aTimerObst.invalidate()
                aTimerObst = nil
                messages.text = "GAME OVER!"
                restartGame()
            } else if ship.frame.intersects(topView.frame) {
                aTimer.invalidate()
                aTimer = nil
                aTimerObst.invalidate()
                aTimerObst = nil
                messages.text = "YOU WIN!"
                restartGame()
            }
        }
     }
    
    
    // --------- Méthode qui change la direction du ship à l'aide du slider
    @IBAction func changeDirection(_ sender: UISlider) {
        let degreesToChange = Double(sender.value)
        cos = __cospi(degreesToChange/180)
        sin = __sinpi(degreesToChange/180)
        ship.transform = CGAffineTransform(rotationAngle: CGFloat(sender.value) * 0.5)
        
    }
    
    // --------- Méthode pour creer des cibles de taille aleatoire et les positioner de façon randomique--------
    func createObstacles (numOfObstacles: Int) {
        arrOfObst = []
        for _ in 1...numOfObstacles {
            let aObstacle = UIImageView()
            let x: Double = Double(arc4random_uniform(768))
            let y: Double = Double(arc4random_uniform(1024))
            let w: Double = Double(arc4random_uniform(61) + 20)
            let h: Double = Double(arc4random_uniform(61) + 20)
            aObstacle.frame = CGRect(x: x, y: y, width: w, height: h)
            aObstacle.image = UIImage(named: "obst.png")
            self.view.addSubview(aObstacle)
            arrOfObst.append(aObstacle)
            launchAnimation()
        }
    }
    
    // ---------- Méthode pour creer des cos et des sins de façon randomique pour mes obstacles -------------
    func addToCosAndSinArrays () {
        for _ in arrOfObst {
            let randomAngle = Double(arc4random_uniform(360))
            arrOfCos.append(__cospi(randomAngle/180))
            arrOfSin.append(__sinpi(randomAngle/180))
        }
    }
    
    // ---------- Méthode pour "dessiner" des obstacles et les placer de façon randomique ------------
    func createAndPlaceObstacles () {
        for aObstacle in arrOfObst {
            aObstacle.layer.cornerRadius = 0.5
            aObstacle.center.x = UIScreen.main.bounds.width / CGFloat(arc4random_uniform(5))
            aObstacle.center.y = UIScreen.main.bounds.width / CGFloat(arc4random_uniform(5))
        }
    }
    
    // ----------- Méthode qui va lancer l'animation des cibles -----------
    
    func launchAnimation () {
        aTimerObst = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(animate), userInfo: nil, repeats: true)
    }
    
    // ----------- Méthode qui anime des cibles -----------
    
    @objc func animate () {
        for i in 0..<arrOfObst.count {
            // Ici j'ai essaié de faire que mes cibles retournent après avoir touché les murs. Ça n'a pas marché, mais ça a donné un effet de parkinson a mes cibles que j'ai terminé pour aimer, puis j'ai laissé comme ça.
            if arrOfObst[i].frame.intersects(leftWall.frame) || arrOfObst[i].frame.intersects(rightWall.frame) || arrOfObst[i].frame.intersects(topView.frame) || arrOfObst[i].frame.intersects(bottomView.frame) {
                arrOfSin = []
                arrOfCos = []
                addToCosAndSinArrays()
                arrOfObst[i].center.x -= CGFloat(arrOfCos[i])
                arrOfObst[i].center.y -= CGFloat(arrOfSin[i])
            } else {
                arrOfObst[i].center.x += CGFloat(arrOfCos[i])
                arrOfObst[i].center.y += CGFloat(arrOfSin[i])
            }
        }
    }
}

