//
//  RAC_PHPhotoLibrary.swift
//  BWallpapers
//
//  Created by Alejandro Martinez on 21/6/15.
//  Copyright (c) 2015 Alejandro Martinez. All rights reserved.
//

import Foundation
import Photos
import ReactiveCocoa

// I would like all of this to be SignalProducers but flatMap only requieres a SignalProducer, and i don´t know any other way of combining SignalProducers.
// All the Error types on SignalProducers have to be of the same type? it's not enoguht to be of the protocol?

public enum RACPhotosError: ErrorType {
    case NotAuthorized(status: PHAuthorizationStatus)
    case CollectionCreationFailed
    case CollectionNotFound
    case PhotoSaveFailed
    
    public var nsError: NSError {
        return NSError(domain: "RACPhotosError", code: 0, userInfo: nil)
    }
}

extension PHPhotoLibrary {
    
    public class func requestAuthorization() -> SignalProducer<PHAuthorizationStatus, RACPhotosError> {
        return SignalProducer { sink, disposable in
            
            let status = PHPhotoLibrary.authorizationStatus()
            
            switch status {
            case .NotDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                    switch (status) {
                    case .Authorized:
                        sendNext(sink, status)
                        sendCompleted(sink)
                    default:
                        sendError(sink, RACPhotosError.NotAuthorized(status: status))
                    }
                })
            case .Restricted, .Denied:
                sendError(sink, RACPhotosError.NotAuthorized(status: status))
            case .Authorized:
                sendNext(sink, status)
                sendCompleted(sink)
            }
            
        }
    }
    
    public func saveImage(image: UIImage, toCollection album: PHAssetCollection) -> SignalProducer<Void, RACPhotosError> {
        return SignalProducer { sink, disposable in
            self.performChanges({ () -> Void in
                
                let request = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                let asset = request.placeholderForCreatedAsset
                
                let albumRequest = PHAssetCollectionChangeRequest(forAssetCollection: album)
                albumRequest.addAssets([asset])
                
            }, completionHandler: { (completed, error) -> Void in
                if completed {
                    sendNext(sink, Void())
                    sendCompleted(sink)
                } else {
                    sendError(sink, RACPhotosError.PhotoSaveFailed)
                }
            })
        }
    }
    
    public func createCollectionWithTitle(title: String) -> SignalProducer<String, RACPhotosError> {
        return SignalProducer { sink, disposable in
            
            var identifier: String?
            
            self.performChanges({ () -> Void in
                
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(title)
                
                identifier = request.placeholderForCreatedAssetCollection.localIdentifier
                
            }, completionHandler: { (completed, error) -> Void in
                if completed {
                    if let identifier = identifier {
                        sendNext(sink, identifier)
                        sendCompleted(sink)
                    } else {
                        sendError(sink, RACPhotosError.CollectionCreationFailed)
                    }
                } else {
                    sendError(sink, RACPhotosError.CollectionCreationFailed)
                }
                
            })
        }
    }
    
}

extension PHAssetCollection {
    
    public class func fetchCollectionWithIdentifier(identifier: String) -> SignalProducer<PHAssetCollection, RACPhotosError> {
        return SignalProducer { sink, disposable in
            let result = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([identifier], options: nil)
            let album = result.firstObject as? PHAssetCollection
            
            if let album = album {
                sendNext(sink, album)
                sendCompleted(sink)
            } else {
                sendError(sink, RACPhotosError.CollectionNotFound)
            }
        }
    }
    
    public class func fetchCollectionWithTitle(title: String) -> SignalProducer<PHAssetCollection, RACPhotosError> {
        return SignalProducer { sink, disposable in
            
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "title == %@", title)
            
            let result = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: options)
            let album = result.firstObject as? PHAssetCollection
            
            if let album = album {
                sendNext(sink, album)
                sendCompleted(sink)
            } else {
                sendError(sink, RACPhotosError.CollectionNotFound)
            }
        }
    }
}



