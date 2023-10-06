import Foundation
import AVFoundation

public protocol CameraServiceProtocol {
    var cameraAuthorizationStatus: AVAuthorizationStatus { get }
    func requestCameraPermissionNative() async
    func grantCameraPermission(customRequest: (() -> Void)?) -> Bool
}

public extension CameraServiceProtocol {
    var cameraAuthorizationStatus: AVAuthorizationStatus {
        get {
            return AVCaptureDevice.authorizationStatus(for: .video)
        }
    }
    
    func requestCameraPermissionNative() async {
        await AVCaptureDevice.requestAccess(for: .video)
    }
    
    func grantCameraPermission(customRequest: (() -> Void)? = nil) -> Bool {
        switch cameraAuthorizationStatus {
        case .authorized:
            break
        case .notDetermined:
            Task {
                await requestCameraPermissionNative()
            }
        default:
            customRequest?()
        }
        
        return cameraAuthorizationStatus == .authorized
    }
}

public final class CameraService: CameraServiceProtocol { 
    public init() {}
}
