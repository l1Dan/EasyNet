//
//  PhotosTableViewController.swift
//  EasyNetDemoSwift
//
//  Created by lidan on 2021/5/27.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class PhotosTableViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = CGFloat(120)
        tableView.register(PhotosTableViewCell.self, forCellReuseIdentifier: String(describing: PhotosTableViewCell.self))
        return tableView
    }()
    
    private let itemsObservable = BehaviorRelay<[PhotoModel]>(value: [])
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Photos"
        view.backgroundColor = .white
        
        NetworkListener.shared.networkListenerChangeStatus { [weak self] _ in
            self?.sendRequest()
        }
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

extension PhotosTableViewController {
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        itemsObservable.bind(to: tableView.rx.items(cellIdentifier: String(describing: PhotosTableViewCell.self), cellType: PhotosTableViewCell.self)
        ) { row, photo, cell in
            cell.photoModel = photo
            cell.textLabel?.text = photo.title
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.bind { [weak self] indexPath in
            let profile = ProfileTableViewController()
            profile.userId = self?.itemsObservable.value[indexPath.row].userId ?? 0.0
            self?.navigationController?.pushViewController(profile, animated: true)
        }.disposed(by: disposeBag)
        
    }
    
    private func sendRequest() {
        SVProgressHUD.show(withStatus: nil)
        NetworkClient.default.requestPhotos { request in
            SVProgressHUD.showSuccess(withStatus: nil)
            SVProgressHUD.dismiss(withDelay: 0.2)
            if let responses = request.convertObject as? [PhotoResponse] {
                self.itemsObservable.accept(responses.map { PhotoModel(photoResponse: $0) })
            }
        } failure: { request in
            SVProgressHUD.showSuccess(withStatus: nil)
            SVProgressHUD.dismiss(withDelay: 0.2)
            print(request.error ?? "")
        }
    }
    
}


extension PhotosTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

