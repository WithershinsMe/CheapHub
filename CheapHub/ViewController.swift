//
//  ViewController.swift
//  CheapHub
//
//  Created by GK on 2018/8/15.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import UIKit
import Vision
import Foundation
import AVFoundation
import Moya

class ViewController: UIViewController {

    private let cameraController = CameraViewController()
    private let visionService = VisionService()
    private let boxService = BoxService()

    
    let provider = MoyaProvider<GitHub>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//
//        cameraController.view.frame = view.bounds
//        add(childController: cameraController)
//        cameraController.didMove(toParentViewController: self)
//
//        cameraController.delegate = self
//
//        visionService.delegate = self
//        boxService.delegate = self
//
//        provider.request(GitHub.login) { [weak self] result in
//
//        }
    }

    @IBAction func testDownload(_ sender: UIButton) {
        Network.Manager.download("logo_github.png", callbackQueue: DispatchQueue.main, progress: progressClosure) { result in
            
            var color: UIColor
            switch result {
            case .success:
                color = .green
            case .failure:
                color = .red
            }
        }
    }
    lazy var progressClosure: ProgressBlock = { response in
        print(CGFloat(response.progress))
    }
    
    @IBAction func TestUpload(_ sender: UIButton) {
        Network.Manager.upload(TestData.animatedBirdData) { response in
            
        }
        
    }
    @IBAction func getUserInfo(_ sender: UIButton) {
        
        Network.User.getUserInfo { result in
            switch result {
            case .success(let user):
                print(user.value)
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        
        if let loginVC = LoginViewController.instantiateFromAppStoryboard(appStoryboard: AppStoryboard.Main) {
            loginVC.url = URL(string: "https://github.com/login/oauth/authorize/?client_id=\(AuthConstant.clientID)&state=1995&redirect_uri=\(AuthConstant.redirectURL)&scope=public_repo,user,delete_repo")
             present(loginVC, animated: true, completion: nil)
        }
    }
}


extension ViewController: CameraViewControllerDelegate {
    func cameraController(_ controller: CameraViewController, didCapture buffer: CMSampleBuffer) {
        visionService.handle(buffer: buffer)
    }
}
extension ViewController: VisionServiceDelegate {
    func visionService(_ version: VisionService, didDetect image: UIImage, results: [VNTextObservation]) {
        boxService.handle(
            overlayLayer: cameraController.overlayLayer,
            image: image,
            results: results,
            on: cameraController.view
        )
    }
}

extension ViewController: BoxServiceDelegate {
    func boxService(_ service: BoxService, didDetect image: UIImage) {
       // ocrService.handle(image: image)
    }
}
