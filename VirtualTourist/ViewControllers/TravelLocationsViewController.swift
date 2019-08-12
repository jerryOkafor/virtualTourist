//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Jerry Hanks on 12/08/2019.
//  Copyright © 2019 Jerry. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController : DataController!
    var fetchResultController:NSFetchedResultsController<Album>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Travel Locations"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Ok", style: .plain, target: nil, action: nil)
        // Do any additional setup after loading the view.
        
        //configure map
        self.configureMap()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //configure fetch
        self.setupFetchResultController()
        
        self.refreshAlbumPins()
    }
    private func setupFetchResultController(){
        let fetchRequest:NSFetchRequest<Album> = Album.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "albums")
        
        fetchResultController.delegate = self
        
        
        //try to perform fetch
        do{
            try fetchResultController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func configureMap(){
        self.mapView.delegate = self
        
        //try to get the persisted map data if it exists
        if let mapData = LocalStorage.mapData{
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
            let annotation = MKPointAnnotation()
            annotation.coordinate = cordinate
            
            //add pin to map
            self.mapView.addAnnotation(annotation)
            
            let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            
            //try to find the name corresponding to this cordinate
            CLGeocoder().reverseGeocodeLocation(location) { (placeMark, error) in
                guard error == nil else{
                    //save the selected location also
                    self.saveLocation(cordinate,locationName: "No Name")
                    return
                }
                
                if let placeName = placeMark?[0].name{
                    self.saveLocation(cordinate,locationName: placeName)
                }
            }
            
            
        }
        
    }
    
    private func saveLocation(_ cordinate:CLLocationCoordinate2D,locationName:String){
        let album = Album(context: dataController.viewContext)
        album.lat = cordinate.latitude
        album.lng = cordinate.longitude
        album.name = locationName
        
        do{
            try dataController.viewContext.save()
        }catch{
            self.shoWAlert(title: "Error", message: "Unable to save location pin")
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.fetchResultController = nil
    }
}


//MapView delegate

extension TravelLocationsViewController : MKMapViewDelegate{
    
    func refreshAlbumPins(){
        //remvoe existing annotations
        
        
        if let albums = fetchResultController.fetchedObjects{
            albums.forEach { (album) in
                self.addAnnotation(album)
            }
        }
    }
    
    func addAnnotation(_ album:Album){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: album.lat, longitude: album.lng)
        
        DispatchQueue.main.async {
            //add pin to map
            self.mapView.addAnnotation(annotation)
        }
    }
    
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
            
            //here we can try to load the album associated with the cordinate before navigating,
            //but we can just navigate for now.
            if let album = self.fetchResultController.fetchedObjects?.first(where: { (album) -> Bool in
                album.lat == cordinate.latitude && album.lng == cordinate.longitude
            }){
                let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: String(describing: PhotoAlbumViewController.self)) as! PhotoAlbumViewController
                //inject the photo album here
                photoAlbumVC.dataController = dataController
                photoAlbumVC.album = album
                
                self.navigationController?.pushViewController(photoAlbumVC, animated: true)
            }
            
        }
    }
}



//FetchResultController Delegate
extension TravelLocationsViewController : NSFetchedResultsControllerDelegate{

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let album = anObject as? Album else {return}
        
        switch type {
        case .insert:
            self.addAnnotation(album)
            break
        default:
            break
        }
        
    }
}
