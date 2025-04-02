//
//  DetailView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 1/4/2025.
//

import SwiftUI

struct DetailView: View {
    @State var text: String = ""
    @State var picked: String = "1"
    var isPresentingPicker: Bool = false
    var body: some View {
        NavigationView {
            ScrollView {
                Text(text.isEmpty ? "Tap here to start typing" : text)
                TextField("Testing", text: $text)
            }
            .navigationTitle("Detail")
        }
    }
}

#Preview {
    DetailView()
}
