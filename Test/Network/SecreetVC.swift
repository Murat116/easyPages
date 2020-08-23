//
//  SecreetVC.swift
//  Test
//
//  Created by Мурат Камалов on 22.08.2020.
//  Copyright © 2020 Мурат Камалов. All rights reserved.
//

//y = 3x + k
import UIKit

class SeccretVC: UIViewController{
    private var hero = Hero(frame: .zero)
    private var timer = Timer()
    
    private var index: Float = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.hero)
        
    }
    
    private func startGame(){
        self.timer = Timer(timeInterval: 0.2, target: self, selector: #selector(self.generateВрагов), userInfo: nil, repeats: true)
        self.timer.fire()
    }
    
    @objc func generateВрагов(){
        self.view.subviews.forEach { (view) in
            guard !(view is Hero) else { return }
            
            guard view.frame.origin.x == 0 ||
                view.frame.maxX == self.view.frame.width ||
                view.frame.origin.y == 0 ||
                view.frame.maxY == self.view.frame.height else {
                    view.frame.origin.y = 
                    return
            }
            self.index = Float.random(in: 0.1 ... 4.0)
        }
    }
}

class Hero: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.backgroundColor = .systemPink
        self.layer.cornerRadius = 30
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.green.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
