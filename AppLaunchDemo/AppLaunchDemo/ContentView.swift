//
//  ContentView.swift
//  AppLaunchDemo
//
//  Created by Ming Dai on 2024/12/22.
//

import SwiftUI

struct ContentView: View {
    @State var state: String = ""
    
    var body: some View {
        EmptyView()
            .onOpenURL { url in
                // SwiftPamphletApp://view?content=detail
                if let content = URLComponents(url: url, resolvingAgainstBaseURL: true)?
                    .queryItems?.first(where: { $0.name == "content" })?.value {
                    if content == "detail" {
                        state = "detail"
                    } else {
                        state = ""
                    }
                }
            }
        if state == "detail" {
            DetailView(state: $state)
        } else {
            // 首页
            HomeView()
        }
    }
}

struct HomeView: View {
    var body: some View {
        ScrollView {
            TaskCaseUIUpdateView(isBad: false)
                .onAppear {
                    Perf.showTime("UI update view")
                }
//            TaskCaseAnimationView(isBad: false)
//                .onAppear {
//                    Perf.showTime("Animation View")
//                }
            TaskCaseBigImageView(isBad: false)
                .onAppear {
                    Perf.showTime("Big image view")
                }
            TaskCaseCacheView()
            // Asynchronous execution, but a large computational load may impact the main thread.
//            TaskCasePriorityView(isBad: false)
//                .onAppear {
//                    Perf.showTime(des: "Priority view.")
//                }
        }
    } // end body
}

struct DetailView: View {
    @Binding var state: String
    var body: some View {
        VStack {
            Text("Detail View here")
            Button(action: {
                state = ""
            }) {
                Text("Back")
            }
        }
    }
}
