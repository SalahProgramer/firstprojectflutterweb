import UIKit
import Flutter
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure() // Initialize Firebase
        GeneratedPluginRegistrant.register(with: self)

        if let url = launchOptions?[.url] as? URL {
            return handleIncomingURL(url)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return handleIncomingURL(url)
    }

    private func handleIncomingURL(_ url: URL) -> Bool {
        print("Received deep link: \(url)")
        // You might need to pass the URL to Flutter if necessary
        return true
    }
}
