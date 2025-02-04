//
//  OstovanehPDFReaderController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 10/12/1400 AP.
//

import UIKit

class CustomPDFReaderViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pageTextField: UITextField!
    @IBOutlet weak var totalPageLabel: UILabel!
    @IBOutlet weak var controlBoxView: UIView!

    private weak var pdfController: PDFViewController!
    private var timer: Timer?
    let button = UIButton()
    var isUp = true

    override func configUI() {
        super.configUI()
        view.bindToKeyboard()
        pageTextField.delegate = self
        if let pdfURL = data as? URL {
            if let pdfDocument = document(pdfURL) {
                showDocument(pdfDocument)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reviewTimeEnded(notification:)), name: .fileReviewTimeEnded, object: nil)
    }
    
    override func updateUI() {
        super.updateUI()
        button.frame = CGRect(x: 16, y: 8, width: 64, height: 64)
        button.setTitle("", for: .normal)
        button.setImage(UIImage(systemName: "arrowtriangle.up.circle"), for: .normal)
        button.addTarget(self, action: #selector(upButtonTapped), for: .touchUpInside)
        button.alpha = 0
        if #available(iOS 15.0, *) {
            button.configuration = .plain()
        }
        view.addSubview(button)
    }
    
    @objc func reviewTimeEnded(notification: Notification) {
        if let _ = notification.userInfo?["productID"] as? String {
            // check if this product is that preview product
        }
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        view.endEditing(true)
        if sender.isOn {
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [weak self] _ in
                guard let self = self else { return }
                let currentIndex = self.pdfController.currentPageIndex
                if currentIndex < self.pdfController.document.pageCount-1 {
                    self.pdfController.movePDFViewPage(to: currentIndex+1)
                }
            })
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @IBAction func goButtonTapped(_ sender: Any) {
        view.endEditing(true)
        if let index = Int(pageTextField.text!.toEnNumber), index > 0 {
            if index-1 <= pdfController.document.pageCount-1 {
                pdfController.movePDFViewPage(to: index-1)
            }
        }
    }
    
    @IBAction func rotationButtonTapped() {
        if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    
    @IBAction func upAndDownButtonTapped(_ sender: UIButton) {
        //arrowtriangle.down.circle
        //arrowtriangle.up.circle
        controlBoxView.alpha = 0
        pdfController.view.frame = view.frame
        button.alpha = 1
        isUp = true
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        let index = pdfController.currentPageIndex+1
        if index <= pdfController.document.pageCount-1 {
            pdfController.movePDFViewPage(to: index)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let index = pdfController.currentPageIndex-1
        if index >= 0 {
            pdfController.movePDFViewPage(to: index)
        }
    }
    
    @objc func upButtonTapped() {
        controlBoxView.alpha = 1
        button.alpha = 0
        let frame = view.frame
        pdfController.view.frame = CGRect(x: .zero, y: .zero, width: frame.width, height: frame.height-150)
        isUp = false
    }

    /// Initializes a document with the name of the pdf in the file system
    private func document(_ name: String) -> PDFDocument? {
        guard let documentURL = Bundle.main.url(forResource: name, withExtension: "pdf") else { return nil }
        return PDFDocument(url: documentURL)
    }
    
    /// Initializes a document with the data of the pdf
    private func document(_ data: Data) -> PDFDocument? {
        return PDFDocument(fileData: data, fileName: "PDF")
    }
    
    /// Initializes a document with the remote url of the pdf
    private func document(_ remoteURL: URL) -> PDFDocument? {
        return PDFDocument(url: remoteURL)
    }
    
    private func showDocument(_ document: PDFDocument) {
        let image = UIImage(named: "")
        let controller = PDFViewController.createNew(with: document, title: "", actionButtonImage: image, actionStyle: .activitySheet)
        pdfController = controller
        pdfController.delegate = self
        let totalPagesCount = controller.document.pageCount
        totalPageLabel.text = "از \(totalPagesCount)"
        addPDF(controller: controller) // (3*)
    }
    
    func addPDF(controller: PDFViewController) {
        addChild(controller)
        view.addSubview(controller.view)
        view.sendSubviewToBack(controller.view)
        
        let frame = view.frame
        controller.view.frame = CGRect(x: .zero, y: .zero, width: frame.width, height: frame.height-150)
        controller.didMove(toParent: self)
    }
    
    deinit {
        print("deinit")
    }
}

extension CustomPDFReaderViewController: PDFViewControllerDelegate {
    func PDFPage(moveTo currentPageIndex: Int, forward: Bool) {
        //
    }
}
