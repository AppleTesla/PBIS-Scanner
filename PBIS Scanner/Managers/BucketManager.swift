// MARK: Imports

import Foundation
import SwiftUI
import Combine

// MARK: Classes

final class BucketManager: APIManagerInjector {

    private var cancellable: AnyCancellable?

    @ObservedObject var observedNWManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.observedNWManager = networkManager
        cancellable = observedNWManager.$isConnected.sink(receiveValue: { isConnected in
            if isConnected {
                self.attemptToPushPosts()
            }
        })
    }

    func attemptToPushPosts() {
        apiManager.offlineFetch { (posts: [Post]) in
            if observedNWManager.isConnected {
                print("Attempt being made to push \(posts.count) posts.")

                DispatchQueue.global(qos: .background).async {
                    let dispatchGroup = DispatchGroup()

                    for post in posts {
                        dispatchGroup.enter()
                        if let juvenile_id = Int(post.juvenile_id), let behavior_id = Int(post.behavior_id) {
                            let json: [String: Any] = [
                                "juvenile_id": juvenile_id,
                                "behavior_id": behavior_id
                            ]

                            if let data = try? JSONSerialization.data(withJSONObject: json) {
                                let endpoint = EndpointConfiguration(path: .juvenile(.incr),
                                                                     httpMethod: .post,
                                                                     body: data,
                                                                     queryStrings: nil)

                                self.apiManager.request(from: endpoint) { (result: Result<Juvenile, ResponseError>) in
                                    switch result {
                                    case .success(let juvenile):
                                        print("Successfully pushed \(juvenile.first_name).")
                                        self.apiManager.delete(entity: post) { _ in dispatchGroup.leave() }
                                    case .failure(let error):
                                        print(error)
                                        dispatchGroup.leave()
                                    }
                                }
                            } else {
                                dispatchGroup.leave()
                            }
                        } else {
                            dispatchGroup.leave()
                        }
                    }

                    dispatchGroup.wait()

                    DispatchQueue.main.async {
                        self.apiManager.offlineFetch { (posts: [Post]) in
                            print("Yay, only \(posts.count) posts left.")
                        }
                    }
                }
            } else if !posts.isEmpty {
                print("No network...will try to post \(posts.count) posts later.")
            }
        }
    }
}
