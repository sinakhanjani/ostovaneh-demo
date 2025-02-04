//
//  VoxAPIDelegate.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/25/1400 AP.
//

import UIKit

//protocol VoxAPIDelegate: UIViewController {
//    func handleRequestByUI<S,R>(_ fetchRequest: FetchRequest<S,R>, animated: Bool, tappedButton: UIButton?, completion: @escaping (S?) -> Void, error: ((Error)->Void)?)
//    func dataSource<T: Resource>(absolutePath: String) -> DataSource<T>
//}
//
//extension VoxAPIDelegate {
//    func dataSource<T: Resource>(absolutePath: String) -> DataSource<T> {
//        let baseURL = URL(string: Setting.baseURL.value)!
//        let client = JSONAPIClient.Alamofire(baseURL: baseURL)
//        let dataSource = DataSource<T>.init(strategy: .path(absolutePath), client: client)
//
//        return dataSource
//    }
//    
//    func handleRequestByUI<S,R>(_ fetchRequest: FetchRequest<S,R>, animated: Bool, tappedButton: UIButton?, completion: @escaping (S?) -> Void, error: ((Error)->Void)?) {
//        do {
//            try? fetchRequest.result({ (document: Document<S>?) in
//                completion(document?.data)
//            } as! R, { err in
//                // nothing here.
//                completion(nil)
//            })
//        }
//    }
//}



/*
 // Documents:
 https://github.com/aronbalog/Vox
 
 // MARK: -A Single resource
 import Vox
 let data: Data // -> provide data received from JSONAPI server
 let deserializer = Deserializer.Single<Article>()
 do {
     let document = try deserializer.deserialize(data: self.data)
     // `document.data` is an Article object
 } catch JSONAPIError.API(let errors) {
     // API response is valid JSONAPI error document
     errors.forEach { error in
         print(error.title, error.detail)
     }
 } catch JSONAPIError.serialization {
     print("Given data is not valid JSONAPI document")
 } catch {
     print("Something went wrong. Maybe `data` does not contain valid JSON?")
 
 
 // MARK: -B Resource collection
 let data: Data // -> provide data received from JSONAPI server
 let deserializer = Deserializer.Collection<Article>()
 let document = try! deserializer.deserialize(data: self.data)

 // `document.data` is an [Article] object
 */
