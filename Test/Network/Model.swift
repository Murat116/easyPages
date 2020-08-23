//
//  Model.swift
//  Test
//
//  Created by Мурат Камалов on 19.08.2020.
//  Copyright © 2020 Мурат Камалов. All rights reserved.
//

//просто структура чтобы разобрать все что пришло, не очень рационально в этом кейсе, но зато красиво
struct MovieApiResponse {
    private var status: Int
    private var taskID: Int
    private(set) var moviesURL: [URL] = []
    private(set) var preview: URL? = nil
}

extension MovieApiResponse: Decodable {
    
    private enum MovieApiResponseCodingKeys: String, CodingKey {
        case results
        case status
        case taskID = "task_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieApiResponseCodingKeys.self)
        self.status = try container.decode(Int.self, forKey: .status)
        self.taskID = try container.decode(Int.self, forKey: .taskID)
        let result = try container.decode([String: URL].self, forKey: .results)
        
        guard let resArr = result.asArray as? [URL] else { return }
        //не совсем понятно почему приходит один файл в виде фото, но будем думать что это превью для всех видео
        //просто отсортируем чтобы разобрать эту кашу
        //а так было бы несколько вопросов к бэкенд разработчику
        self.moviesURL = resArr.filter { (url) -> Bool in
            guard url.pathExtension != "mp4" else { return true }
            self.preview = url
            return false
        }
    }
}

//гвоздь всего UI именно им заполняется тупая view
//структура выбранна не случайно
//это value type - что удобно, ибо value Type - safe tread и просто удобнее
//да и вообще нет какой-то объективной причины использовать class
import UIKit
struct Movie {
    var url: URL//url по которой должно проигрываться video
    var number: Int //просто порядкой номер, хотя лучше бы использовать тут ID если будет сохранение в local storage
    var preview: UIImage? //было бы очень кстати для красоты ui иметь preview
    
    var urlError :String? = nil {
        didSet{
            //сообщим всем кому нужно что ошибка в url у видео
            guard oldValue != self.urlError, let error = self.urlError else { return }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "urlError"), object: error)
        }
        
    }
}

