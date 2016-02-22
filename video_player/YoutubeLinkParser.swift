//
//  YoutubeLinkParser.swift
//  video_player
//
//  Created by kemal enver on 16/02/2016.
//  Copyright © 2016 kemal enver. All rights reserved.
//

import Foundation

extension String {
    
    func stringByDecodingURLFormat() -> String? {
        
        let result = self.stringByReplacingOccurrencesOfString("+", withString: " ")
        
        return result.stringByRemovingPercentEncoding
    }
    
    func dictionaryFromQueryStringComponents() -> Dictionary<String, Array<String>> {
        
        var paramaters = Dictionary<String, Array<String>>()
        
        for keyValue in self.componentsSeparatedByString("&") {
            
            var kv = keyValue.componentsSeparatedByString("=")
            
            if kv.count < 2 {
                continue
            }
            
            if let key = kv[0].stringByDecodingURLFormat(),
                value = kv[1].stringByDecodingURLFormat() {
                    
                    var results = paramaters[key]
                    
                    if results == nil {
                        
                        results = Array<String>()
                        paramaters[key] = results
                    }
                    
                    results?.append(value)
            }
        }

        return paramaters
    }
}

extension NSURL {
    
    func dictionaryForQueryString() -> Dictionary<String, Array<String>> {
        
        if let query = self.query {
            
            return query.dictionaryFromQueryStringComponents()
        }
        
        return Dictionary<String, Array<String>>()
    }
}