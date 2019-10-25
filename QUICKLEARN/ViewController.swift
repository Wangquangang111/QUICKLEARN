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
    @IBOutlet weak var listBtn: UIBarButtonItem!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var shutterBtn: UIButton!
    @IBOutlet weak var photoTextView: UITextView!
    @IBOutlet weak var translateBtn: UIButton!
    @IBOutlet weak var translateTextView: UITextView!
    @IBOutlet weak var speechBtn: UIButton!
    let syntesizer = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance()
    var language = "en"
    var dataArr = [[String]]()
    let saveDataKey = "languageData"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let data = UserDefaults.standard.array(forKey: saveDataKey) as? [[String]] {
            dataArr = data
        }

        shutterBtn.clipsToBounds = true
        shutterBtn.layer.cornerRadius = 5
        shutterBtn.layer.borderWidth = 1
        shutterBtn.layer.borderColor = UIColor.gray.cgColor

        translateBtn.clipsToBounds = true
        translateBtn.layer.cornerRadius = 5
        translateBtn.layer.borderWidth = 1
        translateBtn.layer.borderColor = UIColor.gray.cgColor

        speechBtn.clipsToBounds = true
        speechBtn.layer.cornerRadius = 5
        speechBtn.layer.borderWidth = 1
        speechBtn.layer.borderColor = UIColor.gray.cgColor

        photoTextView.clipsToBounds = true
        photoTextView.layer.cornerRadius = 5
        photoTextView.layer.borderWidth = 1
        photoTextView.layer.borderColor = UIColor.gray.cgColor
        photoTextView.isEditable = false

        translateTextView.clipsToBounds = true
        translateTextView.layer.cornerRadius = 5
        translateTextView.layer.borderWidth = 1
        translateTextView.layer.borderColor = UIColor.gray.cgColor
        translateTextView.isEditable = false

    }

    @IBAction func historyAction(_ sender: UIBarButtonItem) {


    }

    @IBAction func shutterAction(_ sender: Any) {
        showCamera()
    }

    @IBAction func translateAction(_ sender: Any) {
        if let text = photoTextView.text, text.count > 0 {
            self.requestNewText(language: language, text: text)
        }
    }

    @IBAction func speechAction(_ sender: Any) {
        let string = translateTextView.text ?? ""
        utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice.init(language: "zh-CN")
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
                print(responseString)
            } else {
                print("request failed: \(String(describing: error))")
            }
        })
        dataTask.resume()
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
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { [weak self] (data, response, error) -> Void in
            guard let self = self else { return }
            if let data = data, let text = self.getTranslateText(data: data) {
                DispatchQueue.main.async {
                    self.translateTextView.text = text
                    if let str = self.photoTextView.text, str.count > 0 {
                        self.dataArr.insert([str, text], at: 0)
                        self.saveData()
                    }
                }
            } else {
                print("request failed")
            }
        })
        dataTask.resume()
    }

    func dataToJSON(data: Data) -> AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
        } catch {
            print(error)
        }
        return nil
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

    func getTranslateText(data: Data) -> String? {
        if let d =  try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Array<Any>,
            let s = d.first as? [String: Any], let arr = s["translations"] as? [[String: Any]] {
            return arr.first?["text"] as? String
        }
        return nil
    }

    func saveData() {
        UserDefaults.standard.set(dataArr, forKey: saveDataKey)
        UserDefaults.standard.synchronize()
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let img = info[.originalImage] as? UIImage else { return }
        picker.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            self.photoView.image = img
        }
        requestImage(image: img) { [weak self] (model) in
            if let self = self {
                DispatchQueue.main.async {
                    self.photoTextView.text = self.getImageText(model: model)
                }
                print("photoTextView: \(self.photoTextView.text ?? "")")
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
