//
//  KRLCollectionViewGridLayout.swift
//  KRLCollectionViewGridLayoutDemo
//
//  Created by Kevin Lundberg on 7/13/14.
//  Copyright (c) 2014 Lundbergsoft. All rights reserved.
//

import CoreGraphics
import UIKit

class KRLCollectionViewGridLayout : UICollectionViewLayout {
    var scrollDirection: UICollectionViewScrollDirection = .Vertical {
    didSet {
        if scrollDirection != oldValue {
            self.invalidateLayout()
        }
    }
    }
    var sectionInset: UIEdgeInsets = UIEdgeInsetsZero {
    didSet {
        if !UIEdgeInsetsEqualToEdgeInsets(sectionInset, oldValue) {
            self.invalidateLayout()
        }
    }
    }
    var interitemSpacing: CGFloat = 10 {
    didSet {
        if interitemSpacing != oldValue {
            self.invalidateLayout()
        }
    }
    }
    var lineSpacing: CGFloat = 10 {
    didSet {
        if lineSpacing != oldValue {
            self.invalidateLayout()
        }
    }
    }
    var numberOfItemsPerLine: Int = 1 {
    didSet {
        if numberOfItemsPerLine != oldValue {
            self.invalidateLayout()
        }
    }
    }
    var aspectRatio: CGFloat = 1 {
    didSet {
        if aspectRatio != oldValue {
            self.invalidateLayout()
        }
    }
    }

    var collectionViewContentLength: CGFloat = 0;
    var attributesBySection = [[UICollectionViewLayoutAttributes]]()

    override func prepareLayout() {
        self.collectionViewContentLength = self.contentLength()
        self.calculateLayoutAttributes()
    }

    func contentLength() -> CGFloat {
        let cellSize = self.cellSize
        var contentLength: CGFloat = 0.0

        for section in 0..<self.collectionView.numberOfSections() {
            contentLength += self.contentLength(section)
        }

        return contentLength;
    }

    var cellSize: CGSize {
        let cellLength = self.usableSpace / CGFloat(self.numberOfItemsPerLine)

        if self.scrollDirection == .Vertical {
            return CGSize(
                width: cellLength,
                height: cellLength * CGFloat(1.0 / self.aspectRatio)
            )
        } else {
            return CGSize(
                width: cellLength * CGFloat(self.aspectRatio),
                height: cellLength
            )
        }
    }

    var usableSpace: CGFloat {
        let collectionViewLength = (self.scrollDirection == .Vertical
            ? self.collectionViewContentSize().width
            : self.collectionViewContentSize().height)

        return collectionViewLength - self.insetLength - self.totalItemSpacing
    }

    var insetLength: CGFloat {
        if self.scrollDirection == .Vertical {
            return self.sectionInset.top + self.sectionInset.bottom
        } else {
            return self.sectionInset.left + self.sectionInset.right
        }
    }

    var totalItemSpacing: CGFloat {
        return CGFloat(self.numberOfItemsPerLine - 1) * self.interitemSpacing
    }

    func contentLength(section: Int) -> CGFloat {
        return self.totalLineSpacing(section) + self.insetLength + self.totalRowLength(section)
    }

    func totalLineSpacing(section: Int) -> CGFloat {
        return CGFloat(self.rowsInSection(section) - 1) * self.lineSpacing;
    }

    func totalRowLength(section: Int) -> CGFloat {
        if self.scrollDirection == .Vertical {
            return self.rowsInSection(section) * self.cellSize.height
        } else {
            return self.rowsInSection(section) * self.cellSize.width
        }
    }

    func rowsInSection(section: Int) -> CGFloat {
        let itemsInSection = self.collectionView.numberOfItemsInSection(section)
        return CGFloat((itemsInSection / self.numberOfItemsPerLine) + (itemsInSection % self.numberOfItemsPerLine > 0 ? 1 : 0))
    }

    func calculateLayoutAttributes() {
        self.attributesBySection = (0..<self.collectionView.numberOfSections()).map(self.layoutAttributesForItemsInSection)
    }

    func layoutAttributesForItemsInSection(section: Int) -> [UICollectionViewLayoutAttributes] {
        return self.indexPathsInSection(section).map { self.layoutAttributesForCellAtIndexPath($0) }
    }

    func indexPathsInSection(section: Int) -> [NSIndexPath] {
        return (0..<self.collectionView.numberOfItemsInSection(section)).map {
            NSIndexPath(forItem: $0, inSection: section)
        }
    }

    func layoutAttributesForCellAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath:indexPath)
        attributes.frame = self.frameForItemAtIndexPath(indexPath)
        return attributes
    }

    func frameForItemAtIndexPath(indexPath: NSIndexPath) -> CGRect {
        let cellSize = self.cellSize
        let rowOfItem = CGFloat(indexPath.item / self.numberOfItemsPerLine)
        let locationInRowOfItem = CGFloat(indexPath.item % self.numberOfItemsPerLine)

        var origin = CGPoint()

        let sectionStart = self.startOfSection(indexPath.section)
        if self.scrollDirection == .Vertical {
            origin.x = self.sectionInset.left + (locationInRowOfItem * cellSize.width) + (self.interitemSpacing * locationInRowOfItem)
            origin.y = sectionStart + self.sectionInset.top + (rowOfItem * cellSize.height) + (self.lineSpacing * rowOfItem)
        } else {
            origin.x = sectionStart + self.sectionInset.left + (rowOfItem * cellSize.width) + (self.lineSpacing * rowOfItem)
            origin.y = self.sectionInset.top + (locationInRowOfItem * cellSize.height) + (self.interitemSpacing * locationInRowOfItem)
        }
        return CGRect(origin: origin, size: cellSize)
    }

    func startOfSection(section: Int) -> CGFloat {
        return (0..<section).map(self.contentLength).reduce(0, combine: +)
    }

    override func collectionViewContentSize() -> CGSize {
        if self.scrollDirection == .Vertical {
            return CGSize(width: self.collectionView.bounds.size.width, height: self.collectionViewContentLength)
        } else {
            return CGSize(width: self.collectionViewContentLength, height: self.collectionView.bounds.size.height)
        }
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]! {
        var visibleAttributes = [UICollectionViewLayoutAttributes]()
        for sectionAttributes in self.attributesBySection {
            visibleAttributes += sectionAttributes.filter { rect.intersects($0.frame) }
        }
        return visibleAttributes
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath!) -> UICollectionViewLayoutAttributes! {
        return self.attributesBySection[indexPath.section][indexPath.item]
    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return newBounds.size != self.collectionView.bounds.size
    }
}
