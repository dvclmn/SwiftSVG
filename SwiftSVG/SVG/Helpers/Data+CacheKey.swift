//
//  Data+CacheKey.swift
//  SwiftSVG
//
//
//  Copyright (c) 2017 Michael Choe
//  http://www.github.com/mchoe
//  http://www.straussmade.com/
//  http://www.twitter.com/_mchoe
//



import Foundation

extension Data {
    var cacheKey: String {
        return "\(self.hashValue)-\(self.count)"
    }
}
