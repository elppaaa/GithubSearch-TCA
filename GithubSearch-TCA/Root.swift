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
    var isLoading = false
  }
  
  enum Action {
    case updateSearchResult(TaskResult<[SearchResult]>)
    case search(String)
    case viewAppeared(Int) // id
  }
  
  private enum SearchingID {}
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
      
    case let .viewAppeared(id):
      guard !state.isLoading else { return .none }
      if state.searchResult.suffix(10).map(\.id).contains(id) {
        let keyword = state.keyword
        return .task { .search(keyword) }
      }
      
      return .none
      
      
    case let .updateSearchResult(.success(result)):
      defer { state.isLoading = false }
      
      if state.page == 1 {
        state.searchResult = result
      } else {
        state.searchResult.append(contentsOf: result)
      }
      return .none
      
    case let .updateSearchResult(.failure(error)):
      defer { state.isLoading = false }
      // TODO: Error handling 필요
      assertionFailure(String(describing: error))
      return .none
      
      // 키워드 변경 처리.
      // 변경시 page 변경 처리
    case let .search(keyword):
      if state.keyword == keyword && state.page == -1 { return .none }
      if keyword != state.keyword {
        state.page = 1
        state.isLoading = false
        state.searchResult = []
      } else {
        state.page += 1
      }
      state.keyword = keyword
      
      guard !state.isLoading else { return .none }
      state.isLoading = true
      
      guard !keyword.isEmpty else {
        state.searchResult = []
        return .cancel(id: SearchingID.self)
      }
      
      let _keyword = keyword
      let _page = state.page
      
      return .task {
        await .updateSearchResult(TaskResult { try await API.search(keyword: _keyword, page: _page) })
      }
      .debounce(id: SearchingID.self, for: .milliseconds(300), scheduler: DispatchQueue.main)
    }
  }
}
