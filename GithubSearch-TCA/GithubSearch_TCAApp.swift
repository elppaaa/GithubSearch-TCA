//
//  GithubSearch_TCAApp.swift
//  GithubSearch-TCA
//
//  Created by 송준권 on 2022/11/27.
//

import SwiftUI

import ComposableArchitecture

@main
struct GithubSearch_TCAApp: App {
    var body: some Scene {
        WindowGroup {
          RootView(store: Store(initialState: Root.State(), reducer: Root()._printChanges()))
        }
    }
}
