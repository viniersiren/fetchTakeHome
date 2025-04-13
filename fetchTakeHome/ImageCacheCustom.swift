//
//  ImageCacheCustom.swift
//  fetchTakeHome
//
//  Created by Devin Studdard on 4/12/25.
//

import UIKit
import CommonCrypto //sha

actor ImageCache {
    static let shared = ImageCache()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private var inMemoryCache = NSCache<NSString, UIImage>()
    
    init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("RecipeImages", isDirectory: true)
        createCacheDirectory()
    }
    
    private func createCacheDirectory() {
        guard !fileManager.fileExists(atPath: cacheDirectory.path) else { return }
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func image(for url: URL) async -> UIImage? {
        let key = url.absoluteString.sha256() //save unique
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        if let cachedImage = inMemoryCache.object(forKey: key as NSString) {
            return cachedImage
        }
        //if previously cached
        if let diskImage = UIImage(contentsOfFile: fileURL.path) {
            inMemoryCache.setObject(diskImage, forKey: key as NSString)
            return diskImage
        }
        
        //cache + download
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            inMemoryCache.setObject(image, forKey: key as NSString)
            try data.write(to: fileURL)
            
            return image
        } catch {
            return nil
        }
    }
}

//fixes previous bug that every image saved to the same place
extension String {
    func sha256() -> String {
        let data = Data(self.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
