//
//  ContentView.swift
//  mainMgimo
//
//  Created by Семен Безгин on 05.01.2022.
//

import UIKit
import SVGKit
import SwiftUI
import SwiftGraph
import PocketSVG
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields

// --------------------------------

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
    
    static let darkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    static let darkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)
    
    static let lightStart = Color(red: 60 / 255, green: 160 / 255, blue: 240 / 255)
    static let lightEnd = Color(red: 30 / 255, green: 80 / 255, blue: 120 / 255)
    
    static let purpleStart = Color(red: 98 / 255, green: 0 / 255, blue: 238 / 255)
    static let purpleEnd = Color(red: 48 / 255, green: 0 / 255, blue: 118 / 255)
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct ColorfulButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(15)
            .contentShape(Circle())
            .background(
                ColorfulBackground(isHighlighted: configuration.isPressed, shape: Circle())
            )
    }
}

struct ColorfulButtonStyleRoundedRectangle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .contentShape(RoundedRectangle(cornerRadius: 25))
            .background(
                ColorfulBackground(isHighlighted: configuration.isPressed, shape: RoundedRectangle(cornerRadius: 25))
            )
        //            .animation(nil)
    }
}

struct ColorfulToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            configuration.label
                .padding(15)
                .contentShape(Circle())
        }
        .background(
            ColorfulBackground(isHighlighted: configuration.isOn, shape: Circle())
        )
    }
}

struct ColorfulBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S
    
    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color.lightEnd, Color.lightStart))
                    .overlay(shape.stroke(LinearGradient(Color.lightStart, Color.lightEnd), lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 10, x: 5, y: 5)
                    .shadow(color: Color.darkEnd, radius: 10, x: -5, y: -5)
                
            } else {
                shape
                    .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                    .overlay(shape.stroke(LinearGradient(Color.lightStart, Color.lightEnd), lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 10, x: -5, y: -5)
                    .shadow(color: Color.darkEnd, radius: 10, x: 5, y: 5)
            }
        }
    }
}

struct ColorfulButtonStyleWithoutShadows: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .contentShape(RoundedRectangle(cornerRadius: 25))
            .background(
                ColorfulBackgroundWithoutShadows(isHighlighted: configuration.isPressed, shape: RoundedRectangle(cornerRadius: 25))
            )
        //            .animation(nil)
    }
}

struct ColorfulBackgroundWithoutShadows<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S
    
    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color.lightEnd, Color.lightStart))
                    .overlay(shape.stroke(LinearGradient(Color.lightStart, Color.lightEnd), lineWidth: 4))
                
            } else {
                shape
                    .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                    .overlay(shape.stroke(LinearGradient(Color.lightStart, Color.lightEnd), lineWidth: 4))
            }
        }
    }
}

// --------------------------------

struct Point: Decodable, Encodable, Equatable {
    var name: String
    var housing: String
    var floor: String
    var x0: String
    var y0: String
    var x: String
    var y: String
    
    init() {
        name = ""
        housing = ""
        floor = ""
        x = ""
        y = ""
        x0 = ""
        y0 = ""
    }
    
    init(newName: String, newHousing: String, newFloor: String, newX: String, newY: String, newX0: String, newY0: String) {
        name = newName
        housing = newHousing
        floor = newFloor
        x = newX
        y = newY
        x0 = newX0
        y0 = newY0
    }
}

extension Point {
    static func == (first: Point, second: String) -> Bool {
        return first.name == second
    }
}

class PinchZoomView: UIView {
    
    weak var delegate: PinchZoomViewDelgate?
    
    private(set) var scale: CGFloat = 0 {
        didSet {
            delegate?.pinchZoomView(self, didChangeScale: scale)
        }
    }
    
    private(set) var anchor: UnitPoint = .center {
        didSet {
            delegate?.pinchZoomView(self, didChangeAnchor: anchor)
        }
    }
    
    private(set) var offset: CGSize = .zero {
        didSet {
            delegate?.pinchZoomView(self, didChangeOffset: offset)
        }
    }
    
    private(set) var isPinching: Bool = false {
        didSet {
            delegate?.pinchZoomView(self, didChangePinching: isPinching)
        }
    }
    
    private var startLocation: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches: Int = 0
    
    
    public init() {
        super.init(frame: .zero)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func pinch(gesture: UIPinchGestureRecognizer) { // !!!
        
        switch gesture.state {
        case .began:
            
            isPinching = true
            startLocation = gesture.location(in: self)
            anchor = UnitPoint(x: startLocation.x / bounds.width, y: startLocation.y / bounds.height)
            numberOfTouches = gesture.numberOfTouches
            
        case .changed:
            if gesture.numberOfTouches != numberOfTouches {
                // If the number of fingers being used changes, the start location needs to be adjusted to avoid jumping.
                let newLocation = gesture.location(in: self)
                let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
                startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)
                
                numberOfTouches = gesture.numberOfTouches
            }
            
            scale = gesture.scale
            
            location = gesture.location(in: self)
            offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)
            
        case .ended, .cancelled, .failed:
            
            isPinching = false
            scale = 1.0
            anchor = .center
            offset = .zero
            
        default:
            break
        }
    }
}

