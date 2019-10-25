//
//  QUICKLEARNTests.swift
//  QUICKLEARNTests
//
//  Created by  wangquangang on 2019/10/24.
//  Copyright © 2019 wangquangang. All rights reserved.
//

import XCTest
@testable import QUICKLEARN
import ObjectMapper

class QUICKLEARNTests: XCTestCase {
    var vc = ViewController()
    var hvc = HistoryListViewController()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: type(of: self)))
        vc = storyboard.instantiateViewController(withIdentifier: "viewcontroller") as! ViewController
        vc.loadView()
        vc.viewDidLoad()

        hvc = storyboard.instantiateViewController(withIdentifier: "historylistviewcontroller") as! HistoryListViewController
        hvc.loadView()
        hvc.viewDidLoad()

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

    }

    func testCameraAuthorization() {
        XCTAssertTrue(vc.cameraAuthorization() == true)
    }

    func testTranslation() {
        let headers = [
            "Ocp-Apim-Subscription-Key": "f2c2cfaca25b4bca97edfce0a3610d82",
            "Content-Type": "application/json",
            "cache-control": "no-cache",
        ]

        let postData = "[{'text': 'hello'}]".data(using: String.Encoding.utf8)!

        let request = NSMutableURLRequest(url: URL(string: "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from=en&to=zh-Hans")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { [weak self] (data, response, error) -> Void in
            guard let self = self else { return }
            if let data = data, let text = self.vc.getTranslateText(data: data) {
                XCTAssertTrue(text == "你好")
            }
        })
        dataTask.resume()
    }

    func testImage() {
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
        if let image = UIImage(named: "hello") {
            request.httpBody = self.vc.createBody(parameters: [:],
                                                  boundary: boundary,
                                                  data: image.jpegData(compressionQuality:0.5)!,
                                                  mimeType: "image/JPG",
                                                  filename: "")
        }

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if error == nil, let responseString = String(data: data!, encoding: String.Encoding.utf8), let model = Mapper<Model>().map(JSONString: responseString) {
                XCTAssertTrue(self.vc.getImageText(model: model) == "hello ")
            }
        })
        dataTask.resume()
    }

    func testHasSearchString() {
        XCTAssertTrue(hvc.hasSearchString(data: ["hello", "world"], text: "d") == true)
    }

    func testSearchArr() {
        let array = [["h", "w"], ["he", "wo"], ["hel", "wor"], ["hell", "worl"], ["hello", "world"]]
        var result = [[String]]()
        for data in array {
            if hvc.hasSearchString(data: data, text: "d") {
                result.append(data)
            }
        }
        XCTAssertTrue(result == [["hello", "world"]])
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
