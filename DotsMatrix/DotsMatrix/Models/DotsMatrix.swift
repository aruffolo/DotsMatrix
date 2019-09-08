//
//  DotsMatrix.swift
//  DotsMatrix
//
//  Created by Ruffolo Antonio on 01/09/2019.
//  Copyright © 2019 AR. All rights reserved.
//

import Foundation

struct Rectangle
{
  let row: Int
  let column: Int
  let rowSize: Int
  let columnSize: Int
}

struct DotsMatrix
{
  private(set) var matrix: [[MatrixItemViewData]]

  var currentMaxRectangle: Rectangle?

  init(rows: Int, columns: Int)
  {
    matrix = [[]]
    matrix = Array.init(repeating: Array.init(repeating: .dot, count: columns), count: rows)
  }

  mutating func indexTapped(row: Int, column: Int)
  {
    switch matrix[row][column]
    {
    case .dot:
      matrix[row][column] = .rectangle(belongsToLargestRectangle: false)
    case .rectangle:
      matrix[row][column] = .dot
    }

    resetCurrentRectangle()
    setMaxRectangleIfPresent()
  }

  private mutating func setMaxRectangleIfPresent()
  {
    if let maxRectangle = maxRectangle()
    {
      self.currentMaxRectangle = maxRectangle

      for row in maxRectangle.row..<(maxRectangle.row + maxRectangle.rowSize)
      {
        for column in maxRectangle.column..<(maxRectangle.column + maxRectangle.columnSize)
        {
          matrix[row][column] = .rectangle(belongsToLargestRectangle: true)
        }
      }
    }
  }

  private mutating func resetCurrentRectangle()
  {
    for row in 0..<matrix.count
    {
      for column in 0..<matrix[row].count
      {
        switch matrix[row][column]
        {
        case .rectangle:
          matrix[row][column] = MatrixItemViewData.rectangle(belongsToLargestRectangle: false)
        default:
          break
        }
      }
    }
  }

  mutating func clearAll()
  {
    for row in 0..<matrix.count
    {
      for column in 0..<matrix[row].count
      {
        matrix[row][column] = .dot
      }
    }
    currentMaxRectangle = nil
  }

  private func maxRectangle() -> Rectangle?
  {
    var sizeTuple: (rowSize: Int, columnSize: Int)?
    var maxRowPosition: Int?
    var maxColumnPosition: Int?

    for row in 0..<matrix.count
    {
      for column in 0..<matrix[row].count
      {
        if let rect = createRectFromCurrentPosition(row: row, column: column, sizeTuple: sizeTuple)
        {
          maxRowPosition = rect.row
          maxColumnPosition = rect.column
          sizeTuple = (rowSize: rect.rowSize, columnSize: rect.columnSize)
        }
      }
    }

    return createMaxRectangleIfPresent(maxRowPosition, maxColumnPosition, sizeTuple)
  }

  private func createMaxRectangleIfPresent(_ maxRowPosition: Int?, _ maxColumnPosition: Int?,
                                           _ sizeTuple: (rowSize: Int, columnSize: Int)?) -> Rectangle?
  {
    if let maxRowPosition = maxRowPosition, let maxColumnPosition = maxColumnPosition, let sizeTuple = sizeTuple
    {
      return Rectangle(row: maxRowPosition, column: maxColumnPosition, rowSize: sizeTuple.rowSize,
                       columnSize: sizeTuple.columnSize)
    }
    return nil
  }

  private func createRectFromCurrentPosition(row: Int, column: Int,
                                             sizeTuple: (rowSize: Int, columnSize: Int)?) -> Rectangle?
  {
    if let newTuple = maxSizeFromPosition(startRow: row, startColumn: column),
      let rect = updateRectangle(row: row, column: column, sizeTuple: sizeTuple, newTuple: newTuple)
    {
      return rect
    }

    return nil
  }

  private func updateRectangle(row: Int, column: Int,
                               sizeTuple: (rowSize: Int, columnSize: Int)?,
                               newTuple: (rowSize: Int, columnSize: Int)) -> Rectangle?
  {
    if let currentTuple = sizeTuple,
      currentTuple.columnSize * currentTuple.rowSize < newTuple.columnSize * newTuple.rowSize
    {
      return Rectangle(row: row, column: column, rowSize: newTuple.rowSize, columnSize: newTuple.columnSize)

    }
    else if sizeTuple == nil
    {
      return Rectangle(row: row, column: column, rowSize: newTuple.rowSize, columnSize: newTuple.columnSize)
    }

    return nil
  }

