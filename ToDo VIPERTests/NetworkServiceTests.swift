//
//  NetworkClient.swift
//  ToDo VIPERTests
//
//  Created by Артур  Арсланов on 07.08.2025.
//

import XCTest
@testable import ToDo_VIPER

final class NetworkServiceTests: XCTestCase {
    var networkService: NetworkService!

    override func setUp() {
        super.setUp()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)

        networkService = NetworkService(session: mockSession)
    }

    override func tearDown() {
        super.tearDown()
        MockURLProtocol.testData = nil
        MockURLProtocol.response = nil
        MockURLProtocol.error = nil
    }

    func test_fetchTasks_success() {
        // Given
        let json = """
        {
            "todos": [
                {
                    "id": 1,
                    "todo": "Test task",
                    "completed": false,
                    "userId": 10
                }
            ]
        }
        """
        MockURLProtocol.testData = json.data(using: .utf8)
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "https://dummyjson.com/todos")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let expectation = self.expectation(description: "FetchTasks")

        // When
        networkService.fetchTasks { result in
            // Then
            switch result {
            case .success(let tasks):
                XCTAssertEqual(tasks.count, 1)
                XCTAssertEqual(tasks.first?.todo, "Test task")
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func test_fetchTasks_failure_invalidJSON() {
        // Given
        let invalidJSON = "{ invalid json }"
        MockURLProtocol.testData = invalidJSON.data(using: .utf8)

        let expectation = self.expectation(description: "DecodeFailure")

        // When
        networkService.fetchTasks { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertTrue(error is DecodingError)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func test_fetchTasks_failure_noData() {
        // Given
        MockURLProtocol.testData = nil

        let expectation = self.expectation(description: "NoData")

        // When
        networkService.fetchTasks { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Данные не удалось прочитать, так как они имеют неверный формат.")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func test_fetchTasks_failure_networkError() {
        // Given
        MockURLProtocol.error = NSError(domain: "Test", code: -1)

        let expectation = self.expectation(description: "NetworkError")

        // When
        networkService.fetchTasks { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected network error")
            case .failure(let error):
                XCTAssertEqual((error as NSError).domain, "Test")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}


final class MockURLProtocol: URLProtocol {
    static var testData: Data?
    static var response: URLResponse?
    static var error: Error?

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let error = MockURLProtocol.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = MockURLProtocol.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = MockURLProtocol.testData {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
    
    
}
