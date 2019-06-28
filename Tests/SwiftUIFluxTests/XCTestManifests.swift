#if DEBUG
import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwiftUIFluxTests.allTests),
    ]
}
#endif
#endif
