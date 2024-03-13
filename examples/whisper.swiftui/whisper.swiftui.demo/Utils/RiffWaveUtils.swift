import Foundation
import AVFoundation


func decodeWaveFile(_ url: URL) throws -> [Float] {
    let data = try Data(contentsOf: url)
    let floats = stride(from: 44, to: data.count, by: 2).map {
        return data[$0..<$0 + 2].withUnsafeBytes {
            let short = Int16(littleEndian: $0.load(as: Int16.self))
            return max(-1.0, min(Float(short) / 32767.0, 1.0))
        }
    }
    return floats
}


func decodeAudioFile(_ url: URL) throws -> [Float] {
    // Create an AVAudioFile instance with the provided URL
    let audioFile = try AVAudioFile(forReading: url)

    // Use the audio file's processing format and frame length
    let audioFormat = audioFile.processingFormat
    let audioFrameCount = UInt32(audioFile.length)

    // Create an AVAudioPCMBuffer to hold the audio data
    guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount) else {
        throw NSError(domain: "AudioBufferError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to create audio buffer"])
    }

    // Read the audio file into the buffer
    try audioFile.read(into: audioBuffer)

    // Ensure the buffer has float channel data
    guard let floatChannelData = audioBuffer.floatChannelData else {
        throw NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Buffer contains no float channel data"])
    }

    // Extract the floats and return them
    var floats: [Float] = []
    let channelCount = Int(audioFormat.channelCount)
    let frameLength = Int(audioBuffer.frameLength)
    
    var min:Float = 0.0
    var max:Float = 0.0
    
    for channel in 0..<channelCount {
        for frame in 0..<frameLength {
            let sample = floatChannelData[channel][frame]
            floats.append(sample)
            if sample < min{
                min = sample
            }
            
            if sample > max{
                max = sample
            }
        }
    }

    return floats
}
