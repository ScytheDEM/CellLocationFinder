import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let mapVC = MapViewController()
        mapVC.title = "Map"
        mapVC.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map.fill"), tag: 0)
        
        let compassVC = CompassViewController()
        compassVC.title = "Compass"
        compassVC.tabBarItem = UITabBarItem(title: "Compass", image: UIImage(systemName: "location.north.line.fill"), tag: 1)
        
        let arVC = ARViewController()
        arVC.title = "AR View"
        arVC.tabBarItem = UITabBarItem(title: "AR View", image: UIImage(systemName: "camera.viewfinder"), tag: 2)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: mapVC),
            UINavigationController(rootViewController: compassVC),
            UINavigationController(rootViewController: arVC)
        ]
        
        // --- Style the Tab Bar ---
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.tabBar.tintColor = .white

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}
