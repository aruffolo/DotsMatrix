//
//  DotsMatrixViewModel.swift
//  DotsMatrix
//
//  Created by Ruffolo Antonio on 02/09/2019.
//  Copyright © 2019 AR. All rights reserved.
//

import Foundation

class DotsMatrixViewModel
{
    private(set) var dotsMatrix: DotsMatrix
    
    var updateMatrix: ((_ dotsMatrix: DotsMatrix) -> Void)?
    var updateSelected: ((_ selected: String) -> Void)?
    var updateSize: ((_ size: String) -> Void)?
    
    init()
    {
        self.dotsMatrix = DotsMatrix(rows: 15, columns: 20)
    }
    
    func itemTapped(row: Int, column: Int)
    {
        dotsMatrix.indexTapped(row: row, column: column)
        refreshUi()
    }
    
    private func refreshUi()
    {
        updateMatrix?(self.dotsMatrix)
        
        let selected = selectedDots()
        
        self.updateSelected?(String(selected))
        
        if let rect = dotsMatrix.currentMaxRectangle
        {
            let size = String(rect.rowSize * rect.columnSize)
            self.updateSize?(size)
        }
        else
        {
            self.updateSize?("0")
        }
    }
    
    private func selectedDots() -> Int
    {
        var selected: Int = 0
        for row in 0..<dotsMatrix.matrix.count
        {
            for column in 0..<dotsMatrix.matrix[row].count
            {
                switch dotsMatrix.matrix[row][column]
                {
                case .rectangle:
                    selected += 1
                default:
                    break
                }
            }
        }
        
        return selected
    }
    
    func selectAll()
    {
        dotsMatrix.selectAll()
        refreshUi()
    }
    
    func clearAll()
    {
        dotsMatrix.clearAll()
        refreshUi()
    }
}
