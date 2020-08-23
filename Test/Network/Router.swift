//
//  Router.swift
//  Test
//
//  Created by Мурат Камалов on 19.08.2020.
//  Copyright © 2020 Мурат Камалов. All rights reserved.
//

import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?,_ response: URLResponse?,_ error: Error?)->()

protocol NetworkRouter: class {
    func request(_ route: URL, completion: @escaping NetworkRouterCompletion)
    func cancel()
}

//сильны закос на гибкий и правильный роутер
//но если что его будет гораздо легче дописать до чего-то более гибкого 
class Router : NetworkRouter {
    private var task: URLSessionTask?
    
    func request(_ route: URL, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        do {
            let request = try self.buildRequest(from: route)
 
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                completion(data, response, error)
            })
        }catch {
            completion(nil, nil, error)
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    fileprivate func buildRequest(from route: URL) throws -> URLRequest {
        
        var request = URLRequest(url: route)
        
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        return request
        
    }
    
}
