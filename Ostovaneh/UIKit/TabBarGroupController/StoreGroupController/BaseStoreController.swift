//
//  StoreBaseController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/30/1400 AP.
//

import UIKit

public var storeThemColor: UIColor = .OSTBlue

class BaseStoreViewController: BaseViewController {
    override func configUI() {
        super.configUI()
        view.backgroundColor = .systemBackground
    }
}

class BaseStoreTableViewController: BaseTableViewController {
    override func configUI() {
        super.configUI()
        tableView.backgroundColor = .systemBackground
    }
}

class BaseStoreCollectionViewController: BaseCollectionViewController {
    override func configUI() {
        super.configUI()
        collectionView.backgroundColor = .systemBackground
    }
}
