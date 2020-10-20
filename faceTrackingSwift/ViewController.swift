//
//  ViewController.swift
//  faceTrackingSwift
//
//  Created by Маркі on 09.10.2020.
//

import Cocoa
import AVFoundation
import Vision

class ViewController: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var imageView: NSImageView!
    var session: AVCaptureSession!
    var device: AVCaptureDevice!
    var output: AVCaptureVideoDataOutput!
    private var drawings: [CAShapeLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSession.Preset.vga640x480
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) else {
            print("no device")
            return
        }
        self.device = device
        do {
            let input = try AVCaptureDeviceInput(device: self.device)
            self.session.addInput(input)
        } catch {
            print("no device input")
            return
        }
        self.output = AVCaptureVideoDataOutput()
        self.output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        let queue: DispatchQueue = DispatchQueue(label: "videocapturequeue", attributes: [])
        self.output.setSampleBufferDelegate(self, queue: queue)
        self.output.alwaysDiscardsLateVideoFrames = true
        if self.session.canAddOutput(self.output) {
            self.session.addOutput(self.output)
        } else {
            print("could not add a session output")
            return
        }
        self.session.startRunning()
    }
    
    func cropImage(object: VNDetectedObjectObservation, inputImage: NSImage) -> CGImage? {
        let width = object.boundingBox.width * CGFloat(self.imageView.frame.width)
        let height = object.boundingBox.height * CGFloat(self.imageView.frame.height)
        let x = object.boundingBox.origin.x * CGFloat(self.imageView.frame.width)
        let y = (1 - object.boundingBox.origin.y) * CGFloat(self.imageView.frame.height) - height
        let croppingRect = CGRect(x: x, y: y, width: width, height: height)
        guard let image = inputImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        let imageCropped = image.cropping(to: croppingRect)
        return imageCropped
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Convert a captured image buffer to NSImage.
        guard let buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("could not get a pixel buffer")
            return
        }
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
        let imageRep = NSCIImageRep(ciImage: CIImage(cvImageBuffer: buffer))
        var capturedImage = NSImage(size: imageRep.size)
        capturedImage.addRepresentation(imageRep)
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
            
        let request = VNDetectFaceRectanglesRequest { (req, err)
            in
            if err != nil {
                print("Failed to detect faces.")
                return
            }
            req.results?.forEach({(res) in
                guard let faceObserve = res as? VNFaceObservation else { return }
                let nsImage = capturedImage
                let faceImage = self.cropImage(object: faceObserve, inputImage: nsImage)
                let image = NSImage(cgImage: faceImage!, size: NSZeroSize)
                capturedImage = image
            })
        }
        guard let cgImage = capturedImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return
        }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch let reqErr{
            print("Failed to perform request:", reqErr)
        }
       
//        let resultImage = capturedImage

        // Show the result.
        DispatchQueue.main.async(execute: {
            self.imageView.image = capturedImage
        })
    }

}

// https://www.youtube.com/watch?v=d0U5j89M6aI&ab_channel=LetsBuildThatApp
// https://github.com/rudrajikadra/Face-Detection-Using-Vision-Framework-iOS-Application/blob/master/Face%20Detection/ViewController.swift
