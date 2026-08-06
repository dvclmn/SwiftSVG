//
//  VariousCell.swift
//  SwiftSVGExamples
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//



import UIKit

class VariousCell: UICollectionViewCell {
    
    @IBOutlet weak var svgView: UIView!
    
    override func prepareForReuse() {
        for thisSublayer in self.svgView.layer.sublayers! {
            thisSublayer.removeFromSuperlayer()
        }
    }
    
}
