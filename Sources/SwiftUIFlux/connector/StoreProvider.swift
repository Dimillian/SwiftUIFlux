//
//  File.swift
//  
//
//  Created by Thomas Ricouard on 23/07/2019.
//

import SwiftUI

public struct StoreProvider<S: FluxState, V: View>: View {
    public let store: Store<S>
    public let content: () -> V
    
    public init(store: Store<S>, content: @escaping () -> V) {
        self.store = store
        self.content = content
    }
    
    public var body: some View {
        content().environmentObject(store)
    }
}
