//
//  pngquantTests.swift
//  pngquantTests
//
//  Created by Guy Pascarella on 1/20/20.
//  Copyright © 2020 Jenever, LLC. All rights reserved.
//

import XCTest
@testable import pngquant

class pngquantTests: XCTestCase {

    private static let fileName = "1024px-Da_Vinci_Vitruve_Luc_Viatour";
    private static let fileType = "png"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testQuantize4() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let file = loadFile(fileName: pngquantTests.fileName, fileType: pngquantTests.fileType);
        let image = UIImage(contentsOfFile: file!);
        print("Testing Quantization(4): Begin");
        var newImage:UIImage? = nil;
        let start = Date();
//        self.measure {
//            do {
                newImage = try PngQuantizer.quantize(image!, 4);
//            } catch {
//                print("Error: \(error)");
//            }
//        }
        print("Quantization(16) took \(Date().timeIntervalSince(start)) s")
        if let pngData = newImage?.pngData() {
            let filename = getDocumentsDirectory().appendingPathComponent("quantize4.png")
            print("Saving \(filename)");
            try? pngData.write(to: filename)
        }
        if let jpgData = newImage?.jpegData(compressionQuality: 0.75) {
            let filename = getDocumentsDirectory().appendingPathComponent("quantize4.jpg")
            print("Saving \(filename)");
            try? jpgData.write(to: filename)
        }
        print("Testing Quantization(4): End");
    }

    func testQuantize16() throws {
        let file = loadFile(fileName: pngquantTests.fileName, fileType: pngquantTests.fileType);
        let image = UIImage(contentsOfFile: file!);
        print("Testing Quantization(16): Begin");
        var newImage:UIImage? = nil;
        let start = Date();
//        self.measure {
//            do {
                newImage = try PngQuantizer.quantize(image!, 16);
//            } catch {
//                print("Error: \(error)");
//            }
//        }
        print("Quantization(16) took \(Date().timeIntervalSince(start)) s")
        if let pngData = newImage?.pngData() {
            let filename = getDocumentsDirectory().appendingPathComponent("quantize16.png")
            print("Saving \(filename)");
            try? pngData.write(to: filename)
        }
        if let jpgData = newImage?.jpegData(compressionQuality: 0.75) {
            let filename = getDocumentsDirectory().appendingPathComponent("quantize16.jpg")
            print("Saving \(filename)");
            try? jpgData.write(to: filename)
        }
        print("Testing Quantization(16): End");
    }

    func testReencodeJpeg() throws {
        let file = loadFile(fileName: pngquantTests.fileName, fileType: pngquantTests.fileType);
        let image = UIImage(contentsOfFile: file!);
        print("Testing JPG Quantization: Begin");
        let newImage = image;// try PngQuantizer.quantize(image!, 4);
        if let data = newImage?.jpegData(compressionQuality: 0.75) {
            let filename = getDocumentsDirectory().appendingPathComponent("reencode.jpg")
            print("Saving \(filename)");
            try? data.write(to: filename)
        }
        print("Testing JPG Quantization: End");
    }

    func loadFile(fileName: String, fileType: String) -> String? {
        let bundle = Bundle(for: type(of: self))
        return bundle.path(forResource: fileName, ofType: fileType)!
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}
