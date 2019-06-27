import XCTest
@testable import SwiftUIFlux

struct TestState: FluxState {
    var count = 0
}

struct IncrementAction: Action { }

func testReducer(state: TestState, action: Action) -> TestState {
    var state = state
    switch action {
    case _ as IncrementAction:
        state.count += 1
    default:
        break
    }
    return state
}

@available(iOS 13.0, *)
final class SwiftUIFluxTests: XCTestCase {
    let store = Store<TestState>(reducer: testReducer, state: TestState(), queue: .main)
    
    func testStore() {
        XCTAssert(store.state.count == 0, "Initial state is not valid")
        store.dispatch(action: IncrementAction())
        DispatchQueue.main.async {
            XCTAssert(self.store.state.count == 1, "Reduced state increment is not valid")
        }
    }

    static var allTests = [
        ("testExample", testStore),
    ]
}
