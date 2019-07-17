//
//  ImageStore.swift
//  Fit Timer
//
//  Created by User 1 on 10/13/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit
import SDWebImage

class ImageStore {
    
    let cache = NSCache<NSString, UIImage>()
    let gifcache = SDImageCache()
    
    func setGifImage(_ image: UIImage?, forKey key: String) {
        gifcache.store(image, forKey: key, completion: nil)
        
    }
    func gifImage(forKey key: String) -> UIImage? {
        return gifcache.imageFromDiskCache(forKey: key)
    }
    func deleteGifImage(forKey key: String) {
        gifcache.removeImage(forKey: key, withCompletion: nil)
    }
    
    /*
     These three methods all take in a key of type String so that
     the rest of your codebase does not have to think about the
     underlying implementation of NSCache. You then cast each String
     to an NSString when passing it to the cache.
     */
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }

}