  private func maxSizeFromPosition(startRow: Int, startColumn: Int) -> (rowSize: Int, columnSize: Int)?
  {
    var sizeTuple: (rowSize: Int, columnSize: Int)?

    if let newTuple = sizeFromTallerRectangle(startRow: startRow,
                                              startColumn: startColumn,
                                              sizeTuple: sizeTuple)
    {
      sizeTuple = newTuple
    }

    if let newTuple = sizeFromWiderRectangle(startRow: startRow,
                                             startColumn: startColumn,
                                             sizeTuple: sizeTuple)
    {
      sizeTuple = newTuple
    }

    return sizeTuple
  }

  private func sizeFromTallerRectangle(
    startRow: Int,
    startColumn: Int,
    sizeTuple: (rowSize: Int, columnSize: Int)?
    ) -> (rowSize: Int, columnSize: Int)?
  {
    var sizeTuple: (rowSize: Int, columnSize: Int)?
    for rowSize in 1...matrix.count - startRow
    {
      for columnSize in 1...matrix[0].count - startColumn
      {
        if let newTuple = createNewMaxSizeRange(startRow: startRow,
                                                startColumn: startColumn,
                                                rowSize: rowSize,
                                                columnSize: columnSize,
                                                currentTuple: sizeTuple)
        {
          sizeTuple = newTuple
        }
      }
    }

    return sizeTuple
  }

  private func sizeFromWiderRectangle(
    startRow: Int,
    startColumn: Int,
    sizeTuple: (rowSize: Int, columnSize: Int)?
    ) -> (rowSize: Int, columnSize: Int)?
  {
    var sizeTuple: (rowSize: Int, columnSize: Int)?
    for columnSize in 1...matrix[0].count - startColumn
    {
      for rowSize in 1...matrix.count - startRow
      {
        if let newTuple = createNewMaxSizeRange(startRow: startRow,
                                                startColumn: startColumn,
                                                rowSize: rowSize,
                                                columnSize: columnSize,
                                                currentTuple: sizeTuple)
        {
          sizeTuple = newTuple
        }
      }
    }

    return sizeTuple
  }

  private func createNewMaxSizeRange(startRow: Int, startColumn: Int,
                                     rowSize: Int,
                                     columnSize: Int,
                                     currentTuple: (rowSize: Int, columnSize: Int)?) -> (rowSize: Int, columnSize: Int)?
  {
    var sizeTuple: (rowSize: Int, columnSize: Int)?
    if isRectangleSquare(startRow: startRow, startColumn: startColumn,
                         rowSize: rowSize, columnSize: columnSize)
    {
      if let currentTuple = currentTuple, rowSize * columnSize > currentTuple.rowSize * currentTuple.columnSize
      {
        sizeTuple = (rowSize: rowSize, columnSize: columnSize)
      }
      else if currentTuple == nil
      {
        sizeTuple = (rowSize: rowSize, columnSize: columnSize)
      }
    }

    return sizeTuple
  }

  private func isRectangleSquare(startRow: Int, startColumn: Int, rowSize: Int, columnSize: Int) -> Bool
  {
    for row in startRow..<(startRow + rowSize)
    {
      for colum in startColumn..<(startColumn + columnSize)
      {
        switch matrix[row][colum]
        {
        case .dot:
          return false
        default:
          break
        }
      }
    }
    return true
  }

  mutating func selectAll()
  {
    for row in 0..<matrix.count
    {
      for column in 0..<matrix[row].count
      {
        matrix[row][column] = .rectangle(belongsToLargestRectangle: true)
      }
    }
    currentMaxRectangle = Rectangle(row: 0, column: 0, rowSize: matrix.count, columnSize: matrix[0].count)
  }

  func printMatrix()
  {
    for row in 0..<matrix.count
    {
      var rowString = ""
      for column in 0..<matrix[row].count
      {
        rowString += createSymbolForElement(row: row, column: column)
      }

      print(rowString)
    }
  }

  private func createSymbolForElement(row: Int, column: Int) -> String
  {
    switch matrix[row][column]
    {
    case .dot:
      return "*"
    case .rectangle(let belongToBiggestRectangle):
      if belongToBiggestRectangle
      {
        return "+"
      }
      else
      {
        return "-"
      }
    }
  }
}
