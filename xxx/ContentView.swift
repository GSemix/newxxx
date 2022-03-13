//
//  ContentView.swift
//  mainMgimo
//
//  Created by Семен Безгин on 05.01.2022.
//

import UIKit
import CoreData
import SVGKit
import SwiftUI
import SwiftGraph
import PocketSVG
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields

// --------------------------------

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
            .padding(20)
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
                    .fill(LinearGradient(settings.theme == 0 ? Color.lightEnd : Color.purpleEnd, settings.theme == 0 ? Color.lightStart : Color.purpleStart))
                    .overlay(shape.stroke(LinearGradient(settings.theme == 0 ? Color.lightStart : Color.purpleStart, settings.theme == 0 ? Color.lightEnd : Color.purpleEnd), lineWidth: 4))
                    .shadow(color: settings.theme == 0 ? Color.darkStart : Color.white, radius: 5, x: 5, y: 5)
                    .shadow(color: settings.theme == 0 ? Color.darkEnd : Color.gray, radius: 5, x: -5, y: -5)
                
            } else {
                shape
                    .fill(LinearGradient(settings.theme == 0 ? Color.darkStart : Color.offWhite, settings.theme == 0 ? Color.darkEnd : Color.offWhite))
                    .overlay(shape.stroke(LinearGradient(settings.theme == 0 ? Color.lightStart : Color.purpleStart, settings.theme == 0 ? Color.lightEnd : Color.purpleEnd), lineWidth: 4))
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

extension Point {
    static func == (first: Point, second: String) -> Bool {
        return first.name == second
    }
}

extension Binding {
    func didSet(_ didSet: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                didSet(newValue)
            }
        )
    }
    
    func willSet(_ willSet: @escaping ((newValue: Value, oldValue: Value)) -> Void) -> Binding<Value> {
            return .init(get: { self.wrappedValue }, set: { newValue in
                willSet((newValue, self.wrappedValue))
                self.wrappedValue = newValue
            })
        }
}

extension View {
    public func pinchToZoom() -> some View {
        self.modifier(PinchToZoom())
    }
    
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    public func cardFlip(isFaceUp: Bool) -> some View {
        modifier(CardFlip(isFaceUp: isFaceUp))
    }
    
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
             .overlay(roundedRect.strokeBorder(content, lineWidth: width))
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
    @State var isPinching: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .offset(offset)
            .animation(isPinching ? .none : .spring(), value: true)
            .overlay(PinchZoom(scale: $scale, anchor: $anchor, offset: $offset, isPinching: $isPinching))
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
    var way: [String] = ["", ""]
}

struct ContentView: View {
    @State var maps: Dictionary<Int, mapContents> = Dictionary()
    @StateObject var viewRouter: ViewRouter
    @ObservedObject var settings = UserDefaultsSettings()
    @State var menu: Bool = true
    @State var isBookmark: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            switch viewRouter.currentPage {

            case .navigation:
                Wall(settings: settings, page: .navigation)
                Navigation(geometry: geometry, maps: $maps, viewRouter: viewRouter, settings: settings, isBookmark: $isBookmark)
//                    .transition(.scale)
                    
            case .datalist:
                Wall(settings: settings, page: .datalist)
                dataList(settings: settings)
//                    .transition(.scale)

            case .properties:
//                Wall(settings: settings, page: .properties)
                Properties(settings: settings)
//                    .transition(.scale)

            case .maps:
                Wall(settings: settings, page: .maps)
                navigationPage(maps: $maps, viewRouter: viewRouter, bookmark: $isBookmark, settings: settings)
                    .transition(.scale)

            case .news:
                Wall(settings: settings, page: .news)
                news(settings: settings)
//                    .transition(.scale)
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

struct news: View {
    @ObservedObject var settings: UserDefaultsSettings
    
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
                        .foregroundColor(settings.theme == 0 ? Color(viewRouter.currentPage == assignedPage ? .white : .gray) : Color(viewRouter.currentPage == assignedPage ? .black : .gray))
                    
                    Text(tabName)
                        .font(.system(size: 10)) // 18
                        .foregroundColor(settings.theme == 0 ? Color(viewRouter.currentPage == assignedPage ? .white : .gray) : Color(viewRouter.currentPage == assignedPage ? .black : .gray))
                }
            }
            .padding(.horizontal, width/8/6)
            .buttonStyle(GrowingButton())
            
