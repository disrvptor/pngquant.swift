//
//  PngQuantizer.swift
//  pngquant
//
//  Created by Guy Pascarella on 1/19/20.
//  Copyright © 2020 Jenever, LLC. All rights reserved.
//

import Foundation
import UIKit

public class PngQuantizer {

    private static let debug = false;
    private static func log(_ msg:String) {
        if debug {
            print(msg);
        }
    }

    public enum Errors: Error {
        case InvalidImage
        case OnlySupport32BitImages
        case OnlySupport8BitPerChannel
        case UnableToCreateContext
        case UnableToGetContextData
        case UnableToCreateImage
        case UnableToEncodeImage
    }

    public static func quantize(_ image: UIImage, _ nColors: Int) throws -> UIImage {
        guard var cgImage = image.cgImage else {
            throw Errors.InvalidImage;
        }
        cgImage = try PngQuantizer.quantize(cgImage, nColors);
        return UIImage(cgImage: cgImage);
    }

    public static func quantize(_ image: CGImage, _ nColors: Int) throws -> CGImage {
        log("Quantizing image to \(nColors) colors");
        log("Getting pixels");
        let points = try PngQuantizer.getPixels(image).map({Point(from: $0)});

        log("Clustering");
        let clusters = KMeans.cluster(points: points, into: nColors).sorted(by: {$0.points.count > $1.points.count})
        log("Mapping clusters");
        let newPoints = clusters.map(({$0.center}));

        // Loop over the points and assign to the closest new Point
        log("Mapping pixels to clusters");
        let newPixels = points.map({PngQuantizer.findClosest(for: $0, from: newPoints)});

        var uniqueValues: [Point] = []
        newPixels.forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        log("Detected \(uniqueValues.count) unique colors");

        // Convert each point to a color
        log("Mapping clusters to colors");
        let newColors = newPixels.map(({$0.toUIColor()}));

        // Save the new color map to a CGImage
        log("Setting pixels of image");
        let newImage = try setPixels(image, colors: newColors);

        return newImage;
    }

    private static func findClosest(for p : Point, from points: [Point]) -> Point {
        return points.min(by: {$0.distanceSquared(to: p) < $1.distanceSquared(to: p)})!
    }

    private static func setPixels(_ cgImage: CGImage, colors: [UIColor]) throws -> CGImage {
        let rgbaColors = colors.map(({RGBA32(color: $0)}));

        var indexes = [UInt8]();
        var palette = [RGBA32]();
        for (_, rgba) in rgbaColors.enumerated() {
            var indexC = palette.firstIndex(of: rgba);
            if ( nil == indexC ) {
                // Add the color to the index
                palette.append(rgba);
                indexC = palette.count;
            }
            indexes.append(UInt8(indexC!));
        }

        if ( palette.count < 256/*2^8*/ ) {
            return try setIndexedPixels(cgImage, indexes: indexes, palette: palette);
        }
        return try setRGBAPixels(cgImage, colors: rgbaColors);
    }

    // TODO: Make this create a new CGImage instead of re-using the old
    private static func setRGBAPixels(_ cgImage: CGImage, colors: [RGBA32]) throws -> CGImage {
        log("Using RGBA Color Space");

        var rgbaColors = colors;

        let colorSpace       = CGColorSpaceCreateDeviceRGB();
        let width            = cgImage.width
        let height           = cgImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue

        let cgImage = rgbaColors.withUnsafeMutableBytes { (ptr) -> CGImage in
            let ctx = CGContext(
                data: ptr.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: colorSpace, // CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: bitmapInfo
                )!
            return ctx.makeImage()!
        }

        return cgImage;

//        let buffer = UnsafeMutableBufferPointer<UInt32>.allocate(capacity: size)
//        var result = [UIColor]()
//        result.reserveCapacity(size)
//        for pixel in buffer {
//            var r : UInt32 = 0
//            var g : UInt32 = 0
//            var b : UInt32 = 0
//            if cgImage.byteOrderInfo == .orderDefault || cgImage.byteOrderInfo == .order32Big {
//                r = pixel & 255
//                g = (pixel >> 8) & 255
//                b = (pixel >> 16) & 255
//            } else if cgImage.byteOrderInfo == .order32Little {
//                r = (pixel >> 16) & 255
//                g = (pixel >> 8) & 255
//                b = pixel & 255
//            }
//            let color = UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
//            result.append(color)
//        }
//
//        imageData.from`
//        _ = imageData.copyBytes (to: buffer)
    }

