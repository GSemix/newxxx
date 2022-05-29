//
//  PageNavigation.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI

struct fastCard: Identifiable {
    var id: UUID = UUID()
    var isFaceUp: Bool = false
    var images: [String]
    var color: LinearGradient
    var name: String
}

enum FieldType {
    case none
    case mainFrom
    case mainTo
    case fast
}

struct Navigation: View {
    @Binding var Nav: PointRouting
    var geometry: GeometryProxy
    @State var errorInput: String = ""
    @State var fastErrorInput: String = ""
    @Binding var source: String
    @Binding var destination: String
    @StateObject var viewRouter: ViewRouter
    @State var time = Timer.publish(every: 0.1, on: .current, in: .tracking).autoconnect()
    @State var show = false
    @ObservedObject var settings: UserDefaultsSettings
    @State var Cards: [fastCard] = [
        .init(images: ["fork.knife"], color: LinearGradient(.offWhite, .gray), name: "кафе"),
        .init(images: ["w.square.fill", "c.square.fill"], color: LinearGradient(.green, .black), name: "туалет"),
        .init(images: ["rectangle.portrait.and.arrow.right.fill"], color: LinearGradient(.orange, .brown), name: "вход"),
        .init(images: ["cross"], color: LinearGradient(.red, .red.opacity(0.2)), name: "медпункт"),
        .init(images: ["dollarsign.circle"], color: LinearGradient(.yellow, .gray), name: "банкомат"),
    ]
    @State var errorType: errorSignal = .nothing
    @State var fastErrorType: errorSignal = .nothing
    @State var fastCab: String = ""
    @State var typeCard: String = ""
    @State var isLoading: Bool = false
    @State var searchText: String = ""
    @State var searchHelp: Bool = false
    @State var field: FieldType = .none
    @State var fastButon: Bool = false
    @State var offsetSearchText: CGFloat = UIScreen.main.bounds.height
    @Binding var isHideTabBarAndBlurWall: Bool
    @State var searchTittle: String = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            LoadingView(isShowing: .constant(self.isLoading), theme: self.settings.theme) {
                ScrollView(.vertical, showsIndicators: false) {
                        GeometryReader { g in
                            Tittle(settings: settings, text: "Навигация", name: "location.viewfinder")
                                .offset(y: g.frame(in: .global).minY > 0 ? -g.frame(in: .global).minY/25 : 0)
                                .scaleEffect(g.frame(in: .global).minY >= 0 ? g.frame(in: .global).minY/150 + 1 : g.frame(in: .global).minY/150 + 1 > 0.8 ? g.frame(in: .global).minY/150 + 1 : 0.8)
                                .frame(width: g.size.width)
                                .onReceive(self.time) { (_) in
                                        
                                    let y = g.frame(in: .global).minY
                                        
                                    if -y > (UIScreen.main.bounds.height * 0.1 / 2) {
                                        withAnimation{
                                            self.show = true
                                        }
                                    } else {
                                        self.show = false
                                    }
                                        
                                }
                                .padding(.top, UIScreen.main.bounds.height*0.07)
                                    
                        }
                        .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.height*0.15, alignment: .center)
                            
                        VStack {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(LinearGradient(settings.theme == 0 ? Color.darkEnd : Color.offWhite, settings.theme == 0 ? Color.darkStart : Color.offWhite))
                                .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height / 4.5)
                                .shadow(color: settings.theme == 0 ? Color.darkStart : Color.white, radius: 5, x: -5, y: -5)
                                .shadow(color: settings.theme == 0 ? Color.darkEnd : Color.gray, radius: 5, x: 5, y: 5)
                                .overlay(
                                    HStack {
                                        Spacer()
                                            
                                        entryField(
                                            sourse: $source,
                                            destination: $destination,
                                            errorInput: $errorInput,
                                            errorType: $errorType,
                                            settings: settings,
                                            searchText: $searchText,
                                            searchHelp: $searchHelp,
                                            field: $field,
                                            searchTittle: $searchTittle
                                        )
                                            
                                        Spacer()
                                        
                                        Button(action: {
                                            withAnimation {
                                                if self.Nav.find(p: String(source.replacingOccurrences(of: " ", with: "&")).lowercased()) != Point() && self.Nav.find(p: String(destination.replacingOccurrences(of: " ", with: "&")).lowercased()) != Point() && source != destination {
                                                    self.isLoading = true
                                                    self.isHideTabBarAndBlurWall = true
                                                }
                                            }
                                            
                                            DispatchQueue.global(qos: .utility).async {
                                                withAnimation {
                                                    let errors = self.Nav.mainRoute(source: String(source.replacingOccurrences(of: " ", with: "&")).lowercased(), destination: String(destination.replacingOccurrences(of: " ", with: "&")).lowercased(), theme: self.settings.theme, selectedMaps: self.settings.selectedMaps)
                                                    self.errorType = errors.errorType
                                                    self.errorInput = errors.errorInput
                                                }
                                                
//                                                self.isLoading = false
                                            }
                                        }) {
                                                
                                            Image(systemName: "magnifyingglass")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.height / 4.5)
                                                .padding(.horizontal, 30)
                                        }
                                        .buttonStyle(ColorfulButtonStyleWithoutShadows(settings: settings))
                                            
                                    }
                                )
                                .padding(.bottom, UIScreen.main.bounds.height*0.025)
                                
