//
//  ViewController.swift
//  Test
//
//  Created by Мурат Камалов on 17.08.2020.
//  Copyright © 2020 Мурат Камалов. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    
    private var pageController: UIPageViewController?
    private var movie: [Movie] = [] //в качестве модели для pageView выбрал целый массив ибо экземпляры хранящиеся в ним занимают почти ничтожное место в памяти и это решение для нас безболезненное

    private var presentor = ViewControllerPresentor()// презентор для общения с сетью, которая в данном случае выступает в архитектуре model, ибо сам по себе model нам не нужен
        
    private var errorGroup = ShowErrorGroup() // экзмепляр хранящий DispathGroup для контролирование показа уведомлений о проблеме с отображением видео, сделал на основе группы просто потому что люблю DispathGroup не смотря на то что он немного понижает читабельность кода, но в проекте из одного контроллера это не страшно
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        self.setupPageController()
        
        self.presentor.delegate = self
        self.presentor.getMovies() // спрашиваем у модели видео для обновления data source у котроллера
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkError(sender:)), name: NSNotification.Name(rawValue: "urlError"), object: nil) // если что-то не так с отображением
        //Обсервер никогда не удаляется ибо это root контроллер и в памяти у нас из - за него ничего не застрянет лишнего
        //Но если бы это был реальный проект то для того чтобы какой-то джунн потом не косякнул обязательно бы сделал удаления на обсерв
    }

    private func setupPageController() {
        
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageController?.dataSource = self
        self.pageController?.delegate = self
        self.pageController?.view.backgroundColor = .black
        self.pageController?.view.frame = self.view.frame
        self.addChild(self.pageController!)
        self.view.addSubview(self.pageController!.view)
    }
    
    @objc func checkError(sender: Any){
           guard let notification = sender as? NSNotification, let error = notification.object as? String else { return }
           self.errorGroup.group.notify(queue: .main) {
               self.showAlert(with: error)
           }
       }
}

//MARK: UIPageViewControllerDelegate
extension ViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
       return self.moveToVC(at: .before, with: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.moveToVC(at: .after, with: viewController)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.movie.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, self.errorGroup.enterCount > 0 else { return }
        //уведомляем что закончили это действие
        //в принципе мы могли это сделать каким нибудь флагом или вообще делать проверку и показывать alert в cамом PageView,
        self.errorGroup.group.leave() //сообщаем группе что перелистование закончилось
        self.errorGroup.enterCount -= 1
    }

    //вынес в отдельные метод ибо дублирование кода не приносит ничего хорошего
    func moveToVC(at state: State, with vc: UIViewController) -> UIViewController?{
        guard let currentVC = vc as? PageVC else { return nil }
        
        var index = currentVC.movie.number
        
        //говорим группе что мы начали перелистовать котнроллери
        if self.errorGroup.enterCount == 0 {
            self.errorGroup.group.enter()
            self.errorGroup.enterCount += 1
        }

        if state == .after{
            guard index < self.movie.count - 1 else { return nil }
            index += 1
        }else {
            guard index != 0 else { return nil }
            index -= 1
        }
    
        let vc: PageVC = PageVC(with: self.movie[index])
        
        return vc
    }
    
    //просто для "чуть-чуть" более читабельного кода
    enum State{
        case after
        case before
    }
    
    class ShowErrorGroup {
        var group = DispatchGroup()
        var enterCount: Int = 0
    }
}

extension ViewController: ViewControllerDelegate {
    //обновляем UI
    func setUpPages(with moview: [Movie]) {
        DispatchQueue.main.async {
            self.movie = moview
            
            let initialVC = PageVC(with: self.movie[0])
            
            self.pageController?.setViewControllers([initialVC], direction: .forward, animated: true, completion: nil)
            
            self.pageController?.didMove(toParent: self)
        }
    }

    //если были какие-то ошибки в модели то показываем их тут
    func showAlert(with title: String) {
        self.showSimpleAlert(with: title)
    }
    
}
