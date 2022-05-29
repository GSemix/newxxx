//
//  TextErrorView.swift
//  xxx
//
//  Created by Семен Безгин on 29.05.2022.
//

import SwiftUI

struct inputError: View {
    @Binding var errorInput: String
    
    var body: some View {
        Text(errorInput)
            .font(.system(size: 20))
            .foregroundColor(.red.opacity(0.7))
            .transition(.opacity)                       // Не работает transition для Text
    }
}
