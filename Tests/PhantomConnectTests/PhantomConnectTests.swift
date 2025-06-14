//
//  PhantomUtilsTests.swift
//
//
//  Created by Eric McGary on 7/7/22.
//

import XCTest
@testable import PhantomConnect

final class PhantomConnectTests: XCTestCase {
    
    func testConfiguration() throws {
            
        PhantomConnect.configure(appUrl: "url", cluster: "cluster", redirectUrl: "redirect")

        XCTAssertEqual(PhantomConnectService.walletProvider, .phantom)

        PhantomConnect.configure(appUrl: "url", cluster: "cluster", redirectUrl: "redirect", walletProvider: .solflare)

        XCTAssertEqual(PhantomConnectService.walletProvider, .solflare)
        
        XCTAssertEqual(PhantomConnectService.appUrl, "url")
        XCTAssertEqual(PhantomConnectService.cluster, "cluster")
        XCTAssertEqual(PhantomConnectService.redirectUrl, "redirect")
        
    }
    
}
