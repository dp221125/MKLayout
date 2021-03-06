//
//  ViewController.swift
//  Sample
//
//  Created by Seokho on 2020/03/02.
//  Copyright © 2020 Seokho. All rights reserved.
//

import UIKit
import MKLayout

class ViewController: UIViewController {

    override func loadView() {
        
        let view = UIView()
        view.backgroundColor = .white
        self.view = view
        
        let redView = UIView().builder
            .mkAnchor
            .add(at: view)
            .top(to: view, at: .safeTop, comparer: .equal)
            .left(to: view, at: .safeLeft, constant: 16, comparer: .equal)
            .size(width: AnchorSize(120, .equal))
            .equalHeightToWidth()
            .active()
        redView.backgroundColor = .brown
        
        let indigoView = UIView().builder
            .mkAnchor
            .add(at: self.view)
            .top(to: redView, at: .centerY, comparer: .equal)
            .left(to: redView, at: .centerX, comparer: .equal)
            .width(to: redView, at: .width, comparer: .equal)
            .height(to: redView, at: .height, comparer: .equal)
            .active()
        indigoView.backgroundColor = .blue
        
        let pinkView = UIView().builder
            .mkAnchor
            .add(at: self.view)
            .top(to: indigoView, at: .centerY, comparer: .equal)
            .leading(to: indigoView, at: .centerX, comparer: .equal)
            .width(to: indigoView, at: .width, comparer: .equal)
            .height(to: indigoView, at: .height, comparer: .equal)
            .active()
        pinkView.backgroundColor = .systemPink
        
        let label = UILabel().builder
            .mkAnchor
            .add(at: self.view)
            .centerX(to: view, at: .safeCenterX, comparer: .equal)
            .bottom(to: view, at: .safeBottom, comparer: .equal)
            .width(to: view, at: .width, comparer: .less)
            .active()
        
        label.adjustsFontSizeToFitWidth = true
        label.text = "This is Test Layout"
        label.textColor = .black
    }


}
