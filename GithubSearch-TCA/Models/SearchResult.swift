//
//  SearchResult.swift
//  GithubSearch-TCA
//
//  Created by 송준권 on 2022/11/27.
//

import Foundation

/*
curl -H 'Accept: application/vnd.github.text-match+json' \
'https://api.github.com/search/issues?q=windows+label:bug \
+language:python+state:open&sort=created&order=asc'
*/


struct GithubSearchResultDTO: Decodable {
//  let totalCount: Int
  let items: [SearchResult]
}


struct SearchResult: Decodable {
  let id: Int
  let name: String
}

extension SearchResult: Identifiable, Equatable { }

final class API {
  private init() { }
  static let per_page = 30
  static let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    return decoder
  }()
  
  static func search(keyword: String, page: Int = 0) async throws -> [SearchResult] {
    guard let request = createURLRequest(keyword: keyword, page: page) else { return [] }
    let result = try await URLSession.shared.data(for: request)
    let data = try decodeSerachResult(from: result.0)
    
    return data
  }

  private static func createURLRequest(keyword: String, page: Int) -> URLRequest? {
    guard let url = URL(string: "https://api.github.com/search/repositories?q=\(keyword)&per_page=\(per_page)&page=\(page)") else {
      return nil
    }
    var request = URLRequest(url: url)
    
    request.addValue("application/vnd.github.text-match+json", forHTTPHeaderField: "Accept")
    
    return request
  }
  
  private static func decodeSerachResult(from data: Data) throws -> [SearchResult] {
    try decoder.decode(GithubSearchResultDTO.self, from: data).items
  }
}
