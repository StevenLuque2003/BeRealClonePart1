import UIKit
import ParseSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ParseSwift.initialize(applicationId: "llmowKP60ggxkUa51g7RhLSexGGSy3uVi7pdRLb6",
                              clientKey: "nKLrhRz239fu2NlUYmjSPLdEjzG8s2BCMoTKjjEM",
                              serverURL: URL(string: "https://parseapi.back4app.com")!)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }


}

