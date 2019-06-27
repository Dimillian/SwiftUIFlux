//
//  File.swift
//  
//
//  Created by Thomas Ricouard on 27/06/2019.
//

import Foundation

public protocol AsyncAction: Action {
    func execute(state: FluxState?, dispatch: @escaping DispatchFunction)
}