protocol PinchZoomViewDelgate: AnyObject {
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize)
}

struct PinchZoom: UIViewRepresentable {
    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    @Binding var offset: CGSize
    @Binding var isPinching: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PinchZoomView {
        let pinchZoomView = PinchZoomView()
        pinchZoomView.delegate = context.coordinator
        return pinchZoomView
    }
    
    func updateUIView(_ pageControl: PinchZoomView, context: Context) { }
    
    class Coordinator: NSObject, PinchZoomViewDelgate {
        var pinchZoom: PinchZoom
        
        init(_ pinchZoom: PinchZoom) {
            self.pinchZoom = pinchZoom
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool) {
            pinchZoom.isPinching = isPinching
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat) {
            pinchZoom.scale = scale
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint) {
            pinchZoom.anchor = anchor
        }
        
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize) {
            pinchZoom.offset = offset
        }
    }
}

struct PinchToZoom: ViewModifier {
    @State var scale: CGFloat = 1.0
    @State var anchor: UnitPoint = .center
    @State var offset: CGSize = .zero
    @State var isPinching: Bool = false // Для обнаружения касаний (false, если пальцы не касаются)
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .offset(offset)
            .animation(isPinching ? .none : .spring(), value: true)
            .overlay(PinchZoom(scale: $scale, anchor: $anchor, offset: $offset, isPinching: $isPinching))
    }
}

extension View {
    func pinchToZoom() -> some View {
        self.modifier(PinchToZoom())
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

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

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    var center: Bool
    
    public func body(content: Content) -> some View {
        ZStack(alignment: center ? .center: .leading) {
            Color.offWhite
            
            if showPlaceHolder {
                HStack {
                    Spacer()
                        .frame(width: center ? 0: 5)
                    Text(placeholder)
                        .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
                        .font(.body)
                        .padding(.horizontal, 15)
                }
            }
            content
                .foregroundColor(Color.darkStart)
                .padding(.horizontal, 20)
        }
    }
}

struct mapContents: Hashable {
    var name: String = String()
    var mainContent: String = String()
    var image: UIImage = UIImage()
    var text: String = String()
    var blur: Bool = false
}

struct ContentView: View {
    @State var maps: Dictionary<Int, mapContents> = Dictionary()
    @StateObject var viewRouter: ViewRouter
    @State var menu: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            switch viewRouter.currentPage {

            case .navigation:
                Wall(page: .navigation)
                Navigation(geometry: geometry, maps: $maps, viewRouter: viewRouter)

            case .datalist:
                Wall(page: .datalist)
                dataList()

            case .properties:
                Wall(page: .properties)
                Properties()

            case .maps:
                Wall(page: .maps)
                navigationPage(maps: $maps, viewRouter: viewRouter)
                
            case .news:
                Wall(page: .news)
                news()
            }

            tabBarIcons(geometry: geometry, viewRouter: viewRouter)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func rotate() -> Void {
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
}

struct news: View {
    var body: some View {
        Color.clear
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

struct TabBarIconNew: View {
    @StateObject var viewRouter: ViewRouter
    let assignedPage: Page
    let width, height: CGFloat
    let systemIconName, tabName: String
    
    var body: some View {
        VStack {
            Button (action: {
                viewRouter.currentPage = assignedPage
            }) {
                VStack {
                    Image(systemName: systemIconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width/15, height: height/23)
                        .foregroundColor(Color(viewRouter.currentPage == assignedPage ? .white : .gray))
                    
                    Text(tabName)
                        .font(.system(size: 10)) // 18
                        .foregroundColor(viewRouter.currentPage == assignedPage ? .white : .gray)
                }
            }
            .padding(.horizontal, width/8/6)
            .buttonStyle(GrowingButton())
            
            Spacer()
        }
    }
}

struct navigationPage: View {
    @Binding var maps: Dictionary<Int, mapContents>
    @State var blurMap: Bool = false
    @State var image: UIImage = UIImage()
    @State var zIndexValue: Bool = false
    @StateObject var viewRouter: ViewRouter
    @State var time = Timer.publish(every: 0.1, on: .current, in: .tracking).autoconnect()
    @State var show = false
    @State var bookmark: Bool = false
    
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .top) {
                ZStack {
                        ScrollView(.vertical) {
                            Spacer()
                                .frame(height: UIScreen.main.bounds.height*0.08)
                            
                            ForEach (Array(maps.keys).sorted(by: {$0 < $1}), id: \.self) { map in
                                GeometryReader { gg in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                                            .shadow(color: Color.darkEnd, radius: 5, x: 5, y: 5)
                                            
                                            Map(number: map, image: maps[map]!.image, text: maps[map]!.text, geometry: gg)
                                                .onTapGesture(count: 1) {
                                                    zIndexValue = true
                                                    image = maps[map]!.image
                                                    blurMap = true
                                                }
                                    }
                                }
                                .frame(width: g.size.width, height: g.size.height * 0.35, alignment: .center)
                                Spacer()
                                    .frame(height: g.size.height*0.09)
                            }
                        }
                            .disabled(zIndexValue)
                            .blur(radius: blurMap ? 15 : 0)
                            .zIndex(zIndexValue ? 0 : 1)
                        
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.25, alignment: .center)
                            .pinchToZoom()
                            .zIndex(zIndexValue ? 1 : 0)
                    }
                        .onTapGesture(count: 1) {
                            zIndexValue = false
                            image = UIImage()
                            blurMap = false
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3))
                        .edgesIgnoringSafeArea(.bottom)
                
