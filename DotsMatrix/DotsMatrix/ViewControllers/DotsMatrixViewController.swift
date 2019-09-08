//
//  ViewController.swift
//  DotsMatrix
//
//  Created by Antonio Ruffolo on 29/08/2019.
//  Copyright © 2019 AR. All rights reserved.
//

import UIKit

class DotsMatrixViewController: UIViewController
{
  @IBOutlet weak var collectionView: UICollectionView!

  @IBOutlet weak var maxSizeLabel: UILabel!
  @IBOutlet weak var selectedLabel: UILabel!
  private var collectionDataSource: DotsCollectionDataSource!
  // swiftlint:disable weak_delegate
  private var collectionFlowDelegate: DotsCollectionFlowDelegate!
  private var dotsMatrix: DotsMatrix!

  private let viewModel = DotsMatrixViewModel()

  override func loadView()
  {
    super.loadView()

    dotsMatrix = viewModel.dotsMatrix
  }

  override func viewDidLoad()
  {
    super.viewDidLoad()
    initDataSource()

    initViewModelClosures()

    collectionFlowDelegate.didSelectItem = { [unowned self] row, column in
      self.viewModel.itemTapped(row: row, column: column)
    }
  }

  private func initViewModelClosures()
  {
    viewModel.updateMatrix = { [unowned self] (dotsMatrix: DotsMatrix) in
      self.collectionDataSource.updateMatrix(matrix: dotsMatrix.matrix)
      self.collectionFlowDelegate.updateMatrix(matrix: dotsMatrix.matrix)
      self.collectionView.reloadData()
    }

    viewModel.updateSize = { [unowned self] size in
      self.maxSizeLabel.text = size
    }

    viewModel.updateSelected = { [unowned self] selected in
      self.selectedLabel.text = selected
    }
  }

  private func initDataSource()
  {
    collectionDataSource = DotsCollectionDataSource(matrix: dotsMatrix.matrix)
    collectionView.dataSource = collectionDataSource
    collectionFlowDelegate = DotsCollectionFlowDelegate(rows: 15, columns: 20, matrix: dotsMatrix.matrix)
    collectionView.delegate = collectionFlowDelegate
  }

  @IBAction func selectAllButtonAction(_ sender: UIButton)
  {
    viewModel.selectAll()
  }

  @IBAction func clearAllButtonAction(_ sender: UIButton)
  {
    viewModel.clearAll()
  }
}

class DotsCollectionDataSource: NSObject, UICollectionViewDataSource
{
  private(set) var matrix: [[MatrixItemViewData]]

  init(matrix: [[MatrixItemViewData]])
  {
    self.matrix = matrix
  }

  func updateMatrix(matrix: [[MatrixItemViewData]])
  {
    self.matrix = matrix
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int
  {
    return matrix.count
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    return matrix[section].count
  }

  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DotsCollectionViewCell.identifier,
                                                        for: indexPath) as? DotsCollectionViewCell
      else {
        fatalError("Cell could not be created: \(DotsCollectionViewCell.identifier)")
    }

    return cell
  }
}

class DotsCollectionFlowDelegate: NSObject, UICollectionViewDelegateFlowLayout
{
  private(set) var matrix: [[MatrixItemViewData]]

  var didSelectItem: ((_ row: Int, _ column: Int) -> Void)?

  private let horizontalMargin: CGFloat = 2
  private let minimumSpacing: CGFloat = 2
  private let rows: Int
  private let columns: Int

  init(rows: Int, columns: Int, matrix: [[MatrixItemViewData]])
  {
    self.rows = matrix.count
    self.columns = matrix.first?.count ?? 0
    self.matrix = matrix
  }

  func updateMatrix(matrix: [[MatrixItemViewData]])
  {
    self.matrix = matrix
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize
  {
    let width = calculateItemWidth(collectionViewWidth: collectionView.bounds.width)

    return CGSize(width: width, height: width)
  }

  private func calculateItemWidth(collectionViewWidth: CGFloat) -> CGFloat
  {
    return collectionViewWidth / CGFloat(columns) - horizontalMargin / 2
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets
  {

    return UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat
  {
    return horizontalMargin / 2
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
  {
    return horizontalMargin / 2
  }

  func collectionView(_ collectionView: UICollectionView,
                      willDisplay cell: UICollectionViewCell,
                      forItemAt indexPath: IndexPath)
  {
    guard let dotCell = cell as? DotsCollectionViewCell
      else {
        fatalError("Cell could not be created: \(DotsCollectionViewCell.identifier)")
    }

    let viewData = self.matrix[indexPath.section][indexPath.item]
    setCell(cell: dotCell, viewData: viewData, collectionViewWidth: collectionView.bounds.width)
  }

  private func setCell(cell: DotsCollectionViewCell, viewData: MatrixItemViewData, collectionViewWidth: CGFloat)
  {
    switch viewData
    {
    case .dot:
      setDotCell(cell: cell, collectionViewWidth: collectionViewWidth)
    case .rectangle(let belongsToLargest):
      setRectangleCell(cell: cell, belongsToLargest: belongsToLargest)
    }
  }

  private func setDotCell(cell: DotsCollectionViewCell, collectionViewWidth: CGFloat)
  {
    let width = calculateItemWidth(collectionViewWidth: collectionViewWidth)
    cell.shapeView.layer.cornerRadius = width / 2
    cell.shapeView.backgroundColor = UIColor.cyan
  }

  private func setRectangleCell(cell: DotsCollectionViewCell, belongsToLargest: Bool)
  {
    cell.shapeView.layer.cornerRadius = 0
    if belongsToLargest
    {
      cell.shapeView.backgroundColor = UIColor.red
    }
    else
    {
      cell.shapeView.backgroundColor = UIColor.blue
    }
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    didSelectItem?(indexPath.section, indexPath.item)
  }
}
