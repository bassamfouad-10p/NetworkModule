import Foundation
import Alamofire

enum NetworkError: Error {
    
    case transportError(Error)
    case serverError(Int)
    case noData
    case decodingError(Error)
}

public protocol NetworkService {
    
    func execute<Model: Decodable>(url: URL, completion: @escaping ((Result<Model, Error>) -> Void))
}

public struct NetworkSerivceImpl: NetworkService {
    
    let session: URLSession
    let decoder: JSONDecoder
    
    public func execute<Model: Decodable>(url: URL, completion: @escaping ((Result<Model, Error>) -> Void)) {
        
        session.dataTask(with: url) { data , response, error in
            
            if let error = error {
                
                completion(.failure(NetworkError.transportError(error)))
                return
            }
            if let response = response as? HTTPURLResponse, !(200..<300).contains(response.statusCode) {
                
                completion(.failure(NetworkError.serverError(response.statusCode)))
                return
            }
            guard let data = data else {
                
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                
                let model = try decoder.decode(Model.self, from: data)
                completion(.success(model))
                
            } catch let error {
                
                completion(.failure(NetworkError.decodingError(error)))
            }
        }
        .resume()
    }
}

public struct AFNetworkServiceImpl: NetworkService {
    
    public func execute<Model>(url: URL, completion: @escaping ((Result<Model, Error>) -> Void)) where Model : Decodable {
        
        let request = AF.request(url)
        request.responseDecodable(of: Model.self) { dataResponse in
            
            switch dataResponse.result {
                
            case .success(let model):
                completion(.success(model))
            case .failure(let afError):
                if let error = afError as Error? {
                    completion(.failure(error))
                }
            }
        }
    }
}