                ZStack(alignment: .top) {
                    header(text: "Маршрут")
                    VStack {
                        HStack {
                                Button(action: {
                                    clearSVG()
                                    maps.removeAll()
                                    zIndexValue = false
                                    image = UIImage()
                                    blurMap = false
                                    bookmark = false
                                    viewRouter.currentPage = .navigation
                                }) {
                                        Image(systemName: "arrow.uturn.backward")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .foregroundColor(.offWhite)
                                        .frame(width: UIScreen.main.bounds.width * 0.05, height: UIScreen.main.bounds.width * 0.05)
                                }
                                    .frame(width: 50, height: 50)
                                    .buttonStyle(ColorfulButtonStyle())

                                Spacer()
                            
                                Toggle(isOn: $bookmark) {
                                    Image(systemName: self.bookmark ? "bookmark.fill" : "bookmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: UIScreen.main.bounds.width * 0.05, height: UIScreen.main.bounds.width * 0.05)
                                        .foregroundColor(Color.offWhite)
                                }
                                .frame(width: 50, height: 50)
                                .toggleStyle(ColorfulToggleStyle())
                            }
//                        .ignoresSafeArea(edges: .top)
                                .padding(.horizontal, 30)
                                .padding(.top, -10)
                        
                        Spacer()
                }
                          
                }
            }
            .frame(width: g.size.width, height: g.size.height)
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
    }
    
    func clearSVG () {
        for resource in maps.keys {
            let url = URL(fileURLWithPath: Bundle.main.path(forResource: maps[resource]!.name, ofType: "svg")!)
            try? maps[resource]!.mainContent.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewRouter: ViewRouter())
    }
}

struct Map: View {
    var number: Int
    var image: UIImage
    var text: String
    var geometry: GeometryProxy
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width, height: geometry.size.height * 0.9, alignment: .center)
            
            Text(text)
                .foregroundColor(Color.white)
                .frame(height: UIScreen.main.bounds.height * 0.1)
        }
        .padding(.vertical, 5)
    }
}

struct tabBarIcons: View {
    var geometry: GeometryProxy
    @StateObject var viewRouter: ViewRouter
    var showTabBar: [Page] = [.navigation, .datalist, .properties, .news]
    
    var body: some View {
        if showTabBar.contains(viewRouter.currentPage) {
            VStack {
                
                Spacer()
                
                ZStack {
                    Rectangle() // UIColor.systemBackground
                        .fill(
                            LinearGradient(Color.darkStart.opacity(0.97), Color.darkEnd)
                        )
                        .frame(width: geometry.size.width)
                        .cornerRadius(15, corners: [.topRight, .topLeft])
                    
                    HStack {
                        Spacer()
                        
                        TabBarIconNew(viewRouter: viewRouter, assignedPage: .navigation, width: geometry.size.width, height: geometry.size.height, systemIconName: "location", tabName: "Навигация")
                            .padding(.top, geometry.size.height/16/8)
                        
                        
                        Spacer()
                        
                        TabBarIconNew(viewRouter: viewRouter, assignedPage: .datalist, width: geometry.size.width, height: geometry.size.height, systemIconName: "list.bullet", tabName: "Расписание")
                            .padding(.top, geometry.size.height/16/8)
                        
                        
                        Spacer()
                        
                        TabBarIconNew(viewRouter: viewRouter, assignedPage: .news, width: geometry.size.width, height: geometry.size.height, systemIconName: "newspaper", tabName: "Новости")
                            .padding(.top, geometry.size.height/16/8)
                        
                        Spacer()
                        
                        TabBarIconNew(viewRouter: viewRouter, assignedPage: .properties, width: geometry.size.width, height: geometry.size.height, systemIconName: "gearshape", tabName: "Настройки")
                            .padding(.top, geometry.size.height/16/8)
                        
                        Spacer()
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3))
                    .frame(width: geometry.size.width, height: geometry.size.height/9)
                    
                    
                    // Линия над меню
                    
                    
                    //                        .overlay(
                    //                            Rectangle()
                    //                                .frame(width: nil, height: 1, alignment: .top)
                    //                                .foregroundColor(.gray)
                    //                                ,
                    //                            alignment: .top
                    //                        )
                    
                    
                    .shadow(color: .black, radius: 15)
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height/10)
                .frame(alignment: .bottom)
                //                ZStack{
                //                    Color.white.frame(width: geometry.size.width, height: geometry.size.height/8).opacity(0.9).overlay(
                //                        HStack {
                //                            Spacer()
                //                            TabBarIconNew(viewRouter: viewRouter, assignedPage: .navigation, width: geometry.size.width, height: geometry.size.height, systemIconName: "homekit", tabName: "Navigation")
                //                            Spacer()
                //                            TabBarIconNew(viewRouter: viewRouter, assignedPage: .properties, width: geometry.size.width, height: geometry.size.height, systemIconName: "heart", tabName: "Properties")
                //                            Spacer()
                //                        }
                //                            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3))
                //                            .overlay(
                //                                Rectangle()
                //                                    .frame(width: nil, height: 1, alignment: .top)
                //                                    .foregroundColor(.gray)
                //                                ,
                //                                alignment: .top
                //                            )
                //        //                    .blur(radius: 15)
                //        //                    .background(.pink)
                //                            .shadow(color: .black, radius: 15)
                //                    )
                //                }
            }
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

enum errorSignal {
    case start
    case end
    case all
    case nothing
}

struct entryField: View {
    @Binding var sourse: String
    @Binding var destination: String
    @Binding var errorInput: String
    @Binding var errorType: errorSignal
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("", text: $sourse)
                .modifier(
                    PlaceholderStyle(
                        showPlaceHolder: sourse.isEmpty,
                        placeholder: "Начальный кабинет",
                        center: false
                    )
                )
                .onChange(of: sourse) { newValue in
                    errorInput = ""
                    
                    if errorType == .all {
                        errorType = .end
                    } else if errorType == .start {
                        errorType = .nothing
                    }
                }
                .textContentType(.dateTime)
                .cornerRadius(10)
                .frame(height: 50, alignment: .leading)
                .multilineTextAlignment(.leading)
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(errorType == .start || errorType == .all ? Color.red : Color.clear, style: StrokeStyle(lineWidth: 3.0)))
            
            Spacer()
            
            Image(systemName: "chevron.down")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundColor(Color.offWhite)
                .frame(width: UIScreen.main.bounds.width*0.9/15, height: UIScreen.main.bounds.height / 4.5 / 10)
            
            Spacer()
            
            TextField("", text: $destination)
                .modifier(
                    PlaceholderStyle(
                        showPlaceHolder: destination.isEmpty,
                        placeholder: "Конечный кабинет",
                        center: false
                    )
                )
                .onChange(of: destination) { newValue in
                    errorInput = ""
                    
                    if errorType == .all {
                        errorType = .start
                    } else if errorType == .end {
                        errorType = .nothing
                    }
                }
                .cornerRadius(10)
                .frame(height: 50, alignment: .leading)
                .multilineTextAlignment(.leading)
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(errorType == .end || errorType == .all ? Color.red : Color.clear, style: StrokeStyle(lineWidth: 3.0)))
            
