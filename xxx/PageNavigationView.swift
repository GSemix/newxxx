//
//  PageNavigation.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI
import SwiftGraph
import SVGKit

enum Field {
    case firstCab
    case lastCab
    case fast
}

struct fastCard: Identifiable {
    var id: UUID = UUID()
    var isFaceUp: Bool = false
    var images: [String]
    var color: LinearGradient
    var name: String
}

struct Navigation: View {
    @Binding var Nav: PointRouting
    var geometry: GeometryProxy
    @State var errorInput: String = ""
    @State var fastErrorInput: String = ""
    @State var source: String = "" // 2068
    @State var destination: String = "" // 2115
    @StateObject var viewRouter: ViewRouter
    @State var time = Timer.publish(every: 0.1, on: .current, in: .tracking).autoconnect()
    @State var show = false
    @ObservedObject var settings: UserDefaultsSettings
    @State var Cards: [fastCard] = [
        .init(images: ["fork.knife"], color: LinearGradient(.offWhite, .gray), name: "Кафе"),
        .init(images: ["w.square.fill", "c.square.fill"], color: LinearGradient(.green, .black), name: "Туалет"),
        .init(images: ["rectangle.portrait.and.arrow.right.fill"], color: LinearGradient(.orange, .brown), name: "Вход"),
        .init(images: ["cross"], color: LinearGradient(.red, .red.opacity(0.2)), name: "Мед пункт"),
        .init(images: ["dollarsign.circle"], color: LinearGradient(.yellow, .gray), name: "Банкомат"),
    ]
    @State var errorType: errorSignal = .nothing
    @State var fastErrorType: errorSignal = .nothing
    @State var fastCab: String = ""
    @State var typeCard: String = ""
    @FocusState private var focusedField: Field?
    @State var indexToScroll: Int?
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical, showsIndicators: false) {
                ScrollViewReader { scrollViewReaderValue in
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
                                        
                                    entryField(sourse: $source, destination: $destination, errorInput: $errorInput, errorType: $errorType, settings: settings, focusedField: _focusedField)
                                        
                                    Spacer()
                                        
                                    Button(action: {
                                        withAnimation {
                                            let errors = self.Nav.mainRoute(source: source, destination: destination, theme: self.settings.theme, selectedMaps: self.settings.selectedMaps)
                                            self.errorType = errors.errorType
                                            self.errorInput = errors.errorInput
                                            
                                            if !self.Nav.getMaps().isEmpty {
                                                viewRouter.currentPage = .maps
                                            }
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
                            
        //                    inputError(errorInput: $errorInput)
        //                        .frame(height: UIScreen.main.bounds.height / 4.5 / 3)
                            
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
                                                FlipView(showBack: self.Cards[index].isFaceUp, settings: settings, geometry: gg, imageName: self.Cards[index].images, color: self.Cards[index].color, fastCab: $fastCab, typeCard: $typeCard, name: self.Cards[index].name, fastErrorInput: $fastErrorInput, fastErrorType: $fastErrorType, indexToScroll: $indexToScroll)
                                                    .focused($focusedField, equals: .fast)
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
//                                        .padding(.bottom, 50)
                                        .padding(.horizontal)
                                    }
                                    .frame(height: UIScreen.main.bounds.height/2.5, alignment: .center)
                                    .onChange(of: fastCab) { newValue in
                                        let errors = self.Nav.searchShortestWay(source: newValue, destinationList: self.Nav.searchDestinationPoint(type: typeCard), theme: self.settings.theme, selectedMaps: self.settings.selectedMaps)
                                        
                                        withAnimation {
                                            self.fastErrorType = errors.fastErrorType
                                            self.fastErrorInput = errors.fastErrorInput
                                        }
                                        
                                        if !self.Nav.getMaps().isEmpty {
                                            self.viewRouter.currentPage = .maps
                                        }
                                    }
                                }
                                .onAppear(perform: {
                                    value.scrollTo(Int(Cards.count/2), anchor: .center)
                                })
//                                .padding(.trailing, 15)
                            }
                        }
                        .id(1)
                            
        //                    inputError(errorInput: $fastErrorInput)
        //                        .frame(height: UIScreen.main.bounds.height / 4.5 / 3)
                            
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
                                            let numbers: [String] = self.settings.selectedMaps[index].split(separator: " ").map {String($0)}
                                            self.Nav.setIsBookmark(isBookmark: true)
                                            self.Nav.makeRouteFast(first: numbers[0], last: numbers[1], theme: self.settings.theme)
                                            
                                            if !self.Nav.getMaps().isEmpty {
                                                viewRouter.currentPage = .maps
                                            }
                                        }
                                    }) {
                                        HStack {
                                                
                                            Spacer()
                                                
                                            ForEach(self.Cards.indices) { i in
                                                if self.settings.selectedMaps[index].split(separator: " ")[0].contains(self.Cards[i].name) {
                                                    Text(self.Cards[i].name)
                                                        .font(.system(size: UIScreen.main.bounds.height / 50))
                                                        .fontWeight(.semibold)
                                                }
                                                
                                                if i == self.Cards.count - 1 && !self.settings.selectedMaps[index].split(separator: " ")[0].contains("_") {
                                                    Text(self.settings.selectedMaps[index].split(separator: " ")[0])
                                                        .font(.system(size: UIScreen.main.bounds.height / 50))
                                                        .fontWeight(.semibold)
                                                }
                                            }
                                                
                                            Spacer()
                                                
                                            Image(systemName: "chevron.forward.square")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: UIScreen.main.bounds.width*0.8*0.07)
                                                
                                            Spacer()
                                                
                                            ForEach(self.Cards.indices) { i in
                                                if self.settings.selectedMaps[index].split(separator: " ")[1].contains(self.Cards[i].name) {
                                                    Text(self.Cards[i].name)
                                                        .font(.system(size: UIScreen.main.bounds.height / 50))
                                                        .fontWeight(.semibold)
                                                }
                                                
                                                if i == self.Cards.count - 1 && !self.settings.selectedMaps[index].split(separator: " ")[1].contains("_") {
                                                    Text(self.settings.selectedMaps[index].split(separator: " ")[1])
                                                        .font(.system(size: UIScreen.main.bounds.height / 50))
                                                        .fontWeight(.semibold)
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
                                    
//                                    Text("Для добавления маршрута в избранные нажмите на \(Image(systemName: "bookmark")) при просмотре")
//                                        .foregroundColor(settings.theme == 0 ? .offWhite : .darkStart)
//                                        .font(.system(size: UIScreen.main.bounds.height / 50))
//                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .padding(.top, -5)
                            
                            //                    Spacer()
                            //
                            //                    Advert()
                            //
                            //                    Advert()
                            
                        Spacer()
                            .frame(height: UIScreen.main.bounds.height/4 + UIScreen.main.bounds.height/4)
                    }
                        .onChange(of: indexToScroll) { value in
                            if value != nil {
                                self.show = true
                                
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)) {
                                    scrollViewReaderValue.scrollTo(value, anchor: .leading)
                                }
                            }
                        }
                        .padding(.top, 15)
                    }
                }
            
            if self.show {
                header(settings: settings, text: "Навигация")
            }
            
        }
        .onTapGesture {
            self.endEditing()
            
            withAnimation(.linear(duration: 0.2)) {
                for i in 0..<Cards.count {
                    self.Cards[i].isFaceUp = false
                }
            }
        }
        .onSubmit {
            switch focusedField {
                case .firstCab:
                    focusedField = .lastCab
                default:
                    self.endEditing()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .edgesIgnoringSafeArea(.bottom)
        .onAppear(perform: {
            self.Cards[2].color = settings.theme == 0 ? LinearGradient(.lightEnd, .lightStart) : LinearGradient(.purpleEnd, .purpleStart)
        })
    }
}

