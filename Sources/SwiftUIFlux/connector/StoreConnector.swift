//
//  File.swift
//  
//
//  Created by Thomas Ricouard on 23/07/2019.
//

import SwiftUI

public struct StoreConnector<State: FluxState, V: View>: View {
    @EnvironmentObject var store: Store<State>
    let content: (State, @escaping (Action) -> Void) -> V
    
    public var body: V {
        content(store.state, store.dispatch(action:))
    }
}
