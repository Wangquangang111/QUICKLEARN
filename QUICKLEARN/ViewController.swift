//
//  ViewController.swift
//  QUICKLEARN
//
//  Created by  wangquangang on 2019/10/24.
//  Copyright © 2019 wangquangang. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import ObjectMapper

class ViewController: UIViewController {
    let textView = UITextView()
    let syntesizer = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance()
    let btn = UIButton()
    var language = "en"
    var imageText = ""
    var newText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        btn.setTitle("add", for: .normal)
        btn.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        btn.backgroundColor = UIColor.red
        btn.addTarget(self, action: #selector(runs), for: .touchUpInside)
        view.addSubview(btn)
    }

    @objc func runs() {
        let string = "我的天啊我的不是健康的山东黄金大客户达科技"
        utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice.init(language: "zh-CN")
        utterance.rate = 0.1
        syntesizer.speak(utterance)
//        self.requestNewText(language: language, text: imageText)

    }

    @IBAction func play(_ sender: UIButton) {
        let string = textView.text ?? ""
        utterance = AVSpeechUtterance(string: string)
        utterance.rate = 0.1
        syntesizer.speak(utterance)
    }

}

extension ViewController {
    func showCamera() {
        guard cameraAuthorization() else {
            return
        }
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alert = UIAlertController.init(title: nil, message: "This device doesn't support the camera", preferredStyle: .alert)
            let action = UIAlertAction.init(title: "sure", style: .default) { (_) in }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.navigationBar.isTranslucent = false
        present(imagePickerController, animated: true, completion: nil)
    }

    func cameraAuthorization() -> Bool {
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            let alert = UIAlertController.init(title: "Unable to access your camera", message: "Please enable camera permissions in the system settings and allow QUICKLEARN to access your camera.", preferredStyle: .alert)
            let action = UIAlertAction.init(title: "sure", style: .default) { (_) in }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }

    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()

        let boundaryPrefix = "--\(boundary)\r\n"

        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))

        return body as Data
    }

    func requestImage(image: UIImage, completion: @escaping (Model)->Void) {
        let headers = [
            "Ocp-Apim-Subscription-Key": "edc194d0c5a6433a8fe7d781838d0061",
            "Content-Type": "application/json",
            "cache-control": "no-cache",
        ]
        var request = URLRequest(url: URL(string: "https://eastus.api.cognitive.microsoft.com/vision/v2.0/ocr?language=unk&detectOrientation=true")! as URL,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBody(parameters: [:],
                                boundary: boundary,
                                data: image.jpegData(compressionQuality:0.5)!,
                                mimeType: "image/JPG",
                                filename: "")

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if error == nil, let responseString = String(data: data!, encoding: String.Encoding.utf8), let model = Mapper<Model>().map(JSONString: responseString) {
                completion(model)
            } else {
                print("request failed: \(String(describing: error))")
            }
        })
        dataTask.resume()
    }

    func getImageText(model: Model) -> String {
        var imageText = ""
        if let regions = model.regions {
            for region in regions {
                if let lines = region.lines {
                    for line in lines {
                        var str = ""
                        if let words = line.words {
                            for word in words {
                                if let text = word.text {
                                    str += "\(text) "
                                }
                            }
                        }
                        if str.count > 0 {
                            imageText += "\(str)\n"
                        }
                    }
                }
            }
        }
        return imageText
    }

    func requestNewText(language: String, text: String) {
        let headers = [
            "Ocp-Apim-Subscription-Key": "f2c2cfaca25b4bca97edfce0a3610d82",
            "Content-Type": "application/json",
            "cache-control": "no-cache",
        ]

        let postData = "[{'text': '\(text)'}]".data(using: String.Encoding.utf8)!

        let request = NSMutableURLRequest(url: URL(string: "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from=\(language)&to=zh-Hans")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if error == nil, let responseString = String(data: data!, encoding: String.Encoding.utf8) {
                print(responseString)
            } else {
                print("request failed: ", terminator: "")
            }
        })
        dataTask.resume()
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let img = info[.originalImage] as? UIImage else { return }
        picker.dismiss(animated: true, completion: nil)
        requestImage(image: img) { [weak self] (model) in
            if let self = self {
                self.imageText = self.getImageText(model: model)
                self.requestNewText(language: model.language ?? "en", text: self.imageText)
                print("imageText: \(self.imageText)")
            }
        }
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
