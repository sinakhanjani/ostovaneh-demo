//
//  CollectionViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/30/1400 AP.
//

import UIKit

enum SupplementaryViewKind {
    static let header = "header"
    static let topLine = "topLine"
    static let bottomLine = "bottomLine"
}

class StoreCollectionViewController: BaseStoreCollectionViewController {
    
    enum Section: Hashable {
        case categories
        case promoted(String)
        case products(IncludedTypeModel<CategoryAttributeModel,IncludedCategoryProductDataModel>)
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, StoreItemModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, StoreItemModel>()
    
    private var bannerPivots: [BannerPivotModel]?
    private var currentCategoryID: String?
    
    override func configUI() {
        super.configUI()
        navigationItem.largeTitleDisplayMode = .never
        // collection View Setup
        collectionView.collectionViewLayout = createLayout()
        // register Cells and Supplementary Views
        register(collectionView, with: StoreCategoryCollectionViewCell.self)
        register(collectionView, with: StoreBannerCollectionViewCell.self)
        register(collectionView, with: StoreProductCollectionViewCell.self)
        //
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: SupplementaryViewKind.header, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        collectionView.register(LineView.self, forSupplementaryViewOfKind: SupplementaryViewKind.topLine, withReuseIdentifier: LineView.reuseIdentifier)
        collectionView.register(LineView.self, forSupplementaryViewOfKind: SupplementaryViewKind.bottomLine, withReuseIdentifier: LineView.reuseIdentifier)
        // configuration data source
        configureDataSource()
    }
    
    override func updateUI() {
        super.updateUI()
        fetchData()
    }
    
    override func reachabilityStatusChanges(_ notification: Notification) {
        super.reachabilityStatusChanges(notification)
        if case .online(_) = connetctionStatus {
            updateUI()
            collectionView.semanticContentAttribute = .forceRightToLeft
            collectionView.backgroundView = nil
        } else {
            collectionView.backgroundView = BadConnectionView()
            collectionView.semanticContentAttribute = .unspecified
            dataSource.apply(createSnapshot(item: MainSchemaResponseModel(data: nil, included: [])))
        }
    }
    
    private func fetchData() {
        if let catID = data as? String {
            fetchCategoryData(catId: catID) { [weak self] result in
                if let result = result {
                    self?.bannerPivots = result.data?.relationships?.banners?.meta?.pivots
                    self?.reloadSnapshot(item: result)
                }
            }
        }
        
        if let result = data as? MainSchemaResponseModel {
            currentCategoryID = result.data?.id
            reloadSnapshot(item: result)
        }
    }
    
    func showProductListTableController(catID: String) {
        fetchCategoryData(catId: catID) { [weak self] result in
            if let result = result {
                if result.hasChild {
                    self?.show(StoreCollectionViewController
                            .instantiate()
                            .with(passing: result),
                         sender: nil)
                } else {
                    self?.show(ProductListTableViewController
                            .instantiate()
                            .with(passing: catID),
                         sender: nil)
                }
            }
        }
    }
    
    private func reloadSnapshot(item: MainSchemaResponseModel) {
        // MARK: -TempCode: Snapshot Definition
        snapshot = createSnapshot(item: item)
        dataSource.apply(snapshot)
    }
    
    private func createLayout() -> UICollectionViewLayout {
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
            
            let section = self.snapshot.sectionIdentifiers[sectionIndex]
            switch section {
            case .categories:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(150), heightDimension: .estimated(84))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                //                section.boundarySupplementaryItems = [bottomLineItem]
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                return section
            case .promoted:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .fractionalWidth(0.46))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0)
                
                return section
            case .products:
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
    
