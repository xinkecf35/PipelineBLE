//
//  SavedDevicesTableViewCell.swift
//  PipelineAnalysis
//
//  Created by Samuel Peterson on 7/29/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit

class AvailableDevicesTableViewCell: UITableViewCell {
    
    //  Mark: UI components and peripheral data
    public let deviceName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    public let signalImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    public let subtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override var isHighlighted: Bool {
        didSet{
            backgroundColor = isHighlighted ? UIColor.darkGray : super.backgroundColor
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //  Set constraints
        SetUpConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func SetUpConstraints(){
        //  Add the label to the cell
        addSubview(deviceName)
        
        //  Add constraints to the label
        deviceName.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        deviceName.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        deviceName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        deviceName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
 
        
    }
    
    
    /*override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }*/

    /*override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }*/

}
