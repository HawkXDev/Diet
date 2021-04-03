//
//  DataManager.swift
//  Diet
//
//  Created by Sergey Sokolkin on 3.04.21.
//

import Foundation

class DataManager {
    
    var dateToView = Date()
    var dateToViewString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM, dd"
        
        return dateFormatter.string(from: dateToView)
    }
}
