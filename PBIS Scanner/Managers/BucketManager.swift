// MARK: Imports

import Foundation
import SwiftUI
import Combine
import Amplify

// MARK: Classes

final class BucketManager: APIManagerInjector {

    private var networkCancellable: AnyCancellable?
    private var countCancellable: AnyCancellable?
    public let postRemainingCount = PassthroughSubject<Int, Never>()
    private var count = 0

    @ObservedObject var observedNWManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.observedNWManager = networkManager
        networkCancellable = observedNWManager.$isConnected.sink(receiveValue: { isConnected in
            if isConnected {
                self.attemptToPushPosts()
            }
        })

        apiManager.offlineFetch { (posts: [Post]) in
            count = posts.count
            countCancellable = postCountCancellable()
        }
    }

    deinit {
        countCancellable?.cancel()
        networkCancellable?.cancel()
    }

    private func postCountCancellable() -> AnyCancellable {
        Amplify.DataStore.publisher(for: Post.self)
            .sink { errors in
            } receiveValue: { changes in
                switch DataStoreMutationType(rawValue: changes.mutationType) {
                case .create:
                    self.count += 1
                case .delete:
                    self.count -= 1
                default:
                    break
                }
                self.postRemainingCount.send(self.count)
            }
    }

    func attemptToPushPosts() {
        apiManager.offlineFetch { (posts: [Post]) in
            postRemainingCount.send(posts.count)
            if !posts.isEmpty && observedNWManager.isConnected {
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

    func clearFromDataStore() {
        Amplify.DataStore.query(Post.self) {
            switch $0 {
            case .success(let posts):
                // result will be of type [Post]
                posts.forEach({ _ = Amplify.DataStore.delete($0) })
            case .failure(let error):
                print("Error on query() for type Juvenile - \(error.localizedDescription)")
            }
        }
    }
}
