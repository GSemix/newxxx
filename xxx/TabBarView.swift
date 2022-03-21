//
//  TabBar.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI

struct TabBarIconNew: View {
    @ObservedObject var settings: UserDefaultsSettings
    @StateObject var viewRouter: ViewRouter
    let assignedPage: Page
    let width, height: CGFloat
    let systemIconName, tabName: String
    
    var body: some View {
        VStack {
            Button (action: {
                withAnimation {
                    viewRouter.currentPage = assignedPage
                }
            }) {
                VStack {
                    Image(systemName: systemIconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width/15, height: height/23)
                        .foregroundColor(settings.theme == 0 ? Color(viewRouter.currentPage == assignedPage ? UIColor(.lightStart) : .gray) : Color(viewRouter.currentPage == assignedPage ? UIColor(Color.purpleStart) : .gray))
                    
                    Text(tabName)
                        .font(.system(size: 10)) // 18
                        .foregroundColor(settings.theme == 0 ? Color(viewRouter.currentPage == assignedPage ? UIColor(.lightStart) : .gray) : Color(viewRouter.currentPage == assignedPage ? UIColor(Color.purpleStart) : .gray))
                }
            }
            .padding(.horizontal, width/8/6)
            .buttonStyle(GrowingButton())
            
            Spacer()
        }
    }
}

struct tabBarIcons: View {
    @ObservedObject var settings: UserDefaultsSettings
    var geometry: GeometryProxy
    @StateObject var viewRouter: ViewRouter
    var showTabBar: [Page] = [.navigation, .datalist, .properties, .news]
    
    var body: some View {
        if showTabBar.contains(viewRouter.currentPage) {
            VStack {
                
                Spacer()
                
                ZStack {
                    Rectangle() // UIColor.systemBackground
                        .fill(LinearGradient(settings.theme == 0 ? Color.darkStart.opacity(0.97) : Color.offWhite, settings.theme == 0 ? Color.darkEnd : Color.offWhite))
                        .frame(width: geometry.size.width + 2)
                        .cornerRadius(15, corners: [.topRight, .topLeft])
                        .addBorder(LinearGradient(settings.theme == 0 ? Color.lightEnd : Color.purpleEnd, settings.theme == 0 ? Color.lightStart.opacity(0.8) : Color.purpleStart.opacity(0.8)), width: 1, cornerRadius: 15)
                    
                    HStack {
                        Spacer()
                        
                        TabBarIconNew(settings: settings, viewRouter: viewRouter, assignedPage: .navigation, width: geometry.size.width, height: geometry.size.height, systemIconName: "location", tabName: "Навигация")
                            .padding(.top, geometry.size.height/16/8)
                        
                        
                        Spacer()
                        
                        TabBarIconNew(settings: settings, viewRouter: viewRouter, assignedPage: .datalist, width: geometry.size.width, height: geometry.size.height, systemIconName: "list.bullet", tabName: "Расписание")
                            .padding(.top, geometry.size.height/16/8)
                        
                        
                        Spacer()
                        
                        TabBarIconNew(settings: settings, viewRouter: viewRouter, assignedPage: .news, width: geometry.size.width, height: geometry.size.height, systemIconName: "newspaper", tabName: "Новости")
                            .padding(.top, geometry.size.height/16/8)
                        
                        Spacer()
                        
                        TabBarIconNew(settings: settings, viewRouter: viewRouter, assignedPage: .properties, width: geometry.size.width, height: geometry.size.height, systemIconName: "gearshape", tabName: "Настройки")
                            .padding(.top, geometry.size.height/16/8)
                        
                        Spacer()
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3))
                    .frame(width: geometry.size.width, height: geometry.size.height/9)
                    //                    .shadow(color: .black, radius: 15)
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height/10)
                .frame(alignment: .bottom)
            }
        }
    }
}
