//
//  ActionSheetTableViewCell.swift
//  GUActionSheet
//
//  Created by lijia xu on 8/10/21.
//

import UIKit
import Kingfisher

class ActionSheetTableViewCell: UITableViewCell {
    
    private let imagePadding: CGFloat = 16
    private let checkMarkViewHeight: CGFloat = 15
        
    private lazy var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var checkMarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        
        let systemImageNameString = "checkmark.circle.fill"
        
        guard var image = UIImage(systemName: systemImageNameString) else {
            print("failed to load system image name \(systemImageNameString)")
            return imageView
        }
        image.withTintColor(.blue)
        
        imageView.image = image
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        
    }
    
    //will be called by the table view in action sheet view
    func updateViews(_ actionInfo: ActionSheetInfo, _ rowHeight: CGFloat) {
        
        let url = URL(string: actionInfo.imageURL)
        self.cellImageView.kf.setImage(with: url)
        
        self.nameLabel.text = actionInfo.title
        
        self.checkMarkView.alpha = actionInfo.isSelected ? 1.0 : 0.0
        
        //print(frame) not showing the expected frame in the cell, will use row height pased in to determine the corner radius for the image view
        cellImageView.layer.cornerRadius = (rowHeight - imagePadding * 2.0) / 2.0
    }
    
    override func prepareForReuse() {
        cellImageView.image = UIImage()
        nameLabel.text = ""
        checkMarkView.alpha = 0.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}///End Of TableViewCell

// MARK: - Setup TableView Cell
extension ActionSheetTableViewCell {
    private func setupViews() {
        selectionStyle = .none
        
        //image view related
        addSubview(cellImageView)
        cellImageView.anchor(top: topAnchor,
                             left: leftAnchor,
                             bottom: bottomAnchor,
                             paddingTop: imagePadding,
                             paddingLeft: imagePadding,
                             paddingBottom: imagePadding)
        
        cellImageView.addConstraint(
            NSLayoutConstraint(item: cellImageView,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: cellImageView,
                               attribute: .width,
                               multiplier: 1, constant: 0)
        )
        
        //checkMark related
        cellImageView.addSubview(checkMarkView)
        checkMarkView.anchor(bottom: cellImageView.bottomAnchor,
                             right: cellImageView.rightAnchor,
                             paddingBottom: 0,
                             paddingRight: 0,
                             width: checkMarkViewHeight,
                             height: checkMarkViewHeight)
        
        checkMarkView.layer.cornerRadius = checkMarkViewHeight / 2.0
        
        //label related
        addSubview(nameLabel)
        nameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 26, paddingLeft: 71, paddingBottom: 26, paddingRight: 44)
        
    }///End Of setupViews
    
}///End Of Extension
