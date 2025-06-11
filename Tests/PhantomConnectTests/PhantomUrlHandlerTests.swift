//
//  PhantomUtilsTests.swift
//  
//
//  Created by Eric McGary on 7/7/22.
//

import XCTest
@testable import PhantomConnect

class PhantomUrlHandlerTests: XCTestCase {
    
    func testCanHandle() throws {

        PhantomConnect.configure(appUrl: "url", cluster: "cluster", redirectUrl: "redirect")

        let prefix = PhantomConnectService.walletProvider.prefix
        let connect = URL(string: "url.scheme://\(prefix)_connect")!
        let disconnect = URL(string: "url.scheme://\(prefix)_disconnect")!
        let singAndSendTransaction = URL(string: "url.scheme://\(prefix)_sign_and_send_transaction")!
        
        let unknown = URL(string: "url.scheme://unknown")!
        
        XCTAssertTrue(PhantomUrlHandler.canHandle(url: connect))
        XCTAssertTrue(PhantomUrlHandler.canHandle(url: disconnect))
        XCTAssertTrue(PhantomUrlHandler.canHandle(url: singAndSendTransaction))
        
        XCTAssertFalse(PhantomUrlHandler.canHandle(url: unknown))
        
    }
    
    func xtestParse() throws {
        
    }
    
}
