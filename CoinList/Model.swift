//
//  Model.swift
//  CoinList
//
//  Created by Terence Pettit on 2021-05-10.
//

import Foundation
import Combine

let myKey = "8025c44c-542c-4a3f-8db5-4a5c2741d2a8"
let quoteAPI = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest"
let infoAPI = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/info"
let fileUrl = "https://drive.google.com/uc?export=view&id=1MxI-6s7-I2wRURgIZP6kOfxY5Ogirphi"

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }

    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

struct Coin: Decodable, Hashable {
    var id: Int = 0
    var code: String = ""
    var quantity: Double = 0.0
    var name: String = ""
    var value: Double = 0.0
    var imageUrl: String = ""
    
    // Manual protocol stuff
    static func == (lhs: Coin, rhs: Coin) -> Bool {
        return (lhs.code == rhs.code)
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(quantity)
    }
    private enum CodingKeys: String, CodingKey { case code, quantity}
}

class ModelData: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var working = false
    @Published var error = false;
    
    init() {
        updateCoinList()
    }
    
    func updateCoinList() {
        if (working) {
            return
        }
        working = true
        if let url = URL(string: fileUrl) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { data, response, error in
                do {
                    let decodedData = try JSONDecoder().decode([Coin].self, from: data!)
                    var params = ""
                    DispatchQueue.main.async {
                        self.error = false
                        
        
                        for i in 0..<decodedData.count {
                            if i >= self.coins.count {
                                self.coins.append(decodedData[i])
                            }
                            else {
                                self.coins[i].code = decodedData[i].code
                                self.coins[i].quantity = decodedData[i].quantity
                            }
                            self.coins[i].code = self.coins[i].code.uppercased()
                            self.coins[i].id = i;
                            
                            params += self.coins[i].code
                            if i < decodedData.count-1 {
                                params += ","
                            }
                        }
                        
                        if self.coins.count > decodedData.count {
                            self.coins.removeSubrange(decodedData.count...self.coins.count-1)
                        }
                        
                        guard var apiUrl = URL(string: quoteAPI + "?convert=USD&symbol=" + params) else { return }
                        var request = URLRequest(url: apiUrl)
                        request.httpMethod = "GET"
                        request.setValue(myKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
                        URLSession.shared.dataTask(with: request) { (data, response, error) in
                            let jsonResult = try? JSONSerialization.jsonObject(with: data!)
                            let parsedJson = jsonResult as? [String: Any]
                            let parsedData = parsedJson!["data"] as? [String: Any]
                            
                            DispatchQueue.main.async {
                                for i in 0 ..< self.coins.count {
                                    let coinJson = parsedData![self.coins[i].code]
                                    let quote = (((coinJson as? [String: Any])!["quote"]) as? [String: Any])!["USD"] as? [String: Any]
                                        self.coins[i].value = quote!["price"] as! Double
                                        self.working = false;
                                }
                            }
                        }
                        .resume()
                        
                        apiUrl = URL(string: infoAPI + "?symbol=" + params)!
                        request = URLRequest(url: apiUrl)
                        request.httpMethod = "GET"
                        request.setValue(myKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
                        
                        URLSession.shared.dataTask(with: request) { (data, response, error) in
                            let jsonResult = try? JSONSerialization.jsonObject(with: data!)
                            let parsedJson = jsonResult as? [String: Any]
                            let parsedData = parsedJson!["data"] as? [String: Any]
                            
                            DispatchQueue.main.async {
                                for i in 0 ..< self.coins.count {
                                    let coinJson = parsedData![self.coins[i].code] as? [String:Any]
                                    self.coins[i].name = coinJson!["name"] as! String
                                    self.coins[i].imageUrl = coinJson!["logo"] as! String
                                    self.working = false;
                                }
                            }
                        }
                        .resume()
                    }
                } catch {
                    print("decode error")
                    DispatchQueue.main.async {
                        self.working = false
                        self.error = true
                    }
                }
            }
            urlSession.resume()
        }
    }
    
    func getTotal() -> Double {
        var total = 0.0
        if coins.count == 0 {
            return 0.0
        }
        for i in 0...coins.count-1 {
            total += coins[i].value * coins[i].quantity
        }
        return Double(round(1000*total)/1000)
    }

}
