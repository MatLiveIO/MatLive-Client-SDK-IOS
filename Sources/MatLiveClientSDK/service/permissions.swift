//
//  permissions.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 28/12/2024.
//

import Foundation
import AVFoundation
import CoreBluetooth
import PhotosUI

final class PermissionsManager: ObservableObject {
    // Published properties for permission states
    @Published var isCameraAuthorized: Bool = false
    @Published var isBluetoothAuthorized: Bool = false
    @Published var isGalleryAuthorized: Bool = false
    @Published var isMicrophoneAuthorized: Bool = false
    
    
    // MARK: - Camera Permission
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        isCameraAuthorized = (status == .authorized)
    }

    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            self?.isCameraAuthorized = granted
        }
    }

    // MARK: - Bluetooth Permission
    func checkBluetoothPermission() {
        if #available(iOS 13.1, *) {
            let authorizationStatus = CBManager.authorization
            if authorizationStatus == .notDetermined {
                requestBluetoothPermission()
            }
            isBluetoothAuthorized = (authorizationStatus == .allowedAlways)
        } else {
            let centralManager = CBCentralManager(delegate: nil, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
            if centralManager.authorization == .notDetermined {
                requestBluetoothPermission()
            }
            isBluetoothAuthorized = (centralManager.authorization == .allowedAlways)
        }
    }

    func requestBluetoothPermission() {
        let centralManager = CBCentralManager(delegate: nil, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        centralManager.scanForPeripherals(withServices: nil) // This triggers the permission prompt
    }

    // MARK: - Gallery Permission
    @available(iOS 14, *)
    func checkGalleryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        isGalleryAuthorized = (status == .authorized || status == .limited)
    }

    @available(iOS 14, *)
    func requestGalleryPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            self?.isGalleryAuthorized = (status == .authorized || status == .limited)
        }
    }
    
    // MARK: - Microphone Permission
    func checkMicrophonePermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .notDetermined{
            requestMicrophonePermission()
        }
        isMicrophoneAuthorized = (status == .authorized)
    }

    func requestMicrophonePermission() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            self?.isMicrophoneAuthorized = granted
        }
    }
}
