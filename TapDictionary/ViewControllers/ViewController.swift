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
    
    var list: [String: NSValue] = [:]
    
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
    
    lazy var scanningViewController: UIViewController? = {
        guard let coordinator = self.coordinator else { return nil }
        return PPViewControllerFactory.cameraViewController(with: self, coordinator: coordinator, error: nil)
    }()
    
    // MARK: - Life cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        if let viewController = scanningViewController {
            present(viewController, animated: false, completion: nil)
        }
    }
    
    
    // MARK: Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        let point = touch.location(in: view)
        
        for (key, value) in list {
            let rect = value.cgRectValue
            if rect.contains(point) {
                print("FOUND: \(key)")
                (scanningViewController as? PPScanningViewController)?.pauseScanning()
              
                UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: key)
                if UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: key) {
                    showDictionary(forWord: key)
                } else {
//                    let guesses = spellCheck(key)
//                    displaySuggestionViewControllerWithSuggestions(guesses)
                    (scanningViewController as? PPScanningViewController)?.resumeScanningAndResetState(false)
                }
            }
        }
    }
    
    private func showDictionary(forWord word: String) {
        let vc = UIReferenceLibraryViewController(term: word)
        scanningViewController?.present(vc, animated: true, completion: nil)
//        scanningViewController?.presentViewController(vc, animated: true, completion: nil)
//            UserDictionary.sharedDictionary.logWordViewed(word)
//        })
    }
}


// MARK: - PPScanningDelegate

extension ViewController: PPScanningDelegate {
    func scanningViewController(_ scanningViewController: UIViewController?, didOutputResults results: [PPRecognizerResult]) {
        guard let viewController = scanningViewController as? PPScanningViewController else { return }
        viewController.pauseScanning()
        
        list = OCRResultsParser.parse(results)
        
        viewController.resumeScanningAndResetState(false)
    }
    
    func scanningViewController(_ scanningViewController: UIViewController, invalidLicenseKeyWithError error: Error) {
        print("poiadsfjapsdlfj")
    }
    func scanningViewControllerUnauthorizedCamera(_ scanningViewController: UIViewController) {
        print("unauthorized")
    }
    
    func scanningViewController(_ scanningViewController: UIViewController, didFindError error: Error) {
        print("\(error)")
    }
    
    func scanningViewControllerDidClose(_ scanningViewController: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
}
