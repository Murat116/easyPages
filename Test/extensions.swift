//
//  extensions.swift
//  Test
//
//  Created by Мурат Камалов on 19.08.2020.
//  Copyright © 2020 Мурат Камалов. All rights reserved.
//

import Foundation

//вещи которые могут круто пригодиться в проекте и используются в много-много разных местах  я люблю выносить в extension

extension Dictionary{
    var asArray: [Any]{
        return self.map { return $0.value }
    }
}

import UIKit
extension UIViewController{
    func showSimpleAlert(with text: String, animated: Bool = true){
        let alert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: animated)
    }
}
