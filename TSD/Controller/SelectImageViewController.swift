//
//  SelectImageViewController.swift
//  TSD
//
//  Created by Samuel Esposito on /1412/20.
//

import UIKit
import CropViewController

class SelectImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate{
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var detecButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    var imagePicker = UIImagePickerController()
    var cropEdit = TOCropViewController()
    @IBOutlet weak var image: UIImageView!
    
    
    
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
        image.image = selected
        dismiss(animated: true, completion: nil)
        
    }
    
    func presentCropViewController() {
        
        
      let toCrop: UIImage =  image.image!
      
      let cropViewController = CropViewController(image: toCrop)
      cropEdit.delegate = self
      present(cropViewController, animated: true, completion: nil)
        
    }

    private func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) -> UIImage {
            
        dismiss(animated: true, completion: nil)
        return image
        
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
