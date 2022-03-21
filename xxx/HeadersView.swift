//
//  Headers.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI

struct header: View {
    @ObservedObject var settings: UserDefaultsSettings
    var text: String
    
    var body: some View {
        VStack {
            Text(text)
                .foregroundColor(settings.theme == 0 ? .offWhite : .darkStart)
                .font(.system(size: UIScreen.main.bounds.height / 30))
                .fontWeight(.bold)
                .frame(width: UIScreen.main.bounds.width)
                .padding(.top, UIScreen.main.bounds.height*0.05)
                .padding(.bottom, UIScreen.main.bounds.height*0.01)
                .background(BlurBG(settings: settings))
                .cornerRadius(25, corners: [.bottomRight, .bottomLeft])
                .edgesIgnoringSafeArea(.top)
            
//            Spacer()
        }
    }
}

struct Tittle: View {
    @ObservedObject var settings: UserDefaultsSettings
    var text: String
    var name: String = ""
    var fontValue: CGFloat = UIScreen.main.bounds.height / 20
    
    var body: some View {
        HStack {
            if !name.isEmpty {
                Image(systemName: name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width*0.07, height: UIScreen.main.bounds.width*0.07)
                    .foregroundColor(settings.theme == 0 ? .offWhite : .darkStart)
            }
            
            Text(text)
                .foregroundColor(settings.theme == 0 ? .offWhite : .darkStart)
                .font(.system(size: fontValue))
                .fontWeight(.bold)
                .animation(.spring())
        }
    }
}
