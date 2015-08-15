//
//  RAC_PHPhotoLibrary.swift
//  Originally build for BWallpapers.
//  http://alejandromp.com/bwallpapers/
//
//  Created by Alejandro Martinez on 21/6/15.
//  Copyright (c) 2015 Alejandro Martinez. All rights reserved.
//

import Foundation
import Photos
import ReactiveCocoa

public enum RACPhotosError: ErrorType {
    case NotAuthorized(status: PHAuthorizationStatus)
    case CollectionCreationFailed
    case CollectionNotFound
    case PhotoSaveFailed
    
    public var nsError: NSError {
        return NSError(domain: "RACPhotosError", code: 0, userInfo: nil)
    }
}

// Sends next event and inmediatly completes the Signal.
// Usefoul for Signals that only have one event.
private func sendNextAndComplete<T, E>(sink: SinkOf<Event<T, E>>, value: T) {
    sendNext(sink, value)
    sendCompleted(sink)
}

// MARK: Authorization

extension PHPhotoLibrary {
    
    public class func requestAuthorization() -> SignalProducer<PHAuthorizationStatus, RACPhotosError> {
        return SignalProducer { sink, disposable in
            
            let status = PHPhotoLibrary.authorizationStatus()
            
            switch status {
            case .NotDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                    switch (status) {
                    case .Authorized:
                        sendNextAndComplete(sink, status)
                    default:
                        sendError(sink, RACPhotosError.NotAuthorized(status: status))
                    }
                })
            case .Restricted, .Denied:
                sendError(sink, RACPhotosError.NotAuthorized(status: status))
            case .Authorized:
                sendNextAndComplete(sink, status)
            }
            
        }
    }
    
}

// MARK: Images

extension PHPhotoLibrary {
    
    public class func saveImage(image: UIImage, toCollection album: PHAssetCollection) -> SignalProducer<Void, RACPhotosError> {
        return PHPhotoLibrary.sharedPhotoLibrary().saveImage(image, toCollection: album)
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
                        sendNextAndComplete(sink, Void())
                    } else {
                        sendError(sink, RACPhotosError.PhotoSaveFailed)
                    }
            })
        }
    }
    
}

// MARK: Collections

extension PHPhotoLibrary {
    
    public func createCollectionWithTitle(title: String) -> SignalProducer<String, RACPhotosError> {
        return SignalProducer { sink, disposable in
            
            var identifier: String?
            
            self.performChanges({ () -> Void in
                
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(title)
                
                identifier = request.placeholderForCreatedAssetCollection.localIdentifier
                
            }, completionHandler: { (completed, error) -> Void in
                if completed {
                    if let identifier = identifier {
                        sendNextAndComplete(sink, identifier)
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
    
    public class func createCollectionWithTitle(title: String) -> SignalProducer<String, RACPhotosError> {
        return PHPhotoLibrary.sharedPhotoLibrary().createCollectionWithTitle(title)
    }
    
    public class func fetchCollectionWithIdentifier(identifier: String) -> SignalProducer<PHAssetCollection, RACPhotosError> {
        return SignalProducer { sink, disposable in
            let result = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([identifier], options: nil)
            let album = result.firstObject as? PHAssetCollection
            
            if let album = album {
                sendNextAndComplete(sink, album)
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
                sendNextAndComplete(sink, album)
            } else {
                sendError(sink, RACPhotosError.CollectionNotFound)
            }
        }
    }
}



