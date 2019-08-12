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
}
