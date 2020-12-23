//
//  SelectImageViewController.swift
//  TSD
//
//  Created by Samuel Esposito on /1412/20.
//

import UIKit
import CoreML
import CropViewController
import Toucan
import Vision
import TensorFlowLite
import Alamofire

class SelectImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate{
    
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var detecButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    var imagePicker = UIImagePickerController()
    //var cropEdit = TOCropViewController()
    @IBOutlet weak var imageView: UIImageView!
    var croppedImage: UIImage?
    var modelDataHandler: ModelDataHandler?
    let modelInfo: FileInfo = (name: "traffic_signs_detector3", extension: "tflite")
    let labelsInfo: FileInfo = (name: "tflabels", extension: "txt")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modelDataHandler = ModelDataHandler(modelFileInfo: modelInfo, labelsFileInfo: labelsInfo)
        // Do any additional setup after loading the view.
    }

    @IBAction func selectPhotoButtonPressed(_ sender: Any) {
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func takePhotoButtonPressed(_ sender: Any) {
        
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let selected = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = selected
        dismiss(animated: true, completion: nil)
        
    }
    
    func presentCropViewController() {
        
        
        if let toCrop: UIImage =  imageView.image {
            print("imageView letta")
            let cropEdit = CropViewController(image: toCrop)
            cropEdit.delegate = self
            present(cropEdit, animated: true, completion: nil)
        }
      
        
    }

    func cropViewController(_ cropViewController: CropViewController, didCropToImage editedimage: UIImage, withRect cropRect: CGRect, angle: Int){
        
        print("funzione chiamata")
        let newImage: UIImage = editedimage
        croppedImage = newImage
        dismiss(animated: true, completion: nil)
        print("cropped image letta")
        print("cropped image non letta")
        
        
    }
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
      let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
      var pixelBuffer : CVPixelBuffer?
      let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
      guard (status == kCVReturnSuccess) else {
        return nil
      }

      CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
      let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

      let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
      let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

      context?.translateBy(x: 0, y: image.size.height)
      context?.scaleBy(x: 1.0, y: -1.0)

      UIGraphicsPushContext(context!)
      image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      UIGraphicsPopContext()
      CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

      return pixelBuffer
    }
    
    @IBAction func detectButtonPressed(_ sender: Any) {
        
        let croppingalert = UIAlertController(title: "⚠️ Detect Alert ⚠️", message: "In order to correctly predict your data let the app know exactly where the traffic sign is located in the photo", preferredStyle: .alert)
        self.present(croppingalert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7, execute: {
        croppingalert.dismiss(animated: true, completion: nil)
        self.presentCropViewController()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.7, execute: {
                /*let resizedImage = Toucan.Resize.resizeImage(self.croppedImage!, size: CGSize(width: 48, height: 48), fitMode: .clip)*/
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.7, execute: {
                    do{
                        
                        
                        if let resized = self.croppedImage{
                        print("valuto il modello")
                            guard let pixelBuffer = self.buffer(from: resized) else {
                                        fatalError()
                                    }
                            let result = self.modelDataHandler?.runModel(onFrame: pixelBuffer)
                            print(result!.inferences)
                        }
                        else{
                            print("error with resized")
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
            })
        })
    })

        
    }
    

    func myResultsMethod(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation]
            else { fatalError("huh") }
        for classification in results {
            print(classification.identifier, // the scene label
                  classification.confidence)
        }

    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    
    func resize(to newSize: CGSize) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1.0)
            self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            return resizedImage
        }

        func cropToSquare() -> UIImage? {
            guard let cgImage = self.cgImage else {
                return nil
            }
            var imageHeight = self.size.height
            var imageWidth = self.size.width

            if imageHeight > imageWidth {
                imageHeight = imageWidth
            }
            else {
                imageWidth = imageHeight
            }

            let size = CGSize(width: imageWidth, height: imageHeight)

            let x = ((CGFloat(cgImage.width) - size.width) / 2).rounded()
            let y = ((CGFloat(cgImage.height) - size.height) / 2).rounded()

            let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
            if let croppedCgImage = cgImage.cropping(to: cropRect) {
                return UIImage(cgImage: croppedCgImage, scale: 0, orientation: self.imageOrientation)
            }

            return nil
        }

        func pixelBuffer() -> CVPixelBuffer? {
            let width = self.size.width
            let height = self.size.height
            let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                         kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
            var pixelBuffer: CVPixelBuffer?
            let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                             Int(width),
                                             Int(height),
                                             kCVPixelFormatType_32ARGB,
                                             attrs,
                                             &pixelBuffer)

            guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
                return nil
            }

            CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)

            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            guard let context = CGContext(data: pixelData,
                                          width: Int(width),
                                          height: Int(height),
                                          bitsPerComponent: 8,
                                          bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                          space: rgbColorSpace,
                                          bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
                                            return nil
            }

            context.translateBy(x: 0, y: height)
            context.scaleBy(x: 1.0, y: -1.0)

            UIGraphicsPushContext(context)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

            return resultPixelBuffer
        }
}

/*
@IBAction func detectButtonPressed(_ sender: Any) {
    
    let croppingalert = UIAlertController(title: "⚠️ Detect Alert ⚠️", message: "In order to correctly predict your data let the app know exactly where the traffic sign is located in the photo", preferredStyle: .alert)
    self.present(croppingalert, animated: true, completion: nil)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.7, execute: {
    croppingalert.dismiss(animated: true, completion: nil)
    self.presentCropViewController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.7, execute: {
            let resizedImage = Toucan.Resize.resizeImage(self.croppedImage!, size: CGSize(width: 48, height: 48), fitMode: .scale)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.7, execute: {
                do{
                    
                    
                    if let resized = resizedImage{
                    print("valuto il modello")
                    guard let pixelBuffer = resized.pixelBuffer() else {
                                    fatalError()
                                }
                        let options = MLPredictionOptions()
                        options.usesCPUOnly = true
                        let prediction = try self.coreMLModel.prediction(input: prova1Input.init(conv2d_input: pixelBuffer), options: options)
                        print(prediction)
                    }
                    else{
                        print("error with resized")
                    }
                }catch{
                    print(error.localizedDescription)
                }
        })
    })
})

    
    
}
*/

/*
let croppingalert = UIAlertController(title: "⚠️ Detect Alert ⚠️", message: "In order to correctly predict your data let the app know exactly where the traffic sign is located in the photo", preferredStyle: .alert)
self.present(croppingalert, animated: true, completion: nil)
DispatchQueue.main.asyncAfter(deadline: .now() + 2.7, execute: {
croppingalert.dismiss(animated: true, completion: nil)
self.presentCropViewController()
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.7, execute: {
        let resizedImage = Toucan.Resize.resizeImage(self.croppedImage!, size: CGSize(width: 48, height: 48), fitMode: .scale)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.7, execute: {
            do{
                let model = try VNCoreMLModel(for: harrypotter().model)
                let request = VNCoreMLRequest(model: model, completionHandler: self.myResultsMethod)
                let handler = VNImageRequestHandler(cgImage: (resizedImage?.cgImage)!, options: [:])
                try handler.perform([request])
            }catch{
                print(error.localizedDescription)
            }
    })
})
})

*/