            Spacer()
        }
    }
}

struct Advert: View {
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image("1")
                        .resizable()
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)), lineWidth: 3)
                        )                        }
                
                VStack {
                    Image("2")
                        .resizable()
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)), lineWidth: 3)
                        )
                }
            }
            
            HStack {
                VStack {
                    Image("3")
                        .resizable()
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)), lineWidth: 3)
                        )
                }
                
                VStack {
                    Image("4")
                        .resizable()
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)), lineWidth: 3)
                        )
                }
            }
        }
        .frame(height: 210)
        .padding(.horizontal)
    }
}

struct Tittle: View {
    var text: String
    var name: String = ""
    
    var body: some View {
        HStack {
            if !name.isEmpty {
                Image(systemName: name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width*0.07, height: UIScreen.main.bounds.width*0.07)
                    .foregroundColor(.offWhite)
            }
            
            Text(text)
                .foregroundColor(.offWhite)
                .font(.system(size: UIScreen.main.bounds.height / 30))
                .fontWeight(.bold)
                .animation(.spring())
        }
    }
}

struct selectedRoutes: View {
    var route: [String] // Binding
    
    var body: some View {
        Button(action: {}) {
            ZStack {
                Rectangle()
                    .strokeBorder(Color("Purple"), lineWidth: 5)
                    .foregroundColor(Color.white)
                    .frame(width: UIScreen.main.bounds.width*0.9, height: 50)
                
                Text(route[0] + "\t->\t" + route[1])
                    .font(.system(size: UIScreen.main.bounds.width / 20))
                    .fontWeight(.bold)
                    .foregroundColor(Color.black.opacity(0.6))
            }
        }
        .buttonStyle(GrowingButtonWays())
    }
}

struct inputError: View {
    @Binding var errorInput: String
    
    var body: some View {
        Text(errorInput)
            .font(.system(size: 20))
            .foregroundColor(.red.opacity(0.7))
            .animation(.spring())
    }
}

struct Wall: View {
    var page: Page
    
