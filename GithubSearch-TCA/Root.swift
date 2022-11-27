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
    case updateSearchResult(TaskResult<GithubSearchResultDTO>)
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
      guard !result.apiExceeded else { return .none }
      if result.totalCount > 0 { state.totalCount = result.totalCount }
      if state.searchResult.count >= state.totalCount {
        state.page = -1
      }
      
      if state.page == 1 {
        state.searchResult = result.items
      } else {
        state.searchResult.append(contentsOf: result.items)
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
      let isNewSearch = keyword != state.keyword
      if keyword != state.keyword {
        state.keyword = keyword
        state.isLoading = false
        self.resetSearch(state: &state)
      } else if state.page == -1 {
        return .none
      }
      
      guard !state.isLoading else { return .none }
      state.isLoading = true
      
      guard !keyword.isEmpty else {
        self.resetSearch(state: &state)
        return .cancel(id: SearchingID.self)
      }
      
      state.page += 1
      let _keyword = keyword
      let _page = state.page
      
      let search = EffectTask<Action>.task {
        await .updateSearchResult(TaskResult { try await API.search(keyword: _keyword, page: _page) })
      }
        .debounce(id: SearchingID.self, for: .milliseconds(500), scheduler: DispatchQueue.main)
      
      return isNewSearch ?
        .concatenate(.cancel(id: SearchingID.self), search) :
      search
    }
  }
  
  private func resetSearch(state: inout State) {
    state.totalCount = 0
    state.searchResult = []
    state.page = 0
  }
}
