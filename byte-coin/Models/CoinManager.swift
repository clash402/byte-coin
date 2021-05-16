//
//  CoinManager.swift
//  byte-coin
//
//  Created by Josh Courtney on 4/30/21.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdate(price: String, with currency: String)
    func didFail(with error: Error)
}


struct CoinManager {
    let apiEndpoint = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "1F2B8DE1-EC36-4242-B85A-3A95C23D5B4D"
    let currencies = [
        "AUD","BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY",
        "MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"
    ]
    
    var delegate: CoinManagerDelegate?
    
    func fetchCoinPrice(for currency: String) {
        let urlString = "\(apiEndpoint)/\(currency)?apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                self.delegate?.didFail(with: error)
                return
            }
            
            guard let safeData = data else { return }
            guard let bitcoinPrice = self.parseJSON(with: safeData) else { return }
            
            let price = String(format: "%.2f", bitcoinPrice)
            
            self.delegate?.didUpdate(price: price, with: currency)
        }
        
        task.resume()
    }
    
    func parseJSON(with data: Data) -> Double? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let rate = decodedData.rate
            return rate
        } catch {
            delegate?.didFail(with: error)
            return nil
        }
    }
}
