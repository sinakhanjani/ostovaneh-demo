//
//  MainMyProductCollectionViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 10/19/1400 AP.
//

import UIKit
import RestfulAPI

public var folderDict: [String:String] { // productID:folderID
    get {
        return UserDefaults.standard.object(forKey: "_folderDict") as? [String:String] ?? [:]
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "_folderDict")
    }
}

class MainMyProductCollectionViewController: BaseCollectionViewController {
    typealias Product = IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>
    
    enum Section {
        case main
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Product>!
    var snapshot: NSDiffableDataSourceSnapshot<Section, Product>!
    
    var currentType = 1 {
        didSet {
            fetch(type: currentType)
        }
    }
    
    private var product: Product?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetch(type: currentType)
        

    }
    
    override func configUI() {
        super.configUI()
        collectionView.collectionViewLayout = createLayout()
        configureDataSource()
        // update folderDict when viewDidLoad here from init request:
        if let folders = CustomerAuth.shared.loginResponseModel?.foldersResponseModel?.data {
            var dict = [String:String]()
            folders.forEach { folder in
                if let productID = folder.relationships?.products?.data?.last?.id, let folderID = folder.id {
                    dict.updateValue(folderID, forKey: productID)
                }
            }
            
            AddFolderResponseModel.folderItems = folders.map { AddFolderResponseModel(data: $0) }
            folderDict = dict
            if #available(iOS 14.0, *) {
                let rightBarButton = UIBarButtonItem(title: "", image: UIImage(systemName: "list.dash"), primaryAction: nil, menu: createMenu())
                navigationItem.rightBarButtonItem = rightBarButton
            }
        }
    }
    
    override func updateUI() {
        super.updateUI()
    }
    
    override func reachabilityStatusChanges(_ notification: Notification) {
        super.reachabilityStatusChanges(notification)
        fetch(type: currentType)
    }
    
    private func createMenu() -> UIMenu {
//        let all = UIAction(title: "همه محصولات", handler: { [weak self] _ in
//            guard let self = self else { return }
//            self.currentType = 1
//        })
//        let reading = UIAction(title: "در حال مطالعه", handler: { [weak self] _ in
//            guard let self = self else { return }
//            self.currentType = 2
//        })
//        let done = UIAction(title: "تمام شده‌ها", handler: { [weak self] _ in
//            guard let self = self else { return }
//            self.currentType = 3
//        })
//
        var elements: [UIAction] = [] // = [
//            all,
//            reading,
//            done
//        ]
        let others: [UIAction] = AddFolderResponseModel.fetchRecordedFolders().map { item in
            return UIAction(title: item.data?.attributes?.name ?? "", handler: { [weak self] _ in
                guard let self = self else { return }
                self.currentType = Int(item.data?.id ?? "0") ?? 0
            })
        }
        
        elements.append(contentsOf: others)

        let menu = UIMenu(options: .displayInline, children: elements)
        
        return menu
    }
    
    private func createProductAction(product: Product) -> UIMenu {
        let about = UIAction(title: "درباره محصول", identifier: nil, discoverabilityTitle: nil) {[weak self] _ in
            guard let self = self else { return }
            let vc = ProductDetailCollectionViewController.instantiate().with(passing: product.id!)
            self.show(vc, sender: nil)
        }
        let done = UIAction(title: "تمام شد", identifier: nil, discoverabilityTitle: nil) {[weak self] _ in
            guard let self = self else { return }
            let network = RestfulAPI<EMPTYMODEL,Data>.init(path: "/v1/product/done_reading")
                .with(auth: .user)
                .with(method: .POST)
                .with(parameters: ["product_id":"\(product.id!)"])
            self.handleRequestByUI(network, animated: true) { [weak self] results in
                guard let _ = self else { return }
                //
            }
        }
        let addFrom = UIAction(title: "افزودن به پوشه", identifier: nil, discoverabilityTitle: nil) { [weak self] _ in
            guard let self = self else { return }
            let mores = AddFolderResponseModel.fetchRecordedFolders().map { MoreModel.init(id: $0.data!.id!, key: "", faKey: "", name: $0.data?.attributes?.name ?? "") }
            let vc = MoreTableViewController.instantiate().with(passing: mores)
            self.product = product
            vc.delegate = self
            self.present(vc)
        }
        let social = UIAction(title: "معرفی به دیگران", identifier: nil, discoverabilityTitle: nil) {[weak self] _ in
            guard let self = self else { return }
            if let url = product.attributes?.url {
                let message = """
سلام و عرض ادب من از دیدن این محصول در استوانه لذت بردم، پیشنهاد می کنم این محصول را در فروشگاه استوانه مشاهده فرمایید. پس روی لینک زیر کلیک کنید.
\(url)
"""
                let vc = UIActivityViewController(activityItems: [message], applicationActivities: nil)
                self.present(vc)
            }
        }
        let suggest = UIAction(title: "ثبت نظرات و امتیاز‌ها", identifier: nil, discoverabilityTitle: nil) {[weak self] _ in
            guard let self = self else { return }
            self.present(AddSuggestionViewController.instantiate().with(passing: product.id!))
        }
        
        var actions: [UIAction] = [about,done]
        
        if folderDict["\(product.id!)"] != nil {
            let folderID = folderDict["\(product.id!)"]!
            if let folder = AddFolderResponseModel.fetchRecordedFolders().first(where: { i in
                i.data?.id == folderID
            }) {
                let removeFrom = UIAction(title: "حذف از پوشه \(folder.data?.attributes?.name ?? "")", identifier: nil, discoverabilityTitle: nil) { [weak self] _ in
                    guard let self = self else { return }
                    self.addOrRemoveProduct(productID: product.id!, folderID: folderDict["\(product.id!)"]!, isAdd: false)
                }
                actions.append(removeFrom)
            }
        } else {
            actions.append(addFrom)
        }
        
        actions.append(contentsOf: [social,suggest])
        
        return UIMenu(title: "", image: nil, identifier: nil, options: .destructive, children: actions)
    }
    
    func fetch(type: Int) {
        switch connetctionStatus {
        case .offline:
            let encoded = ProductResponseModel.fetchRecordedProducts().map { $0.data! }
            self.reloadSnapshot(items: encoded)
        default:
            let network = RestfulAPI<EMPTYMODEL,MyProductResponseModel>.init(path: "/v1/folder/\(type)/products")
                .with(auth: .user)
            
            handleRequestByUI(network, animated: true) { [weak self] results in
                guard let self = self else { return }
                if let items = results?.data?.filter({ $0.attributes!.fileType != nil }) {
                    self.reloadSnapshot(items: items)
                }
            }
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func configureDataSource() {
        dataSource = .init(collectionView: collectionView) { [weak self]
            (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "cell",
                for: indexPath) as? MyProductCollectionViewCell else { fatalError("Could not create new cell") }
            if let imageURL = itemIdentifier.attributes?.thumbnailImageURL {
                switch self.connetctionStatus {
                case .offline:
//                    if let imageData = itemIdentifier.attributes?.savedThumbnailImageURL {
//                        cell.coverImageView.image = UIImage(data: imageData)
//                    } else {
//                        cell.coverImageView.image = UIImage(systemName: "book")
//                    }
                    if let forKey = itemIdentifier.id, let savedImage = UserDefaults.standard.value(forKey: forKey) as? Data {
                        cell.coverImageView.image = UIImage(data: savedImage)
                    }
                default:
                    if let forKey = itemIdentifier.id, let savedImage = UserDefaults.standard.value(forKey: forKey) as? Data {
                        cell.coverImageView.image = UIImage(data: savedImage)
                    } else {
                        cell.coverImageView.loadImage(from: imageURL, encoded: true, forKey: itemIdentifier.id!)
                    }
                }
            }
            cell.fileTypeImageView.image = itemIdentifier.attributes?.fileTypeEnum?.icon
            
            return cell
        }
    }
    
    func createSnapshot(items: [Product]) -> NSDiffableDataSourceSnapshot<Section, Product> {
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        
        return snapshot
    }
    
    func reloadSnapshot(items: [Product]) {
        snapshot = createSnapshot(items: items)
        dataSource.apply(snapshot)
    }
    
    func addFolderRequest(name: String) {
        // MARK: - AddFolder
        struct AddFolder: Codable {
            let data: DataClass
            // MARK: - DataClass
            struct DataClass: Codable {
                var type = "folders"
                let attributes: Attributes
                // MARK: - Attributes
                struct Attributes: Codable {
                    let name: String
                }
            }
        }
        let network = RestfulAPI<AddFolder,AddFolderResponseModel>.init(path: "/v1/folders")
            .with(auth: .user)
            .with(method: .POST)
            .with(body: AddFolder(data: AddFolder.DataClass.init(attributes: AddFolder.DataClass.Attributes.init(name: name))))
        
        handleRequestByUI(network, animated: true) { [weak self] results in
            guard let self = self else { return }
            if let results = results {
                AddFolderResponseModel.addFolder(item: results)
                if #available(iOS 14.0, *) {
                    let rightBarButton = UIBarButtonItem(title: "", image: UIImage(systemName: "list.dash"), primaryAction: nil, menu: self.createMenu())
                    self.navigationItem.rightBarButtonItem = rightBarButton
                }
            }
        }
    }
    
    @IBAction func addBarButtonTapped(_ sender: UIBarButtonItem) {
        // open input vc
        //EnterGiftCodeTableViewController
        let vc = EnterGiftCodeTableViewController
            .instantiate()
            .with(passing: "fromAddFolder")
        vc.dataDelegate = self
        present(vc)
    }
}

