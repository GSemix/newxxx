//
//  Wall.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI

struct Wall: View {
    @ObservedObject var settings: UserDefaultsSettings
    var page: Page
    
    var body: some View {
        ZStack {
            LinearGradient(settings.theme == 0 ? Color.darkEnd : Color.offWhite, settings.theme == 0 ? Color.darkStart : Color.offWhite)
                .ignoresSafeArea(.all)
            
            switch page {
            case .navigation:
                Image(systemName: "location")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(settings.theme == 0 ? .darkEnd : .purpleStart)
                    .opacity(settings.theme == 0 ? 0.3 : 0.1)
                    .padding()
                
            case .datalist:
                Image(systemName: "list.bullet")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(settings.theme == 0 ? .darkEnd : .purpleStart)
                    .opacity(settings.theme == 0 ? 0.3 : 0.1)
                    .padding()
                
            case .properties:
                Image(systemName: "gearshape")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(settings.theme == 0 ? .darkEnd : .purpleStart)
                    .opacity(settings.theme == 0 ? 0.3 : 0.1)
                    .padding()
                
            case .maps:
//                Image(systemName: "location")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .foregroundColor(settings.theme == 0 ? .darkEnd : .purpleStart)
//                    .opacity(settings.theme == 0 ? 0.3 : 0.1)
//                    .padding()
                Color.clear
                
            case .news:
                Image(systemName: "newspaper")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(settings.theme == 0 ? .darkEnd : .purpleStart)
                    .opacity(settings.theme == 0 ? 0.3 : 0.1)
                    .padding()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
