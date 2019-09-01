//
//  DotsMatrix.swift
//  DotsMatrix
//
//  Created by Ruffolo Antonio on 01/09/2019.
//  Copyright © 2019 AR. All rights reserved.
//

import Foundation

struct DotsMatrix
{
    private(set) var matrix: [[MatrixItemViewData]]
    
    init(rows: Int, columns: Int)
    {
        matrix = [[]]
        matrix = Array.init(repeating: Array.init(repeating: .dot, count: columns), count: rows)
    }
    
    mutating func indexTapped(row: Int, column: Int) {
        switch matrix[row][column]
        {
        case .dot:
            matrix[row][column] = .rectangle(belongsToLargestRectangle: false)
        case .rectangle:
            matrix[row][column] = .dot
        }
        
        // TODO: check fi the rectangle belong to the largest rectangle
    }
}