struct entryField: View {
    @Binding var sourse: String
    @Binding var destination: String
    @Binding var errorInput: String
    @Binding var errorType: errorSignal
    @ObservedObject var settings: UserDefaultsSettings
    @State var onTapFields: [Bool] = [false, false]
    @FocusState var focusedField: Field?
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("", text: $sourse, onEditingChanged: { value in
                if value {
                    onTapFields[0] = true
                } else {
                    if sourse.isEmpty {
                        onTapFields[0] = false
                    }
                }
            })
                .focused($focusedField, equals: .firstCab)
                .submitLabel(.next)
                .modifier(
                    PlaceholderStyle(
                        showPlaceHolder: !onTapFields[0],
                        placeholder: "Начальный кабинет",
                        center: true,
                        settings: settings
                    )
                )
                .onChange(of: sourse) { newValue in
                    withAnimation {
                        errorInput = ""
                    
                        if errorType == .all {
                            errorType =  .end
                        } else if errorType == .start {
                            errorType = .nothing
                        }
                    }
                }
                .textContentType(.dateTime)
                .frame(height: 50)
                .multilineTextAlignment(.center)
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .strokeBorder(errorType == .start || errorType == .all ? Color.red : Color.clear, style: StrokeStyle(lineWidth: 3.0))
                )
            
            Spacer()
            
            LinearGradient(settings.theme == 0 ? Color.lightStart : Color.purpleStart, settings.theme == 0 ? Color.lightEnd : Color.purpleEnd)
                .mask(
            Image(systemName: "chevron.down")
                .resizable()
                .foregroundColor(settings.theme == 0 ? Color.lightEnd : Color.purpleEnd)
                .frame(width: UIScreen.main.bounds.width*0.9/2.5, height: UIScreen.main.bounds.height / 4.5 / 10)
            )
            
            Spacer()
            
            TextField("", text: $destination, onEditingChanged: { value in
                if value {
                    onTapFields[1] = true
                } else {
                    if destination.isEmpty {
                        onTapFields[1] = false
                    }
                }
            })
                .focused($focusedField, equals: .lastCab)
                .modifier(
                    PlaceholderStyle(
                        showPlaceHolder: !onTapFields[1],
                        placeholder: "Конечный кабинет",
                        center: true,
                        settings: settings
                    )
                )
                .onChange(of: destination) { newValue in
                    withAnimation {
                        errorInput = ""
                        
                        if errorType == .all {
                            errorType = .start
                        } else if errorType == .end {
                            errorType = .nothing
                        }
                    }
                }
                .textContentType(.dateTime)
                .frame(height: 50)
                .multilineTextAlignment(.center)
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(errorType == .end || errorType == .all ? Color.red : Color.clear, style: StrokeStyle(lineWidth: 3.0)))
            
            Spacer()
        }
    }
}

struct inputError: View {
    @Binding var errorInput: String
    
    var body: some View {
        Text(errorInput)
            .font(.system(size: 20))
            .foregroundColor(.red.opacity(0.7))
            .transition(.opacity)                       // Не работает transition для Text
    }
}
