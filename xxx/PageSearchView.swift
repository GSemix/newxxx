//
//  PageSearchView.swift
//  xxx
//
//  Created by Семен Безгин on 15.05.2022.
//

import SwiftUI

enum Field1 {
    case focuse
}

struct Search2: View {
    var tittle: String
    @Binding var searchText: String
    @Binding var searchHelp: Bool
    @Binding var Nav: PointRouting
    @ObservedObject var settings: UserDefaultsSettings
    @FocusState var focusedField: Field1?
    @Binding var offsetSearchText: CGFloat
    @State var startSearchText: String = ""
    @State var onTapField: Bool = true
    @State var offsetScrollContent: CGFloat = .zero
    @State var offsetSearch: CGFloat = .zero
    @State var onTapFieldForButtonRemoveText: Bool = true
    @StateObject var keyboardHeightHelper = KeyboardHeightHelper()
    var searchResults: [Point] {
        if searchText.isEmpty {
            return []
        } else {
            return Nav.getVertex().filter { $0.name.replacingOccurrences(of: "&", with: " ").contains(searchText.lowercased()) }
        }
    }

    var body: some View {
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        settings.theme == 0 ? Color.lightStart : Color.purpleEnd
                        BlurBG(settings: settings)
                    }
                        .opacity(0.9)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .overlay(
                            ZStack {
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack {
                                        Spacer()
                                            .frame(height: geometry.size.height*0.15)
                                        
                                        ForEach(searchResults, id: \.self) { result in
                                            if !result.name.contains("_") {
                                                Button(action: {
                                                    withAnimation {
                                                        endEditing()
                                                        self.offsetSearchText = UIScreen.main.bounds.height
                                                        self.searchText = result.name.replacingOccurrences(of: "&", with: " ").capitalized
                                                        
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                            self.searchHelp = false
                                                        }
                                                    }
                                                }) {
                                                    HStack {
                                                        Spacer()
                                                        
                                                            Text(result.name.replacingOccurrences(of: "&", with: " ").capitalized)
                                                                .font(.system(size: UIScreen.main.bounds.height / 50))
                                                                .fontWeight(.semibold)
                                                        
                                                        Spacer()
                                                    }
                                                    .frame(width: geometry.size.width * 0.97, height: geometry.size.height*0.075)
                                                }
                                                .buttonStyle(GrowingButtonColor(settings: settings))
                                                .padding(.horizontal, UIScreen.main.bounds.width*0.1)
                                                .padding(.vertical, UIScreen.main.bounds.height*0.0005)
                                            }
                                            
                                        }
                                
                                        Spacer()
                                            .frame(height: self.keyboardHeightHelper.keyboardHeight)
                                    }
                                    .padding(.horizontal, geometry.size.width*0.025)
                                    .padding(.top, geometry.size.height*0.01)
                                    .padding(.bottom, UIScreen.main.bounds.height*0.11)
                                }
                                
                                
                                VStack {
                                    VStack {
                                    Text(tittle)
                                        .font(.system(size: UIScreen.main.bounds.height / 50))
                                        .fontWeight(.semibold)
                                        .foregroundColor(settings.theme == 0 ? Color.lightStart : Color.purpleEnd)
                                        .frame(alignment: .center)
                                    
                                    HStack {
                                        TextField("", text: $searchText, onEditingChanged: { value in
                                            if value {
                                                onTapField = true
                                                onTapFieldForButtonRemoveText = true
                                                
                                                self.offsetScrollContent = geometry.size.height*0.35
                                            } else {
                                                if searchText.isEmpty {
                                                    onTapField = false
                                                }
                                                
                                                onTapFieldForButtonRemoveText = false
                                                self.offsetScrollContent = .zero
                                            }
                                        })
                                            .modifier(
                                                SearchPlaceholderStyle(
                                                    showPlaceHolder: !onTapField,
                                                    placeholder: "Поиск по названию",
                                                    center: true
                                                )
                                            )
                                            .foregroundColor(.darkStart)
                                            .frame(width: geometry.size.width*0.8, height: geometry.size.height*0.05)
                                            .cornerRadius(15, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                                            .multilineTextAlignment(.center)
                                            .focused($focusedField, equals: .focuse)
                                            .disableAutocorrection(true)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            withAnimation {
//                                                endEditing()
//                                                self.offsetSearchText = UIScreen.main.bounds.height
//
//                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                                    self.searchHelp = false
//                                                }
                                                
                                                if searchText == "" {
                                                    endEditing()
                                                } else {
                                                    self.searchText = ""
                                                }
                                                
                                                if !self.onTapFieldForButtonRemoveText {
                                                    self.onTapField = false
                                                }
                                            }
                                        }) {
                                            Image(systemName: "xmark.app")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: geometry.size.width*0.075, height: geometry.size.width*0.075)
                                                .foregroundColor(settings.theme == 0 ? Color.lightStart : Color.purpleEnd)
                                        }
                                        .buttonStyle(GrowingButton())
                                        .clipped()
                                        
                                        Spacer()
                                    }
                                }
                                    .padding()
                                    .background(
                                        ZStack {
                                            settings.theme == 0 ? LinearGradient(gradient: Gradient(colors: [Color.lightStart, Color.lightStart.opacity(0)]), startPoint: .top, endPoint: .bottom) : LinearGradient(gradient: Gradient(colors: [Color.purpleEnd, Color.purpleEnd.opacity(0)]), startPoint: .top, endPoint: .bottom)
                                            BlurBG(settings: settings)
                                        }
                                    )
                                    .cornerRadius(15, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                                    .frame(width: geometry.size.width)
                                    
                                    Spacer()
                                }
                            }
                        )
                        .cornerRadius(15, corners: [.topLeft, .topRight])
                }
                .onAppear(perform: {
                    self.startSearchText = self.searchText
                    self.focusedField = .focuse
                    self.offsetScrollContent = geometry.size.height*0.35
                    self.offsetSearchText = .zero
                })
            }
            .offset(y: self.offsetSearchText)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.8, alignment: .bottom)
    }
}
