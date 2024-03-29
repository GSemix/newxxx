//
//  FlipedCards.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI
//import SVGKit

struct CardFlip: ViewModifier {
    var isFaceUp: Bool
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                Angle.degrees(isFaceUp ? 0: 180),
                axis: (0,1,0),
                perspective: 0.3
            )
    }
}

struct FlipEffect: GeometryEffect {

      var animatableData: Double {
            get { angle }
            set { angle = newValue }
      }

      @Binding var flipped: Bool
      var angle: Double
      let axis: (x: CGFloat, y: CGFloat)

      func effectValue(size: CGSize) -> ProjectionTransform {

            DispatchQueue.main.async {
                  self.flipped = self.angle >= 90 && self.angle < 270
            }

            let tweakedAngle = flipped ? -180 + angle : angle
            let a = CGFloat(Angle(degrees: tweakedAngle).radians)

            var transform3d = CATransform3DIdentity;
            transform3d.m34 = -1/max(size.width, size.height)

            transform3d = CATransform3DRotate(transform3d, a, axis.x, axis.y, 0)
            transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height/2.0, 0)

            let affineTransform = ProjectionTransform(CGAffineTransform(translationX: size.width/2.0, y: size.height / 2.0))

            return ProjectionTransform(transform3d).concatenating(affineTransform)
      }
}

struct FlipView: View {
    @State private var flipped = false
    var showBack : Bool
    @ObservedObject var settings: UserDefaultsSettings
    var geometry: GeometryProxy
    var imageName: [String]
    var color: LinearGradient
    @Binding var fastCab: String
    @Binding var typeCard: String
    var name: String
    @State var onTapField: Bool = false
    @Binding var fastErrorInput: String
    @Binding var fastErrorType: errorSignal
    @Binding var searchText: String
    @Binding var searchHelp: Bool
    @Binding var field: FieldType
    @Binding var fastButton: Bool
    @Binding var searchTittle: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(LinearGradient(settings.theme == 0 ? Color.darkEnd : Color.offWhite, settings.theme == 0 ? Color.darkStart : Color.offWhite))
            .frame(width: geometry.size.width, height: geometry.size.height)
            .shadow(color: settings.theme == 0 ? Color.darkStart : Color.white, radius: 5, x: -5, y: -5)
            .shadow(color: settings.theme == 0 ? Color.darkEnd : Color.gray, radius: 5, x: 5, y: 5)
//            .padding(.vertical, 30)
            .overlay(
                ZStack {
                    HStack {                        
                        ForEach(0..<imageName.count) { name in
                            color
                                .mask(
                                    Image(systemName: imageName[name])
                                        .resizable()
                                        .scaledToFill()
                                        .foregroundColor(.black)
                                        .frame(width: geometry.size.width*0.3, height: geometry.size.height/4)
                                        .opacity(0.8)
                                )
                        }
                    }
                    .frame(width: geometry.size.width*0.7)
                    .opacity(flipped ? 0.0 : 1.0)
                    
                    HStack {
                        Spacer()
                        
//                        TextField("", text: $text, onEditingChanged: { value in
                        TextField("", text: $fastCab)
                            .modifier(
                                PlaceholderStyle(
//                                    showPlaceHolder: !onTapField,
                                    showPlaceHolder: fastCab.isEmpty,
                                    placeholder: "Откуда?",
                                    center: true,
                                    settings: settings
                                )
                            )
                            .onChange(of: fastCab) { newValue in
                                withAnimation {
                                    fastErrorInput = ""
                                    
                                    if fastErrorType == .all {
                                        fastErrorType = .nothing
                                    }
                                }
                            }
                            .textContentType(.dateTime)
                            .frame(height: UIScreen.main.bounds.height*0.05)
                            .multilineTextAlignment(.center)
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(fastErrorType == .all ? Color.red : Color.clear, style: StrokeStyle(lineWidth: 3.0)))
                            .onTapGesture(perform: {
                                withAnimation {                                    
                                    self.field = .fast
                                    self.typeCard = self.name
                                    self.searchHelp = true
                                    self.searchTittle = "Откуда?"
                                }
                            })
                        
                        Spacer()
                        
                        Button(action: {
                            self.fastButton = true
                            self.typeCard = self.name
                            
                            withAnimation {
                                if fastCab.isEmpty {
                                    fastErrorType = .all
                                }
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.height / 4.5)
                                .padding(.horizontal, 30)
                        }
//                        .animation(nil)
                        .buttonStyle(ColorfulButtonStyleWithoutShadows(settings: settings))
                    }
                    .opacity(flipped ? 1.0 : 0.0)
                }
            )
            .onChange(of: flipped) { newValue in
                if !newValue {
                    self.onTapField = false
                    self.fastErrorType = .nothing
                    self.fastErrorInput = ""
                    self.fastCab = ""
                }
            }
            .modifier(FlipEffect(flipped: $flipped, angle: showBack ? 180 : 0, axis: (x: 0, y: 1)))
    }
}
