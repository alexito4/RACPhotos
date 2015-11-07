//
//  ViewController.swift
//  RACPhotos
//
//  Created by Alejandro Martínez on 08/15/2015.
//  Copyright (c) 2015 Alejandro Martínez. All rights reserved.
//

import UIKit
import Photos
import ReactiveCocoa
import RACPhotos

extension SignalProducer {
    public func flatMap<U>(transform: T -> ReactiveCocoa.SignalProducer<U, E>) -> ReactiveCocoa.SignalProducer<U, E> {
        return self.flatMap(FlattenStrategy.Latest, transform: transform)
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "image.jpg")!
        saveImage(image)
    }
    
    func saveImage(image: UIImage) {
        let title = "Wallpapers"
        
        // Request authorization
        let auth = PHPhotoLibrary.requestAuthorization()
        
        // Fetch for a collection with the given title
        let fetch = PHAssetCollection.fetchCollectionWithTitle(title)
        
        // Creates and fetches a new collection with the given title
        let createAndFetch = PHAssetCollection.createCollectionWithTitle(title).flatMap { identifier in PHAssetCollection.fetchCollectionWithIdentifier(identifier)
        }
        
        // Retrieves the album with the given title. New or already created!
        let retreiveAlbum = fetch.flatMapError { _ in createAndFetch }
        
        auth.flatMap { _ in
                retreiveAlbum
            }.flatMap { collection in
                PHPhotoLibrary.saveImage(image, toCollection: collection)
            }.on(error: { error in
                    print("Error \(error)")
                }, completed: {
                    print("Image Saved")
                }, interrupted: {
                    print("Interrupted")
                }, next: {
                    print("Next")
                }
            ).start()
    }
    
}

