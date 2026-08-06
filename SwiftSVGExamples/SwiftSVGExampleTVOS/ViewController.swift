//
//  ViewController.swift
//  SwiftSVGExampleTVOS
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//


import SwiftSVG
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var svgView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let thisSVGView = UIView(svgNamed: "hawaiiFlowers") { (svgLayer) in
            svgLayer.resizeToFit(self.svgView.bounds)
        }
        self.svgView.addSubview(thisSVGView)
    }
}

