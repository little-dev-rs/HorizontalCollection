//
//  ViewController.swift
//  HorizontalCollection
//

import UIKit

class ViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let customLayout = CustomFlowLayout()
        customLayout.scrollDirection = .horizontal
        customLayout.minimumLineSpacing = 10
        customLayout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: customLayout)
        collectionView.register(CollectionFlowCell.self, forCellWithReuseIdentifier: "collectionFlowCell")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionFlowCell", for: indexPath) as? CollectionFlowCell ?? UICollectionViewCell()
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .cyan
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 500)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Set the section insets (spacing around the cells)
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}

class CollectionFlowCell: UICollectionViewCell {
    
    let label = UILabel()
    
    func configure(text: String) {
        label.text = text
    }
}

class CustomFlowLayout: UICollectionViewFlowLayout {

    override var collectionViewContentSize: CGSize {
        let contentWidth = super.collectionViewContentSize.width
        let contentHeight = collectionView?.bounds.height ?? 0
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        // Calculate the visible rect of the collection view
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        
        // Get the center point of the visible rect
        let visibleCenterX = visibleRect.midX
        
        // Find the proposed attributes that are closest to the center point
        let proposedAttributes = super.layoutAttributesForElements(in: visibleRect)
        var targetOffset = CGFloat.greatestFiniteMagnitude
        var visibleCellFrames: [CGRect] = []
        
        for attributes in proposedAttributes ?? [] {
            let distance = attributes.center.x - visibleCenterX
            
            // Check if this cell is closer to the center compared to the current target offset
            if abs(distance) < abs(targetOffset) {
                targetOffset = distance
            }
            // Append the frame of the visible cell
            visibleCellFrames.append(attributes.frame)
        }
        
        var leftPoint: CGFloat = 0
        // Access the coordinates or frame of visible cells
        for frame in visibleCellFrames {
            leftPoint = frame.minX - collectionView.layoutMargins.left
            print("Visible cell frame: \(frame) leftPoint \(leftPoint)")
        }
        
        // Add the target offset to the proposed content offset
        let newOffset = CGPoint(x: proposedContentOffset.x + targetOffset, y: proposedContentOffset.y)
        return CGPoint(x: leftPoint, y: 0)
    }
}
