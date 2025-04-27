import UIKit

class BaseViewController: UIViewController {
    
    private var titleBanner: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleBanner()
    }
    
    private func setupTitleBanner() {
        titleBanner = UILabel()
        titleBanner.text = "ALIC LONSDALE COMMUNICATIONS."
        titleBanner.font = UIFont.boldSystemFont(ofSize: 16)
        titleBanner.textAlignment = .center
        titleBanner.textColor = .white
        titleBanner.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        titleBanner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleBanner)
        
        NSLayoutConstraint.activate([
            titleBanner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleBanner.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
