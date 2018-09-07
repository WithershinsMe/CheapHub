//
//  AnimationViewController.swift
//  CheapHub
//
//  Created by GK on 2018/8/29.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import UIKit

class AnimationViewController: UIViewController {

    @IBOutlet weak var panView: UIView!
    
    var animator = UIViewPropertyAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func panViewGesture(_ sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .began:
            animator = UIViewPropertyAnimator(duration: 3, curve: UIViewAnimationCurve.easeOut, animations: {
                self.panView.transform = CGAffineTransform(translationX: 150, y: 0)
                //self.panView.alpha = 0
            })
            animator.startAnimation()
            animator.pauseAnimation()
        case .changed:
            animator.fractionComplete = sender.translation(in: self.panView).x / 275
        case .ended:
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
   

}
