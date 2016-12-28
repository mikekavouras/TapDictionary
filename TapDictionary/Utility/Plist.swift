//
//  Plist.swift
//  Glowb
//
//  Created by Michael Kavouras on 12/9/16.
//  Copyright © 2016 Michael Kavouras. All rights reserved.
//

struct Plist {
    struct Config: PlistReadable {
        static var plistName = "Configuration"
        static var apiKey = Config.unsafeString("OCR_API_KEY")
    }
}
