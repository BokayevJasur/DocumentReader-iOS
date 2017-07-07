//
//  ViewController.swift
//  DocumentReaderSwift-sample
//
//  Created by Dmitry Smolyakov on 6/13/17.
//  Copyright © 2017 Dmitry Smolyakov. All rights reserved.
//

import UIKit
import DocumentReader

class ViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var documentImage: UIImageView!

    // Use this code for recognize on photo from camera
    @IBAction func useCameraViewController(_ sender: UIButton) {

        //initialize license
        guard let dataPath = Bundle.main.path(forResource: "regula.license", ofType: nil) else { return }
        guard let licenseData = try? Data(contentsOf: URL(fileURLWithPath: dataPath)) else { return }

        //create DocReader object
        let docReader = DocReader()

        //initialize DocReader, long operation
        var error: NSError? = nil
        let initializeCompleted = docReader.initializeReader(license: licenseData, error: &error)
        guard initializeCompleted else {
            print("DocReader not initialized with error: \(error?.localizedDescription ?? "Unwnown error")")
            return
        }

        //setup DocReader
        docReader.processParams.mrz = true
        docReader.processParams.ocr = true
        docReader.processParams.locate = true

        //start recognize
        docReader.showScanner(self) { (action, result, error) in
            switch action {
            case .cancel:
                print("Cancelled by user")
            case .complete:
                print("Completed")
                guard let result = result else { return }
                print("Result class: \(result)")
                // use fast getValue method
                let name = result.getTextFieldValueByType(fieldType: .ft_Surname_And_Given_Names)
                print("NAME: \(name ?? "empty field")")
                self.nameLabel.text = name
                self.documentImage.image = result.getGraphicFieldImageByType(fieldType: .gf_DocumentFront, source: .rawImage)
            case .error:
                print("Error")
                guard let error = error else { return }
                print("Error string: \(error)")
            case .process:
                guard let result = result else { return }
                print("Scaning not finished. Result: \(result)")
            }
        }
    }

    // Use this code for recognize on photo from gallery
    @IBAction func useRecognizeImageMethod(_ sender: UIButton) {

        //initialize license
        guard let dataPath = Bundle.main.path(forResource: "regula.license", ofType: nil) else { return }
        guard let licenseData = try? Data(contentsOf: URL(fileURLWithPath: dataPath)) else { return }

        //load image from assets folder
        guard let image = UIImage(named: "testPhoto") else { return }

        //create DocReader object
        let docReader = DocReader()

        //setup DocReader
        docReader.processParams.mrz = true
        docReader.processParams.ocr = true
        docReader.processParams.locate = true

        //initialize DocReader, long operation
        var error: NSError? = nil
        let initializeCompleted = docReader.initializeReader(license: licenseData, error: &error)
        guard initializeCompleted else {
            print("DocReader not initialized with error: \(error?.localizedDescription ?? "Unwnown error")")
            return
        }

        //start recognize
        docReader.recognizeImage(image, completion: { (action, result, error) in
            if action == .complete {
                if result != nil {
                    print("Completed")
                    print("Result class: \(result!)")

                    // use fast getValue method
                    let name = result!.getTextFieldValueByType(fieldType: .ft_Surname_And_Given_Names)
                    print("NAME: \(name ?? "empty field")")
                    self.nameLabel.text = name
                    self.documentImage.image = result?.getGraphicFieldImageByType(fieldType: .gf_DocumentFront, source: .rawImage)
                } else {
                    print("Completed without result")
                }
            } else if action == .error {
                print("Eror")
                guard let error = error else { return }
                print("Eror: \(error)")
            }
        })
    }
}
