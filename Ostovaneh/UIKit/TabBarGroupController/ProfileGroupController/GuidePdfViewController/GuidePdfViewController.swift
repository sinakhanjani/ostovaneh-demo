//
//  GuidePdfViewController.swift
//  Ostovaneh
//
//  Created by Hossein Hajimirza on 10/27/21.
//

import UIKit
import WebKit

class GuidePdfViewController: BaseViewController {
    
    private let webView: WKWebView = {
        let wbv = WKWebView()
        let url = "https://ostovane.com/andguide.pdf".asURL!
        let request = URLRequest(url: url)
        
        wbv.load(request)
        wbv.translatesAutoresizingMaskIntoConstraints = false
        
        return wbv
    }()
   
    override func configUI() {
        super.configUI()
        // add webView to view
        view.addSubview(webView)
        // add constraint
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

