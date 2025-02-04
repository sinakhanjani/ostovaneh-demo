//
//  BasketTableViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/1/1400 AP.
//

import UIKit
import RestfulAPI

class BasketTableViewController: BaseStoreTableViewController {
    enum Section: Hashable {
        case main
    }
    
    @IBOutlet weak var bankPaymentButton: UIButton!
    @IBOutlet weak var walletPaymentButton: UIButton!
    @IBOutlet weak var creditupButton: UIButton!
    @IBOutlet weak var offCodeButton: UIButton!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var finalPriceLabel: UILabel!
    
    private var dataSource: UITableViewDiffableDataSource<Section, IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>>()
    
    private var orderModel: OrderResponseModel?
    
    override func configUI() {
        super.configUI()
        register(tableView, with: ProductListTableViewCell.self)
        configureDataSource()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(paymnetChanged),
                                               name: .profileChangedNotification,
                                               object: nil)
        segmentControl.selectedSegmentIndex = 1
    }
    
    override func updateUI() {
        super.updateUI()
        // remove basket bar button from this controlelr
        navigationItem.leftBarButtonItem?.customView?.alpha = 0
        // update font
        segmentControl.setTitleTextAttributes([.font: UIFont.iranSans(.bold, size: 17)], for: .normal)
        // update category theme
        if tabBarController?.selectedIndex == 2 {
            bankPaymentButton.backgroundColor = storeThemColor
            walletPaymentButton.backgroundColor = storeThemColor
            creditupButton.backgroundColor = storeThemColor
            offCodeButton.backgroundColor = storeThemColor
        }
        //fetch data from server
        fetchData()
    }
    
    @objc private func paymnetChanged() {
        UIApplication.set(root: StarterViewController
                            .instantiate())
    }
    
    private func fetchData() {
        guard let orderID = CustomerAuth.shared.currentOrderModel?.data?.id else { return }
        let network = RestfulAPI<EMPTYMODEL,OrderResponseModel>.init(path: "/v1/orders/\(orderID)")
            .with(auth: .user)
            .with(queries: ["include":["products"].includes()])
        
        handleRequestByUI(network, animated: true) { [weak self] results in
            CustomerAuth.shared.currentOrderModel = results
            
            if let productsAtt = results?.included, productsAtt.isEmpty {
                self?.navigationController?.popViewController(animated: true)
                return
            }
            if results?.included == nil {
                self?.navigationController?.popViewController(animated: true)
                return
            }
            
            if let productsIncluded = results?.included {
                if let orderAttribute = results?.data?.attributes {
                    self?.orderModel = results
                    self?.updateOrderAttribute(orderAttribute)
                }
                self?.reloadSnapshot(items: productsIncluded)
            }
            // set currentOrder defualt to toman and patch it
            self?.orderModel?.data?.attributes?.currency = "toman"
            if let orderModel = self?.orderModel {
                self?.patchOrdersRequest(orderModel, completion: { _ in })
            }
        }
    }
    
    private func patchOrdersRequest(_ body: OrderResponseModel, completion: @escaping (_ result: OrderResponseModel?) -> Void) {
        guard let orderID = CustomerAuth.shared.currentOrderModel?.data?.id else { return }
        var sendBody = body
        sendBody.included = nil
        let network = RestfulAPI<OrderResponseModel,OrderResponseModel>.init(path: "/v1/orders/\(orderID)")
            .with(auth: .user)
            .with(queries: ["include":["products"].includes()])
            .with(method: .PATCH)
            .with(body: sendBody)
        
        handleRequestByUI(network, animated: true) { [weak self] results in
            CustomerAuth.shared.currentOrderModel = results
            
            if let productsAtt = results?.included, productsAtt.isEmpty {
                self?.navigationController?.popViewController(animated: true)
                return
            }
            if results?.included == nil {
                self?.navigationController?.popViewController(animated: true)
                return
            }
            
            if let productsIncluded = results?.included {
                if let orderAttribute = results?.data?.attributes {
                    self?.orderModel = results
                    self?.updateOrderAttribute(orderAttribute)
                }
                self?.reloadSnapshot(items: productsIncluded)
            }
            completion(results)
        }
    }
    
    private func decreaseCreditRequest() {
        guard let orderID = CustomerAuth.shared.currentOrderModel?.data?.id else {
            showAlerInScreen(body: "حداقل یک محصول را به سبد خرید اضافه کنید")
            return
        }
        let network = RestfulAPI<EMPTYMODEL,Data>.init(path: "/v2/decrease_credit")
            .with(method: .POST)
            .with(auth: .user)
            .with(parameters: ["status":"done",
                               "order_id":orderID])
        
        handleRequestByUI(network, animated: true) { results in
            if let data = results, let str = String(data: data, encoding: .utf8), let credit = Double(str) {
                CustomerAuth.shared.loginResponseModel?.credit = Int(credit)
                
                UIApplication.set(root: StarterViewController
                                    .instantiate())
            }
        }
    }
    
    private func updateOrderAttribute(_ order: OrderAttributeModel) {
        let isDollarSelected = segmentControl.selectedSegmentIndex == 0 ? true:false
        if let credit = CustomerAuth.shared.loginResponseModel?.credit?.toPriceFormatter {
            if credit == "0" {
                creditLabel.text = "صفر / کیف‌ پول را شارژ کنید"
            } else {
                creditLabel.text = "\(credit) تومان"
            }
        }
        if isDollarSelected {
            if let discountPriced = order.discountPriced, let basePriced = order.basePriced, let finalPriced = order.finalPriced {
                discountLabel.text = "\(discountPriced) دلار"
                originalPriceLabel.text = "\(basePriced) دلار"
                finalPriceLabel.text = "\(finalPriced) دلار"
            }
        } else {
            if let discountPrice = order.discountPrice?.toPriceFormatter, let basePrice = order.basePrice?.toPriceFormatter, let finapPrice = order.finalPrice?.toPriceFormatter {
                discountLabel.text = "\(discountPrice) تومان"
                originalPriceLabel.text = "\(basePrice) تومان"
                finalPriceLabel.text = "\(finapPrice) تومان"
            }
        }
    }
    
    private func reloadSnapshot(items: [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>]) {
        snapshot = createSnapshot(items: items)
        dataSource.apply(snapshot)
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductListTableViewCell.identifier) as! ProductListTableViewCell
            
            if let productAttribute = itemIdentifier.attributes {
                cell.updateCell(item: productAttribute)
            }
            return cell
        })
    }
    
    private func createSnapshot(items: [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>]) -> NSDiffableDataSourceSnapshot<Section,IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        return snapshot
    }
    
    @IBAction func segmentControllValueChanged(_ sender: UISegmentedControl) {
        guard let orderAttribute = orderModel?.data?.attributes else {
            return
        }
        let currency = segmentControl.selectedSegmentIndex == 0 ? "dollar":"toman"
        orderModel?.data?.attributes?.currency = currency
        updateOrderAttribute(orderAttribute)
    }
    
    @IBAction func discountButtonTapped(_ sender: UIButton) {
        let vc = EnterGiftCodeTableViewController
            .instantiate()
            .with(passing: "fromBasket")
        vc.delegate = self
        
        present(vc)
    }
    
    @IBAction func creditupButtonTapped(_ sender: UIButton) {
        show(WalletTableViewController
                .instantiate(),
             sender: nil)
    }
    
    @IBAction func walletPaymentButtonTapped(_ sender: UIButton) {
        guard segmentControl.selectedSegmentIndex == 1 else {
            showAlerInScreen(title: "پرداخت",
                             body: "در حال حاضر پرداخت با کیف پول فقط با تومان امکان‌پذیر میباشد")
            return
        }
        
        let content = AlertContent(title: .delete, subject: "پرداخت اعتباری", description: "آیا میخواهید سفارش سبد را با کیف پول پرداخت کنید؟")
        let alertVC = AlertContentViewController
            .instantiate()
            .alert(content)
        
        alertVC.yesButtonTappedHandler = { [weak self] in
            if let credit = CustomerAuth.shared.loginResponseModel?.credit,
               let finalPrice = CustomerAuth.shared.currentOrderModel?.data?.attributes?.finalPrice {
                // condition 1
                if credit == 0 && finalPrice > 0 {
                    self?.showAlerInScreen(body: "اعتبار شما برای پرداخت از کیف ‌پول کافی نمیباشد")
                    return
                }
                // condition 2
                if credit >= Int(finalPrice) {
                    self?.decreaseCreditRequest()
                } else {
                    // condition 3
                    let finalPaymentPrice = Int(finalPrice) - credit
                    let paymentWalletAndBankVC = AlertContentViewController
                        .instantiate()
                        .alert(AlertContent(title: .none, subject: "پرداخت اعتباری", description: "مبلغ قابل استفاده از کیف پول \(credit) تومان و مبلغ \(finalPaymentPrice) را پرداخت می‌کنید؟"))
                    
                    paymentWalletAndBankVC.yesButtonTappedHandler = {
                        // go to url bank with wallet query
                        if let rand = CustomerAuth.shared.currentOrderModel?.data?.attributes?.rand ,let url = URL(string: Setting.baseURL.value + "/v2/checkout?use_wallet=1&rand=\(rand)") {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    
                    self?.present(paymentWalletAndBankVC)
                }
                
                return
            }
            
            self?.showAlerInScreen(body: "حداقل یک محصول را به سبد خرید اضافه کنید")
        }
        
        present(alertVC)
    }
    
    @IBAction func bankPaymentButtonTapped(_ sender: UIButton) {
        if let orderModel = self.orderModel {
            patchOrdersRequest(orderModel) { [weak self] result in
                if let rand = CustomerAuth.shared.currentOrderModel?.data?.attributes?.rand, let url = URL(string: Setting.baseURL.value + "/v2/checkout?rand=\(rand)") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                } else {
                    self?.showAlerInScreen(body: "حداقل یک محصول به سبد خرید اضافه کنید")
                }
            }
        }
    }
}