            Spacer()
        }
    }
}

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
  private var content: Content

    init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

    func makeUIView(context: Context) -> UIScrollView {
    // set up the UIScrollView
    let scrollView = UIScrollView()
    scrollView.delegate = context.coordinator  // for viewForZooming(in:)
    scrollView.maximumZoomScale = 4
    scrollView.minimumZoomScale = 1
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.bouncesZoom = true

    // create a UIHostingController to hold our SwiftUI content
    let hostedView = context.coordinator.hostingController.view!
    hostedView.translatesAutoresizingMaskIntoConstraints = true
    hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostedView.frame = scrollView.bounds
    hostedView.backgroundColor = UIColor.clear
    scrollView.addSubview(hostedView)

    return scrollView
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(hostingController: UIHostingController(rootView: self.content))
  }

  func updateUIView(_ uiView: UIScrollView, context: Context) {
    // update the hosting controller's SwiftUI content
    context.coordinator.hostingController.rootView = self.content
    assert(context.coordinator.hostingController.view.superview == uiView)
  }

  // MARK: - Coordinator

  class Coordinator: NSObject, UIScrollViewDelegate {
    var hostingController: UIHostingController<Content>

    init(hostingController: UIHostingController<Content>) {
      self.hostingController = hostingController
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return hostingController.view
    }
  }
}


// Constrains a value between the limits
func clamp(_ value: CGFloat, _ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
  min(maxValue, max(minValue, value))
}

// UIView that relies on UIPinchGestureRecognizer to detect scale, anchor point and offset
class ZoomableView: UIView {
  let minScale: CGFloat
  let maxScale: CGFloat
  let scaleChange: (CGFloat) -> Void
  let anchorChange: (UnitPoint) -> Void
  let offsetChange: (CGSize) -> Void

  private var scale: CGFloat = 1 {
    didSet {
      scaleChange(scale)
    }
  }
  private var anchor: UnitPoint = .center {
    didSet {
      anchorChange(anchor)
    }
  }
  private var offset: CGSize = .zero {
    didSet {
      offsetChange(offset)
    }
  }

  private var isPinching: Bool = false
  private var startLocation: CGPoint = .zero
  private var location: CGPoint = .zero
  private var numberOfTouches: Int = 0
  // track the previous scale to allow for incremental zooms in/out
  // with multiple sequential pinches
  private var prevScale: CGFloat = 0

  init(minScale: CGFloat,
       maxScale: CGFloat,
       scaleChange: @escaping (CGFloat) -> Void,
       anchorChange: @escaping (UnitPoint) -> Void,
       offsetChange: @escaping (CGSize) -> Void) {
    self.minScale = minScale
    self.maxScale = maxScale
    self.scaleChange = scaleChange
    self.anchorChange = anchorChange
    self.offsetChange = offsetChange
    super.init(frame: .zero)
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
    pinchGesture.cancelsTouchesInView = false
    addGestureRecognizer(pinchGesture)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  @objc private func pinch(gesture: UIPinchGestureRecognizer) {
    switch gesture.state {
    case .began:
      isPinching = true
      startLocation = gesture.location(in: self)
      anchor = UnitPoint(x: startLocation.x / bounds.width, y: startLocation.y / bounds.height)
      numberOfTouches = gesture.numberOfTouches
      prevScale = scale
    case .changed:
      if gesture.numberOfTouches != numberOfTouches {
        let newLocation = gesture.location(in: self)
        let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
        startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)
        numberOfTouches = gesture.numberOfTouches
      }
      scale = clamp(prevScale * gesture.scale, minScale, maxScale)
      location = gesture.location(in: self)
      offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)
    case .possible, .cancelled, .failed:
      isPinching = false
      scale = 1.0
      anchor = .center
      offset = .zero
    case .ended:
      isPinching = false
    @unknown default:
      break
    }
  }
}

// Wraps ZoomableView and exposes it to SwiftUI
struct ZoomableOverlay: UIViewRepresentable {
  @Binding var scale: CGFloat
  @Binding var anchor: UnitPoint
  @Binding var offset: CGSize
  let minScale: CGFloat
  let maxScale: CGFloat

  func makeUIView(context: Context) -> ZoomableView {
    let uiView = ZoomableView(minScale: minScale,
                              maxScale: maxScale,
                              scaleChange: { scale = $0 },
                              anchorChange: { anchor = $0 },
                              offsetChange: { offset = $0 })
    return uiView
  }

