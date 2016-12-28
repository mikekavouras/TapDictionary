//
//  ViewController.swift
//  TapDictionary
//
//  Created by Michael Kavouras on 12/28/16.
//  Copyright © 2016 Mike Kavouras. All rights reserved.
//

import UIKit
import MicroBlink


class ViewController: UIViewController {
    
    var list: [AnyHashable: NSValue] = [:]
    
    lazy var coordinator: PPCameraCoordinator? = {
        var error: NSError?
        guard !PPCameraCoordinator.isScanningUnsupported(for: .back, error: &error) else {
            return nil 
        }
        
        let settings = PPSettings()
        settings.licenseSettings.licenseKey = Plist.Config.apiKey
        settings.uiSettings.showCloseButton = false
        
        let recognizerSettings = PPBlinkOcrRecognizerSettings()
        recognizerSettings.addOcrParser(PPRawOcrParserFactory(), name: "RawOcr")
        
        settings.scanSettings.add(recognizerSettings)
        
        let c = PPCameraCoordinator(settings: settings, delegate: nil)
        c.setScanningRegion(self.view.frame)
        return c
    }()
    
    
    // MARK: - Life cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let coordinator = coordinator else { return }
        
        let scanningViewController = PPViewControllerFactory.cameraViewController(with: self, coordinator: coordinator, error: nil)
        present(scanningViewController, animated: true, completion: nil)
    }
    
    
    // MARK: Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        let point = touch.location(in: view)
        
        for (key, value) in list {
            let rect = value.cgRectValue
            if rect.contains(point) {
//                (scanningViewController as? PPScanningViewController)?.pauseScanning()
              
                print(key)
//                if UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: key) {
//                    showDefinitionForWord(key)
//                } else {
//                    let guesses = spellCheck(key)
//                    displaySuggestionViewControllerWithSuggestions(guesses)
//                }
            }
        }
    }
}


// MARK: - PPScanningDelegate

extension ViewController: PPScanningDelegate {
    func scanningViewController(_ scanningViewController: UIViewController?, didOutputResults results: [PPRecognizerResult]) {
        guard let viewController = scanningViewController as? PPScanningViewController else { return }
        viewController.pauseScanning()
        
        for result in results {
            guard let ocrResult = result as? PPBlinkOcrRecognizerResult else { continue }
            print("OCR results are:")
            print("Raw ocr: \(ocrResult.parsedResult(forName: "RawOcr"))")
            
            let layout = ocrResult.ocrLayout()
            print(layout)
            print("Dimensions of ocrLayout are \(NSStringFromCGRect(layout.box))")
        }
        
        viewController.resumeScanningAndResetState(false)
    }
    
    func scanningViewControllerUnauthorizedCamera(_ scanningViewController: UIViewController) {}
    
    func scanningViewController(_ scanningViewController: UIViewController, didFindError error: Error) {}
    
    func scanningViewControllerDidClose(_ scanningViewController: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
}
