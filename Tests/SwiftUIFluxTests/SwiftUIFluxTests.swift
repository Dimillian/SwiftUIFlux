#if DEBUG
import XCTest
import SwiftUI
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

struct HomeView: ConnectedView {
    struct Props {
        let count: Int
        let onIncrementCount: () -> Void
    }
    
    func text(props: Props) -> String{
        return "\(props.count)"
    }
    
    func map(state: TestState, dispatch: @escaping (Action) -> Void) -> Props {
        return Props(count: state.count,
                     onIncrementCount: { dispatch(IncrementAction()) })
    }
    
    func body(props: Props) -> some View {
        VStack {
            Text(text(props: props))
            Button(action: props.onIncrementCount) {
                Text("Increment")
            }
        }
    }
}

@available(iOS 13.0, *)
final class SwiftUIFluxTests: XCTestCase {
    let store = Store<TestState>(reducer: testReducer, state: TestState())
    
    func testStore() {
        XCTAssert(store.state.count == 0, "Initial state is not valid")
        store.dispatch(action: IncrementAction())
        DispatchQueue.main.async {
            XCTAssert(self.store.state.count == 1, "Reduced state increment is not valid")
        }
    }
    
    func testViewProps() {
        let view = StoreProvider(store: store) {
            HomeView()
        }
        store.dispatch(action: IncrementAction())
        DispatchQueue.main.async {
            var props = view.content().map(state: self.store.state, dispatch: self.store.dispatch(action:))
            XCTAssert(props.count == 1, "View state is not correct")
            props.onIncrementCount()
            DispatchQueue.main.async {
                props = view.content().map(state: self.store.state, dispatch: self.store.dispatch(action:))
                XCTAssert(props.count == 2, "View state is not correct")
            }
            
        }
        
    }

    static var allTests = [
        ("testExample", testStore),
    ]
}
#endif
