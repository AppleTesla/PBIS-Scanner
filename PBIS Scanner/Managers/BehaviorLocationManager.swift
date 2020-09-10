// MARK: Imports

import Foundation
import Amplify
import AmplifyPlugins
import Combine

// MARK: Classes

final class BehaviorLocationManager: ObservableObject, APIManagerInjector {

    @Published var selectedCategory: Category = .safe {
        willSet {
            selectedCategory_PREV = selectedCategory
        }
        didSet {
            selectedBehavior = behaviors.filter({ $0.location == selectedLocation && $0.category == selectedCategory }).first
        }
    }
    @Published var selectedCategory_PREV: Category?

    @Published var behaviors = [Behavior]()

    @Published var locations = [Location]()
    @Published var selectedLocation: Location? {
        willSet {
            selectedLocation_PREV = selectedLocation
        }
        didSet {
            selectedBehavior = behaviors.filter({ $0.location == selectedLocation && $0.category == selectedCategory }).first
        }
    }
    @Published var selectedLocation_PREV: Location?

    @Published var selectedBehavior: Behavior? { willSet { selectedBehavior_PREV = selectedBehavior } }
    @Published var selectedBehavior_PREV: Behavior?

    init() {
        initializeLocations()
        initializeBehaviors()
    }
}

// MARK: Locations

extension BehaviorLocationManager {
    func initializeLocations() {
        apiManager.offlineFetch { (locals: [Location]) in
            self.locations = locals
            apiManager.fetchOnlineAtomic(Location.self, withType: String.self) { (remotes: [String]) in
                print("Attempting to fetch locations from remote: ", remotes.count)
                remotes.forEach({ remote in
                    if !self.locations.contains(where: { $0.name == remote }) {
                        let location = Location(id: remote, name: remote)
                        self.apiManager.save(entity: location) { didSave in
                            if didSave && !self.locations.contains(location) {
                                if didSave {
                                    self.locations.append(location)
                                }
                            }
                        }
                    }
                })
                /// Flush outdated locations
                locals.forEach({ local in
                    if !remotes.isEmpty && !remotes.contains(local.name) {
                        self.apiManager.delete(entity: local)
                        if let index = self.locations.firstIndex(where: { $0.name == local.name }) {
                            self.locations.remove(at: index)
                        }
                    }
                })
                /// Sort locations alphabetically
                self.locations.sort { (prev, cur) -> Bool in
                    prev.name < cur.name
                }
            }
        }
    }
}

// MARK: Behaviors

extension BehaviorLocationManager {
    func initializeBehaviors() {
        apiManager.offlineFetch { (locals: [Behavior]) in
            self.behaviors = locals
            apiManager.fetchOnlineList { (remotes: [Behavior]) in
                print("Attempting to fetch behaviors from remote: ", remotes.count)
                remotes.forEach({ remote in
                    if !self.behaviors.contains(remote),
                        let location = self.locations.first(where: { $0 == remote.location })
                    {
                        var behavior = remote
                        behavior.location = location
                        self.apiManager.save(entity: behavior) { didSave in
                            if didSave {
                                self.behaviors.append(behavior)
                            }
                        }
                    }
                })
                /// Flush outdated behaviors
                locals.forEach({ local in
                    if !remotes.isEmpty && !remotes.contains(local) {
                        self.apiManager.delete(entity: local)
                        if let index = self.behaviors.firstIndex(where: { $0.id == local.id }) {
                            self.behaviors.remove(at: index)
                        }
                    }
                })
            }
        }
    }
}
