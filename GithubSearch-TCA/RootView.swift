//
//  RootView.swift
//  GithubSearch-TCA
//
//  Created by 송준권 on 2022/11/27.
//

import SwiftUI

import ComposableArchitecture

struct RootView: View {
  let store: StoreOf<Root>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationView {
        // TODO:  View / Cell 개선
        List(viewStore.searchResult) { result in
          Text(result.name)
            .onAppear {
              viewStore.send(.viewAppeared(result.id))
            }
        }
        .searchable(text: viewStore.binding(get: \.keyword, send: Root.Action.search))
      }
    }
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(store: Store(
      initialState: Root.State(),
      reducer: Root()))
  }
}
