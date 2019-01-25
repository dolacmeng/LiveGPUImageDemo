//
//  ViewController.swift
//  LiveGPUImageDemo
//
//  Created by 许伟杰 on 2019/1/21.
//  Copyright © 2019 JackXu. All rights reserved.
//

import UIKit
import GPUImage
import AVKit

class ViewController: UIViewController {

    fileprivate lazy var camera : GPUImageVideoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .back)
    
    //实时显示画面的预览图层
    fileprivate lazy var showView = GPUImageView(frame: view.bounds)
    
    //滤镜
    let bilateralFilter = GPUImageBilateralFilter()//磨皮
    let exposureFilter = GPUImageExposureFilter() //曝光
    let brightnessFilter = GPUImageBrightnessFilter()//美白
    let satureationFilter = GPUImageSaturationFilter()//饱和
    
    //视频写入类
    fileprivate lazy var movieWriter : GPUImageMovieWriter = {
        [unowned self] in
        let writer = GPUImageMovieWriter(movieURL: self.fileURL, size: self.view.bounds.size)
        return writer!
    }()
    
    //视频沙盒地址
    fileprivate lazy var fileURL : URL = {
        [unowned self] in
        return URL(fileURLWithPath: "\(NSTemporaryDirectory())movie\(arc4random()).mp4")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置摄像头方向为垂直
        camera.outputImageOrientation = .portrait
        //使用前值摄像头
        camera.horizontallyMirrorFrontFacingCamera = true

        //加入预览图层
        view.insertSubview(showView, at: 0)
        
        //获取滤镜组
        let filterGroup = getGroupFilters()
        //设置GUPImage的响应链
        camera.addTarget(filterGroup)
        filterGroup.addTarget(showView)

        //开始采集
        camera.startCapture()
        
        //配置写入文件
        movieWriter.encodingLiveVideo = true
        filterGroup.addTarget(movieWriter)
        camera.delegate = self;
        camera.audioEncodingTarget = movieWriter
        movieWriter.startRecording()
    }
    
    fileprivate func getGroupFilters() -> GPUImageFilterGroup {
        //创建滤镜组
        let filterGroup = GPUImageFilterGroup()
        
        //设置滤镜关系链
        bilateralFilter.addTarget(brightnessFilter)
        brightnessFilter.addTarget(exposureFilter)
        exposureFilter.addTarget(satureationFilter)
        
        //设置滤镜组初始、终点filter
        filterGroup.initialFilters = [bilateralFilter]
        filterGroup.terminalFilter = satureationFilter
        
        return filterGroup
    }
    
    @IBAction func clickPlay(_ sender: Any) {
        print(fileURL)
        camera.stopCapture()
        showView.removeFromSuperview()
        movieWriter.finishRecording()
        let playerVc = AVPlayerViewController()
        playerVc.player = AVPlayer(url: fileURL)
        present(playerVc, animated: true, completion: nil)
    }
}

extension ViewController : GPUImageVideoCameraDelegate{
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        print("采集到画面")
    }
}


