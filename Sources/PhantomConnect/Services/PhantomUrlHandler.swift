//
//  PhantomUrlHandler.swift
//  PhantomConnect
//
//  Created by Eric McGary on 6/28/22.
//

import Foundation
import Solana

public class PhantomUrlHandler {
    
    // ============================================================
    // === Internal Static API ====================================
    // ============================================================
        
    // MARK: - Internal API
    
    // MARK: Internal Static Methods
    
    /// Determines whether or not the url trying to be opened is one coming from phantom
    /// - Parameter url: The incoming url
    /// - Returns: bool of whether or not the url can be handled by the phantom connect service
    public static func canHandle(url: URL) -> Bool {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        
        let prefix = PhantomConnectService.walletProvider.prefix
        let slugs = [
            "\(prefix)_connect",
            "\(prefix)_disconnect",
            "\(prefix)_sign_transaction",
            "\(prefix)_sign_all_transactions",
            "\(prefix)_sign_and_send_transaction",
            "\(prefix)_sign_message"
        ]
        
        return slugs.contains(where: { $0 == components.host ?? ""})
        
    }
    
    /// Handler for incoming links from phantom app
    /// - Parameters:
    ///   - url: Incoming url from phantom
    ///   - phantomEncryptionPublicKey: Public encryption key returned from the initial phantom wallet connection.
    ///   - dappSecretKey: Encryption secret key used during the initial connect and future sharedSecrets. This is a 32 byte private key, not a 64 byte signing secret key.
    /// - Returns: Deeplink parsed from the passed url
    public static func parse(
        url: URL,
        phantomEncryptionPublicKey: PublicKey? = nil,
        dappSecretKey: Data? = nil
    ) throws -> PhantomDeeplink {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let host = components.host else {
            return .unknown
        }
        
        var params: [String: Any] = [:]
        
        components.queryItems?.forEach({ queryItem in
            params[queryItem.name] = queryItem.value
        })
        
        var error: Error?
        
        if components.queryItems?[0].name == "errorCode" {
                        
            error = PhantomConnectError.invalidUrl
            
        }
        
        let prefix = PhantomConnectService.walletProvider.prefix

        switch host {
            case "\(prefix)_connect":
                
                guard let phantomEncryptionPublicKey = PublicKey(string: params["phantom_encryption_public_key"] as? String ?? ""),
                      let dappSecretKey = dappSecretKey,
                      let data = params["data"] as? String,
                      let nonce = params["nonce"] as? String else {
                                        
                    return .unknown
                    
                }
                
                let json = try PhantomUtils.decryptPayload(
                    data: data,
                    nonce: nonce,
                    phantomEncryptionPublicKey: phantomEncryptionPublicKey,
                    dappSecretKey: dappSecretKey
                )
  
                guard let publicKey = json?["public_key"], let session = json?["session"] else {
                    return .connect(
                        publicKey: nil,
                        phantomEncryptionPublicKey: nil,
                        session: nil,
                        error: error
                    )
                }

                return .connect(
                    publicKey: PublicKey(string: publicKey),
                    phantomEncryptionPublicKey: phantomEncryptionPublicKey,
                    session: session,
                    error: error
                )
                
            case "\(prefix)_disconnect":
                return .disconnect(
                    error: error
                )
                
            case "\(prefix)_sign_and_send_transaction":
                    
                guard let data = params["data"] as? String,
                      let nonce = params["nonce"] as? String,
                      let phantomEncryptionPublicKey = phantomEncryptionPublicKey,
                      let dappSecretKey = dappSecretKey else {
                    
                    return .signAndSendTransaction(
                        signature: nil,
                        error: error
                    )
                    
                }
                
                let json = try PhantomUtils.decryptPayload(
                    data: data,
                    nonce: nonce,
                    phantomEncryptionPublicKey: phantomEncryptionPublicKey,
                    dappSecretKey: dappSecretKey
                )
                
                guard let signature = json?["signature"] else {
                    return .signAndSendTransaction(
                        signature: nil,
                        error: error
                    )
                }
                
                return .signAndSendTransaction(
                    signature: signature,
                    error: nil
                )
                                
            default:
                return .unknown
        }
        
    }
    
}
