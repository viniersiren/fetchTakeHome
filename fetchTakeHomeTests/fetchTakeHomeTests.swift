//
//  fetchTakeHomeTests.swift
//  fetchTakeHomeTests
//
//  Created by Devin Studdard on 12/21/24.
//


import XCTest
@testable import fetchTakeHome

final class fetchTakeHomeTests: XCTestCase {
    
    var viewModel: RecipeViewModel!
    var mockSession: URLSession!
    
    @MainActor override func setUpWithError() throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        //GAHH
        mockSession = URLSession(configuration: config)
        
        viewModel = RecipeViewModel()
        viewModel.configureSession(mockSession)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockSession = nil
        MockURLProtocol.handlers = [:]
    }

    @MainActor func testEndpointUpdate() {
        let initialEndpoint = viewModel.currentEndpoint
        viewModel.updateEndpoint(.malformedData)
        XCTAssertNotEqual(viewModel.currentEndpoint, initialEndpoint, "Endpoint should update correctly")
    }
    
    @MainActor func testSuccessfulRecipeFetch() async {
        //succes response
        let testData = """
        {
            "recipes": [
                {
                    "cuisine": "Test Cuisine",
                    "name": "Test Recipe",
                    "uuid": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
                }
            ]
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.handlers[Endpoint.allRecipes.url] = { _ in
            (HTTPURLResponse(), testData)
        }
        
        viewModel.updateEndpoint(.allRecipes)
        await viewModel.fetchRecipes()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.recipes.count, 63)
    }
    
    @MainActor func testMalformedDataHandling() async {
        //malformed
        let malformedData = """
        {
            "recipes": [
                {
                    "invalidKey": "bad data"
                }
            ]
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.handlers[Endpoint.malformedData.url] = { _ in
            (HTTPURLResponse(), malformedData)
        }
        
        viewModel.updateEndpoint(.malformedData)
        await viewModel.fetchRecipes()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "Malformed data - check returned code") //must match exactly
        XCTAssertTrue(viewModel.recipes.isEmpty)
    }
    
    @MainActor func testEmptyResponseHandling() async {
        //empty
        let emptyData = """
        {
            "recipes": []
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.handlers[Endpoint.emptyData.url] = { _ in
            (HTTPURLResponse(), emptyData)
        }
        
        viewModel.updateEndpoint(.emptyData)
        await viewModel.fetchRecipes()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "No recipes available")
        XCTAssertTrue(viewModel.recipes.isEmpty)
    }
}
extension fetchTakeHomeTests {
    class MockURLProtocol: URLProtocol {
        static var handlers: [URL: (URLRequest) -> (HTTPURLResponse, Data)] = [:]
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            guard let url = request.url,
                  let handler = MockURLProtocol.handlers[url] else {
                fatalError("No handler for \(request.url?.absoluteString ?? "unknown URL")")
            }
            
            let (response, data) = handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}

extension RecipeViewModel { //extend only for testing so only exists in testing
    func configureSession(_ session: URLSession) {
        self.session = session 
    }
}
