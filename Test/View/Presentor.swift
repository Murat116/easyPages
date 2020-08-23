//
//  Presentor.swift
//  Test
//
//  Created by Мурат Камалов on 19.08.2020.
//  Copyright © 2020 Мурат Камалов. All rights reserved.
//

import Foundation

//Делегат для общения модели и UI
protocol ViewControllerDelegate: class {
    func setUpPages(with moview: [Movie])
    func showAlert(with title: String)
}

//класс ради одного метода - это несовсем рационально, куда было рациональнее создать статическую функцию
//но как бы следуем принципу single respensobility
class ViewControllerPresentor{
    private let networkManager = NetworkManager()
    weak var delegate : ViewControllerDelegate? = nil
        
    func getMovies(){
        self.networkManager.getNewMovies { (movies, error) in
            guard error == nil, let movies = movies else { self.delegate?.showAlert(with: error ?? "Something wrong"); return }
            var moviesArray = [Movie]()
            for (movieNum, movieVal) in movies.enumerated(){
                moviesArray.append(Movie(url: movieVal, number: movieNum, preview: nil))
            }
            //отправляем в View все что собрали
            self.delegate?.setUpPages(with: moviesArray)
        }
    }
}
