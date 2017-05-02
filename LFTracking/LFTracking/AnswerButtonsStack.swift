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
                                      "Annoying",
                                      "Slightly annoying",
                                      "Perceptible, but not annoying",
                                      "Imperceptible"]
    var buttons: [UIButton] = []

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
            
            // Button to answer the question
            let button = UIButton()
            button.setTitle(String(answers[i]), for: .normal)
            button.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1)
            button.layer.cornerRadius = 10
            //button.addTarget(self, action: #selector(didAnswer(button:)), for: .touchUpInside)
            buttons.append(button)
            //button.addTarget(ViewController.self, action: #selector(ViewController.didAnswer(button:)), for: .touchUpInside)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 32).isActive = true
            
            // Label for the button description
            let buttonLabel = UILabel()
            buttonLabel.text = answersDescription[i]
            buttonLabel.font = UIFont(name: buttonLabel.font.fontName, size: 12)
            buttonLabel.textAlignment = .center
            buttonLabel.lineBreakMode = .byWordWrapping
            buttonLabel.numberOfLines = 0
            
            buttonLabel.translatesAutoresizingMaskIntoConstraints = false
            //buttonLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
            
            // Create a vertical stack for to put the image and its title
            let verticalStack = UIStackView()
            verticalStack.axis = .vertical
            verticalStack.spacing = 10
            verticalStack.addArrangedSubview(button)
            verticalStack.addArrangedSubview(buttonLabel)
            
            addArrangedSubview(verticalStack)
        }
        
    }
    
}
