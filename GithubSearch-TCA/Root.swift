//
//  Root.swift
//  GithubSearch-TCA
//
//  Created by 송준권 on 2022/11/27.
//

import Foundation
import Combine

import ComposableArchitecture

struct Root: ReducerProtocol {
  struct State: Equatable {
    var searchResult: [SearchResult] = []
    var totalCount = 0
    var page = 0
    var keyword = ""
  }
  
  enum Action {
    case updateSearchResult(TaskResult<[SearchResult]>)
    case search(String)
  }
  
  private enum SearchingID {}
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
      
    case let .updateSearchResult(.success(result)):
      state.searchResult = result
      return .none
      
    case .updateSearchResult(.failure(_)):
      // TODO: Error handling 필요
      return .none
      
      // 키워드 변경 처리.
      // 변경시 page 변경 처리
    case let .search(keyword):
      if keyword != state.keyword { state.page = 1 }
      else { state.page += 1 }
      state.keyword = keyword
      
      guard !keyword.isEmpty else {
        state.searchResult = []
        return .cancel(id: SearchingID.self)
      }
      
      let _keyword = keyword
      let _page = state.page
      
      return .task {
        await .updateSearchResult(TaskResult { try await API.search(keyword: _keyword, page: _page)})
      }
      .debounce(id: SearchingID.self, for: .milliseconds(500), scheduler: DispatchQueue.main)
    }
  }
}
