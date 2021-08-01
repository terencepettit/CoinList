//
//  Model.swift
//  CoinList
//
//  Created by Terence Pettit on 2021-05-10.
//

import Foundation
import Combine

let myKey = "8025c44c-542c-4a3f-8db5-4a5c2741d2a8"
let apiUrl = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest"

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
    var name: String = ""
    var code: String = ""
    var quantity: Double = 0.0
    var value: Double = 0.0
    var imageUrl: String = ""
    
    // Manual protocol stuff
    static func == (lhs: Coin, rhs: Coin) -> Bool {
        return (lhs.code == rhs.code)
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(code)
        hasher.combine(quantity)
        hasher.combine(value)
    }
    private enum CodingKeys: String, CodingKey { case code, name, quantity, imageUrl }
}

class ModelData: ObservableObject {
    @Published var coins: [Coin] = load("Coins.json")
    @Published var working = false
    
    init() {
        //update()
    }
    
    func getTotal() -> Double {
        var total = 0.0
        for i in 0...coins.count-1 {
            total += coins[i].value * coins[i].quantity
        }
        return Double(round(1000*total)/1000)
    }
    
    func update() {
        var params = ""
        for i in 0 ..< self.coins.count {
            params += coins[i].code
            if i < coins.count-1 {
                params += ","
            }
        }
        
        guard let url = URL(string: apiUrl + "?convert=USD&symbol=" + params) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(myKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonResult = try? JSONSerialization.jsonObject(with: data!)
            let parsedJson = jsonResult as? [String: Any]
            let parsedData = parsedJson!["data"] as? [String: Any]
            
            
            for i in 0 ..< self.coins.count {
                let coinJson = parsedData![self.coins[i].code]
                let quote = (((coinJson as? [String: Any])!["quote"]) as? [String: Any])!["USD"] as? [String: Any]
                DispatchQueue.main.async {
                    self.coins[i].value = quote!["price"] as! Double
                }
            }
        }
        .resume()
        
        
/*        if (working) {
            return
        }
        working = true
        DispatchQueue.global(qos: .userInitiated).async {
            for i in 0 ..< self.coins.count {
                let url = URL(string: apiUrl)!
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                        let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: [])
                        if let parsedJson = jsonResult as? [Any] {
                            let post_paramsValue = parsedJson[0] as! Dictionary<String,Any>
                            DispatchQueue.main.async {
                                self.coins[i].value = Double(post_paramsValue["price"] as! String) ?? 0.0
                            }
                        }
                        else {
                            print("invalid format")
                        }
                        if (i == self.coins.count-1) {
                            DispatchQueue.main.async {
                                self.working = false;
                            }
                        }
                }
                task.resume()
                usleep(1500000) 
            }
        }
 */
        
    }
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
