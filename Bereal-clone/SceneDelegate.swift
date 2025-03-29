import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private enum Constants {
        static let loginNavigationControllerIdentifier = "LoginNavigationController"
        static let feedNavigationControllerIdentifier = "FeedNavigationController"
        static let storyboardIdentifier = "Main"
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("login"), object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.login()
        }

        NotificationCenter.default.addObserver(forName: Notification.Name("logout"), object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.logOut()
        }

        
        if Users.current != nil {
            login()
        }
    }
    
    private func login() {
        let storyboard = UIStoryboard(name: Constants.storyboardIdentifier, bundle: nil)
        self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: Constants.feedNavigationControllerIdentifier)
    }
    
    private func logOut() {
        Users.logout { [weak self] result in

            switch result {
            case .success:

                DispatchQueue.main.async {

                    let storyboard = UIStoryboard(name: Constants.storyboardIdentifier, bundle: nil)

                    let viewController = storyboard.instantiateViewController(withIdentifier: Constants.loginNavigationControllerIdentifier)

                    self?.window?.rootViewController = viewController
                }
            case .failure(let error):
                print("❌ Log out error: \(error)")
            }
        }

    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}

