//
//  PageRoute.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI

struct navigationPage: View {
    @Binding var Nav: PointRouting
    @State var image: UIImage = UIImage()
    @StateObject var viewRouter: ViewRouter
    @State var bookmark: Bool
    @ObservedObject var settings: UserDefaultsSettings
    @State var showImageViewer: Bool = false
    @State var blurValue: Double = 0
    @State var zoomScale: Double = 1.0
    
    var body: some View {
        ZStack(alignment: .top) {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach (Array(Nav.getMaps().keys).sorted(by: {$0 < $1}), id: \.self) { map in
                            piceOfMap(settings: settings, image: Nav.getMaps()[map]!.image)
                                .onTapGesture(count: 1) {
                                    image = Nav.getMaps()[map]!.image
                                    withAnimation(.interactiveSpring()) {
                                        showImageViewer = true
                                    }
                                }

                        Explanation(settings: settings, text: Nav.getMaps()[map]!.text)
                                .padding(.vertical, 5)
                    }
                    
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height*0.15)
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height) // Избранные маршруты (isBookmark)
                .frame(maxHeight: .infinity)
                .blur(radius: blurValue)
                .disabled(showImageViewer)
                .overlay(ZoomingImage(viewerShown: self.$showImageViewer, image: self.$image, blurValue: self.$blurValue, zoomScale: self.$zoomScale))
                .onChange(of: showImageViewer, perform: { newValue in
                    withAnimation(.interactiveSpring()) {
                        if !newValue {
                            blurValue = 0
                            zoomScale = 1.0
                        } else {
                            blurValue = 15
                        }
                    }
                })
                .safeAreaInset(edge: .top) {
                    ZStack {
                        header(settings: settings, text: "Маршрут")
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        clearSVG()
                                        Nav.clearMaps()
                                        image = UIImage()
                                        blurValue = 0
                                        showImageViewer = false
                                        Nav.setIsBookmark(isBookmark: false)
                                        viewRouter.currentPage = .navigation
                                    }
                                }) {
                                    Image(systemName: "arrow.uturn.backward")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .foregroundColor(settings.theme == 0 ? .lightStart : .purpleStart)
                                        .frame(width: UIScreen.main.bounds.width * 0.05, height: UIScreen.main.bounds.width * 0.05)
                                        .padding(15)
                                        .clipShape(Capsule())
                                }
                                .frame(width: 50, height: 50)
                                
                                Spacer()
                                
                                Toggle(isOn: $bookmark.didSet { _ in
                                    if bookmark {
                                        if !self.settings.selectedMaps.contains(Nav.getMaps()[0]!.way.joined(separator: " ")) {
                                            self.settings.selectedMaps.append(Nav.getMaps()[0]!.way.joined(separator: " "))
                                        }
                                    } else {
                                        if self.settings.selectedMaps.contains(Nav.getMaps()[0]!.way.joined(separator: " ")) {
                                            self.settings.selectedMaps.remove(at: self.settings.selectedMaps.firstIndex(of: Nav.getMaps()[0]!.way.joined(separator: " "))!)
                                        }
                                    }
                                }
                                ) {
                                    Image(systemName: self.bookmark ? "bookmark.fill" : "bookmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: UIScreen.main.bounds.width * 0.05, height: UIScreen.main.bounds.width * 0.05)
                                        .foregroundColor(settings.theme == 0 ? .lightStart : .purpleStart)
                                }
                                .frame(width: 50, height: 50)
                                .toggleStyle(ImageToggle())
                            }
                            .padding(.horizontal, 30)
                            .padding(.top, UIScreen.main.bounds.height*0.05)
                            .padding(.bottom, UIScreen.main.bounds.height*0.01)
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3))
                .ignoresSafeArea(edges: .vertical)
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
    }
    
    func clearSVG () { // Зачем?
        for resource in Nav.getMaps().keys {
            let url = URL(fileURLWithPath: Bundle.main.path(forResource: Nav.getMaps()[resource]!.name, ofType: "svg")!)
            try? Nav.getMaps()[resource]!.mainContent.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}

struct ZoomingImage: View {
    @Binding var viewerShown: Bool
    @Binding var image: UIImage
    var aspectRatio: Binding<CGFloat>?
    @State var dragOffset: CGSize = CGSize(width: -504, height: -579)
    @State var dragOffsetPredicted: CGSize = CGSize(width: -504, height: -579)
    @Binding var blurValue: Double
    @Binding var zoomScale: Double
    
    var body: some View {
        if viewerShown {
                Zoom(zoomScale: $zoomScale) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.35)
                }
                .offset(x: self.dragOffset.width, y: self.dragOffset.height)
                .rotationEffect(.init(degrees: Double(self.dragOffset.width / 30)))
                .onTapGesture(count: 2) {
                    withAnimation(.interactiveSpring()) {
                        if self.zoomScale == 1.0 {
                            zoomScale = 2.0
                        } else {
                            zoomScale = 1.0
                        }
                    }
                }
                .gesture(DragGesture()
                            .onChanged { value in
                    if zoomScale == 1.0  && viewerShown {
                        self.dragOffset = value.translation
                        self.dragOffsetPredicted = value.predictedEndTranslation
                    }
                }
                            .onEnded { value in
                    if zoomScale == 1.0 && viewerShown {
                        if ((abs(self.dragOffset.height) + abs(self.dragOffset.width) > 570) || ((abs(self.dragOffsetPredicted.height)) / (abs(self.dragOffset.height)) > 3) || ((abs(self.dragOffsetPredicted.width)) / (abs(self.dragOffset.width))) > 3) {
                            withAnimation(.spring()) {
                                self.dragOffset = self.dragOffsetPredicted
                            }
                            self.viewerShown = false
                            
                            return
                        }
                        withAnimation(.interactiveSpring()) {
                            self.dragOffset = .zero
                        }
                    }
                }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: self.dragOffset, perform: { newValue in
                    blurValue = 15 - Double(abs(newValue.width) + abs(newValue.height)) / 40
                })
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                .onAppear() {
                    dragOffset = .zero
                    dragOffsetPredicted = .zero
                }
                .frame(height: UIScreen.main.bounds.height)
                .ignoresSafeArea(edges: .vertical)
        }
    }
}


struct Explanation: View {
    @ObservedObject var settings: UserDefaultsSettings
    var text: String
    
    var body: some View {
        HStack {
            Firefly(color: settings.theme == 0 ? Color.lightStart : Color.purpleStart)
            
            Text(text)
                .foregroundColor(settings.theme == 0 ? Color.offWhite : Color.darkStart)
        }
    }
}

struct piceOfMap: View {
    @ObservedObject var settings: UserDefaultsSettings
    var image: UIImage
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width*0.99, height: UIScreen.main.bounds.height*0.25)
        }
        .frame(height: UIScreen.main.bounds.height*0.3)
        .addBorder(LinearGradient(settings.theme == 0 ? Color.lightStart : Color.purpleStart, settings.theme == 0 ? Color.lightEnd : Color.purpleEnd), width: 2, cornerRadius: 15)
        .pinchToZoom(theme: settings.theme)
    }
}

struct Firefly: View {
    var color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .shadow(color: color, radius: 2.5)
            .frame(width: 5, height: 5)
    }
}
