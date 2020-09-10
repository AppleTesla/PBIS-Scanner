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
        cancellable = observedNWManager.objectWillChange.sink(receiveValue: { [weak self] in
            self?.attemptToPushBuckets()
        })
    }

    func attemptToPushBuckets() {
        if observedNWManager.isConnected {
            apiManager.offlineFetch { (buckets: [Bucket]) in
                for bucket in buckets {
                    if bucket.posts?.isEmpty == true {
                        apiManager.delete(entity: bucket)
                    }
                }
                guard !buckets.isEmpty else { return }
                print("Attempt being made to push \(buckets.count) buckets.")
                for bucket in buckets {
                    bucket.posts?.load({ result in
                        switch result {
                        case .success(let posts):
                            for post in posts {
                                guard let juvenile_id = Int(post.juvenile_id), let behavior_id = Int(post.behavior_id) else { continue }

                                let json: [String: Any] = [
                                    "juvenile_id": juvenile_id,
                                    "behavior_id": behavior_id
                                ]

                                guard let data = try? JSONSerialization.data(withJSONObject: json) else { continue }

                                let endpoint = EndpointConfiguration(path: .juvenile(.incr),
                                                                     httpMethod: .post,
                                                                     body: data,
                                                                     queryStrings: nil)

                                apiManager.request(from: endpoint) { (result: Result<Juvenile, ResponseError>) in
                                    switch result {
                                    case .success(let juvenile):
                                        print("Successfully pushed \(juvenile.first_name) from bucket \(bucket.id).")
                                        self.apiManager.delete(entity: post)
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    })
                    if bucket.posts?.isEmpty == true {
                        apiManager.delete(entity: bucket)
                    }
                }
            }
        } else {
            apiManager.offlineFetch { (buckets: [Bucket]) in
                if !buckets.isEmpty {
                    print("No network...will try to post \(buckets.count) buckets later.")
                }
            }
        }
    }
}
