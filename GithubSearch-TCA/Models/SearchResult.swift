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


struct SearchResult: Equatable {
  let id: Int
  let name: String
}

extension SearchResult: Identifiable { }
extension SearchResult: Decodable { }

final class API {
  private init() { }
  
  static func search(keyword: String, page: Int = 0) async throws -> [SearchResult] {
    let url = createURL(keyword: keyword, page: page)
    let result = try await URLSession.shared.data(from: url)
    let data = try JSONDecoder().decode([SearchResult].self, from: result.0)
    return data
  }

  private static func createURL(keyword: String, page: Int ) -> URL {
    // TODO: 정확한 URL 적기
    URL(string: "https://github.com/~~\(keyword)&page=\(page)")!
  }
}
