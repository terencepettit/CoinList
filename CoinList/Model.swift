//
//  Model.swift
//  CoinList
//
//  Created by Terence Pettit on 2021-05-10.
//

import Foundation
import Combine

let myKey = "63d7ed8faac618890903b87e9acbfb5229727376"
let apiUrl = "https://api.nomics.com/v1/currencies/ticker"

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
    
    init() {
        update()
    }
    
    func update() {
        DispatchQueue.global(qos: .userInitiated).async {
            for i in 0 ..< self.coins.count {
                let url = URL(string: apiUrl +
                                "?key=" + myKey +
                                "&ids=" + self.coins[i].code +
                                "&interval=1d,30d" +
                                "&convert=USD" +
                                "&per-page=100" +
                                "&page=1")!
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
                }
                task.resume()
                usleep(1500000) 
            }
        }
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
