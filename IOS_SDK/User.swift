import Foundation

struct User: Identifiable, Decodable {
    var id: Int?
    var merchantInfo: MerchantInfo
    
    
    struct MerchantInfo: Decodable {
        var checkoutLandingUrlPath: String
        struct Geo: Decodable {
            var lat: String
            var lng: String
        }
    }
    
    struct Company: Decodable {
        var name: String
        var catchPhrase: String
        var bs: String
    }
}
