// MARK: Imports

import Foundation
import Amplify
import AmplifyPlugins
import Combine

// MARK: Classes

final class BehaviorLocationManager: ObservableObject, APIManagerInjector {

    // Cateogry
    @Published var selectedCategory: Category = .safe {
        willSet {
            selectedCategory_PREV = selectedCategory
        }
        didSet {
            behaviors = behaviors_CACHE.filter({ $0.location == selectedLocation && $0.category == selectedCategory })
            selectedBehavior = behaviors.first
        }
    }
    var selectedCategory_PREV: Category?

    // Behavior
    private var behaviors_CACHE: [Behavior] = [] {
        didSet {
            behaviors = behaviors_CACHE.filter({ $0.location == selectedLocation && $0.category == selectedCategory })
        }
    }
    var behaviors = [Behavior]()
    @Published var selectedBehavior: Behavior? { willSet { selectedBehavior_PREV = selectedBehavior } }
    var selectedBehavior_PREV: Behavior?

    // Location
    var locations = [Location]()
    @Published var selectedLocation: Location? {
        willSet {
            selectedLocation_PREV = selectedLocation
        }
        didSet {
            behaviors = behaviors_CACHE.filter({ $0.location == selectedLocation && $0.category == selectedCategory })
            selectedBehavior = behaviors.first
        }
    }
    var selectedLocation_PREV: Location?

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
            self.behaviors_CACHE = locals
            apiManager.fetchOnlineList { (remotes: [Behavior]) in
                print("Attempting to fetch behaviors from remote: ", remotes.count)
                remotes.forEach({ remote in
                    if !self.behaviors_CACHE.contains(remote),
                        let location = self.locations.first(where: { $0 == remote.location })
                    {
                        var behavior = remote
                        behavior.location = location
                        self.apiManager.save(entity: behavior) { didSave in
                            if didSave {
                                self.behaviors_CACHE.append(behavior)
                            }
                        }
                    }
                })
                /// Flush outdated behaviors
                locals.forEach({ local in
                    if !remotes.isEmpty && !remotes.contains(local) {
                        self.apiManager.delete(entity: local)
                        if let index = self.behaviors_CACHE.firstIndex(where: { $0.id == local.id }) {
                            self.behaviors_CACHE.remove(at: index)
                        }
                    }
                })
            }
        }
    }

    func clearFromDataStore() {
        Amplify.DataStore.query(Behavior.self) {
            switch $0 {
            case .success(let behaviors):
                // result will be of type [Post]
                behaviors.forEach({ _ = Amplify.DataStore.delete($0) })
                self.behaviors_CACHE.removeAll()
                self.behaviors.removeAll()
                self.selectedBehavior = nil
                self.selectedBehavior_PREV = nil
            case .failure(let error):
                print("Error on query() for type Behavior - \(error.localizedDescription)")
            }
        }

        Amplify.DataStore.query(Location.self) {
            switch $0 {
            case .success(let locations):
                // result will be of type [Post]
                locations.forEach({ _ = Amplify.DataStore.delete($0) })
                self.locations.removeAll()
                self.selectedLocation = nil
                self.selectedLocation_PREV = nil
            case .failure(let error):
                print("Error on query() for type Location - \(error.localizedDescription)")
            }
        }
    }
}
