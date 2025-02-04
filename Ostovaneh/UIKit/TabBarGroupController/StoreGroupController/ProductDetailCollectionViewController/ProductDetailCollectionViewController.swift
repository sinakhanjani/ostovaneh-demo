//
//  ProductDetailCollectionViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/20/1400 AP.
//

import UIKit

class ProductDetailCollectionViewController: BaseStoreCollectionViewController {
    
    enum Section: Hashable {
        case main
        case moreDetail
        case detail
        case comment([IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>])
        case writeComment
        case simular([IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>])
    }
    
    enum ProductItemModel: Hashable {
        case info(ProductResponseModel) // main
        case moreDetail(ProductResponseModel) // moreDetail
        case detail(ProductDetail) // detail
        case comment(IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>) // comment
        case writeComment
        case product(IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>) // simular
    }
    
    public var dataSource: UICollectionViewDiffableDataSource<Section, ProductItemModel>!
    public var snapshot = NSDiffableDataSourceSnapshot<Section, ProductItemModel>()
    
    public var parentCatID: String = ""
    public var simularProducts = [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>]()
    
    public var multiDownloader: MultiFilesDownloader?
    public weak var delegate: ProductDetailCollectionViewControllerDelegate?
    public var timer: Timer?
    public var incrementTime = 0
    
    override func configUI() {
        super.configUI()
        NotificationCenter.default.addObserver(self, selector: #selector(reviewTimeEnded(notification:)), name: .fileReviewTimeEnded, object: nil)
        //
        navigationItem.largeTitleDisplayMode = .never
        // collection View Setup
        collectionView.collectionViewLayout = createLayout()
        // register cells
        register(collectionView, with: ProductInfoCollectionViewCell.self)
        register(collectionView, with: ProductMoreDetailCollectionViewCell.self)
        register(collectionView, with: ProductDetailCollectionViewCell.self)
        register(collectionView, with: ProductCommentCollectionViewCell.self)
        register(collectionView, with: ProductWriteCommentCollectionViewCell.self)
        register(collectionView, with: StoreProductCollectionViewCell.self)
        // register headers
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: SupplementaryViewKind.header, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        collectionView.register(LineView.self, forSupplementaryViewOfKind: SupplementaryViewKind.topLine, withReuseIdentifier: LineView.reuseIdentifier)
        collectionView.register(LineView.self, forSupplementaryViewOfKind: SupplementaryViewKind.bottomLine, withReuseIdentifier: LineView.reuseIdentifier)
        // config datasource
        configureDataSource()
    }

    override func updateUI() {
        super.updateUI()
        if let productID = data as? String {
            switch connetctionStatus {
            case .offline:
                if let results = ProductResponseModel.fetchRecordedProducts().first(where: { item in
                    item.data?.id == productID
                }) {
                    reloadSnapshot(item: results)
                    title = results.data?.attributes?.name
                }
            default:
                fetchProductRequest(productID: productID)
//                if parentCatID != "" {
//                    fetchSimularProductsRequest(catID: parentCatID)
//                }
            }
        }
    }
    
    public func createLayout()-> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [unowned self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            //add header
            let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .estimated(44))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: SupplementaryViewKind.header, alignment: .top)
            
            let lineItemHeight: CGFloat = 1 / layoutEnvironment.traitCollection.displayScale
            let lineItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(lineItemHeight))
            // add top line
            let topLineItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: lineItemSize, elementKind: SupplementaryViewKind.topLine, alignment: .top)
            // add bottom line
            let bottomLineItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: lineItemSize, elementKind: SupplementaryViewKind.bottomLine, alignment: .bottom)
            // supplementaryItemContentInsets
            let supplementaryItemContentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            headerItem.contentInsets = supplementaryItemContentInsets
            topLineItem.contentInsets = supplementaryItemContentInsets
            bottomLineItem.contentInsets = supplementaryItemContentInsets
            
            let section = snapshot.sectionIdentifiers[sectionIndex]
            switch section {
            case .main:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(580))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(580))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 8, bottom: 0, trailing: 8)
