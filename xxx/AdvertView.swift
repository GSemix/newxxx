//
//  Advert.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI

struct Advert: View {
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image("1")
                        .resizable()
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)), lineWidth: 3)
                        )                        }
                
                VStack {
                    Image("2")
                        .resizable()
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)), lineWidth: 3)
                        )
                }
            }
            
            HStack {
                VStack {
                    Image("3")
                        .resizable()
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)), lineWidth: 3)
                        )
                }
                
                VStack {
                    Image("4")
                        .resizable()
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)), lineWidth: 3)
                        )
                }
            }
        }
        .frame(height: 210)
        .padding(.horizontal)
    }
}
