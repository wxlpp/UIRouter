![UIRouter: Router in Swift](https://raw.githubusercontent.com/wxlpp/UIRouter/main/log.png)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/UIRouter.svg)](https://img.shields.io/cocoapods/v/UIRouter.svg)
![Cocoapods](https://img.shields.io/cocoapods/l/UIRouter)
![Bitbucket open issues](https://img.shields.io/bitbucket/issues/wxlpp/UIRouter)
![Documentation](https://raw.githubusercontent.com/wxlpp/UIRouter/main/docs/badge.svg)

UIRouter 是一个用Swift实现的路由解耦框架.
[API文档](https://wxlpp.github.io/UIRouter/)
## 安装

### CocoaPods

```ruby
pod 'UIRouter', '~> 0.2.0.alpha'
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/wxlpp/UIRouter", .upToNextMajor(from: "0.2.0"))
]
```
## 使用

### 页面注册

```swift
import UIKit
import UIRouter

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 可以在此调用 autoRegisterIfNeed 进行页面预注册，否则会在第一次页面路由发生时进行注册
        application.router.autoRegisterIfNeed()
        // 注册拦截器，WebInterceptor 是一个默认实现的 htttp 协议拦截器
        application.router.register(interceptors: [WebInterceptor()])
        // 注册错误处理器进行错误处理
        application.router.registerErrorHandler(RouteErrorHandler())
        return true
    }
}

```

```swift
import UIKit
import UIRouter

public final class UserProfileViewController: UIViewController {}

// MARK: 路由

extension UserProfileViewController: Routable {
    public static var paths: [String] {
        ["user/profile/:id"]
    }

    public static func route(parameters: RouterParameters, object: Any?, completion: @escaping RouteCompletionHandler<UserProfileViewController>) {
        if let userID: String = parameters.get("userID") {
            completion(.success(UserProfileViewController()))
        } else {
            completion(.failure(RouteError.parameterValidationFailed(vcType: Self.self, name: "userID")))
        }
    }
}
```
### 页面路由
```swift
UIApplication.shared.route(url: "user/profile/123456?name=wxlpp").push()
UIApplication.shared.route(url: "https://github.com/wxlpp/UIRouter").present()
UIApplication.shared.route(url: "flutter://shop.com/home").presentWithNavigationController(UINavigationController.self)
```
### 错误拦截
```swift
import UIRouter

class RouteErrorHandler: RouteErrorHandling {
    func handleRouteError(_ error: RouteError) {
        #if DEBUG
            let vc = ErrorDetailsViewController(error: error)
            UIApplication.shared.route(viewcontroller: vc).presentWithNavigationController(UINavigationController.self)
        #else
            debugPrint(error.errorDescription)
        #endif
    }

    func handleCustomError(_ error: Error) {
        //这里对业务错误信息进行处理，比如用户鉴权失败弹出登录页面
    }
}
```