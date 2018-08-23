//
//  BottomSheetContrinerViewController.swift
//  CheapHub
//
//  Created by GK on 2018/8/23.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import UIKit

protocol BottomSheetDelegate: AnyObject {
    func bottomSheet(_ bottomSheet: BottomSheet, didScrollTo contentOffset: CGPoint)
}
protocol BottomSheet: AnyObject {
    var bottomSheetDelegate: BottomSheetDelegate? { get set }
}
typealias BottomSheetViewController = UIViewController & BottomSheet

class BottomSheetContrainerView: UIView {
    private let mainView: UIView
    private let sheetView: UIView
    private let sheetBackground = BottomSheetBackgroundView()
    private var sheetBackgroundTopContraint: NSLayoutConstraint? = nil
    
   init(mainView: UIView, sheetView: UIView) {
        self.mainView = mainView
        self.sheetView = sheetView
        
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    var topDistance: CGFloat = 0 {
        didSet {
            sheetBackgroundTopContraint?.constant = topDistance
        }
    }
    
    private func setupViews() {
        
        //make the main view fill super view
        addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.leftAnchor.constraint(equalTo: leftAnchor),
            mainView.rightAnchor.constraint(equalTo: rightAnchor),
            mainView.topAnchor.constraint(equalTo: topAnchor),
            mainView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        addSubview(sheetBackground)
        sheetBackground.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = sheetBackground.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        
        NSLayoutConstraint.activate([
            topConstraint,
            sheetBackground.heightAnchor.constraint(equalTo: heightAnchor),
            sheetBackground.leftAnchor.constraint(equalTo: leftAnchor),
            sheetBackground.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        sheetBackgroundTopContraint = topConstraint
        
        addSubview(sheetView)
        
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sheetView.leftAnchor.constraint(equalTo: leftAnchor),
            sheetView.rightAnchor.constraint(equalTo: rightAnchor),
            sheetView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            sheetView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if sheetBackground.bounds.contains(sheetBackground.convert(point, from: self)) {
            return sheetView.hitTest(sheetView.convert(point, from: self),with: event)
        }
        return mainView.hitTest(mainView.convert(point, from: self),with: event)
    }
}
class BottomSheetContrinerViewController: UIViewController {

    private let mainViewController: UIViewController
    private let sheetViewController: BottomSheetViewController
    private lazy var bottomSheetContainerView = BottomSheetContrainerView(mainView: mainViewController.view, sheetView: sheetViewController.view)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(mainController: UIViewController, sheetViewController: BottomSheetViewController) {
        self.mainViewController = mainController
        self.sheetViewController = sheetViewController
        
        super.init(nibName: nil, bundle: nil)
    
        addChildViewController(mainController)
        addChildViewController(sheetViewController)
    
        sheetViewController.bottomSheetDelegate = self
    }
    override func loadView() {
        view = bottomSheetContainerView
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mainViewController.didMove(toParentViewController: self)
        sheetViewController.didMove(toParentViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension BottomSheetContrinerViewController: BottomSheetDelegate {
    func bottomSheet(_ bottomSheet: BottomSheet, didScrollTo contentOffset: CGPoint) {
        bottomSheetContainerView.topDistance = max(0, -contentOffset.y)
    }
}
