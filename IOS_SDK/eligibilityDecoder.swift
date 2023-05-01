//
//  eligibilityDecoder.swift
//  IOS_SDK
//
//  Created by dev tushar on 25/04/23.

import Foundation
import SwiftUI

struct Response : Decodable {
    
    private enum CodingKeys : String, CodingKey { case merchant_id,access_token,order_id }
    
    let merchant_id : String
    let access_token : String
    let order_id : String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        merchant_id = try container.decode(String.self, forKey: .merchant_id)
        access_token = try container.decode(String.self, forKey: .access_token)
        order_id = try container.decode(String.self, forKey: .order_id)
    }
}