extension MainMyProductCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let productID = snapshot.itemIdentifiers[indexPath.item].id {
            let vc = ProductDetailCollectionViewController
                .instantiate()
                .with(passing: productID)
            show(vc, sender: nil)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: .none) { [weak self] actions in
            if let item = self?.snapshot.itemIdentifiers[indexPath.item] {
                return self?.createProductAction(product: item)
            }
            return nil
        }
    }
}

extension MainMyProductCollectionViewController: EnterGiftCodeTableViewControllerDataDelegate {
    func enterInput(data: String) {
        addFolderRequest(name: data)
    }
}

extension MainMyProductCollectionViewController: MoreTableViewControllerDelegate {
    func headerSelected(_ more: MoreModel) {
        let folderID = more.id
        if let productID = product?.id {
            self.addOrRemoveProduct(productID: productID, folderID: folderID, isAdd: true)
        }
    }
    
    func addOrRemoveProduct(productID: String, folderID: String, isAdd: Bool) {
        let network = RestfulAPI<EMPTYMODEL,Data>.init(path: "/v1/product/add_to_folder")
            .with(auth: .user)
            .with(method: .POST)
            .with(parameters: ["product_id":"\(productID)",
                               "folder_id":"\(folderID)"])
        self.handleRequestByUI(network, animated: true) { [weak self] results in
            guard let self = self else { return }
            if !isAdd {
                folderDict["\(productID)"] = nil
                self.fetch(type: self.currentType)
            }
            if let product = self.product, isAdd {
                var currentProduct = product
                currentProduct.attributes?.folderIDs = folderID
                folderDict["\(productID)"] = folderID
            }
        }
    }
}

