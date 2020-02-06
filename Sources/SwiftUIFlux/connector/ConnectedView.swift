//
//  File.swift
//  
//
//  Created by Thomas Ricouard on 23/07/2019.
//

import SwiftUI

public protocol ConnectedView: View {
    associatedtype StoreState: FluxState
    associatedtype Props
    associatedtype V: View
    
    func map(state: StoreState, dispatch: @escaping DispatchFunction) -> Props
    func body(props: Props) -> V
}

public extension ConnectedView {
    func render(state: StoreState, dispatch: @escaping DispatchFunction) -> V {
        let props = map(state: state, dispatch: dispatch)
        return body(props: props)
    }
    
    var body: StoreConnector<StoreState, V> {
        return StoreConnector(content: render)
    }
}
