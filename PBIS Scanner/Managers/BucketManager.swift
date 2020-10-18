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
            guard !posts.isEmpty else { return }
            if observedNWManager.isConnected {
                print("Attempt being made to push \(posts.count) posts.")
                let dispatchGroup = DispatchGroup()
                let semaphore = DispatchSemaphore(value: 1)
                let dispatchQueue = DispatchQueue(label: "com.bucketManager", qos: .userInitiated, attributes: .concurrent)
                dispatchQueue.async(group: dispatchGroup,flags: .barrier) {
                    for post in posts {
                        dispatchGroup.enter()
                        semaphore.wait()
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
                                        self.apiManager.delete(entity: post) { _ in
                                            dispatchGroup.leave()
                                            semaphore.signal()
                                        }
                                    case .failure(let error):
                                        print(error)
                                        dispatchGroup.leave()
                                        semaphore.signal()
                                    }
                                }
                            } else {
                                // Could not serialize post body
                                dispatchGroup.leave()
                                semaphore.signal()
                            }
                        } else {
                            // Could not convert args into attributes
                            dispatchGroup.leave()
                            semaphore.signal()
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    self.apiManager.offlineFetch { (posts: [Post]) in
                        print("\(posts.count) posts remaining.")
                    }
                }
            } else if !posts.isEmpty {
                print("No network...will try to post \(posts.count) posts later.")
            }
        }
    }
}
