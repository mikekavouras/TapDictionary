//
//  ScanWordParser.swift
//  TapDictionary
//
//  Created by Michael Kavouras on 12/29/16.
//  Copyright © 2016 Mike Kavouras. All rights reserved.
//

import Foundation
import MicroBlink

struct OCRResultsParser {
    static func parse(_ results: [PPRecognizerResult]) -> [String: NSValue] {
        
        let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines
        let punctuationCharacterSet = CharacterSet.punctuationCharacters
        
        var list: [String: NSValue] = [:]
        
        for result in results {
            guard let ocrResult = result as? PPBlinkOcrRecognizerResult else { continue }
            
            let layout = ocrResult.getOcrLayoutElement("defaultParserGroup.OCRResult")
            guard layout.blocks.count > 0 else { break }
            let lines = layout.blocks[0].lines
            
            typealias Word = [PPOcrChar]
            for line in lines {
                var lineWords = [Word]()
                var word = Word()
                for ch in line.chars {
                    if whitespaceCharacterSet.contains(UnicodeScalar(ch.value)!) || punctuationCharacterSet.contains(UnicodeScalar(ch.value)!) {
                        if word.count > 0 {
                            lineWords.append(word)
                        }
                        word = []
                    } else {
                        word.append(ch)
                    }
                }
                
                for word in lineWords {
                    let key = word.map { $0.description }.joined(separator: "")
                    if let first = word.first,
                        let last = word.last {
                        let ul = first.position.ul
                        let ur = last.position.ur
                        let lr = first.position.lr
                        
                        let x = ul.x / 2.0
                        let y = ul.y / 2.0
                        let width = (ur.x - ul.x) / 2.0
                        let height = lr.y - ur.y
                        let box = CGRect(x: x, y: y, width: width, height: height)
                        let vBox = NSValue(cgRect: box)
                        
                        list[key] = vBox
                    }
                }
            }
        }
        
        return list
    }
}
