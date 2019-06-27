//
//  AppState.swift
//  MovieSwift
//
//  Created by Thomas Ricouard on 06/06/2019.
//  Copyright © 2019 Thomas Ricouard. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@available(iOS 13.0, *)
final public class Store<State: FluxState>: BindableObject {
    
    public enum Queue {
        case main, background
    }
    
    public let didChange = PassthroughSubject<State, Never>()
        
    private(set) public var state: State {
        didSet {
            DispatchQueue.main.async {
                self.didChange.send(self.state)
            }
        }
    }
    
    private let backgroundQueue = DispatchQueue(label: "Flux queue",
                                      qos: DispatchQoS.userInitiated)
    private let reducer: Reducer<State>
    private let lock = NSLock()
    private let queueMode: Queue
    
    public init(reducer: @escaping Reducer<State>, state: State, queue: Queue) {
        self.reducer = reducer
        self.state = state
        self.queueMode = queue
    }
    
    private func currentQueue() -> DispatchQueue {
        queueMode == .main ? DispatchQueue.main : backgroundQueue
    }
        
    public func dispatch(action: Action) {
        currentQueue().async {
            self.lock.lock()
            var state = self.state
            state = self.reducer(state, action)
            self.state = state
            self.lock.unlock()
        }
    }
}
