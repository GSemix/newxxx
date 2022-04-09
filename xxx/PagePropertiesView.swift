//
//  PageProperties.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI

struct Properties: View {
    @ObservedObject var settings: UserDefaultsSettings
    @State var time = Timer.publish(every: 0.1, on: .current, in: .tracking).autoconnect()
    @State var show = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Form {
                    GeometryReader { g in
                        Tittle(settings: settings, text: "Настройки", fontValue: UIScreen.main.bounds.height / 30)
                            .offset(y: g.frame(in: .global).minY > 0 ? -g.frame(in: .global).minY/25 : 0)
                            .scaleEffect(g.frame(in: .global).minY > 0 ? g.frame(in: .global).minY/150 + 1 : 1)
                            .frame(width: g.size.width)
                            .onReceive(self.time) { (_) in
                                let y = g.frame(in: .global).minY
                                
                                if -y > (UIScreen.main.bounds.height * 0.1 / 4) {
                                    withAnimation{
                                        self.show = true
                                    }
                                } else {
                                    self.show = false
                                }
                                
                            }
                            .padding(.top, UIScreen.main.bounds.height*0.05)
                    }
                    
                    .listRowBackground(Color.clear)
                    .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.height*0.1, alignment: .center)
                    
                    
                    //Section2(settings: settings)
                    //Section1(settings: settings)
                    Section5(settings: settings)
                    Section3(settings: settings)
                    Section4(settings: settings)
                    
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height/4)
                        .listRowBackground(Color.clear)
                }
                .onAppear{
                    UITableView.appearance().backgroundColor = .clear
                    UITableView.appearance().showsVerticalScrollIndicator = false
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .background(
                    Wall(settings: settings, page: .properties)
                )
                
                if self.show {
                    header(settings: settings, text: "Настройки")
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(settings.theme == 0 ? .dark : .light)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .ignoresSafeArea(.all)
        .padding(.horizontal, -10)
    }
}

struct Section1: View {
    @ObservedObject var settings: UserDefaultsSettings
    @State var username: String = "login"
    @State var password: String = "password"
    @State var isPrivate: Bool = false
    
    var body: some View {
        Section(header: Text("PROFILE")) {
            TextField("Логин", text: $username)
                .blur(radius: isPrivate ? 15 : 0)
                .disabled(isPrivate)
            
            TextField("Пароль", text: $password)
                .blur(radius: isPrivate ? 15 : 0)
                .disabled(isPrivate)
            
            Toggle(isOn: $isPrivate) {
                Text("Скрыть данные")
            }
        }
        .listRowBackground(Color.gray.opacity(0.5))
    }
}

struct Section2: View {
    @ObservedObject var settings: UserDefaultsSettings
    @State private var previewIndexU = 1
    @State private var previewIndexF = 3
    var name = [" ", "МГИМО", "МГУ", "НИЯУ МИФИ"]
    var fac = [" ", "1", "2", "3"]
    
    var body: some View {
        Section(header: Text("Университет")) {
            Picker(selection: $previewIndexU, label: Text("Название")) {
                ForEach(0..<name.count) {
                    Text(self.name[$0])
                }
            }
            
            Picker(selection: $previewIndexF, label: Text("Факультет")) {
                ForEach(0..<fac.count) {
                    Text(self.fac[$0])
                }
            }
            
            HStack {
                Text("Адрес")
                Spacer()
                Text("г. Москва, ул. Улица, д. 16/7")
            }
        }
        .listRowBackground(Color.gray.opacity(0.5))
    }
}

struct Section3: View {
    @ObservedObject var settings: UserDefaultsSettings
    
    var body: some View {
        Section(header: Text("О приложении")) {
            HStack {
                Text("Версия")
                Spacer()
                Text("2.2.1")
            }
        }
        .listRowBackground(Color.gray.opacity(0.5))
    }
}

struct Section4: View {
    @ObservedObject var settings: UserDefaultsSettings
    
    var body: some View {
        Section {
            Button(action: {
                print("Perform an action here...")
            }) {
                Text("Сбросить все настройки")
                    .foregroundColor(settings.theme == 0 ? Color.lightStart : Color.purpleStart)
            }
        }
        .listRowBackground(Color.gray.opacity(0.5))
    }
}

struct Section5: View {
    @ObservedObject var settings: UserDefaultsSettings
    @State private var previewIndexL = 0
    var theme: [Theme] = [.dark, .light]
    var language = ["Русский", "English"]
    
    var body: some View {
        Section(header: Text("Интерфейс")) {
            Picker(selection: $settings.theme, label: Text("Тема")) {
                ForEach(0..<theme.count) {
                    switch $0 {
                    case 0:
                        Text("Тёмная")
                    case 1:
                        Text("Светлая")
                    default:
                        Color.clear
                    }
                    
                }
            }
            .onAppear(perform: {
                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.gray.opacity(0.8))
                UISegmentedControl.appearance().backgroundColor = .clear
            })
            .pickerStyle(SegmentedPickerStyle())
            
            Picker(selection: $previewIndexL, label: Text("Язык")) {
                ForEach(0..<language.count) {
                    Text(self.language[$0])
                }
            }
            
        }
        .listRowBackground(Color.gray.opacity(0.5))
    }
}
