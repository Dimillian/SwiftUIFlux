//
//  File.swift
//  
//
//  Created by Thomas Ricouard on 23/07/2019.
//

import SwiftUI

public struct StoreConnector<StoreState: FluxState, V: View>: View {
    @EnvironmentObject var store: Store<StoreState>
    let content: (StoreState, @escaping (Action) -> Void) -> V
    
    public var body: V {
        content(store.state, store.dispatch(action:))
    }
}
