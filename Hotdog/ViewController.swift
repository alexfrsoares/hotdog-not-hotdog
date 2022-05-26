//
//  ViewController.swift
//  Hotdog
//
//  Created by Alex Freitas on 26/05/2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage

            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage into CIImage.")
            }

            detectImage(ciImage)
        }

        imagePicker.dismiss(animated: true)
    }

    func detectImage(_ image: CIImage) {
        let config = MLModelConfiguration()
        guard let coreMLModel = try? Inceptionv3(configuration: config),
              let visionModel = try? VNCoreMLModel(for: coreMLModel.model) else {
            fatalError("Loading CoreML model failed.")
        }

        let request = VNCoreMLRequest(model: visionModel) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model fail to process image.")
            }

            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }

        let handler = VNImageRequestHandler(ciImage: image)

        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true)
    }

}

