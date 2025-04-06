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
}
