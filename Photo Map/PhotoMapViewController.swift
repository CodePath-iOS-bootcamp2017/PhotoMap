//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cameraButton: UIButton!
    
    var pickedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
        self.addPin(lat: latitude, long: longitude)
    }
    
    func addPin(lat: NSNumber, long: NSNumber) {
        let annotation = PhotoAnnotation()
        let locationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
        annotation.coordinate = locationCoordinate
//        annotation.title = String(describing: lat)
        annotation.photo = self.pickedImage
        self.mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let reuseID = "myAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
            annotationView?.image = thumbnail
            annotationView?.layer.borderWidth = 3.0
            annotationView?.layer.borderColor = UIColor.white.cgColor
            annotationView?.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
        }
        
        annotationView?.leftCalloutAccessoryView = resizeRenderImageView
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped")
        performSegue(withIdentifier: "fullImageSegue", sender: view)
    }
    
    fileprivate func setupUI(){
        self.mapView.delegate = self
        self.cameraButton.layer.cornerRadius = 50.0
        self.cameraButton.layer.masksToBounds = true
        self.setInitialVisibleRegion()
    }
    
    fileprivate func setInitialVisibleRegion(){
        
        // One degree of latitude is approximately 111 kilometers (69 miles) at all times.
        // San Francisco Lat, Long = latitude: 37.783333, longitude: -122.416667
        let mapCenter = CLLocationCoordinate2D(latitude: 37.783333, longitude: -122.416667)
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: mapCenter, span: mapSpan)
        // Set animated property to true to animate the transition to the region
        mapView.setRegion(region, animated: false)
    }
    
    @IBAction func didTapCamera(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
//        vc.sourceType = UIImagePickerControllerSourceType.camera
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
        }
        
        self.present(vc, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = self.resize(image: originalImage, newSize: CGSize(width: 200.0, height: 200.0))
        
        self.pickedImage = editedImage
        
        // Dismiss UIImagePickerController to go back to your original view controller
//        dismiss(animated: true, completion: nil)
        dismiss(animated: true) { 
            self.performSegue(withIdentifier: "tagSegue", sender: self)
        }
    }
    
    fileprivate func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        resizeImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tagSegue" {
            let locationsViewController = segue.destination as! LocationsViewController
            locationsViewController.delegate = self
        }else if segue.identifier == "fullImageSegue" {
            let fullImageViewController = segue.destination as! FullImageViewController
            if let annotationView = sender as? MKAnnotationView {
                if let pAnnotation = annotationView.annotation as? PhotoAnnotation{
                    fullImageViewController.poster = pAnnotation.photo
                }
            }
        }
        
            
    }
    

}

class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    
    var title: String? {
        return "\(coordinate.latitude)"
    }
}
