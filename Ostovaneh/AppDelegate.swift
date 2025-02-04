//
//  AppDelegate.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/25/1400 AP.
//

import UIKit
import CoreData
import RestfulAPI
import Firebase
import GoogleSignIn
import SwiftUI
import Photos

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private static let screenProtecter = ScreenProtector()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // configuration RestfulAPI
        RestfulAPIConfiguration().setup { () -> APIConfiguration in
            APIConfiguration(baseURL: Setting.baseURL.value,
                             headers: ["Content-Type":"application/vnd.api+json"])
        }
        // route project
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [weak self] in
//            let reachability = Reachability()
//            let connetctionStatus = reachability.connectionStatus()
//            switch connetctionStatus {
//            case .online(_):
//                self?.checkRegion()
//            default:
////                self?.externalStart()
//                self?.internalStart()
//            }
//        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Ostovaneh")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate {
    func didTakeScreenshot() {
        self.perform(#selector(deleteAppScreenShot), with: nil, afterDelay: 1, inModes: [])
    }

    @objc func deleteAppScreenShot() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors?[0] = Foundation.NSSortDescriptor(key: "creationDate", ascending: true)
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        guard let lastAsset = fetchResult.lastObject else { return }
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets([lastAsset] as NSFastEnumeration)
        } completionHandler: { (success, errorMessage) in
            if !success, let errorMessage = errorMessage {
                print(errorMessage.localizedDescription)
            }
        }
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }
}

extension AppDelegate {
    static func checkRegion() {
        print("Timezone: \(TimeZone.current.identifier)")
        if TimeZone.current.identifier == "Asia/Tehran" {
            internalStart()
//            externalStart()
        } else {
            externalStart()
        }
    }
    
    static func internalStart() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.iranSans(.medium, size: 12)], for: .normal)
        FirebaseApp.configure()
        //
        screenProtecter.startPreventingRecording()
        screenProtecter.startPreventingScreenshot()
        //
        UIApplication.shared.beginReceivingRemoteControlEvents()
        UIApplication.set(root: StarterViewController.instantiate())
    }
    
    static func externalStart() {
        let nav = UINavigationController.instantiate(withId: "todoNav")
        UIApplication.set(root: nav)
    }
}

/*
 Email
 Tofighimostafa4@gmail.com
 mt123123
 
 AppleID:
 Tofighimostafa4@gmail.com
 Mt123123#
 
 Appstoreconnect Bundle:
 ir.ostovane.ios1
 
 App ID Prefix
 274SZ4LXKQ (Team ID)
 
 FCM:
 nokgbegan100@gmail.com
 Mt2000000
 
 GAuth Client ID:
 425953461881-ubviiku7vrc9fbvs15aceiq1cmd165dd.apps.googleusercontent.com
 */
