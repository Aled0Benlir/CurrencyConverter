//
//  ViewController.swift
//  Currency Converter
//
//  Created by Mauricio Tapia on 14/07/23.
//

import UIKit

struct RatesResponse: Decodable {
    let success: Bool
    let rates: Rates?
    let error: ErrorResponse?
    
    enum CodingKeys: String, CodingKey {
        case success
        case rates
        case error
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try values.decodeIfPresent(Bool.self, forKey: .success)!
        self.rates = try values.decodeIfPresent(Rates.self, forKey: .rates)
        self.rates = try values.decodeIfPresent(ErrorResponse.self, forKey: .error)
    }
}

struct Rates: Decodable {
    let cad: Double
    let eur: Double
    let usd: Double
    
    enum CodingKeys: String, CodingKey {
        case cad = "CAD"
        case eur = "EUR"
        case usd = "USD"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.cad = try values.decodeIfPresent(Double.self, forKey: .cad)!
        self.eur = try values.decodeIfPresent(Double.self, forKey: .eur)!
        self.usd = try values.decodeIfPresent(Double.self, forKey: .usd)!
    }
}

struct ErrorResponse: Decodable {
    let code: Int
    let info: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case info
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try values.decodeIfPresent(Int.self, forKey: .code)!
        self.info = try values.decodeIfPresent(String.self, forKey: .info)!
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var badge1Lbl: UILabel!
    @IBOutlet weak var badge2Lbl: UILabel!
    @IBOutlet weak var badge3Lbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        badge1Lbl.text = ""
        badge2Lbl.text = ""
        badge3Lbl.text = ""
    }
    
    @IBAction func getRatesClicked(_ sender: Any) {
        let url = URL(string: "https://data.fixer.io/api/latest?access_key=40e740d28e70d8f6b72a01af9fbbdd04")
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { data, response, error in
            if error != nil {
                let alert = UIAlertController(
                    title: "Error",
                    message: error?.localizedDescription,
                    preferredStyle: .alert)
                let okButton = UIAlertAction(
                    title: "OK",
                    style: .default)
                alert.addAction(okButton)
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            } else {
                if data != nil {
                    print(data!)
                    do {
                        let rateResponse: RatesResponse = try JSONDecoder().decode(
                            RatesResponse.self,
                            from: data!)
                        print(rateResponse)
                        if rateResponse.success {
                            print(rateResponse.success)
                            let rates = rateResponse.rates
                            DispatchQueue.main.async {
                                self.badge1Lbl.text = "CAD: \(rates?.cad ?? 0.0)"
                                self.badge2Lbl.text = "EUR: \(rates?.eur ?? 0.0)"
                                self.badge3Lbl.text = "USD: \(rates?.usd ?? 0.0)"
                            }
                        } else {
                            /*if let error = rateResponse.error {
                                switch error.code {
                                case 104:
                                case 404:
                                default:
                                }
                            }*/
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }

}

