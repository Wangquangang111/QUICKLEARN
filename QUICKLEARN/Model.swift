//
//  Model.swift
//  QUICKLEARN
//
//  Created by  wangquangang on 2019/10/24.
//  Copyright © 2019 wangquangang. All rights reserved.
//

import Foundation
import ObjectMapper

class Model: NSObject, Mappable{
    var language: String?
    var orientation: String?
    var regions: [Region]?
    var textAngle: Float?

    required init?(map: Map){}

    func mapping(map: Map) {
        language <- map["language"]
        orientation <- map["orientation"]
        regions <- map["regions"]
        textAngle <- map["textAngle"]
    }
}

class Region: NSObject, Mappable{
    var boundingBox: String?
    var lines: [Line]?

    required init?(map: Map){}

    func mapping(map: Map) {
        boundingBox <- map["boundingBox"]
        lines <- map["lines"]
    }
}

class Line: NSObject, Mappable{
    var boundingBox: String?
    var words: [Word]?

    required init?(map: Map){}

    func mapping(map: Map) {
        boundingBox <- map["boundingBox"]
        words <- map["words"]
    }
}

class Word: NSObject, Mappable{
    var boundingBox: String?
    var text: String?

    required init?(map: Map){}

    func mapping(map: Map) {
        boundingBox <- map["boundingBox"]
        text <- map["text"]
    }
}

class TranslationModel : NSObject, Mappable{
    var translations: [Translation]?

    required init?(map: Map){}

    func mapping(map: Map){
        translations <- map["translations"]
    }
}

class Translation: NSObject, Mappable{
    var text: String?
    var to: String?

    required init?(map: Map){}

    func mapping(map: Map){
        text <- map["text"]
        to <- map["to"]
    }

}
