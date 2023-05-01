import SwiftUI

class Test: ObservableObject {
    @Published var users: String? = String()
}




class Network: ObservableObject {
    @Published var users: User?
    @Published var eligibilityData: EligibilityType?
    @Published var routerActive: String?=""
    @Published var fieldBeingEdited = false
    
    
    func getUsers(merchantId : String) {
        
        guard let url = URL(string: "https://fnbo-dev.skeps.dev/application/api/pos/v1/oauth/merchant/generate/checkout/hash?merchantId=\(merchantId)") else {
            fatalError("Missing URL")
//            YKVABNVB
        }

        let urlRequest = URLRequest(url: url)

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let decodedUsers = try JSONDecoder().decode(User.self, from: data)
                        self.users = decodedUsers
                        self.routerActive = decodedUsers.merchantInfo.checkoutLandingUrlPath
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }
        }

        dataTask.resume()
    }
    
//    ----------
    func checkEligiblityService(merchantId : String) {
        debugPrint(merchantId)
        guard let url = URL(string: "https://fnbo-dev.skeps.dev/application/api/pos/v1/financing/getEligibleOffersForCIN/") else { fatalError("Missing URL")
//            YKVABNVB
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(merchantId, forHTTPHeaderField: "merchant_id")
        urlRequest.httpMethod = "post"
        let parameters:[String:Any] = [
            "currency": "USD",
            "amount": 400
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        urlRequest.httpBody = jsonData;
          let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            guard let response = response as? HTTPURLResponse else { return }
            debugPrint("response.statusCode\(response.statusCode)")
            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let decoder = JSONDecoder()
                        let messages = try decoder.decode(EligibilityType.self, from: data)
                        self.routerActive = messages.landing_url_path
                        debugPrint(messages as Any)
                        debugPrint("response.body\(messages.landing_url_path)")
                    } catch DecodingError.dataCorrupted(let context) {
                        debugPrint(context)
                    } catch DecodingError.keyNotFound(let key, let context) {
                        debugPrint("Key '\(key)' not found:", context.debugDescription)
                        debugPrint("codingPath:", context.codingPath)
                    } catch DecodingError.valueNotFound(let value, let context) {
                        debugPrint("Value '\(value)' not found:", context.debugDescription)
                        debugPrint("codingPath:", context.codingPath)
                    } catch DecodingError.typeMismatch(let type, let context) {
                        debugPrint("Type '\(type)' mismatch:", context.debugDescription)
                        debugPrint("codingPath:", context.codingPath)
                    } catch {
                        debugPrint("error: ", error)
                    }
                }
            }
        }

        dataTask.resume()
    }
}






