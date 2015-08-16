//
//  ViewController.swift
//  RACPhotos
//
//  Created by Alejandro Martínez on 08/15/2015.
//  Copyright (c) 2015 Alejandro Martínez. All rights reserved.
//

import UIKit

import RACPhotos

// why I need to import Photos and RAC?
import Photos
import ReactiveCocoa

public func flatMap<T, U, E>(transform: T -> SignalProducer<U, E>) -> SignalProducer<T, E> -> SignalProducer<U, E> {
    return flatMap(FlattenStrategy.Latest, transform)
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
        let createAndFetch = PHAssetCollection.createCollectionWithTitle(title)
            |> flatMap { identifier in PHAssetCollection.fetchCollectionWithIdentifier(identifier) }
        
        // Retrieves the album with the given title. New or already created!
        let retreiveAlbum = fetch |> catch { _ in createAndFetch }
        
        auth
            |> flatMap { _ in
                retreiveAlbum
            }
            |> flatMap { collection in
                PHPhotoLibrary.saveImage(image, toCollection: collection)
            }
            |> start(
                error: {error in
                    println("Error \(error)")
                },
                completed: {
                    println("Image Saved")
                },
                interrupted: { println("Interrupted") },
                next: { println("Next")})
    }
}

