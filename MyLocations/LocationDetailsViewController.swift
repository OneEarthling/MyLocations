//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Nadya K on 07.12.2021.
//

import UIKit
import CoreLocation
import CoreData

class LocationDetailsViewController: UITableViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0,longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    var managedObjectContext: NSManagedObjectContext!
    var date = Date()
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                  descriptionText = location.locationDescription
                  categoryName = location.category
                  date = location.date
                  coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                  placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    var image: UIImage? {
        didSet {
            if let theImage = image {
                show(image: theImage)
            }
        }
    }
    var observer: Any!
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let location = locationToEdit {
            title = "Edit Location"
            if location.hasPhoto {
                if let theImage = location.photoImage {
                    show(image: theImage)
                }
            }
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = format(date: date)
        // Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        listenForBackgroundNotification()
    }
    
    
    // MARK:- Actions
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        
        let location: Location
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }
        
        location.locationDescription = descriptionTextView.text
        location.date =  date
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.placemark = placemark

        // Save image
        if let image = image {
          if !location.hasPhoto {
            location.photoID = Location.nextPhotoID() as NSNumber
          }
          if let data = image.jpegData(compressionQuality: 0.5) {
            
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
          }
        }
        
        do {
            try managedObjectContext.save()
            let delayInSeconds = 0.6
            afterDelay(delayInSeconds) {
                hudView.hide(animated: true)
                afterDelay(delayInSeconds/2) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    func show(image: UIImage){
        addPhotoLabel.text = ""
        imageView.image = image
        imageView.isHidden = false
        let ratio = image.size.width / image.size.height
        let height = imageView.frame.width / ratio
        imageHeight.constant = height
        tableView.reloadData()
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            if let weakSelf = self {
                if weakSelf.presentedViewController != nil {
                    weakSelf.dismiss(animated: false, completion: nil)
                }
                weakSelf.descriptionTextView.resignFirstResponder()
          }
        }
    }
    
    deinit {
      print("*** deinit \(self)")
      NotificationCenter.default.removeObserver(observer!)
    }
    
    // MARK:- Table View Delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
      if indexPath.section == 0 || indexPath.section == 1 {
        return indexPath
      } else {
        return nil
      }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if indexPath.section == 0 && indexPath.row == 0 {
        descriptionTextView.becomeFirstResponder()
      } else {
        if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
      }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      let selection = UIView(frame: CGRect.zero)
      selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
      cell.selectedBackgroundView = selection
    }
    
    // MARK:- Helper Methods
    func string(from placemark: CLPlacemark) -> String {
        var line = ""
        line.add(text: placemark.subThoroughfare)
        line.add(text: placemark.thoroughfare, separatedBy: " ")
        line.add(text: placemark.locality, separatedBy: ", ")
        line.add(text: placemark.administrativeArea,
        separatedBy: ", ")
        line.add(text: placemark.postalCode, separatedBy: " ")
        line.add(text: placemark.country, separatedBy: ", ")
        return line
    }
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
   }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "PickCategory" {
        let controller = segue.destination as! CategoryPickerViewController
        controller.selectedCategoryName = categoryName
      }
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
      let controller = segue.source as! CategoryPickerViewController
      categoryName = controller.selectedCategoryName
      categoryLabel.text = categoryName
    }
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
  // MARK:- Image Helper Methods
    func takePhotoWithCamera() {
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto() {
      if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
      } else {
            choosePhotoFromLibrary()
      }
    }
    
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel,  handler: nil)
        let actPhoto = UIAlertAction(title: "Take Photo",style: .default, handler: {_ in
            self.takePhotoWithCamera()
        })
        let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in
            self.choosePhotoFromLibrary()
        })
        alert.addAction(actCancel)
        alert.addAction(actPhoto)
        alert.addAction(actLibrary)
        present(alert, animated: true, completion: nil)
    }
    


    // MARK:- Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage

        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
