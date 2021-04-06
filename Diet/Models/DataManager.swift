//
//  DataManager.swift
//  Diet
//
//  Created by Sergey Sokolkin on 3.04.21.
//

import Foundation

class DataManager {
    
    var dateToView = Date().truncatedUTC()
    
    var dateToViewString: String {
        
        if dateToView.isSame(with: Date()) {
            
            return "Today"
        } else {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM, dd"
            
            return dateFormatter.string(from: dateToView)
        }
    }
    
}