extension BasketTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        show(ProductDetailCollectionViewController
                .instantiate()
                .with(passing: snapshot.itemIdentifiers[indexPath.item].id!),
             sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let closeAction = UIContextualAction(style: .destructive, title:  "", handler: { [weak self] (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let content = AlertContent(title: .delete, subject: "حذف محصول", description: "آیا میخواهید این محصول را از سبد خرید حذف کنید؟")
            let alertVC = AlertContentViewController
                .instantiate()
                .alert(content)
            
            alertVC.yesButtonTappedHandler = { [weak self] in
                if let productID = self?.snapshot.itemIdentifiers[indexPath.item].id {
                    self?.orderModel?.data?.relationships?.products?.removeProductFromList(productID: productID)
                    if let orderModel = self?.orderModel {
                        self?.patchOrdersRequest(orderModel, completion: { _ in })
                    }
                }
            }
            
            self?.present(alertVC)
            success(true)
        })
        
        closeAction.image = UIImage(systemName: "trash")
        closeAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [closeAction])
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let titleLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.width-256, y: 16, width: 240, height: 44))
        
        headerView.backgroundColor = .clear
        headerView.addSubview(titleLabel)
        
        titleLabel.font = UIFont.iranSans(.bold, size: 17)
        titleLabel.textColor = UIColor.label
        titleLabel.textAlignment = .right
        titleLabel.text = "لیست محصولات سبد خرید"
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        64
    }
}

extension BasketTableViewController: EnterGiftCodeTableViewControllerDelegate {
    func reedemCodeComplete(_ error: ErrorModel?) {
        if let error = error, let body = error.detail {
            showAlerInScreen(body: body)
            return
        }
        if let productsIncluded = CustomerAuth.shared.currentOrderModel?.included {
            if let orderAttribute = CustomerAuth.shared.currentOrderModel?.data?.attributes {
                orderModel = CustomerAuth.shared.currentOrderModel
                updateOrderAttribute(orderAttribute)
            }
            reloadSnapshot(items: productsIncluded)
        }
    }
}