  func updateUIView(_ uiView: ZoomableView, context: Context) { }
}

// Applies ZoomableOverlay to intercept gestures and apply scale,
// anchor point and offset
struct Zoomable: ViewModifier {
    @Binding var scale: CGFloat
    @Binding private var offset: CGSize
    let minScale: CGFloat
    let maxScale: CGFloat
    @State private var anchor: UnitPoint = .center

    init(scale: Binding<CGFloat>,
         offset: Binding<CGSize>,
         minScale: CGFloat,
         maxScale: CGFloat) {
        _scale = scale
        _offset = offset
        self.minScale = minScale
        self.maxScale = maxScale
    }

  func body(content: Content) -> some View {
    content
      .scaleEffect(scale, anchor: anchor)
      .offset(offset)
      .animation(.spring()) // looks more natural
      .overlay(ZoomableOverlay(scale: $scale,
                               anchor: $anchor,
                               offset: $offset,
                               minScale: minScale,
                               maxScale: maxScale))
      .gesture(TapGesture(count: 2).onEnded {
        if scale != 1 { // reset the scale
          scale = clamp(1, minScale, maxScale)
          anchor = .center
          offset = .zero
        } else { // quick zoom
          scale = clamp(2, minScale, maxScale)
        }
      })
  }
}

extension View {
  func zoomable(scale: Binding<CGFloat>,
                offset: Binding<CGSize>,
                minScale: CGFloat = 1,
                maxScale: CGFloat = 3) -> some View {
      modifier(Zoomable(scale: scale, offset: offset, minScale: minScale, maxScale: maxScale))
  }
}


struct navigationPage: View {
    @Binding var maps: Dictionary<Int, mapContents>
    @State var blurMap: Bool = false
    @State var image: UIImage = UIImage()
    @State var zIndexValue: Bool = false
    @StateObject var viewRouter: ViewRouter
    @Binding var bookmark: Bool
    @State var offsetValue: CGFloat = .zero
    @ObservedObject var settings: UserDefaultsSettings
    @State private var scale: CGFloat = 1.0
    @State var offset = CGSize.zero
    @State var newPosition = CGSize.zero
    
    var body: some View {
            ZStack(alignment: .top) {
                ZStack {
                        ScrollView(.vertical, showsIndicators: false) {
                            Spacer()
                                .frame(height: UIScreen.main.bounds.height*0.08)
                            
                            ForEach (Array(maps.keys).sorted(by: {$0 < $1}), id: \.self) { map in
                                Map(settings: settings, number: map, image: maps[map]!.image, text: maps[map]!.text)
                                    .onTapGesture(count: 1) {
                                        zIndexValue = true
                                        image = maps[map]!.image
                                        blurMap = true
                                }
                            }
                        }
                            .disabled(zIndexValue)
                            .blur(radius: blurMap ? 15 : 0)
                            .zIndex(zIndexValue ? 0 : 1)
                    
                  
                    
                        
                            VStack {
                                Spacer()
                                
                                Image(uiImage: image)
                                    .resizable()
                                    
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.25, alignment: .center)
                                    
                                    
                                        
                                Spacer()
                            }
                            .zoomable(scale: $scale, offset: $offset)
                            .gesture(DragGesture()
                                            .onChanged { value in
                                                self.offset = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                                        }
                                            .onEnded { value in
                                                self.offset = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                                                print(self.newPosition.width)
                                                self.newPosition = self.offset
                                            }
                                    )
                        .zIndex(zIndexValue ? 1 : 0)
                    
//                    if blurMap {
//                        VStack {
//                            Spacer()
//                            Image(uiImage: image)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.25, alignment: .center)
//                            Spacer()
//                        }
//                            .pinchToZoom()
////                            .zIndex(zIndexValue ? 1 : 0)
//                    }
                    
                            
                    }
                        .onTapGesture(count: 1) {
                            zIndexValue = false
                            image = UIImage()
                            blurMap = false
                            scale = 1.0
                            offset = .zero
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3))
                        .edgesIgnoringSafeArea(.bottom)
                
