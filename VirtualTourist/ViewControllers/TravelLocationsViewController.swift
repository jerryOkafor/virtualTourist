//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Jerry Hanks on 12/08/2019.
//  Copyright © 2019 Jerry. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    private func configureMap(){
        self.mapView.delegate = self
        
        //try to get the persisted map data if it exists
        
        if let mapData = LocalStorage.mapData{
            print("Map Data Retrived: \(mapData)")
            
            //set the map region
            let span = MKCoordinateSpan(latitudeDelta: mapData.spanLatDelta, longitudeDelta: mapData.spanLngDelta)
            let center = CLLocationCoordinate2D(latitude: mapData.lat, longitude: mapData.lng)
            let region = MKCoordinateRegion(center: center, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    
    }

    
    //Callled when MapView is long pressed
    @IBAction func onMapViewLongPress(_ sender: UILongPressGestureRecognizer) {
        
        //get the point that was long pressedd base on the map view
        let cgPoint = sender.location(in: mapView)
        
        //convert the cgPoint to cordinates
        let cordinate  = self.mapView.convert(cgPoint, toCoordinateFrom: self.mapView)
        
        //ensure that the gesture recognizer is ended before adding annotation to the map
        
        if sender.state == .ended{
            print("State ended!")
            let annotation = MKPointAnnotation()
            annotation.coordinate = cordinate
            
            //add pin to map
            self.mapView.addAnnotation(annotation)
            
            //save the selected location also
            saveLocation(cordinate)
        }
        
    }
    
    private func saveLocation(_ cordinate:CLLocationCoordinate2D){
        print("saving Location to core data")
    }
    
}


//MapView delegate

extension TravelLocationsViewController : MKMapViewDelegate{
    
    //Called when the visible region of the map is changed
    //when the map is draged of pinched.
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
       let region = mapView.region
        
        let mapData = MapData(lat:  region.center.latitude, lng: region.center.longitude, spanLatDelta: region.span.latitudeDelta, spanLngDelta: region.span.longitudeDelta)
        
        //save map data to local storage
        LocalStorage.mapData = mapData
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pin!.canShowCallout = true
            pin!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pin!.annotation = annotation
        }
        
        return pin
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let cordinate = view.annotation?.coordinate{
            print("Lat: \(cordinate.latitude) Lng: \(cordinate.longitude)")
            //here we can try to load the album associated with the cordinate before navigating,
            //but we can just navigate for now.
            
            let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: String(describing: PhotoAlbumViewController.self)) as! PhotoAlbumViewController
            //inject the photo album here
            
            self.navigationController?.pushViewController(photoAlbumVC, animated: true)
        }
    }
}
