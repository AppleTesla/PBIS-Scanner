// MARK: Imports

import Foundation
import Amplify
import AmplifyPlugins
import Combine

// MARK: Classes

final class JuvenileManager: ObservableObject, APIManagerInjector, NetworkManagerInjector {

    // MARK: Properties

    @Published var juveniles = [Juvenile]()
    @Published var queueVerbalUpdate = ""
    private var juvenilesSubscription: AnyCancellable?

    weak var bucketManagerDelegate: BucketManager?

    // MARK: Initializers

    init() {
        juvenilesSubscription = subscribeToJuveniles()
        fetchJuveniles()
    }

    deinit {
        juvenilesSubscription?.cancel()
    }

    private func subscribeToJuveniles() -> AnyCancellable {
        Amplify.DataStore.publisher(for: Juvenile.self)
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    print("Subscription received error - \(error.localizedDescription)")
                }
            }, receiveValue: { changes in
                guard let juvenile = try? changes.decodeModel(as: Juvenile.self) else { return }
                switch DataStoreMutationType(rawValue: changes.mutationType) {
                case .create:
                    guard juvenile.isEnqueued else { break }
                    self.juveniles.append(juvenile)
                case .delete:
                    if let index = self.juveniles.firstIndex(of: juvenile) {
                        self.juveniles.remove(at: index)
                    }
                case .update:
                    // TODO: Why is deletion behavior so odd?
                    if juvenile.isEnqueued {
                        // Add to queue
                        if !self.juveniles.contains(juvenile) {
                            self.juveniles.append(juvenile)
                            // Verbal Update
                            self.queueVerbalUpdate = "\(juvenile.first_name) was added!"
                        // Already in queue
                        } else if let index = self.juveniles.firstIndex(of: juvenile) {
                            self.juveniles[index] = juvenile
                        }
                    }
                default:
                    break
                }
            })
    }
}

// MARK: Juvenile Fetch

extension JuvenileManager {
    func fetchJuveniles(withEventID id: Int? = nil) {
        var localFetch: [Juvenile] = []

        defer {
            if networkManager.isConnected {
                apiManager.fetchOnlineList { (remotes: [Juvenile]) in
                    remotes.forEach({ remote in
                        // See if remote contains juvenile of interest.
                        var new = remote
                        if let index = localFetch.firstIndex(of: remote), localFetch[index].isEnqueued {
                            new.isEnqueued = true
                        }
                        self.apiManager.save(entity: new)
                    })
                    if !ProcessInfo.processInfo.isLowPowerModeEnabled {
                        DispatchQueue.global(qos: .background).async {
                            // Remove outdated juveniles.
                            localFetch.forEach({ local in
                                if !remotes.contains(local) {
                                    self.apiManager.delete(entity: local)
                                }
                            })
                        }
                    }
                }
            }
        }

        // Look for juveniles offline first.
        apiManager.offlineFetch { (locals: [Juvenile]) in
            localFetch = locals
            locals.forEach({ local in
                if local.event_id == id {
                    var new = local
                    new.isEnqueued = true
                    self.apiManager.save(entity: new)
                }
            })
        }
    }
}

// MARK: Juvenile Deletion

extension JuvenileManager {
    func removeJuvenile(juvenile: Juvenile) {
        var juvenile = juvenile
        juvenile.isEnqueued = false
        apiManager.save(entity: juvenile) { didSave in
            if didSave { if let index = self.juveniles.firstIndex(of: juvenile) {
                self.juveniles.remove(at: index)
                self.queueVerbalUpdate = "\(juvenile.first_name) was removed."
                }
            }
        }
    }

    func removeAllJuveniles() {
        var failures = 0
        for case var juvenile in juveniles {
            juvenile.isEnqueued = false
            apiManager.save(entity: juvenile) { didSave in
                if !didSave { failures += 1; print("WARNING: Could not remove \(juvenile.first_name) from queue.") }
            }
        }
        DispatchQueue.main.async { self.juveniles.removeAll() }
    }
}

// MARK: Juvenile Post

extension JuvenileManager {
    func saveToBucket(with behavior: Behavior?, for juveniles: [Juvenile]) {
        guard let behavior = behavior else { return }

        for juvenile in juveniles {
            self.removeJuvenile(juvenile: juvenile)
            let post = Post(juvenile_id: juvenile.id, behavior_id: behavior.id)
            self.apiManager.save(entity: post)
        }

        self.bucketManagerDelegate?.attemptToPushPosts()
    }
}
