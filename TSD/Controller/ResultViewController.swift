//
//  ResultViewController.swift
//  TSD
//
//  Created by Samuel Esposito on /2312/20.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var resultView: UIImageView!
    @IBOutlet weak var resultStaticTitle: UILabel!
    @IBOutlet weak var resultName: UILabel!
    var prediction: Response?
    var segnali: Segnali?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseJSON()
        let predictionIndex = Int(prediction!.inference)
        resultView.image = UIImage(named: segnali!.data[predictionIndex!].imagename)
        resultName.text = segnali?.data[predictionIndex!].title
        
    }
    
    func parseJSON(){
        
        guard let path = Bundle.main.path(forResource: "trafficsign", ofType: "json") else{
            return
        }
        let url = URL(fileURLWithPath: path)
        do{
            let jsonData = try Data(contentsOf: url)
            print(jsonData.description)
            segnali = try JSONDecoder().decode(Segnali.self, from: jsonData)
            if let result = segnali{
                print(result.data.count)
            }
            return
            
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        
    }
    
    


}
