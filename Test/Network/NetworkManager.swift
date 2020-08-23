//
//  NetworkManager.swift
//  Test
//
//  Created by Мурат Камалов on 19.08.2020.
//  Copyright © 2020 Мурат Камалов. All rights reserved.
//

import Foundation

enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

enum Result<String>{
    case success
    case failure(String)
}

//закос на сетевой слой
//в полное мере реализовывать не очень хотелось ради одного контоллера
//но вдруг кто - то потом захочет взять и сделать на основе этого мини приложения огромный проект, тогда ему не придется сильно дописывать это
struct NetworkManager {
    
    let router = Router()
    
    func getNewMovies(completion: @escaping (_ movie: [URL]?,_ error: String?)->()){
        //route у request лучше реализовать через enum или отдельную сущность создающую URL
        self.router.request(URL(string: "https://dance.ashmanov.org/test/item")!) { data, response, error in
            //какие - то: проблемы шлем complition с ошибкой
            //никаких проблем шлем результат
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print((jsonData as? [String:Any])!)
                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)
                        completion(apiResponse.moviesURL,nil)
                    }catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