    var body: some View {
        ZStack {
            LinearGradient(Color.darkEnd, Color.darkStart)
            
            switch page {
            case .navigation:
                Image(systemName: "location")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.darkEnd)
                    .opacity(0.8)
                    .padding()
                
            case .datalist:
                Image(systemName: "list.bullet")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.darkEnd)
                    .opacity(0.8)
                    .padding()
                
            case .properties:
                Color.clear
                
            case .maps:
                Color.clear                         // Пофиксить появление после тапа по картинке и сделать нормальные карточки как в Navigation
                                                    // Передалет полностью maps, так чтобы картинка и текст подстраивались под карточку
//                Image(systemName: "location")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .foregroundColor(.darkEnd)
//                    .opacity(0.8)
//                    .padding()
                
            case .news:
                Image(systemName: "newspaper")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.darkEnd)
                    .opacity(0.8)
                    .padding()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct Section1: View {
    @State var username: String = ""
    @State var password: String = ""
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
    @State private var previewIndexU = 0
    @State private var previewIndexF = 0
    @State private var selectedOptionIndex = 0
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

struct Section5: View {
    @State private var previewIndexT = 0
    @State private var previewIndexL = 0
    var theme = ["Тёмная", "Светлая"]
    var language = ["Русский", "English"]
    
    var body: some View {
        Section(header: Text("Интерфейс")) {
            Picker(selection: $previewIndexT, label: Text("Тема")) {
                ForEach(0..<theme.count) {
                    Text(self.theme[$0])
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

struct Section4: View {
    var body: some View {
        Section {
            Button(action: {
                print("Perform an action here...")
            }) {
                Text("Сбросить все настройки")
                    .foregroundColor(Color.lightStart)
            }
        }
        .listRowBackground(Color.gray.opacity(0.5))
    }
}

struct Properties: View {
    @State var time = Timer.publish(every: 0.1, on: .current, in: .tracking).autoconnect()
    @State var show = false
    
    var body: some View {
        VStack {
            NavigationView {
                ZStack(alignment: .top) {
                    Form {
                        GeometryReader { g in
                            Tittle(text: "Настройки")
                                .offset(y: g.frame(in: .global).minY > 0 ? -g.frame(in: .global).minY/25 : 0)
                                .scaleEffect(g.frame(in: .global).minY > 0 ? g.frame(in: .global).minY/150 + 1 : 1)
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
                                .padding(.top, UIScreen.main.bounds.height*0.05)
                        }
                        
                        .listRowBackground(Color.clear)
                        .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.height*0.1, alignment: .center)
                        
                        
                        Section2()
                        Section1()
                        Section5()
                        Section3()
                        Section4()
                        
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
                        ZStack {
                            LinearGradient(Color.darkEnd, Color.darkStart)
                            
                            Image(systemName: "gearshape")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.darkEnd)
                                .opacity(0.8)
                                .padding()
                        }
                    )
                    
                    if self.show {
                        header(text: "Настройки")
                    }
                }
                    .navigationBarHidden(true)
            }
            .preferredColorScheme(.dark)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .ignoresSafeArea(.all)
    }
}

extension CGSize {
    static func + (left: CGSize, right: CGSize) -> CGSize {
        var size: CGSize = CGSize.zero
        
        size.width = left.width + right.width
        size.height = left.height + right.height
        
        return size
    }
}

enum Positions {
    case start
    case scroll
    case showTitle
}

struct selectedRoute: Identifiable {
    var id: UUID = UUID()
    var route: [String] = ["", ""]
}

struct CardView: View {
    var geometry: GeometryProxy
    var isFaceUp: Bool
    var imageName: [String]
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(LinearGradient(Color.darkEnd, Color.darkStart))
            .frame(width: geometry.size.width, height: geometry.size.height)
            .shadow(color: Color.darkStart, radius: 5, x: isFaceUp ? -5 : 5, y: -5)
            .shadow(color: Color.darkEnd, radius: 5, x: isFaceUp ? 5 : -5, y: 5)
            .padding(.vertical, 30)
            .overlay(
                ZStack {
                    if isFaceUp {
                        HStack{
                            ForEach(0..<imageName.count) { name in
                                Image(systemName: imageName[name])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width*0.3, height: geometry.size.height/4)
                                    .foregroundColor(.darkEnd)
                                    .opacity(0.8)
                                    .animation(nil)
                            }
                        }
                    }
                }
            )
    }
}

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

extension View {
    func cardFlip(isFaceUp: Bool) -> some View {
        modifier(CardFlip(isFaceUp: isFaceUp))
    }
}

struct fastCard: Identifiable {
    var id: UUID = UUID()
    var isFaceUp: Bool = true
    var images: [String]
}

struct Navigation: View {
    @State var listOfSelectedRoutes: [selectedRoute] = []
    var geometry: GeometryProxy
    @State var errorInput: String = ""
    @State var sourse: String = "2068" // 2068
    @State var destination: String = "2115" // 2115
    @State var commonFriend: [UnweightedEdge] = []
    @State var Vertex: [Point] = []
    @State var paint: [String] = []
    @Binding var maps: Dictionary<Int, mapContents>
    @State var cityGraph = UnweightedGraph<Point>(vertices: [])
    @State var sPoint: [String] = []
    @State var s: [String] = []
    @State var complete: Bool = false
    @StateObject var viewRouter: ViewRouter
    @State var offsetValue: CGSize = CGSize.zero
    @State var offsetSum: CGSize = CGSize.zero
    @State var position: Positions = .start
    @State var pos = 0
    @State var scrollContentOffset: CGFloat = CGFloat.zero
    @State var scrollContentOffsetSum: CGFloat = CGFloat(110)
    @State var time = Timer.publish(every: 0.1, on: .current, in: .tracking).autoconnect()
    @State var show = false
    @State var Cards: [fastCard] = [
        .init(images: ["rectangle.portrait.and.arrow.right.fill"]),
        .init(images: ["fork.knife"]),
        .init(images: ["w.square.fill", "c.square.fill"]),
        .init(images: ["cross"]),
        .init(images: ["dollarsign.circle"])
    ]
    @State var errorType: errorSignal = .nothing
    @State var selectedMaps: [[String]] = [
        ["2068", "2069"],
        ["2068", "2115"],
        ["2006", "2073"],
        ["2103", "2177"],
        ["2115", "2109"],
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical, showsIndicators: false) { // Для анимации []
                GeometryReader { g in
                    Tittle(text: "Навигация", name: "location.viewfinder")
                        .offset(y: g.frame(in: .global).minY > 0 ? -g.frame(in: .global).minY/25 : 0)
                        .scaleEffect(g.frame(in: .global).minY > 0 ? g.frame(in: .global).minY/150 + 1 : 1)
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
                        .padding(.top, UIScreen.main.bounds.height*0.05)
                }
                .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.height*0.1, alignment: .center)
                
                VStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height / 4.5)
                        .shadow(color: Color.darkStart, radius: 5, x: -5, y: -5)
                        .shadow(color: Color.darkEnd, radius: 5, x: 5, y: 5)
                        .overlay(
                            HStack {
                                Spacer()
                                
                                entryField(sourse: $sourse, destination: $destination, errorInput: $errorInput, errorType: $errorType)
                                
                                Spacer()
                                
                                Button(action: {
                                    makeRoute()
                                }) {
                                    
                                        Image(systemName: "magnifyingglass")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(.offWhite)
                                            .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.height / 4.5)
                                            .padding(.horizontal, 30)
                                }
                                .buttonStyle(ColorfulButtonStyleWithoutShadows())
                                
                            }
                        )
                    
                    inputError(errorInput: $errorInput)
                        .frame(height: UIScreen.main.bounds.height / 4.5 / 3)
                    
                    HStack {
                        Image(systemName: "clock")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width*0.07, height: UIScreen.main.bounds.width*0.07)
                            .foregroundColor(.offWhite)
                        
                        Text("Быстрый поиск")
                            .foregroundColor(.offWhite)
                            .font(.system(size: UIScreen.main.bounds.height / 30))
                            .fontWeight(.bold)
                    }
                    
                        ScrollView(.horizontal, showsIndicators: false) {
                            ScrollViewReader { value in
                                HStack(spacing: -30) {
                                    ForEach(Cards.indices) { index in
                                        GeometryReader { gg in
                                            CardView(geometry: gg, isFaceUp: self.Cards[index].isFaceUp, imageName: self.Cards[index].images)
                                                .cardFlip(isFaceUp: self.Cards[index].isFaceUp)
                                                .animation(.spring())
                                                .onTapGesture {
                                                    if Cards[index].isFaceUp {
                                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)) {
                                                            value.scrollTo(index, anchor: .center)
                                                        }
                                                    }
                                                    
                                                    self.Cards[index].isFaceUp.toggle()
 
                                                    for i in 0..<Cards.count {
                                                        if i != index {
                                                            self.Cards[i].isFaceUp = true
                                                        }
                                                    }
                                                }
                                                .rotation3DEffect(Angle(degrees: Double(gg.frame(in: .global).minX - 50) / -20), axis: (x: 0, y: 100.0, z: 0))
                                        }
                                        .id(index)
                                        .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.height / 4.5)
                                        .padding(.bottom, 50)
                                        .padding(.horizontal)
                                    }
                                }
                                .onAppear(perform: {
                                    value.scrollTo(Int(Cards.count/2), anchor: .center)
                                })
                                .padding(.trailing, 15)
                            }
                        }

                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "bookmark")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width*0.05, height: UIScreen.main.bounds.width*0.05)
                                .foregroundColor(.offWhite)
                            
                            Text("Избранные маршруты")
                                .foregroundColor(.offWhite)
                                .font(.system(size: UIScreen.main.bounds.height / 30))
                                .fontWeight(.bold)
                        }
                        
                        ForEach(selectedMaps.indices) { index in
                            Button(action: {
                                makeRouteFast(first: self.selectedMaps[index][0], last: self.selectedMaps[index][1])
                            }) {
                                Text("\(self.selectedMaps[index][0]) -> \(self.selectedMaps[index][1])")
                                    .foregroundColor(.offWhite)
                                    .font(.system(size: UIScreen.main.bounds.height / 40))
                                    .fontWeight(.semibold)
                                    .frame(width: UIScreen.main.bounds.width*0.8, height: 15)
                            }
                            .buttonStyle(ColorfulButtonStyleRoundedRectangle())
                        }
                    }
                    Spacer()
                    
                    Advert()
                    
                    Advert()
                    
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height/4)
                }
                .padding(.top, 15)
            }
            
            if self.show{
                header(text: "Навигация")
            }
            
        }
        .edgesIgnoringSafeArea(.top)
        .edgesIgnoringSafeArea(.bottom)
        .onAppear(perform: {
            start()
        })
    }
    
    func makeRouteFast(first: String, last: String) {
        errorType = .nothing
        commonFriend = cityGraph.bfs(from: find(p: first), to: find(p: last))
        
        s = parse(way: commonFriend.description)
        sPoint = s.map {Vertex[Int($0)!].name}
        paint = getLines()
        
        for x in 0...paint.count - 1 where x % 3 == 0 {
            maps.updateValue(mapContents(name: "Maps/" + paint[x], mainContent: getSVG(resource: "Maps/" + paint[x]), image: getImage(resource: "Maps/" + paint[x], linesCode: paint[x + 1]), text: paint[x + 2]), forKey: x / 3)
        }
        
        errorInput = ""
        viewRouter.currentPage = .maps
    }
    
    func makeRoute() {
        if find(p: sourse) == Point() && find(p: destination) == Point() {
            errorInput = "Кабинет \(sourse) и \(destination) не найдены"
            errorType = .all
        } else if find(p: sourse) == Point() {
            errorInput = "Кабинет \(sourse) не найден"
            errorType = .start
        } else if find(p: destination) == Point() {
            errorInput = "Кабинет \(destination) не найден"
            errorType = .end
        } else {
            errorType = .nothing
            commonFriend = cityGraph.bfs(from: find(p: sourse), to: find(p: destination))
            
            s = parse(way: commonFriend.description)
            sPoint = s.map {Vertex[Int($0)!].name}
            paint = getLines()
            
            for x in 0...paint.count - 1 where x % 3 == 0 {
                maps.updateValue(mapContents(name: "Maps/" + paint[x], mainContent: getSVG(resource: "Maps/" + paint[x]), image: getImage(resource: "Maps/" + paint[x], linesCode: paint[x + 1]), text: paint[x + 2]), forKey: x / 3)
            }
            
            errorInput = ""
            viewRouter.currentPage = .maps
        }
    }
    
    func find (p: String) -> Point {
        for x in Vertex {
            if x == p {
                return x
            }
        }
        
        return Point()
    }
    
    func parse (way: String) -> [String] {
        var newWay = way.replacingOccurrences(of: " ", with: "")
        newWay = newWay.replacingOccurrences(of: "->", with: ",")
        newWay = newWay.replacingOccurrences(of: "[", with: "")
        newWay = String(newWay.replacingOccurrences(of: "]", with: ""))
        
        return newWay.split(separator: ",").map {String($0)}
    }
    
    func start () {
        if !complete {
            listOfSelectedRoutes.append(.init(route: ["2068", "2115"]))
            listOfSelectedRoutes.append(.init(route: ["2068", "2115"]))
            listOfSelectedRoutes.append(.init(route: ["2068", "2115"]))
            listOfSelectedRoutes.append(.init(route: ["2068", "2115"]))
            listOfSelectedRoutes.append(.init(route: ["2068", "2115"]))
            
            
            var url = URL(fileURLWithPath: Bundle.main.path(forResource: "Data/Vertex" , ofType: "json")!)
            var contentsJSON = NSData(contentsOf: url)! as Data
            
            do {
                let object = try JSONSerialization.jsonObject(with: contentsJSON, options: .allowFragments)
                if let dictionary = object as? Dictionary<String, Dictionary<String, String>> {
                    
                    for x in dictionary.keys {
                        Vertex.append(Point(newName: x, newHousing: dictionary[x]!["housing"]!, newFloor: dictionary[x]!["floor"]!, newX: dictionary[x]!["x"]!, newY: dictionary[x]!["y"]!, newX0: dictionary[x]!["x0"]!, newY0: dictionary[x]!["y0"]!))
                    }
                    
                    cityGraph = UnweightedGraph<Point>(vertices: Vertex)
                }
            } catch {
                print("qwe")
            }
            
            url = URL(fileURLWithPath: Bundle.main.path(forResource: "Data/Edges" , ofType: "json")!)
            contentsJSON = NSData(contentsOf: url)! as Data
            
            do {
                let object = try JSONSerialization.jsonObject(with: contentsJSON, options: .allowFragments)
                if let dictionary = object as? Dictionary<String, [String]> {
                    for x in dictionary.keys {
                        for y in dictionary[x]! {
                            cityGraph.addEdge(from: find(p: x), to: find(p: y))
                        }
                    }
                }
            } catch {
                print("qwe")
            }
            
            complete = true
        }
    }
    
    func getLines () -> [String] {
        var newPaintMass: [String] = []
        var newPaint: String = ""
        
        if sPoint.count > 1 {
            newPaintMass.append(find(p: sPoint[0]).housing + find(p: sPoint[0]).floor)
            newPaint = getSourcePoint(x1: find(p: sPoint[0]).x0, y1: find(p: sPoint[0]).y0) + "\n"
            newPaint += "<polyline class=\"st8\" points=\"" + "\(find(p: sPoint[0]).x0) \(find(p: sPoint[0]).y0), \(find(p: sPoint[0]).x) \(find(p: sPoint[0]).y)"
            
            for x in sequence(first: 0, next: { $0 + 2 }).prefix(while: { $0 <= sPoint.count - 1 }) {
                if x == sPoint.count - 2 {
                    newPaint += ", \(find(p: sPoint[x+1]).x) \(find(p: sPoint[x+1]).y), \(find(p: sPoint[x+1]).x0) \(find(p: sPoint[x+1]).y0) \"/>\n"
                    newPaint += getSourcePoint(x1: find(p: sPoint[x+1]).x0, y1: find(p: sPoint[x+1]).y0) + "\n"
                    newPaintMass.append(newPaint)
                    newPaintMass.append("Вы на месте!")
                } else if find(p: sPoint[x]).housing != find(p: sPoint[x+1]).housing {
                    newPaint += ", \(find(p: sPoint[x]).x0) \(find(p: sPoint[x]).y0) \"/>\n"
                    newPaintMass.append(newPaint)
                    newPaintMass.append("Пройдите по переходу в корпус \(find(p: sPoint[x+1]).housing)")
                    newPaintMass.append(find(p: sPoint[x+1]).housing + find(p: sPoint[x+1]).floor)
                    newPaint = "<polyline class=\"st8\" points=\"" + "\(find(p: sPoint[x+1]).x0) \(find(p: sPoint[x+1]).y0), \(find(p: sPoint[x+1]).x) \(find(p: sPoint[x+1]).y)"
                } else if find(p: sPoint[x]).floor != find(p: sPoint[x+1]).floor {
                    newPaint += ", \(find(p: sPoint[x+1]).x0) \(find(p: sPoint[x+1]).y0) \"/>\n"
                    newPaintMass.append(newPaint)
                    
                    if find(p: sPoint[x]).floor > find(p: sPoint[x+1]).floor {
                        newPaintMass.append("Спуститесь по лестнице на \(find(p: sPoint[x+1]).floor) этаж")
                    } else {
                        newPaintMass.append("Поднимитесь по лестнице на \(find(p: sPoint[x+1]).floor) этаж")
                    }
                    
                    newPaintMass.append(find(p: sPoint[x+1]).housing + find(p: sPoint[x+1]).floor)
                    
                    newPaint = "<polyline class=\"st8\" points=\"" + "\(find(p: sPoint[x+1]).x0) \(find(p: sPoint[x+1]).y0), \(find(p: sPoint[x+1]).x) \(find(p: sPoint[x+1]).y)"
                } else {
                    newPaint += ", \(find(p: sPoint[x+1]).x) \(find(p: sPoint[x+1]).y)"
                }
            }
        }
        
        return newPaintMass
    }
    
    func getImage (resource: String, linesCode: String) -> UIImage {
        let url = urlSVGWithLines(resource: resource, linesCode: linesCode)
        
        return SVGToUIImage(url: url)
    }
    
    func getSVG (resource: String) -> String {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: resource, ofType: "svg")!)
        
        if let urlContents = try? String(contentsOf: url) {
            return urlContents
        }
        
        return String() // !!!
    }
    
    func getSourcePoint (x1: String, y1: String) -> String {
        return "<circle class=\"st9\" cx=\"\(x1)\" cy=\"\(y1)\" r=\"6.4\"/>"
    }
    
    func urlSVGWithLines (resource: String, linesCode: String) -> URL { // $$$
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: resource, ofType: "svg")!)
        var contentsSVG = try? String(contentsOf: url)
        
        contentsSVG = appendLinesToSVG(xmlString: contentsSVG!, linesCode: linesCode)
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let toURL = dir!.appendingPathComponent("B2" + ".svg")
        
        do {
            try contentsSVG!.write(to: toURL, atomically: false, encoding: .utf8)
        } catch {/* error handling here */}
        
        //            //delete
        //            do {
        //                try FileManager.default.removeItem(at: toURL)
        //            }
        //            catch {/* error handling here */}
        
        return toURL
    }
    
    func SVGToUIImage (url: URL) -> UIImage {
        let mySVGImage: SVGKImage = SVGKImage(contentsOf: url)
        let image: UIImage = mySVGImage.uiImage
        
        return image
    }
    
    func appendLinesToSVG (xmlString: String, linesCode: String) -> String { // $$$
        var xml = xmlString.components(separatedBy: "\n")
        
        xml.insert("""
        \(linesCode)
        """, at: xml.count - 2)
        
        return xml.joined(separator: "\n")
    }
}

