import Foundation
import Network

class WidgetNetworkManager {
    static let shared = WidgetNetworkManager()
    
    private let cache: URLCache
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024,  // 50 MB
                                 diskCapacity: 100 * 1024 * 1024)     // 100 MB
        
        self.cache = config.urlCache!
        self.session = URLSession(configuration: config)
    }
    
    func fetchData(from urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        
        // Check cache first
        if let cachedResponse = cache.cachedResponse(for: request),
           let httpResponse = cachedResponse.response as? HTTPURLResponse,
           (200...299).contains(httpResponse.statusCode) {
            completion(.success(cachedResponse.data))
            return
        }
        
        // If not in cache, fetch from network
        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let response = response else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            // Cache the response
            let cachedResponse = CachedURLResponse(response: response, data: data)
            self?.cache.storeCachedResponse(cachedResponse, for: request)
            
            completion(.success(data))
        }.resume()
    }
} 