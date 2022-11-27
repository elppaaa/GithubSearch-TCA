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
  let message: String?
  let totalCount: Int
  let items: [SearchResult]
  
  var apiExceeded: Bool {
    message?.contains("API rate limit") ?? false
  }
}

extension GithubSearchResultDTO {
  enum CodingKeys: CodingKey {
    case message
    case totalCount
    case items
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    // error message
    self.message = try container.decodeIfPresent(String.self, forKey: .message)
    
    self.totalCount = try container.decodeIfPresent(Int.self, forKey: .totalCount) ?? -1
    self.items = try container.decodeIfPresent([SearchResult].self, forKey: .items) ?? []
  }
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
  
  static func search(keyword: String, page: Int = 0) async throws -> GithubSearchResultDTO {
    guard let request = createURLRequest(keyword: keyword, page: page) else {
      throw NSError(domain: "Failed to create URL", code: -1)
    }
    let result = try await URLSession.shared.data(for: request)
    let searchResult = try decoder.decode(GithubSearchResultDTO.self, from: result.0)
    
    return searchResult
  }

  private static func createURLRequest(keyword: String, page: Int) -> URLRequest? {
    guard let url = URL(string: "https://api.github.com/search/repositories?q=\(keyword)&per_page=\(per_page)&page=\(page)") else {
      return nil
    }
    var request = URLRequest(url: url)
    
    request.addValue("application/vnd.github.text-match+json", forHTTPHeaderField: "Accept")
    
    return request
  }
}
