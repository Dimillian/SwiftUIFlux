//
//  File.swift
//  
//
//  Created by Thomas Ricouard on 27/06/2019.
//

public typealias DispatchFunction = (Action) -> Void
public typealias Middleware<State> = (@escaping DispatchFunction, @escaping () -> FluxState?)
    -> (@escaping DispatchFunction) -> DispatchFunction
