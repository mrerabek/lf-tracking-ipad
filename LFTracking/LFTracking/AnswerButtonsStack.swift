//
//  AnswerButtonsStack.swift
//  LFTracking
//
//  Created by Tanguy Albrici on 01.05.17.
//  Copyright © 2017 Tanguy Albrici. All rights reserved.
//

import UIKit

@IBDesignable class AnswerButtonsStack: UIStackView {
    
    //MARK: Properties
    private let answers = [1, 2, 3, 4, 5]
    private let answersDescription = ["Very annoying",
                                      "Annoying\n",
                                      "Alightly annoying\n",
                                      "Perceptible, but not annoying\n",
                                      "Imperceptible"]

    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Private Methods
    
    private func setupButtons() {
        
        for i in 0..<answers.count {
            let button = UIButton()
            button.setTitle(String(answers[i]), for: .normal)
            button.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1)
            button.addTarget(self, action: #selector(ViewController.didAnswer(button:)), for: .touchUpInside)
            
            addArrangedSubview(button)
        }
        
    }
    
}
