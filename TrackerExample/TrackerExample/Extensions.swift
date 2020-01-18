//
//  Extensions.swift
//  TrackerExample
//
//  Created by Tomoya Hirano on 2020/01/19.
//  Copyright © 2020 Tomoya Hirano. All rights reserved.
//

import Accelerate

extension CVPixelBuffer {
    public func toBGRA() throws -> CVPixelBuffer? {
        let pixelBuffer = self
        
        /// Check format
        let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
        guard pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange else { return pixelBuffer }
        
        /// Split plane
        let yImage = pixelBuffer.with({ VImage(pixelBuffer: $0, plane: 0) })!
        let cbcrImage = pixelBuffer.with({ VImage(pixelBuffer: $0, plane: 1) })!
        
        /// Create output pixelBuffer
        let outPixelBuffer = CVPixelBuffer.make(width: yImage.width, height: yImage.height, format: kCVPixelFormatType_32BGRA)!
        
        /// Convert yuv to argb
        var argbImage = outPixelBuffer.with({ VImage(pixelBuffer: $0) })!
        try argbImage.draw(yBuffer: yImage.buffer, cbcrBuffer: cbcrImage.buffer)
        /// Convert argb to bgra
        argbImage.permute(channelMap: [3, 2, 1, 0])
        
        return outPixelBuffer
    }
}

struct VImage {
    let width: Int
    let height: Int
    let bytesPerRow: Int
    var buffer: vImage_Buffer
    
    init?(pixelBuffer: CVPixelBuffer, plane: Int) {
        guard let rawBuffer = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, plane) else { return nil }
        self.width = CVPixelBufferGetWidthOfPlane(pixelBuffer, plane)
        self.height = CVPixelBufferGetHeightOfPlane(pixelBuffer, plane)
        self.bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, plane)
        self.buffer = vImage_Buffer(
            data: UnsafeMutableRawPointer(mutating: rawBuffer),
            height: vImagePixelCount(height),
            width: vImagePixelCount(width),
            rowBytes: bytesPerRow
        )
    }
    
    init?(pixelBuffer: CVPixelBuffer) {
        guard let rawBuffer = CVPixelBufferGetBaseAddress(pixelBuffer) else { return nil }
        self.width = CVPixelBufferGetWidth(pixelBuffer)
        self.height = CVPixelBufferGetHeight(pixelBuffer)
        self.bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        self.buffer = vImage_Buffer(
            data: UnsafeMutableRawPointer(mutating: rawBuffer),
            height: vImagePixelCount(height),
            width: vImagePixelCount(width),
            rowBytes: bytesPerRow
        )
    }
    
    mutating func draw(yBuffer: vImage_Buffer, cbcrBuffer: vImage_Buffer) throws {
        try buffer.draw(yBuffer: yBuffer, cbcrBuffer: cbcrBuffer)
    }
    
    mutating func permute(channelMap: [UInt8]) {
        buffer.permute(channelMap: channelMap)
    }
}

extension CVPixelBuffer {
    func with<T>(_ closure: ((_ pixelBuffer: CVPixelBuffer) -> T)) -> T {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        let result = closure(self)
        CVPixelBufferUnlockBaseAddress(self, .readOnly)
        return result
    }
    
    static func make(width: Int, height: Int, format: OSType) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            format,
                            nil,
                            &pixelBuffer)
        return pixelBuffer
    }
}

extension vImage_Buffer {
    mutating func draw(yBuffer: vImage_Buffer, cbcrBuffer: vImage_Buffer) throws {
        var yBuffer = yBuffer
        var cbcrBuffer = cbcrBuffer
        var conversionMatrix: vImage_YpCbCrToARGB = {
            var pixelRange = vImage_YpCbCrPixelRange(Yp_bias: 0, CbCr_bias: 128, YpRangeMax: 255, CbCrRangeMax: 255, YpMax: 255, YpMin: 1, CbCrMax: 255, CbCrMin: 0)
            var matrix = vImage_YpCbCrToARGB()
            vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_709_2, &pixelRange, &matrix, kvImage420Yp8_CbCr8, kvImageARGB8888, UInt32(kvImageNoFlags))
            return matrix
        }()
        let error = vImageConvert_420Yp8_CbCr8ToARGB8888(&yBuffer, &cbcrBuffer, &self, &conversionMatrix, nil, 255, UInt32(kvImageNoFlags))
        if error != kvImageNoError {
            fatalError()
        }
    }
    
    mutating func permute(channelMap: [UInt8]) {
        vImagePermuteChannels_ARGB8888(&self, &self, channelMap, 0)
    }
}
