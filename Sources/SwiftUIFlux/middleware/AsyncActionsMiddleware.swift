//
//  File.swift
//  
//
//  Created by Thomas Ricouard on 27/06/2019.
//

import Foundation

public let asyncActionsMiddleware: Middleware<FluxState> = { dispatch, getState in
    return { next in
        return { action in
            if let action = action as? AsyncAction {
                action.execute(state: getState(), dispatch: dispatch)
            }
            return next(action)
        }
    }
}