                            HStack {
                                Image(systemName: "clock")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width*0.07, height: UIScreen.main.bounds.width*0.07)
                                    .foregroundColor(settings.theme == 0 ? .offWhite : .darkStart)
                                    
                                Text("Быстрый поиск")
                                    .foregroundColor(settings.theme == 0 ? .offWhite : .darkStart)
                                    .font(.system(size: UIScreen.main.bounds.height / 30))
                                    .fontWeight(.bold)
                            }
                            .padding(.bottom, -5)
                                
                            ScrollView(.horizontal, showsIndicators: false) {
                                ScrollViewReader { value in
                                    HStack(spacing: -30) {
                                        ForEach(Cards.indices) { index in
                                            GeometryReader { gg in
                                                FlipView(
                                                    showBack: self.Cards[index].isFaceUp,
                                                    settings: settings,
                                                    geometry: gg,
                                                    imageName: self.Cards[index].images,
                                                    color: self.Cards[index].color,
                                                    fastCab: $fastCab,
                                                    typeCard: $typeCard,
                                                    name: self.Cards[index].name,
                                                    fastErrorInput: $fastErrorInput,
                                                    fastErrorType: $fastErrorType,
                                                    searchText: $searchText,
                                                    searchHelp: $searchHelp,
                                                    field: $field,
                                                    fastButton: $fastButon,
                                                    searchTittle: $searchTittle
                                                )
                                                        .onTapGesture {
                                                            if !Cards[index].isFaceUp {
                                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)) {
                                                                    value.scrollTo(index, anchor: .center)
                                                                }
                                                            }
                                                                
                                                            withAnimation(.linear(duration: 0.2)) {
                                                                if !self.Cards[index].isFaceUp {
                                                                    self.Cards[index].isFaceUp.toggle()
                                                                }
                                                                    
                                                                for i in 0..<Cards.count {
                                                                    if i != index {
                                                                        self.Cards[i].isFaceUp = false
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        .rotation3DEffect(Angle(degrees: Double(gg.frame(in: .global).minX - 50) / -20), axis: (x: 0, y: 100.0, z: 0))
                                            }
                                            .id(index)
                                            .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.height / 4.5)
                                            .padding(.horizontal)
                                        }
                                        .frame(height: UIScreen.main.bounds.height/2.5, alignment: .center)
                                        .onChange(of: fastButon) { newValue in
                                            if fastButon {
                                                withAnimation {
                                                    if self.Nav.find(p: String(fastCab.replacingOccurrences(of: " ", with: "&")).lowercased()) != Point() {
                                                        self.isLoading = true
                                                        self.isHideTabBarAndBlurWall = true
                                                    }
                                                }
                                                
                                                DispatchQueue.global(qos: .utility).async {
                                                    withAnimation {
                                                        let errors = self.Nav.searchShortestWay(source: String(fastCab.replacingOccurrences(of: " ", with: "&")).lowercased(), destinationList: self.Nav.searchDestinationPoint(type: typeCard), theme: self.settings.theme, selectedMaps: self.settings.selectedMaps)
                                                    
                                                        self.fastErrorType = errors.fastErrorType
                                                        self.fastErrorInput = errors.fastErrorInput
                                                    }
                                                    
//                                                        self.isLoading = false
                                                }
                                            
                                                fastButon = false
                                            }
                                        }
                                    }
                                    .onAppear(perform: {
                                        value.scrollTo(Int(Cards.count/2), anchor: .center)
                                    })
                                }
                            }
                                
                            VStack(spacing: 20) {
                                HStack {
                                    Image(systemName: "bookmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: UIScreen.main.bounds.width*0.05, height: UIScreen.main.bounds.width*0.05)
                                        .foregroundColor(settings.theme == 0 ? .offWhite : .darkStart)
                                        
                                    Text("Избранные маршруты")
                                        .foregroundColor(settings.theme == 0 ? .offWhite : .darkStart)
                                        .font(.system(size: UIScreen.main.bounds.height / 30))
                                        .fontWeight(.bold)
                                }
                                    
                                if !self.settings.selectedMaps.isEmpty {
                                    ForEach(self.settings.selectedMaps.indices) { index in
                                        Button(action: {
                                            withAnimation {
                                                self.isLoading = true
                                                self.isHideTabBarAndBlurWall = true
                                            }
                                            
                                            DispatchQueue.global(qos: .utility).async {
                                                withAnimation {
                                                    let numbers: [String] = self.settings.selectedMaps[index].split(separator: " ").map {String($0)}
                                                    self.Nav.setIsBookmark(isBookmark: true)
                                                    self.Nav.makeRouteFast(first: numbers[0], last: numbers[1], theme: self.settings.theme)
                                                }
                                            }
                                        }) {
                                            HStack {
                                                    
                                                Spacer()
                                                    
                                                ForEach(self.Cards.indices) { i in
                                                    if self.settings.selectedMaps[index].split(separator: " ")[0].contains(self.Cards[i].name.lowercased()) && !self.settings.selectedMaps[index].split(separator: " ")[0].contains("&") {
                                                        Text(self.Cards[i].name.capitalized)
                                                            .font(.system(size: UIScreen.main.bounds.height / 50))
                                                            .fontWeight(.semibold)
                                                    } else if i == self.Cards.count - 1 && !self.settings.selectedMaps[index].split(separator: " ")[0].contains("_") {
                                                        if self.settings.selectedMaps[index].split(separator: " ")[0].contains("&") {
                                                            Text(String(self.settings.selectedMaps[index].split(separator: " ")[0].replacingOccurrences(of: "&", with: " ")).capitalized)
                                                                .font(.system(size: UIScreen.main.bounds.height / 50))
                                                                .fontWeight(.semibold)
                                                        } else {
                                                            Text(self.settings.selectedMaps[index].split(separator: " ")[0].capitalized)
                                                                .font(.system(size: UIScreen.main.bounds.height / 50))
                                                                .fontWeight(.semibold)
                                                        }
                                                    }
                                                }
                                                    
                                                Spacer()
                                                    
                                                Image(systemName: "chevron.forward.square")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: UIScreen.main.bounds.width*0.8*0.07)
                                                    
                                                Spacer()
                                                    
                                                ForEach(self.Cards.indices) { i in
                                                    if self.settings.selectedMaps[index].split(separator: " ")[1].contains(self.Cards[i].name.lowercased()) && !self.settings.selectedMaps[index].split(separator: " ")[1].contains("&") {
                                                        Text(self.Cards[i].name.capitalized)
                                                            .font(.system(size: UIScreen.main.bounds.height / 50))
                                                            .fontWeight(.semibold)
                                                    } else if i == self.Cards.count - 1 && !self.settings.selectedMaps[index].split(separator: " ")[1].contains("_") {
                                                        if self.settings.selectedMaps[index].split(separator: " ")[1].contains("&") {
                                                            Text(String(self.settings.selectedMaps[index].split(separator: " ")[1].replacingOccurrences(of: "&", with: " ")).capitalized)
                                                                .font(.system(size: UIScreen.main.bounds.height / 50))
                                                                .fontWeight(.semibold)
                                                        } else {
                                                            Text(self.settings.selectedMaps[index].split(separator: " ")[1].capitalized)
                                                                .font(.system(size: UIScreen.main.bounds.height / 50))
                                                                .fontWeight(.semibold)
                                                        }
                                                    }
                                                }

                                                    
                                                Spacer()
                                            }
                                            .frame(width: geometry.size.width * 0.8)
                                        }
                                        .buttonStyle(ColorfulButtonStyleRoundedRectangle(settings: settings))
                                    }
                                } else {
                                    VStack {
                                        Text("Пока здесь ничего нет")
                                            .foregroundColor(settings.theme == 0 ? .offWhite : .darkStart)
                                            .font(.system(size: UIScreen.main.bounds.height / 50))
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                            .padding(.top, -5)
                                
                            Spacer()
                                .frame(height: UIScreen.main.bounds.height/4)
                        }
                            .padding(.top, 15)
                    }
                    .onChange(of: !self.Nav.getMaps().isEmpty) { _ in
                        if !self.Nav.getMaps().isEmpty {
                            self.isLoading = false
                            
                            withAnimation {
                                viewRouter.currentPage = .maps
                            }
                        }
                }
            }
            .disabled(self.searchHelp)
            
            if self.show {
                header(settings: settings, text: "Навигация")
            }
        }
        .popup(isPresented: $searchHelp, type: .toast, position: .bottom, animation: .interactiveSpring(), closeOnTap: false, closeOnTapOutside: true, dismissCallback: {
            withAnimation {
                self.offsetSearchText = UIScreen.main.bounds.height
            }
        }) {
            if self.searchHelp {
                Search2(tittle: searchTittle, searchText: $searchText, searchHelp: $searchHelp, Nav: $Nav, settings: settings, offsetSearchText: $offsetSearchText)
            }
        }
        .onChange(of: self.searchHelp) { value in
            switch self.field {
            case .none:
                ()
                
            case .mainFrom:
                if value {
                    self.searchText = self.source
                    self.errorType = .nothing
                    self.errorInput = ""
                } else {
                    self.source = self.searchText
                }
                
            case .mainTo:
                if value {
                    self.searchText = self.destination
                    self.errorType = .nothing
                    self.errorInput = ""
                } else {
                    self.destination = self.searchText
                }
                
            case .fast:
                if value {
                    self.searchText = self.fastCab
                    self.fastErrorType = .nothing
                    self.fastErrorInput = ""
                } else {
                    self.fastCab = self.searchText
                }
            }
            
            if !value {
                self.field = .none
                self.searchText = ""
            }
        }
        .onTapGesture {
            self.endEditing()
            
            if !self.searchHelp {
                withAnimation(.linear(duration: 0.2)) {
                    for i in 0..<Cards.count {
                        self.Cards[i].isFaceUp = false
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .edgesIgnoringSafeArea(.bottom)
        .onAppear(perform: {
            self.Cards[2].color = settings.theme == 0 ? LinearGradient(.lightEnd, .lightStart) : LinearGradient(.purpleEnd, .purpleStart)
            self.isLoading = false
            
            self.isHideTabBarAndBlurWall = false
        })
    }
}