//                section.orthogonalScrollingBehavior = .groupPagingCentered

                return section
                
            case .moreDetail:
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(60)
                    )
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(60)
                    ),
                    subitems: [item]
                )
                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 8, bottom: 0, trailing: 8)

                return section
            case .detail:
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(128), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(128), heightDimension: .fractionalWidth(1/3))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 32, trailing: 8)
                
                return section
            case .comment:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(180))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(180))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.boundarySupplementaryItems = [headerItem]
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 16, trailing: 8)
                
                return section
            case .writeComment:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(160))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(160))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .none
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 16, trailing: 8)
                
                return section
            case .simular:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/5), heightDimension: .fractionalWidth(2/3))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.boundarySupplementaryItems = [headerItem]
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 32, trailing: 8)
                
                return section
            }
        }
        
        return layout
    }
    
    private func configureDataSource() {
        // Data Source Initialization
        dataSource = .init(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            
            switch itemIdentifier {
            case .info(let x):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductInfoCollectionViewCell.identifier, for: indexPath) as! ProductInfoCollectionViewCell
                let isActiveThemeMode = self.tabBarController?.selectedIndex == 2 ? true:false
                cell.updateCell(item: x, activeThemeMode: isActiveThemeMode)
                cell.enablePurchaseButton(self.isPurchase, self.isProductIntoBasket, self.isViewed)
                
                cell.delegate = self
                
                if let fileID = x.files.first?.id, let originalExtension = x.files.first?.attributes?.originalExtension, let _ = try? ProductDetailCollectionViewController.filePath(fileID: fileID, originalExtension: originalExtension) {
                    cell.trashButton.alpha = 1
                } else {
                    cell.trashButton.alpha = 0
                }
                
                return cell
                
            case .moreDetail(let x):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductMoreDetailCollectionViewCell.identifier, for: indexPath) as! ProductMoreDetailCollectionViewCell
                cell.updateCell(item: x)
                cell.delegate = self

                return cell
            case .detail(let x):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductDetailCollectionViewCell.identifier, for: indexPath) as! ProductDetailCollectionViewCell
                cell.updateCell(item: x)
                if indexPath.item == 0 {
                    if case .info(let info) = self.snapshot.itemIdentifiers[0] {
                        cell.thirdLabel.text = "\(info.productCategories.count) دسته‌بندی"
                    }
                }
                
                return cell
            case .comment(let x):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCommentCollectionViewCell.identifier, for: indexPath) as! ProductCommentCollectionViewCell
                if self.tabBarController?.selectedIndex == 2 {
                    cell.udpateTheme(store: true)
                }
                cell.updateCell(score: x.attributes!)
                cell.delegate = self
                
                return cell
            case .writeComment:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductWriteCommentCollectionViewCell.identifier, for: indexPath) as! ProductWriteCommentCollectionViewCell
                if self.tabBarController?.selectedIndex == 2 {
                    cell.updateTheme(store: true)
                }
                cell.delegate = self

                return cell
            case .product(let x):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreProductCollectionViewCell.identifier, for: indexPath) as! StoreProductCollectionViewCell
                cell.updateCell(item: x.attributes!)
                
                return cell
            }
        })
        
        // Supplementary View Provider
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let self = self else { return nil }
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.header, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as! SectionHeaderView

            switch kind {
            case SupplementaryViewKind.header:
                let sectionIdentifier = self.snapshot.sectionIdentifiers[indexPath.section]
                var sectionTitle = ""
                switch sectionIdentifier {
                case .main, .moreDetail:
                    return nil
                case .detail:
                    return nil
                case .writeComment:
                    return nil
                case .comment(let x):
                    if x.isEmpty {
                        headerView.seeAllButton.alpha = 0
                        sectionTitle = "اولین نظر را شما ثبت کنید"
                    } else {
                        headerView.seeAllButton.alpha = 1
                        sectionTitle = "نظرات و امتیاز‌ها"
                    }
                case .simular:
                    sectionTitle = "محصولات مشابه"
                }
                headerView.setTitle(sectionTitle)
                headerView.seeAllButtonHandler = { [weak self] in
                    // this is for more button tapped in header
                    switch sectionIdentifier {
                    case .main, .moreDetail:
                        break
                    case .detail:
                        break
                    case .comment(let x):
                        let vc = AllCommentTableViewController
                            .instantiate()
                            .with(passing: x)
                        vc.productID = self?.data as? String
                        self?.show(vc, sender: nil)
                    case .writeComment:
                        break
                    case .simular(let x):
                        let vc = ProductListTableViewController
                            .instantiate()
                            .with(passing: x)

                        self?.show(vc
                                   , sender: nil)
                    }
                }
                return headerView
            case SupplementaryViewKind.topLine, SupplementaryViewKind.bottomLine:
                let lineView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LineView.reuseIdentifier, for: indexPath) as! LineView

                return lineView
            default:
                return nil
            }
        }
    }
    
    private func createSnapshot(item: ProductResponseModel) -> NSDiffableDataSourceSnapshot<Section, ProductItemModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ProductItemModel>()
        // section main
        snapshot.appendSections([.main])
        snapshot.appendItems([.info(item)], toSection: .main)
        // section more detail:
        snapshot.appendSections([.moreDetail])
        snapshot.appendItems([.moreDetail(item)], toSection: .moreDetail)
        // section detail:
        snapshot.appendSections([.detail])
        let details = item.productInformations(parentCatID: parentCatID).map({ ProductItemModel.detail($0) })
        snapshot.appendItems(details, toSection: .detail)
        // rate and comment:
        if !item.scores.isEmpty {
            // comments
            let commentSection: Section = .comment(item.scores)
            let items: [ProductItemModel] = item.scores.prefix(5).map { .comment($0) }
            snapshot.appendSections([commentSection])
            snapshot.appendItems(items, toSection: commentSection)
            // write comment
            snapshot.appendSections([.writeComment])
            snapshot.appendItems([.writeComment], toSection: .writeComment)
        } else {
            let commentSection: Section = .comment(item.scores)
            snapshot.appendSections([commentSection])
            snapshot.appendItems([.writeComment], toSection: commentSection)
        }
        // simulator section:
        if simularProducts.isEmpty == false && !self.simularProducts.isEmpty {
//            add simular product again to snapshot from past...
           let section: Section = .simular(self.simularProducts)
           let items: [ProductItemModel] = self.simularProducts.prefix(5).map({ .product($0) })
           snapshot.appendSections([section])
           snapshot.appendItems(items, toSection: section)
        }
        
        return snapshot
    }
    
    public func reloadSnapshot(item: ProductResponseModel) {
        // MARK: -TempCode: Snapshot Definition
        snapshot = createSnapshot(item: item)
        dataSource.apply(snapshot)
    }
}

extension ProductDetailCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionIdentifier = snapshot.sectionIdentifiers[indexPath.section]
        let itemsIdentifier = snapshot.itemIdentifiers(inSection: sectionIdentifier)
        let itemIdentifier = itemsIdentifier[indexPath.item]
        
        switch itemIdentifier {
        case .info(_):
            break
        case .moreDetail(_):
            break
        case .detail(_):
            if indexPath.item == 0 { // category index always
                if case .info(let x) = snapshot.itemIdentifiers[0] {
                    let vc = MoreTableViewController
                        .instantiate()
                        .with(passing: x.productCategories)
                    vc.delegate = self
                    present(vc)
                }
            }
        case .comment(let x):
            guard CustomerAuth.shared.isLogin else {
                tabBarController?.selectedIndex = 4
                return
            }
            let vc = ReplyCommentTableViewController
                .instantiate()
                .with(passing: x)
            if let productID = data as? String {
                vc.productID = productID
                present(vc)
            }
            break
        case .writeComment:
            break
        case .product(let x):
            let vc = ProductDetailCollectionViewController
                .instantiate()
                .with(passing: x.id!)
            vc.parentCatID = parentCatID
            
            show(vc
                 , sender: nil)
        }
    }
}
