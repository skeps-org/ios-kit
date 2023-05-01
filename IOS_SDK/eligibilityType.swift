
import Foundation

struct EligibilityType : Identifiable, Decodable {
    var id : Int?
    var customer_details: CustomerDetails
    var offer_data: OfferData
    var offer_type, merchant_name, landing_url_path: String
    var success: Bool?
    
    struct CustomerDetails : Decodable {
        var first_name: String?
    }
    struct OfferData: Decodable  {
//        var offers, worst_offers: [Offer]
//        var expiry: Date
    }

    struct Offer:Decodable {
        var id: String
        var type: TypeEnum
        var lender: Lender
        var firstPaymentUpfront, requiresDownPayment: Bool
        var downPayment, minAmount, maxAmount: Int
        var paymentFrequency: String
        var paymentFrequencyUnit: PaymentFrequencyUnit
        var term: Int
        var termUnit: TermUnit
        var numPayments: Int
        var apr, interestRate: Double
        var isDiscounted, isAutoPayRequired, isPromoApplicable, isLateFeeApplicable: Bool
        var parentOfferID: String?
        var loanAmount, mdr, mdrValue, mdrCents: Int
        var paymentAmount: Double
        var showOffer: Bool
        var paymentScheduler: [PaymentScheduler]
        var totalPayment, totalInterest: Double
    }

    enum Lender:Decodable {
        case fnbo
    }

    enum PaymentFrequencyUnit : Decodable{
        case days
        case month
    }

    struct PaymentScheduler:Decodable {
        var date: String
        var amount: Double
    }

    enum TermUnit : Decodable{
        case days
        case months
    }

    enum TypeEnum: Decodable {
        case interestRateProduct
        case payIn5
    }

}


struct EventType: Decodable {
  let type: String
}
