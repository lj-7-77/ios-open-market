//
//  DetailViewController.swift
//  OpenMarket
//
//  Created by parkhyo on 2022/12/08.
//

import UIKit

final class DetailViewController: UIViewController {
    private let detailView = DetailProductView()
    private let networkManager = NetworkManager()
    private var productData: Product?
    
    var productID: Int?
    var cellImages: [UIImage] = []
    
    init(id: Int) {
        super.init(nibName: nil, bundle: nil)
        productID = id
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = detailView
        setupData()
        setupNavigationBar()
    }
}

// MARK: - Data Setting
extension DetailViewController {
    private func setupData() {
        guard let productID = productID, let productDetailURL =  NetworkRequest.productDetail(productID: productID).requestURL else { return }
        
        networkManager.fetchData(to: productDetailURL, dataType: Product.self) { result in
            switch result {
            case .success(let product):
                self.productData = product
                self.setupCellsImages(data: product)
                DispatchQueue.main.async {
                    self.title = product.name
                }
            case .failure(let error):
                self.showAlert(alertText: error.description, alertMessage: "오류가 발생했습니다.", completion: nil)
            }
        }
    }
    
    private func setupCellsImages(data: Product) {
        guard let productImages = data.images else { return }
        
        productImages.forEach { productImage in
            networkManager.fetchImage(with: productImage.url) { image in
                self.cellImages.append(image)
            }
        }
    }
}

// MARK: - UI & UIAction
extension DetailViewController {
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        let optionBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(optionButtonTapped))
        
        self.navigationItem.rightBarButtonItem = optionBarButton
    }
    
    @objc func optionButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "수정", style: .default) { _ in
            let modifyViewController = ModifyViewController(data: self.productData, images: self.cellImages)
            self.navigationController?.pushViewController(modifyViewController, animated: true)
        }
        
        let deleteAction = UIAlertAction(title: "삭제", style: .default) { _ in
            //서버에 삭제 메서드 보냄
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

// MARK: - Binding Data in View
extension DetailViewController {
    private func bindingData(_ data: Product?) {
        // 추후 구현
    }
}