                ZStack(alignment: .top) {
                    header(settings: settings, text: "Маршрут")
                    VStack {
                        HStack {
                                Button(action: {
                                    withAnimation {
                                        bookmark = false
                                        clearSVG()
                                        maps.removeAll()
                                        zIndexValue = false
                                        image = UIImage()
                                        blurMap = false
                                        viewRouter.currentPage = .navigation
                                    }
                                }) {
                                        Image(systemName: "arrow.uturn.backward")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .foregroundColor(.lightStart)
                                        .frame(width: UIScreen.main.bounds.width * 0.05, height: UIScreen.main.bounds.width * 0.05)
                                        .padding(15)
                                        .clipShape(Capsule())
                                }
                                    .frame(width: 50, height: 50)

                                Spacer()
                            
                            Toggle(isOn: $bookmark.didSet { _ in
                                    if bookmark {
                                        if !self.settings.selectedMaps.contains(self.maps[0]!.way.joined(separator: " ")) {
                                            self.settings.selectedMaps.append(self.maps[0]!.way.joined(separator: " "))
                                        }
                                    } else {
                                        if self.settings.selectedMaps.contains(self.maps[0]!.way.joined(separator: " ")) {
                                            self.settings.selectedMaps.remove(at: self.settings.selectedMaps.firstIndex(of: self.maps[0]!.way.joined(separator: " "))!)
                                        }
                                    }
                                }
                            ) {
                                    Image(systemName: self.bookmark ? "bookmark.fill" : "bookmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: UIScreen.main.bounds.width * 0.05, height: UIScreen.main.bounds.width * 0.05)
                                        .foregroundColor(Color.lightStart)
                                }
                                .frame(width: 50, height: 50)
                                .toggleStyle(ImageToggle())
                            }
                                .padding(.horizontal, 30)
                        
                        Spacer()
                }
                          
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
            .onAppear(perform: {
                print("qwe")
            })
    }
    
    func clearSVG () {
        for resource in maps.keys {
            let url = URL(fileURLWithPath: Bundle.main.path(forResource: maps[resource]!.name, ofType: "svg")!)
            try? maps[resource]!.mainContent.write(to: url, atomically: true, encoding: .utf8)
        }
        
        maps.removeAll()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewRouter: ViewRouter())
    }
}

struct Map: View {
    @ObservedObject var settings: UserDefaultsSettings
    var number: Int
    var image: UIImage
    var text: String
    