    func configureDataSource() {
        // Data Source Initialization
        dataSource = .init(collectionView: collectionView, cellProvider: { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
            switch itemIdentifier {
            case .category(let x):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreCategoryCollectionViewCell.identifier, for: indexPath) as! StoreCategoryCollectionViewCell
                cell.bannerImageView.loadImage(from: x.attributes?.iconUrl)
                
                return cell
            case .banner(let x):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreBannerCollectionViewCell.identifier, for: indexPath) as! StoreBannerCollectionViewCell
                cell.bannerImageView.loadImage(from: x.attributes?.url)
                
                return cell
            case .product(let x):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreProductCollectionViewCell.identifier, for: indexPath) as! StoreProductCollectionViewCell
                if let productAttributeModel = x.attributes {
                    cell.updateCell(item: productAttributeModel)
                }
                
                return cell
            }
        })
        
        // Supplementary View Provider
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let self = self else { return nil }
            switch kind {
            case SupplementaryViewKind.header:
                let sectionIdentifier = self.snapshot.sectionIdentifiers[indexPath.section]
                var sectionTitle = ""
                switch sectionIdentifier {
                case .products(let categoryIncludedModel):
                    if let name = categoryIncludedModel.attributes?.name {
                        sectionTitle = name
                    }
                default : return nil
                }

                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.header, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as! SectionHeaderView
                headerView.setTitle(sectionTitle)
                headerView.seeAllButtonHandler = { [weak self] in
                    if case .products(let x) = sectionIdentifier {
                        if let catID = x.id {
                            if let productSortType = ProductSortType.init(rawValue: catID) {
                                if let currentCatID = (self?.data as? String) ?? self?.currentCategoryID {
                                    let vc = ProductListTableViewController
                                        .instantiate()
                                            .with(passing: currentCatID)
                                    vc.productSortBy = productSortType
                                    self?.show(vc,
                                         sender: nil)
                                }
                            } else {
                                self?.showProductListTableController(catID: catID)
                            }
                        }
                    }
                    print(indexPath)
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
    
    func createSnapshot(item: MainSchemaResponseModel) -> NSDiffableDataSourceSnapshot<Section, StoreItemModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, StoreItemModel>()
        // categories section
        let categoriesStoreItem:[StoreItemModel] = item.includedCategoriesModel.map {.category($0)}
        let categorySection: Section = .categories
        if !categoriesStoreItem.isEmpty {
            snapshot.appendSections([categorySection])
            snapshot.appendItems(categoriesStoreItem, toSection: categorySection)
        }
        // for other section
        item.allCategoriesID.forEach { catID in
            let allFilteredAttirbutes = item.filterAttributeBy(categoryKey: catID)
            if let categoryIncludedModel = allFilteredAttirbutes.categoryIncludedModel {
                // set banner for each productLine
                let bannerSection: Section = .promoted(categoryIncludedModel.id!)
                let bannerStoreItems: [StoreItemModel] = allFilteredAttirbutes.imagesIncludedModel.map { .banner($0) }
                if !bannerStoreItems.isEmpty {
                    snapshot.appendSections([bannerSection])
                    snapshot.appendItems(bannerStoreItems, toSection: bannerSection)
                }
                // set products section and items
                let productsSection: Section = .products(categoryIncludedModel)
                let productStoreItems: [StoreItemModel] = allFilteredAttirbutes.productsIncludedModel.map { .product($0) }
                if !productStoreItems.isEmpty {
                    snapshot.appendSections([productsSection])
                    snapshot.appendItems(productStoreItems, toSection: productsSection)
                }
            }
        }
        
        return snapshot
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionIdentifier = snapshot.sectionIdentifiers[indexPath.section]
        let itemsIdentifier = snapshot.itemIdentifiers(inSection: sectionIdentifier)
        let itemIdentifier = itemsIdentifier[indexPath.item]
        
        if case .category(let x) = itemIdentifier {
            if let catID = x.id {
                showProductListTableController(catID: catID)
                return
            }
        }
        if case .banner(let x) = itemIdentifier {
            if let id = x.id {
                if let bannerPivotModel = bannerPivots?.metaBannerBy(BannerID: id) {
                    if let key = bannerPivotModel.key, let valueID = bannerPivotModel.value {
                        switch key {
                        case "category":
                            showProductListTableController(catID: valueID)
                            break
                        case "product":
                            let vc = ProductDetailCollectionViewController
                                .instantiate()
                                .with(passing: valueID)
                            if let currentCategoryID = currentCategoryID {
                                vc.parentCatID = currentCategoryID
                            }
                            show(vc,sender: nil)

                            break
                        default: break
                        }
                    }
                }
                return
            }
        }
        if case .product(let x) = itemIdentifier {
            if let id = x.id {
                let vc = ProductDetailCollectionViewController
                    .instantiate()
                    .with(passing: id)
                if let currentCategoryID = currentCategoryID {
                    vc.parentCatID = currentCategoryID
                }
                show(vc,
                     sender: nil)
                return
            }
        }
    }
}

extension StoreCollectionViewController: FetchCategoryRequestInjection { }
