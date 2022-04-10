//
//  ContentView.swift
//  mainMgimo
//
//  Created by Семен Безгин on 05.01.2022.
//

import SwiftUI

enum Page {
    case navigation
    case datalist
    case properties
    case news
    case maps
}

class ViewRouter: ObservableObject {
    @Published var currentPage: Page = .navigation
}

struct ContentView: View {
    @State var Nav: PointRouting
    @StateObject var viewRouter: ViewRouter
    @ObservedObject var settings = UserDefaultsSettings()
    
    var body: some View {
        GeometryReader { geometry in
            switch viewRouter.currentPage {
                
            case .navigation:
                Wall(settings: settings, page: .navigation)
                Navigation(Nav: $Nav, geometry: geometry, viewRouter: viewRouter, settings: settings)

            case .datalist:
                Wall(settings: settings, page: .datalist)
                dataList(settings: settings)
                
            case .properties:
                Properties(settings: settings)
                
            case .maps:
                Wall(settings: settings, page: .maps)
                navigationPage(Nav: $Nav, viewRouter: viewRouter, bookmark: Nav.getIsBookmark(), settings: settings)
                    .transition(.scale)
                
            case .news:
                Wall(settings: settings, page: .news)
                news(settings: settings)
            }
            
            tabBarIcons(settings: settings, geometry: geometry, viewRouter: viewRouter)
        }
        .preferredColorScheme(settings.theme == 0 ? .dark : .light)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func rotate() -> Void {
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(Nav: PointRouting(nameOfFileVertex: "Data/Vertex", nameOfFileEdges: "Data/Edges"), viewRouter: ViewRouter())
    }
}

#if canImport(UIKit)
extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
