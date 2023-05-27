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
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionFlowCell", for: indexPath) as? CollectionFlowCell else {
            return UICollectionViewCell()

        }
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .cyan
        cell.configure(text: "\(indexPath.row)")
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 500)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return collectionView.layoutMargins
    }
}

class CollectionFlowCell: UICollectionViewCell {
    
    lazy var label: UILabel = {
        var label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    private func setupSubviews() {
        contentView.addSubview(label)
        label.frame = contentView.bounds
    }

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
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visibleCenterX = visibleRect.midX
        let proposedAttributes = super.layoutAttributesForElements(in: visibleRect)
        var targetOffset = CGFloat.greatestFiniteMagnitude
        var visibleCellFrames: [CGRect] = []
        
        for attributes in proposedAttributes ?? [] {
            let distance = attributes.center.x - visibleCenterX
            if abs(distance) < abs(targetOffset) {
                targetOffset = distance
            }
            visibleCellFrames.append(attributes.frame)
        }
        
        var leftPoint: CGFloat = 0
        for frame in visibleCellFrames {
            leftPoint = frame.minX - collectionView.layoutMargins.left
            print("Visible cell frame: \(frame) leftPoint \(leftPoint)")
        }
        let newOffset = CGPoint(x: proposedContentOffset.x + targetOffset, y: proposedContentOffset.y)
        return CGPoint(x: leftPoint, y: 0)
    }
}
