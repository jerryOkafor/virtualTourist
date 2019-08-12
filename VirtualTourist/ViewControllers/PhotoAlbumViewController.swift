//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Jerry Hanks on 12/08/2019.
//  Copyright © 2019 Jerry. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    
    var dataController : DataController!
    var fetchResultController:NSFetchedResultsController<Photo>!
    var album:Album!
    
    var loadPhotosTask: URLSessionDataTask? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = album.name
        // Do any additional setup after loading the view.
        
        //configure fetchResult controller
        self.setUpFetchResultController()
        
        self.configureCollectionView()
        self.configureMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //configure fetchResult controller
        self.setUpFetchResultController()
        
        if self.fetchResultController.fetchedObjects?.count == 0{
            self.toggleNoImageLabel(true)
            
            //laod new photos
            self.loadNewPhotosForAlbum()
        }else{
            self.toggleNoImageLabel(false)
        }
        
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.fetchResultController = nil
        
        self.loadPhotosTask?.cancel()
    }
    
    
    private func configureMap(){
        self.mapView.delegate = self
        
        self.addAnnotation(album)
        
        
        //set the map region
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let center = CLLocationCoordinate2D(latitude: album.lat, longitude: album.lng)
        let region = MKCoordinateRegion(center: center, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    private func configureCollectionView(){
        self.collectionView.dataSource = self
        self.collectionView.delegate  = self
        
        //allow mutiple selections
        self.collectionView.allowsMultipleSelection = true
        
        //configure collectionView flowlayout item size
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        self.collectionViewFlowLayout.minimumInteritemSpacing = space
        self.collectionViewFlowLayout.minimumLineSpacing = space
        
        //set the item size to square
        self.collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    private func setUpFetchResultController(){
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "album = %@", album)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        self.fetchResultController  = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(String(describing: album.name))-photos")
        
        self.fetchResultController.delegate = self
        
        //perform fetch
        do{
            try self.fetchResultController.performFetch()
        }catch{
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
        
    }
    
    
    private func loadNewPhotosForAlbum(){
        self.toggleLoadingIndicator(true)
        
        self.loadPhotosTask = ApiClient.getPhotosForLocation(lat: album.lat, lng: album.lng){response,error in
            
            self.toggleLoadingIndicator(false)
            
            guard error == nil else{
                self.showAlert(title: "Error", message: error!.localizedDescription)
                return
            }
            
            
            if let photosMetaData = response?.photos.photo{
                self.saveAllPhotos(photosMetaData)
            }
        }
    }
    
    private func saveAllPhotos(_ photosMetadata:[PhotoMetaData]){
        photosMetadata.forEach { (photoMetaData) in
            let photo = Photo(context: dataController.viewContext)
            photo.album = album
            photo.imageData = nil
            photo.imageId = photoMetaData.id
            photo.imageUrl = ApiClient.EndPoints.imageFromMetadata(photoMetaData.farm, photoMetaData.server, photoMetaData.id, photoMetaData.secret).url.absoluteString
            
            do{
                try self.dataController.viewContext.save()
            }catch{
                self.showAlert(title: "Error", message: "Unable to save photos")
            }
        }
    }
    
    private func toggleLoadingIndicator(_ show:Bool){
        self.activityIndicator.isHidden = !show
        if show{
            self.activityIndicator.startAnimating()
        }else{
            self.activityIndicator.stopAnimating()
        }
        
        self.newCollectionButton.isHidden = show
    }
    
    @IBAction func onNewCollectonButtonClicked(_ sender: UIButton) {
        //delet all photos and get new data, save em and reload
        self.deletePhotos()
        
        //reload photos
        self.loadNewPhotosForAlbum()
    }
    
    private func deletePhotos(){
        
        if let photos = self.fetchResultController.fetchedObjects{
            for photo in photos{
                self.dataController.viewContext.delete(photo)
                
                //try to persiste the context
                do{
                    try self.dataController.viewContext.save()
                }catch{
                    print(error)
                }
            }

            
        }
        
    }
    

    private func toggleNoImageLabel(_ show:Bool){
        self.noImageLabel.isHidden = !show
        self.collectionView.isHidden = show
    }
}


//PhotoAlbumViewController + MapDelegate
extension PhotoAlbumViewController:MKMapViewDelegate{
    func addAnnotation(_ album:Album){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: album.lat, longitude: album.lng)
        
        DispatchQueue.main.async {
            //add pin to map
            self.mapView.addAnnotation(annotation)
        }
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

class AlbumViewCell: UICollectionViewCell {
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    func bindImageData(_ imageData:Data){
        let image = UIImage(data: imageData)
        self.albumImageView.image  = image
        self.activityIndicator.stopAnimating()
    }
}


//CollectionView Datasource
extension PhotoAlbumViewController : UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.fetchResultController?.sections?.count ?? 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResultController.sections?[section].numberOfObjects ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AlbumViewCell.self), for: indexPath) as! AlbumViewCell
        
        let photo = self.fetchResultController.object(at: indexPath)
        
        if photo.imageData == nil{
            //load photo image Data
            cell.activityIndicator.startAnimating()
            DispatchQueue.global(qos: .background).async {
                do{
                    let imageData  = try Data(contentsOf: URL(string: photo.imageUrl!)!)
                    photo.imageData = imageData
                    
                    //try to save context
                    do{
                        try self.dataController.viewContext.save()
                    }catch{
                        print("Unable to save context: \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async {
                        cell.bindImageData(imageData)
                    }
                    
                }catch{
                    print("Unable to load image: \(error.localizedDescription)")
                }
            }
            
            
            
        }else{
            
            if let imageData = photo.imageData{
                cell.bindImageData(imageData)
            }
        }
        
        return cell
    }
}



//PhotoAlbumVIewController + UICollectioViewDelgate
extension PhotoAlbumViewController : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photo = self.fetchResultController.object(at: indexPath)
        
        //try to save the deleted item
        do{
            self.dataController.viewContext.delete(photo)
            try self.dataController.viewContext.save()
        }catch{
            self.showAlert(title: "Error", message: "Unable to delete photo, pleaese try again")
        }
    }
}


//PhotoAlbumViewController + FetchResultControllerdelegate
extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate{
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.toggleNoImageLabel(self.fetchResultController.fetchedObjects?.count == 0)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.collectionView.insertItems(at: [newIndexPath!])
            break
            
        case .update:
            self.collectionView.reloadItems(at: [indexPath!])
            break
            
        case .delete:
            self.collectionView.deleteItems(at: [indexPath!])
            break
        default:
            break
            
        }
    }
    
}
