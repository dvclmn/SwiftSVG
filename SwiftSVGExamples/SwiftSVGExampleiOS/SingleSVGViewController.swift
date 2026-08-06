//
//  ViewSVGViewController.swift
//  SwiftSVGExamples
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//



import SwiftSVG
import UIKit


class SingleSVGViewController: UIViewController {

    @IBOutlet weak var canvasView: UIView!
    
    var svgURL = URL(string: "https://openclipart.org/download/181651/manhammock.svg")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        guard let url = self.svgURL else {
            return
        }
        
        let svgView = UIView(svgURL: url) { (svgLayer) in
            svgLayer.resizeToFit(self.canvasView.bounds)
        }
        svgView.backgroundColor = UIColor.blue
        self.canvasView.addSubview(svgView)
    }

}

extension SingleSVGViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.canvasView
    }
    
}


