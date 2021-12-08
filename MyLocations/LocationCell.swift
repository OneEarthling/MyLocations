//
//  LocationCellTableViewCell.swift
//  MyLocations
//
//  Created by Nadya K on 08.12.2021.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK:- Helper Method
    func configure(for location: Location) {
        descriptionLabel.text = location.locationDescription.isEmpty ? "(No Description)" : location.locationDescription
        
        if let placemark = location.placemark {
            var text = ""
            if let s = placemark.subThoroughfare {
                text += s + " "
            }
            if let s = placemark.thoroughfare {
                text += s + ", "
            }
            if let s = placemark.locality {
                text += s
            }
            addressLabel.text = text
        } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude,location.longitude)
        }
    }

}
