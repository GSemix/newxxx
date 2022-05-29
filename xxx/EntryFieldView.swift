//
//  EntryFieldView.swift
//  xxx
//
//  Created by Семен Безгин on 29.05.2022.
//

import SwiftUI

struct entryField: View {
    @Binding var sourse: String
    @Binding var destination: String
    @Binding var errorInput: String
    @Binding var errorType: errorSignal
    @ObservedObject var settings: UserDefaultsSettings
    @Binding var searchText: String
    @Binding var searchHelp: Bool
    @Binding var field: FieldType
    @Binding var searchTittle: String
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("", text: $sourse)
                .modifier(
                    PlaceholderStyle(
                        showPlaceHolder: sourse.isEmpty,
                        placeholder: "Откуда?",
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
                .frame(height: UIScreen.main.bounds.height*0.05)
                .multilineTextAlignment(.center)
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .strokeBorder(errorType == .start || errorType == .all ? Color.red : Color.clear, style: StrokeStyle(lineWidth: 3.0))
                )
                .onTapGesture(perform: {
                    withAnimation {
                        self.field = .mainFrom
                        self.searchHelp = true
                        self.searchTittle = "Откуда?"
                    }
                })
            
            Spacer()
            
            LinearGradient(settings.theme == 0 ? Color.lightStart : Color.purpleStart, settings.theme == 0 ? Color.lightEnd : Color.purpleEnd)
                .mask(
            Image(systemName: "chevron.down")
                .resizable()
                .foregroundColor(settings.theme == 0 ? Color.lightEnd : Color.purpleEnd)
                .frame(width: UIScreen.main.bounds.width*0.9/2.5, height: UIScreen.main.bounds.height / 4.5 / 10)
            )
            
            Spacer()
            
            TextField("", text: $destination)
                .modifier(
                    PlaceholderStyle(
                        showPlaceHolder: destination.isEmpty,
                        placeholder: "Куда?",
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
                .frame(height: UIScreen.main.bounds.height*0.05)
                .multilineTextAlignment(.center)
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(errorType == .end || errorType == .all ? Color.red : Color.clear, style: StrokeStyle(lineWidth: 3.0)))
                .onTapGesture(perform: {
                    withAnimation {
                        self.field = .mainTo
                        self.searchHelp = true
                        self.searchTittle = "Куда?"
                    }
                })
            
            Spacer()
        }
    }
}
