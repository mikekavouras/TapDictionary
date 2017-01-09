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
    static func parse(_ results: [PPRecognizerResult]) -> [AnyHashable: AnyObject] {
        
        for result in results {
            guard let ocrResult = result as? PPBlinkOcrRecognizerResult else { continue }
            print("OCR results are:")
            print("Raw ocr: \(ocrResult.parsedResult(forName: "RawOcr"))")
            
            let layout = ocrResult.getOcrLayoutElement("defaultParserGroup.OCRResult")
            print("Dimensions of ocrLayout are \(NSStringFromCGRect(layout.box))")
        }
        
        return [:]
    }
}
