import Foundation

func fetchData(user: UserModel, completion: @escaping (Result<Welcome, Error>) -> Void) {
    
    guard let url = URL(string: "https://test-hmsync.connect-beurer.com/BHMCWebAPI/User/GetValidateUser") else {
        let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        completion(.failure(error))
        return
    }
    
    do {
        let jsonData = try JSONEncoder().encode(user)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
             
                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    completion(.failure(error))
                    return
                }
                
               
                guard (200...299).contains(httpResponse.statusCode) else {
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned an error"])
                    completion(.failure(error))
                    return
                }
                
                let result = try JSONDecoder().decode(Welcome.self, from: data)
                print("Response:", result)
                
                completion(.success(result))
                
            } catch {
                print("Error fetching data:", error)
                completion(.failure(error))
            }
        }
    } catch {
        print("Encoding Error:", error)
        completion(.failure(error))  
    }
}
