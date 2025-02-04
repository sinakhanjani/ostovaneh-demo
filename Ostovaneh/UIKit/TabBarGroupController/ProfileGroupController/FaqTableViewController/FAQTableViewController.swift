//
//  FaqTableViewController.swift
//  Ostovaneh
//
//  Created by Hossein Hajimirza on 10/27/21.
//

import UIKit

class FAQTableViewController: BaseTableViewController {
    
    private var items: [FAQInternalModel] = []
    
    override func configUI() {
        super.configUI()
        navigationItem.largeTitleDisplayMode = .never
        
        items = makeItems()
    }
    
    func makeItems() -> [FAQInternalModel] {
        let path = Bundle.main.path(forResource: "FAQArray", ofType: "plist")!
        if let array = NSArray(contentsOfFile: path) {
            
            return array.map { item -> FAQInternalModel in
                let dict = item as! [String: Any]
                let title = dict["title"] as! String
                let isOpened = dict["isOpen"] as! Bool
                let answer = dict["answer"] as! String
                
                return FAQInternalModel(title: title, answer: [answer], isOpened: isOpened)
            }
        }
        
        return []
    }
}

extension FAQTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items[section].isOpened {
            return 2
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // question row
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "question") else { return UITableViewCell()}
            let item = items[indexPath.section]
            cell.textLabel?.text = item.title
            
            if item.isOpened {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .allowUserInteraction, animations: {
                    cell.imageView?.transform = CGAffineTransform.init(rotationAngle: .pi/2)
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .allowUserInteraction, animations: {
                    cell.imageView?.transform = CGAffineTransform.init(rotationAngle: .pi/180)
                }, completion: nil)
            }
    
            return cell
        }
        // answer cell
        if let cell = tableView.dequeueReusableCell(withIdentifier: "answer") {
            cell.textLabel?.text = items[indexPath.section].answer[indexPath.row - 1]
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if items[indexPath.section].isOpened {
            let section = IndexSet.init(integer: indexPath.section)

            items[indexPath.section].isOpened = false
            tableView.reloadSections(section, with: .automatic)
        } else {
            items[indexPath.section].isOpened = true
            let section = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(section, with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
