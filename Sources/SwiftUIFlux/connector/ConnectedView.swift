//
//  File.swift
//  
//
//  Created by Thomas Ricouard on 23/07/2019.
//

import SwiftUI

public protocol ConnectedView: View {
    associatedtype State: FluxState
    associatedtype Props
    associatedtype V: View
    
    func map(state: State, dispatch: @escaping DispatchFunction) -> Props
    func body(props: Props) -> V
}

public extension ConnectedView {
    func render(state: State, dispatch: @escaping DispatchFunction) -> V {
        let props = map(state: state, dispatch: dispatch)
        return body(props: props)
    }
    
    var body: StoreConnector<State, V> {
        return StoreConnector(content: render)
    }
}
