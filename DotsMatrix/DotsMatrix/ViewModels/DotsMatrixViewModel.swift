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
    
    init()
    {
        self.dotsMatrix = DotsMatrix(rows: 15, columns: 20)
    }
    
    func itemTapped(row: Int, column: Int)
    {
        dotsMatrix.indexTapped(row: row, column: column)
        updateMatrix?(self.dotsMatrix)
    }
}
