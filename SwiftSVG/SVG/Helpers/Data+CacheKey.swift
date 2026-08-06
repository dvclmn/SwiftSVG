//
//  Data+CacheKey.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//



import Foundation

extension Data {
    var cacheKey: String {
        return "\(self.hashValue)-\(self.count)"
    }
}
