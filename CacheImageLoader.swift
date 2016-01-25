//
//  ImageLoader.swift
//  extension
//
//  Created by Nate Claudio on 4/5/15.
//
import UIKit
import Foundation


class CacheImageLoader {
    
    let cache = NSCache()

    class var sharedLoader : CacheImageLoader {
    struct Static {
        static let instance : CacheImageLoader = CacheImageLoader()
        }
        return Static.instance
    }
    
    
	func imageForUrl(urlString: String, completionHandler:(image: UIImage?, url: String) -> ()) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {()in
			let data: NSData? = self.cache.objectForKey(urlString) as? NSData
			
			if let goodData = data {
				let image = UIImage(data: goodData)
				dispatch_async(dispatch_get_main_queue(), {() in
					completionHandler(image: image, url: urlString)
				})
				return
			}
			
			let downloadTask: NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
				if (error != nil) {
					completionHandler(image: nil, url: urlString)
					return
				}
				
				if let data = data {
					let image = UIImage(data: data)
					self.cache.setObject(data, forKey: urlString)
					dispatch_async(dispatch_get_main_queue(), {() in
						completionHandler(image: image, url: urlString)
					})
					return
				}
				
			})
			downloadTask.resume()
		})
		
	}
}