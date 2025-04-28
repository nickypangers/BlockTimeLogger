//
//  ViewExt.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/4/2025.
//

import SwiftUI

extension View {
    func aviationInputStyle() -> some View {
        self
            .disableAutocorrection(true)
            .textContentType(.none)
            .textInputAutocapitalization(.characters)
    }

    func sectionHeaderStyle() -> some View {
        self
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Color(.systemGray))
            .kerning(0.5)
    }
}
