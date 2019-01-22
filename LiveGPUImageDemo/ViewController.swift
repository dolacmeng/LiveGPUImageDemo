//
//  ViewController.swift
//  LiveGPUImageDemo
//
//  Created by 许伟杰 on 2019/1/21.
//  Copyright © 2019 JackXu. All rights reserved.
//

import UIKit
import GPUImage

class ViewController: UIViewController {
    //注：为了可以进行拍照，这里用子类GPUImageStillCamera代替GPUImgeVideoCamera
    fileprivate lazy var camera : GPUImageStillCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .back)
    fileprivate lazy var filter = GPUImageBrightnessFilter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置摄像头方向为垂直
        camera.outputImageOrientation = .portrait
        
        //1.添加滤镜
        camera.addTarget(filter)
        camera.delegate = self
        
        //2.添加一个用于实时显示画面的GPUImageView
        let showView = GPUImageView(frame: view.bounds)
        view.insertSubview(showView, at: 0)
        filter.addTarget(showView)
        
        //3.开始采集画面
        camera.startCapture()
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        camera.capturePhotoAsImageProcessedUp(toFilter: filter, withCompletionHandler: { (image, error) in
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        })
    }
}

//采集回调
extension ViewController : GPUImageVideoCameraDelegate{
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        print("采集到画面")
    }
}
