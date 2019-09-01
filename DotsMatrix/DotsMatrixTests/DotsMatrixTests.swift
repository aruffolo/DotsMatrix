//
//  DotsMatrixTests.swift
//  DotsMatrixTests
//
//  Created by Antonio Ruffolo on 29/08/2019.
//  Copyright © 2019 AR. All rights reserved.
//

import XCTest
@testable import DotsMatrix

class DotsMatrixTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMatrixInit() {
        let dotsMatrix = DotsMatrix(rows: 20, columns: 15)
        
        for row in 0..<dotsMatrix.matrix.count
        {
            for column in 0..<dotsMatrix.matrix[row].count
            {
                switch dotsMatrix.matrix[row][column]
                {
                case .dot:
                    XCTAssert(true)
                case .rectangle:
                    XCTAssert(false)
                }
            }
        }
    }
    
    func testMatrixChange() {
        var dotsMatrix = DotsMatrix(rows: 20, columns: 15)
        dotsMatrix.indexTapped(row: 5, column: 9)
        
        let item = dotsMatrix.matrix[5][9]
        switch item
        {
        case .rectangle(let belong):
            XCTAssert(belong == false)
        case .dot:
            XCTAssert(false)
        }
    }
}
