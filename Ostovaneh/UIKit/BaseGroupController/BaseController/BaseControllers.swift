//
//  BaseViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/25/1400 AP.
//

import UIKit

class BaseViewController: InterfaceViewController, BaseControllerDelegate {
    var data: Any?
}

class BaseTableViewController: InterfaceTableViewController, BaseControllerDelegate {
    var data: Any?
}

class BaseCollectionViewController: InterfaceCollectionViewController, BaseControllerDelegate {
    var data: Any?
}
