//
//  PageVC.swift
//  Test
//
//  Created by Мурат Камалов on 17.08.2020.
//  Copyright © 2020 Мурат Камалов. All rights reserved.
//


import UIKit
import AVKit

class PageVC: AVPlayerViewController {
    
    private(set) var movie: Movie
    
    private var playerItem: AVPlayerItem? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let asset = AVAsset(url: self.movie.url)
        
        self.playerItem = AVPlayerItem(asset: asset,
                                       automaticallyLoadedAssetKeys: nil)
        
        //обсервер чтобы понять есть ли ошибка в воспроизведение
        self.playerItem?.addObserver(self,
                                     forKeyPath: #keyPath(AVPlayerItem.status),
                                     options: [.new],
                                     context: nil)
    
        self.player = AVPlayer(playerItem: self.playerItem)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        //если просто в чем -то косяк то выходим
        guard keyPath == #keyPath(AVPlayerItem.status),
            let statusNumber = change?[.newKey] as? NSNumber else { return }
        //если не fail то ошибку делаем nil
        //на другие кейсы можно было бы ставить или убирать лоадер к примеру, но мне не нарвитсья дизайн лоадера от apple поэтому я так не сделал)
        guard statusNumber.intValue == AVPlayerItem.Status.failed.rawValue else { self.movie.urlError = nil; return }
        self.movie.urlError = player?.currentItem?.error?.localizedDescription
        
    }
    
    init(with movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    }
    
}