    var body: some View {
        VStack {
            ZoomableScrollView {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: UIScreen.main.bounds.height*0.25)
            }
            .frame(height: UIScreen.main.bounds.height*0.3)
            .cornerRadius(15)
            .addBorder(Color.lightStart, width: 2, cornerRadius: 15)
            
            
            
            HStack {
                Circle()
                    .fill(Color.lightStart)
                    .shadow(color: Color.white, radius: 2.5)
                    .frame(width: 5, height: 5)
                    
                Text(text)
                    .foregroundColor(Color.white)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.35, alignment: .center)
        .padding(.vertical, 5)
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
                        .frame(width: geometry.size.width)
                        .cornerRadius(15, corners: [.topRight, .topLeft])
                        .addBorder(Color.darkStart.opacity(0.8), width: 2, cornerRadius: 15)

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
    @ObservedObject var settings: UserDefaultsSettings
    var text: String
    var name: String = ""
    
    var body: some View {
        HStack {
            if !name.isEmpty {
                Image(systemName: name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width*0.07, height: UIScreen.main.bounds.width*0.07)
                    .foregroundColor(settings.theme == 0 ? .offWhite : .darkEnd)
            }
            
            Text(text)
                .foregroundColor(settings.theme == 0 ? .offWhite : .darkEnd)
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
    @ObservedObject var settings: UserDefaultsSettings
    var page: Page
    
    var body: some View {
        ZStack {
            LinearGradient(settings.theme == 0 ? Color.darkEnd : Color.offWhite, settings.theme == 0 ? Color.darkStart : Color.offWhite)
                .ignoresSafeArea(.all)
            
            switch page {
            case .navigation:
                Image(systemName: "location")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(settings.theme == 0 ? .darkEnd : .purpleStart) // opacity 0.6
                    .opacity(0.8)
                    .padding()
                
            case .datalist:
                Image(systemName: "list.bullet")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(settings.theme == 0 ? .darkEnd : .purpleStart)
                    .opacity(0.8)
                    .padding()
                
            case .properties:
                Image(systemName: "gearshape")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(settings.theme == 0 ? .darkEnd : .purpleStart)
                    .opacity(0.8)
                    .padding()
                
            case .maps:
//                Color.clear                         // Пофиксить появление после тапа по картинке и сделать нормальные карточки как в Navigation
                                                    // Передалет полностью maps, так чтобы картинка и текст подстраивались под карточку
                Image(systemName: "location")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(settings.theme == 0 ? .darkEnd : .purpleStart)
                    .opacity(0.8)
                    .padding()
                
            case .news:
                Image(systemName: "newspaper")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(settings.theme == 0 ? .darkEnd : .purpleStart)
                    .opacity(0.8)
                    .padding()
            }
        }
        .edgesIgnoringSafeArea(.all)
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

struct Properties: View {
    @ObservedObject var settings: UserDefaultsSettings
    @State var time = Timer.publish(every: 0.1, on: .current, in: .tracking).autoconnect()
    @State var show = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Form {
                    GeometryReader { g in
                        Tittle(settings: settings, text: "Настройки")
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
                        
                        
                    Section2(settings: settings)
                    Section1(settings: settings)
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

enum Positions {
    case start
    case scroll
    case showTitle
}

struct CardView: View {
    @ObservedObject var settings: UserDefaultsSettings
    var geometry: GeometryProxy
    var isFaceUp: Bool
    var imageName: [String]
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(LinearGradient(settings.theme == 0 ? Color.darkEnd : Color.offWhite, settings.theme == 0 ? Color.darkStart : Color.offWhite))
            .frame(width: geometry.size.width, height: geometry.size.height)
            .shadow(color: settings.theme == 0 ? Color.darkStart : Color.white, radius: 5, x: isFaceUp ? -5 : 5, y: -5)
            .shadow(color: settings.theme == 0 ? Color.darkEnd : Color.gray, radius: 5, x: isFaceUp ? 5 : -5, y: 5)
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
                                    .foregroundColor(settings.theme == 0 ? .darkEnd : Color.gray)
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

struct fastCard: Identifiable {
    var id: UUID = UUID()
    var isFaceUp: Bool = true
    var images: [String]
}

struct Navigation: View {
    var geometry: GeometryProxy
    @State var errorInput: String = ""
    @State var sourse: String = "" // 2068
    @State var destination: String = "" // 2115
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
    @ObservedObject var settings: UserDefaultsSettings
    @Binding var isBookmark: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical, showsIndicators: false) { // Для анимации []
                GeometryReader { g in
                    Tittle(settings: settings, text: "Навигация", name: "location.viewfinder")
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
                        .fill(LinearGradient(settings.theme == 0 ? Color.darkEnd : Color.offWhite, settings.theme == 0 ? Color.darkStart : Color.offWhite))
                        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height / 4.5)
                        .shadow(color: settings.theme == 0 ? Color.darkStart : Color.white, radius: 5, x: -5, y: -5)
                        .shadow(color: settings.theme == 0 ? Color.darkEnd : Color.gray, radius: 5, x: 5, y: 5)
                        .overlay(
                            HStack {
                                Spacer()
                                
                                entryField(sourse: $sourse, destination: $destination, errorInput: $errorInput, errorType: $errorType)
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        makeRoute()
                                    }
                                }) {
                                    
                                        Image(systemName: "magnifyingglass")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(settings.theme == 0 ? .offWhite : .darkStart)
                                            .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.height / 4.5)
                                            .padding(.horizontal, 30)
                                }
                                .buttonStyle(ColorfulButtonStyleWithoutShadows(settings: settings))
                                
                            }
                        )
                    
                    inputError(errorInput: $errorInput)
                        .frame(height: UIScreen.main.bounds.height / 4.5 / 3)
                    
                    HStack {
                        Image(systemName: "clock")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width*0.07, height: UIScreen.main.bounds.width*0.07)
                            .foregroundColor(settings.theme == 0 ? .offWhite : .darkEnd)
                        
                        Text("Быстрый поиск")
                            .foregroundColor(settings.theme == 0 ? .offWhite : .darkEnd)
                            .font(.system(size: UIScreen.main.bounds.height / 30))
                            .fontWeight(.bold)
                    }
                    
                        ScrollView(.horizontal, showsIndicators: false) {
                            ScrollViewReader { value in
                                HStack(spacing: -30) {
                                    ForEach(Cards.indices) { index in
                                        GeometryReader { gg in
                                            CardView(settings: settings, geometry: gg, isFaceUp: self.Cards[index].isFaceUp, imageName: self.Cards[index].images)
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
                                .foregroundColor(settings.theme == 0 ? .offWhite : .darkEnd)
                            
                            Text("Избранные маршруты")
                                .foregroundColor(settings.theme == 0 ? .offWhite : .darkEnd)
                                .font(.system(size: UIScreen.main.bounds.height / 30))
                                .fontWeight(.bold)
                        }
                        
                        if !self.settings.selectedMaps.isEmpty {
                            ForEach(self.settings.selectedMaps.indices) { index in
                                Button(action: {
                                    withAnimation {
                                        let numbers: [String] = self.settings.selectedMaps[index].split(separator: " ").map {String($0)}
                                        makeRouteFast(first: numbers[0], last: numbers[1])
                                    }
                                }) {
                                    Text(self.settings.selectedMaps[index].replacingOccurrences(of: " ", with: " -> "))
                                        .foregroundColor(settings.theme == 0 ? .offWhite : .darkStart)
                                        .font(.system(size: UIScreen.main.bounds.height / 50))
                                        .fontWeight(.semibold)
                                        .frame(width: UIScreen.main.bounds.width*0.8)
                                }
                                .buttonStyle(ColorfulButtonStyleRoundedRectangle(settings: settings))
                            }
                        } else {
                            Text("Пока здесь ничего нет")
                                .foregroundColor(settings.theme == 0 ? .offWhite : .darkStart)
                                .font(.system(size: UIScreen.main.bounds.height / 50))
                                .fontWeight(.semibold)
                        }
                    }
//                    Spacer()
//
//                    Advert()
//
//                    Advert()
                    
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height/4)
                }
                .padding(.top, 15)
            }
            
            if self.show{
                header(settings: settings, text: "Навигация")
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
        self.isBookmark = true
        
        s = parse(way: commonFriend.description)
        sPoint = s.map {Vertex[Int($0)!].name}
        paint = getLines()
        
        for x in 0...paint.count - 1 where x % 3 == 0 {
            maps.updateValue(mapContents(name: "Maps/" + paint[x], mainContent: getSVG(resource: "Maps/" + paint[x]), image: getImage(resource: "Maps/" + paint[x], linesCode: paint[x + 1]), text: paint[x + 2], way: [first, last]), forKey: x / 3)
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
            self.isBookmark = self.settings.selectedMaps.contains("\(sourse) \(destination)")
            
            s = parse(way: commonFriend.description)
            sPoint = s.map {Vertex[Int($0)!].name}
            paint = getLines()
            
            for x in 0...paint.count - 1 where x % 3 == 0 {
                maps.updateValue(mapContents(name: "Maps/" + paint[x], mainContent: getSVG(resource: "Maps/" + paint[x]), image: getImage(resource: "Maps/" + paint[x], linesCode: paint[x + 1]), text: paint[x + 2], way: [sourse, destination]), forKey: x / 3)
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
    @ObservedObject var settings: UserDefaultsSettings
    @State var time = Timer.publish(every: 0.1, on: .current, in: .tracking).autoconnect()
    @State var show = false
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical, showsIndicators: false) {
                GeometryReader { g in
                    Tittle(settings: settings, text: "Расписание", name: "list.bullet.below.rectangle")
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
                header(settings: settings, text: "Расписание")
            }
        }
            .ignoresSafeArea(.all)
    }
}

struct header: View {
    @ObservedObject var settings: UserDefaultsSettings
    var text: String
    
    var body: some View {
        VStack {
                Text(text)
                    .foregroundColor(settings.theme == 0 ? .offWhite : .darkEnd)
                    .font(.system(size: UIScreen.main.bounds.height / 30))
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.1)
                    .padding(.top, 15)
                    .background(BlurBG(settings: settings))
                    .cornerRadius(25, corners: [.bottomRight, .bottomLeft])
                    .edgesIgnoringSafeArea(.top)
            
            Spacer()
        }
    }
}

struct BlurBG : UIViewRepresentable {
    @ObservedObject var settings: UserDefaultsSettings
    
    func makeUIView(context: Context) -> UIVisualEffectView{
        
        let view = UIVisualEffectView(effect: UIBlurEffect(style: settings.theme == 0 ? .dark : .light))
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}
