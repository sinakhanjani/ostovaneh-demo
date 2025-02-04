//
//  GoogleAuthController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/5/1400 AP.
//

import Foundation
import GoogleSignIn
import Firebase

protocol GoogleAuthenticationControllerDelegate: AnyObject {
    func signIn(user: GIDGoogleUser, credential: AuthCredential)
}

struct GoogleAuthenticationController {
    
    weak var delegate: GoogleAuthenticationControllerDelegate?
    
    func signIn(vc: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: vc) { user, error in
            if let _ = error {
                // ...
                return
            }
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            if let user = user {
                delegate?.signIn(user: user, credential: credential)
            }
        }
    }
    
    static func signOut() {
        let firebaseAuth = Auth.auth()
        
        if firebaseAuth.currentUser != nil {
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
    }
}
