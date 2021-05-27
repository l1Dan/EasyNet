//
//  ProfileTableViewController.swift
//  EasyNetDemoSwift
//
//  Created by lidan on 2021/5/27.
//

import RxSwift
import RxCocoa
import SVProgressHUD

class ProfileTableViewController: UIViewController {
    
    var userId: NSNumber = 0.0 {
        didSet { navigationItem.title = "\(userId)" }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = CGFloat(120)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: String(describing: ProfileTableViewCell.self))
        return tableView
    }()
    
    private let itemsObservable = BehaviorRelay<[String]>(value: [])
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Photos"
        view.backgroundColor = .white
        
        sendUserProfileRequest()
        setupTableView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 12.0, *) {
            if previousTraitCollection?.userInterfaceStyle == .dark {
                SVProgressHUD.setDefaultStyle(.dark)
            } else {
                SVProgressHUD.setDefaultStyle(.light)
            }
        } else {
            SVProgressHUD.setDefaultStyle(.light)
        }
    }

}

extension ProfileTableViewController {
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        itemsObservable.bind(to: tableView.rx.items(cellIdentifier: String(describing: ProfileTableViewCell.self), cellType: ProfileTableViewCell.self)
        ) { row, text, cell in
            cell.textLabel?.text = text
        }.disposed(by: disposeBag)
    }
    
    private func sendUserProfileRequest() {
        SVProgressHUD.show(withStatus: nil)
        
        UserRequest(userId: userId).rx.start(withConvert: UserResponse.self).subscribe { request in
            SVProgressHUD.showSuccess(withStatus: nil)
            SVProgressHUD.dismiss(withDelay: 0.2)
            
            if let response = request.convertObject as? UserResponse {
                self.itemsObservable.accept(UserModel(userResponse: response).profiles)
                self.navigationItem.title = response.name
            }
        } onFailure: { error in
            SVProgressHUD.showSuccess(withStatus: nil)
            SVProgressHUD.dismiss(withDelay: 0.2)
            print(error)
        }.disposed(by: disposeBag)
    }
    
}


extension ProfileTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
