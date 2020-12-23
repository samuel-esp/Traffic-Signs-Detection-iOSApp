//
//  DetectViewController.swift
//  TSD
//
//  Created by Samuel Esposito on /1412/20.
//

import UIKit
import CoreML
import CropViewController

class DetectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate{
    
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var detecButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    var imagePicker = UIImagePickerController()
    var cropEdit = TOCropViewController()
    @IBOutlet weak var imageView: UIImageView!
    var croppedImage: UIImage?
    var coreMLModel = TrafficSignsML()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        
      let toCrop: UIImage =  imageView.image!
      
      let cropViewController = CropViewController(image: toCrop)
      cropEdit.delegate = self
      present(cropViewController, animated: true, completion: nil)
        
    }

    private func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int){
        
        croppedImage = image
        dismiss(animated: true, completion: nil)

        
        
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
        let resizedImage = self.croppedImage?.resized(to: CGSize(width: 48, height: 48))
            do{
            let prediction = try self.coreMLModel.prediction(conv2d_input: self.buffer(from: resizedImage!)!)
                print(prediction)
            }catch{}
    })
        
        
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
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
