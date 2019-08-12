//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Jerry Hanks on 12/08/2019.
//  Copyright © 2019 Jerry. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var noImageLabel: UILabel!
    
    
    var dataController : DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.configureCollectionView()
        self.configureMap()
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
    
    private func configureMap(){
        self.mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func onNewCollectonButtonClicked(_ sender: UIButton) {
    }
    

    private func toggleNoImageLabel(_ show:Bool){
        self.noImageLabel.isEnabled = !show
        self.collectionView.isHidden = show
    }
}


//MapView delegate
extension PhotoAlbumViewController : MKMapViewDelegate{
    
}


class AlbumViewCell: UICollectionViewCell {
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
}


//CollectionView Datasource
extension PhotoAlbumViewController : UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AlbumViewCell.self), for: indexPath) as! AlbumViewCell
        
        return cell
    }
}


extension PhotoAlbumViewController : UICollectionViewDelegate{
    
}