    /// This method creates or sets the indexed pixels for a given CGImage
    /// - Parameters:
    ///     - cgImage: source image
    ///     - indexes: single-dimension array of pixels and their index in the palette
    ///     - palette: list of colors that indexes points to
    /// - Returns: CGImage of the indexed color data
    /// - Throws: on any Error
    private static func setIndexedPixels(_ cgImage: CGImage, indexes: [UInt8], palette: [RGBA32]) throws -> CGImage {
        log("Using Indexed Color Space");
        log("Mapped an Indexed Color Space of \(palette.count) colors");

        // Create a temporary file
//        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
//        let temporaryFilename = ProcessInfo().globallyUniqueString
//        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
//        let temporaryFile = temporaryFileURL.absoluteString
        let temporaryFile = "\(NSTemporaryDirectory())/\(palette.count)_\(ProcessInfo().globallyUniqueString).png";

        let pngPalette = palette.map({
            return PNG.RGBA($0.red, $0.green, $0.blue, $0.alpha);
        });
        let pngIndices = indexes.map({
            return Int($0);
        });

        var code = PNG.Properties.Format.Code.indexed8;
        if palette.count <= 2/*2^1*/ {
            code = .indexed1;
        } else if palette.count <= 4/*2^2*/ {
            code = .indexed2;
        } else if palette.count <= 16/*2^4*/ {
            code = .indexed4;
        }

        if let _:Void = try? PNG.encode(indices: pngIndices, palette: pngPalette, size: (cgImage.width, cgImage.height), as: code, path: temporaryFile) {
            // Read temporary file into a CGImage and return it
            let uiImage = UIImage(contentsOfFile: temporaryFile);
            guard let img = uiImage?.cgImage else {
                throw Errors.UnableToCreateImage;
            }
            return img;
        } else {
            log("failed to encode image")
            throw Errors.UnableToEncodeImage;
        }

//        let baseColorSpace   = CGColorSpaceCreateDeviceRGB();
//        let size             = baseColorSpace.numberOfComponents*(colorTable.count+1);
//        let colorIndex       = UnsafeMutablePointer<UInt8>.allocate(capacity: size);
//
//        // Reformat the color table
//        for (index, rgba) in colorTable.enumerated() {
//            colorIndex[index*baseColorSpace.numberOfComponents+0] = rgba.red;
//            colorIndex[index*baseColorSpace.numberOfComponents+1] = rgba.green;
//            colorIndex[index*baseColorSpace.numberOfComponents+2] = rgba.blue;
//        }
//
//        let colorSpace       = CGColorSpace(
//                                    indexedBaseSpace: baseColorSpace,
//                                    last: baseColorSpace.numberOfComponents*(colorTable.count+1),
//                                    colorTable: colorIndex);
//        let width            = cgImage.width;
//        let height           = cgImage.height;
//        let bytesPerPixel    = 1;
//        let bitsPerComponent = 8;
//        let bytesPerRow      = bytesPerPixel * width;
//        let bitmapInfo       = CGBitmapInfo.byteOrder32Little.rawValue;// | CGImageAlphaInfo.premultipliedFirst.rawValue;
//
//        print("Color Space: color table count->\(colorSpace?.colorTable?.count), supports output->\(colorSpace?.supportsOutput), name->\(colorSpace?.name), num components->\(colorSpace?.numberOfComponents), color model->\(colorSpace?.model)");
//
//        print("Created a Color Space with a model of \(colorSpace?.model)");
//
        // Grrr - Cannot output indexed color space
        // CGBitmapContextInfoCreate: CGColorSpace does't support output
//
//        var pixels = pixelMap;
//        let cgImage = pixels.withUnsafeMutableBytes { (ptr) -> CGImage in
//            let ctx = CGContext(
//                data: ptr.baseAddress,
//                width: width,
//                height: height,
//                bitsPerComponent: bitsPerComponent,
//                bytesPerRow: bytesPerRow,
//                space: colorSpace!,
//                bitmapInfo: bitmapInfo
//            )!;
//            return ctx.makeImage()!;
//        }
//
//        // Cleanup our custom color space
//        //CGColorSpaceRelease(colorSpace!);
//
//        return cgImage;
    }

    private static func getPixels(_ cgImage:  CGImage) throws -> [UIColor] {
        if ( cgImage.bitsPerPixel != 32 ) {
            throw Errors.OnlySupport32BitImages;
        }

        if ( cgImage.bitsPerComponent != 8 ) {
            throw Errors.OnlySupport8BitPerChannel;
        }

        guard let imageData = cgImage.dataProvider?.data as Data? else {
            return []
        }
        let size = cgImage.width * cgImage.height
        let buffer = UnsafeMutableBufferPointer<UInt32>.allocate(capacity: size)
        _ = imageData.copyBytes(to: buffer)
        var result = [UIColor]()
        result.reserveCapacity(size)
        for pixel in buffer {
            var r : UInt32 = 0
            var g : UInt32 = 0
            var b : UInt32 = 0
            if cgImage.byteOrderInfo == .orderDefault || cgImage.byteOrderInfo == .order32Big {
                r = pixel & 255
                g = (pixel >> 8) & 255
                b = (pixel >> 16) & 255
            } else if cgImage.byteOrderInfo == .order32Little {
                r = (pixel >> 16) & 255
                g = (pixel >> 8) & 255
                b = pixel & 255
            }
            let color = UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
            result.append(color)
        }
        return result
    }

}
