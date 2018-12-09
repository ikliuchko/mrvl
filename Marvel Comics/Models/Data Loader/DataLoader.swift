//
//  DataLoader.swift
//  Marvel Comics
//
//  Created by Igor Kliuchko on 12/2/18.
//  Copyright © 2018 Igor Kliuchko. All rights reserved.
//

import Swinject
import PromiseKit
import Alamofire
import SwiftyJSON
import CommonCrypto

protocol DataLoader {
    func getData(for requestType: RequestType) -> Promise<JSON>
}

final class DataLoaderImp: DataLoader {
    
    var serviceData: String {
        get {
            let currentDate = String(Date().timeIntervalSince1970)
            var resultString = ""
            resultString += "?ts=\(currentDate)"
            resultString += "&apikey=\(GlobalConstants.publicKey)"
            resultString += "&hash=\(md5(currentDate + GlobalConstants.privateKey + GlobalConstants.publicKey))"
            resultString += "&limit=\(GlobalConstants.itemsToDisplay)"
            return resultString
        }
    }
    
    func getData(for requestType: RequestType) -> Promise<JSON> {
        return Promise { [weak self] seal in
            guard let self = self else { return }
            let requestToSend = self.request(byType: requestType)
            Alamofire.request(requestToSend)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        seal.fulfill(JSON(data))
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }
    
    private func request(byType type: RequestType) -> String {
        var finalRequest = GlobalConstants.base
        switch type {
        case .getComics:
            finalRequest += "v1/public/comics"
            finalRequest += serviceData
        case .searchForComics(withTitle: let title):
            finalRequest += "v1/public/comics"
            finalRequest += serviceData
            finalRequest += "&titleStartsWith=\(title)"
        }
        return finalRequest.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
    }
    
    private func md5(_ string: String) -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let d = string.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
}
