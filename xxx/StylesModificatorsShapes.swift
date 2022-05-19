//
//  Styles.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI

struct ColorfulButtonStyle: ButtonStyle {
    @ObservedObject var settings: UserDefaultsSettings
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(15)
            .contentShape(Circle())
            .background(
                ColorfulBackground(settings: settings, isHighlighted: configuration.isPressed, shape: Circle())
            )
    }
}

struct ColorfulButtonStyleRoundedRectangle: ButtonStyle {
    @ObservedObject var settings: UserDefaultsSettings
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(settings.theme == 0 ? configuration.isPressed ? .darkEnd  : .offWhite : configuration.isPressed ? .offWhite : .purpleEnd)
            .padding(20)
            .frame(alignment: .center)
            .contentShape(RoundedRectangle(cornerRadius: 15))
            .background(
                ColorfulBackground(settings: settings, isHighlighted: configuration.isPressed, shape: RoundedRectangle(cornerRadius: 15))
            )
        //            .animation(nil)
    }
}

struct ColorfulToggleStyle: ToggleStyle {
    @ObservedObject var settings: UserDefaultsSettings
    
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            configuration.label
                .padding(15)
                .contentShape(Circle())
        }
        .background(
            ColorfulBackground(settings: settings, isHighlighted: configuration.isOn, shape: Circle())
        )
    }
}

struct ImageToggle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            configuration.label
                .padding(15)
                .contentShape(Capsule())
        }
    }
}

struct ColorfulBackground<S: Shape>: View {
    @ObservedObject var settings: UserDefaultsSettings
    var isHighlighted: Bool
    var shape: S
    
    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(settings.theme == 0 ? Color.lightStart : Color.purpleStart, settings.theme == 0 ? Color.lightEnd : Color.purpleEnd))
//                    .overlay(shape.stroke(LinearGradient(settings.theme == 0 ? Color.lightStart : Color.purpleStart, settings.theme == 0 ? Color.lightEnd : Color.purpleEnd), lineWidth: 4))
                    .shadow(color: settings.theme == 0 ? Color.darkStart : Color.white, radius: 5, x: 5, y: 5)
                    .shadow(color: settings.theme == 0 ? Color.darkEnd : Color.gray, radius: 5, x: -5, y: -5)
                
            } else {
                shape
                    .fill(LinearGradient(settings.theme == 0 ? Color.darkEnd : Color.offWhite, settings.theme == 0 ? Color.darkStart : Color.offWhite))
//                    .overlay(shape.stroke(LinearGradient(settings.theme == 0 ? Color.lightStart : Color.purpleStart, settings.theme == 0 ? Color.lightEnd : Color.purpleEnd), lineWidth: 4))
                    .shadow(color: settings.theme == 0 ? Color.darkStart : Color.white, radius: 5, x: -5, y: -5)
                    .shadow(color: settings.theme == 0 ? Color.darkEnd : Color.gray, radius: 5, x: 5, y: 5)
            }
        }
    }
}

struct ColorfulButtonStyleWithoutShadows: ButtonStyle {
    @ObservedObject var settings: UserDefaultsSettings
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(settings.theme == 0 ? .offWhite : configuration.isPressed ? .offWhite : .darkStart)
            .contentShape(RoundedRectangle(cornerRadius: 25))
            .background(
                ColorfulBackgroundWithoutShadows(settings: settings, isHighlighted: configuration.isPressed, shape: RoundedRectangle(cornerRadius: 25))
            )
        //            .animation(nil)
    }
}

struct ColorfulBackgroundWithoutShadows<S: Shape>: View {
    @ObservedObject var settings: UserDefaultsSettings
    var isHighlighted: Bool
    var shape: S
    
    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(settings.theme == 0 ? Color.lightEnd : Color.purpleEnd, settings.theme == 0 ? Color.lightStart : Color.purpleStart))
                    .overlay(shape.stroke(LinearGradient(settings.theme == 0 ? Color.lightStart : Color.purpleStart, settings.theme == 0 ? Color.lightEnd : Color.purpleEnd), lineWidth: 4))
                
            } else {
                shape
                    .fill(LinearGradient(settings.theme == 0 ? Color.darkStart : Color.offWhite, settings.theme == 0 ? Color.darkEnd : Color.offWhite))
                    .overlay(shape.stroke(LinearGradient(settings.theme == 0 ? Color.lightStart : Color.purpleStart, settings.theme == 0 ? Color.lightEnd : Color.purpleEnd), lineWidth: 4))
            }
        }
    }
}

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.3 : 1)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct GrowingButtonColor: ButtonStyle {
    @ObservedObject var settings: UserDefaultsSettings
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.offWhite)
            .cornerRadius(5)
            .foregroundColor(.darkEnd)
            .opacity(configuration.isPressed ? 0.3 : 1)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct GrowingButtonWays: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(configuration.isPressed ? Color("Purple") : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct BlurBG : UIViewRepresentable {
    @ObservedObject var settings: UserDefaultsSettings
    
    func makeUIView(context: Context) -> UIVisualEffectView {

        let view = UIVisualEffectView(effect: UIBlurEffect(style: settings.theme == 0 ? .dark : .light))
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    var center: Bool
    @ObservedObject var settings: UserDefaultsSettings
    
    public func body(content: Content) -> some View {
        ZStack(alignment: center ? .center : .leading) {
            Color.clear
            
            if showPlaceHolder {
                Text(placeholder)
                    .foregroundColor(settings.theme == 0 ? Color.offWhite.opacity(0.7) : Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
                    .font(.body)
                    .font(.system(size: UIScreen.main.bounds.width/25))
            }
            
            content
                .foregroundColor(settings.theme == 0 ? Color.offWhite : Color.darkStart)
                .font(.system(size: UIScreen.main.bounds.width/20, weight: .heavy, design: .default))
        }
    }
}

public struct SearchPlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    var center: Bool
    
    public func body(content: Content) -> some View {
        ZStack(alignment: center ? .center : .leading) {
            Color.offWhite
            
            if showPlaceHolder {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width*0.05, height: UIScreen.main.bounds.width*0.05)
                        .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
                    
                    Text(placeholder)
                        .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
                        .font(.body)
                        .font(.system(size: UIScreen.main.bounds.width/25))
                }
            }
            
            content
                .foregroundColor(Color.darkStart)
                .font(.system(size: UIScreen.main.bounds.width/20, weight: .heavy, design: .default))
        }
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
