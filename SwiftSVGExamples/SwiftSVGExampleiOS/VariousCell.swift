//
//  VariousCell.swift
//  SwiftSVGExamples
//
//  Copyright (c) 2017 Michael Choe
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