struct dataList: View {
    @State var time = Timer.publish(every: 0.1, on: .current, in: .tracking).autoconnect()
    @State var show = false
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical, showsIndicators: false) {
                GeometryReader { g in
                    Tittle(text: "Расписание", name: "list.bullet.below.rectangle")
                        .offset(y: g.frame(in: .global).minY > 0 ? -g.frame(in: .global).minY/25 : 0)
                        .scaleEffect(g.frame(in: .global).minY > 0 ? g.frame(in: .global).minY/150 + 1 : 1)
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
                        .padding(.top, UIScreen.main.bounds.height*0.05)
                }
                .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.height*0.1, alignment: .center)
                
                Rectangle()
                    .fill(Color.darkStart)
                    .frame(height: 500)
                    .opacity(0.5)
                    .padding()
            }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            if self.show{
                header(text: "Расписание")
            }
        }
            .ignoresSafeArea(.all)
    }
}

struct header: View {
    var text: String
    
    var body: some View {
        VStack {
                Text(text)
                    .foregroundColor(.offWhite)
                    .font(.system(size: UIScreen.main.bounds.height / 30))
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.1)
                    .padding(.top, 15)
                    .background(BlurBG())
                    .cornerRadius(25, corners: [.bottomRight, .bottomLeft])
                    .edgesIgnoringSafeArea(.top)
            
            Spacer()
        }
    }
}

struct BlurBG : UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIVisualEffectView{
        
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}
