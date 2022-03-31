//
//  PageNavigation.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI
import SwiftGraph
import SVGKit

enum errorSignal {
    case start
    case end
    case all
    case nothing
}

enum Field {
        case firstCab
        case lastCab
        case fast
}

struct Navigation: View {
    var geometry: GeometryProxy
    @State var errorInput: String = ""
    @State var fastErrorInput: String = ""
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
    @State var pos = 0
    @State var scrollContentOffset: CGFloat = CGFloat.zero
    @State var scrollContentOffsetSum: CGFloat = CGFloat(110)
    @State var time = Timer.publish(every: 0.1, on: .current, in: .tracking).autoconnect()
    @State var show = false
    @ObservedObject var settings: UserDefaultsSettings
    @State var Cards: [fastCard] = [
        .init(images: ["rectangle.portrait.and.arrow.right.fill"], color: LinearGradient(.orange, .brown), name: "Вход"),
        .init(images: ["fork.knife"], color: LinearGradient(.offWhite, .gray), name: "Кафе"),
        .init(images: ["w.square.fill", "c.square.fill"], color: LinearGradient(.lightEnd, .lightStart), name: "Туалет"),
        .init(images: ["cross"], color: LinearGradient(.red, .red.opacity(0.2)), name: "Мед пункт"),
        .init(images: ["dollarsign.circle"], color: LinearGradient(.yellow, .gray), name: "Банкомат"),
    ]
    @State var errorType: errorSignal = .nothing
    @State var fastErrorType: errorSignal = .nothing
    @Binding var isBookmark: Bool
    @State var fastCab: String = ""
    @State var typeCard: String = ""
    @FocusState private var focusedField: Field?
    @State var indexToScroll: Int?
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical, showsIndicators: false) { // Для анимации []
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
        //                       .padding(.bottom, UIScreen.main.bounds.height*0.04)
                                
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
                                        
                                    entryField(sourse: $sourse, destination: $destination, errorInput: $errorInput, errorType: $errorType, settings: settings, focusedField: _focusedField, indexToScroll: $indexToScroll)
                                        
                                    Spacer()
                                        
                                    Button(action: {
                                        withAnimation {
                                            makeRoute()
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
                            //.id(0)
                            .padding(.bottom)
                            
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
                                        .padding(.bottom, 50)
        //                                    .padding(.top, 25)
                                        .padding(.horizontal)
                                    }
                                    .onChange(of: fastCab) { newValue in
                                        searchShortestWay(source: newValue, destinationList: searchDestinationPoint(type: typeCard))
                                    }
                                }
                                .onAppear(perform: {
                                    value.scrollTo(Int(Cards.count/2), anchor: .center)
                                })
                                .padding(.trailing, 15)
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
                                            makeRouteFast(first: numbers[0], last: numbers[1])
                                        }
                                    }) {
                                        HStack{
        //                                        Text(self.settings.selectedMaps[index].replacingOccurrences(of: " ", with: " -> "))
                                                
                                            Spacer()
                                                
                                            Text(self.settings.selectedMaps[index].split(separator: " ")[0])
                                                .font(.system(size: UIScreen.main.bounds.height / 50))
                                                .fontWeight(.semibold)
                                                
                                            Spacer()
                                                
                                            Image(systemName: "chevron.forward.square")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: UIScreen.main.bounds.width*0.8*0.07)
                                                
                                            Spacer()
                                                
                                            Text(self.settings.selectedMaps[index].split(separator: " ")[1])
                                                .font(.system(size: UIScreen.main.bounds.height / 50))
                                                .fontWeight(.semibold)
                                                
                                            Spacer()
                                        }
                                        .frame(width: geometry.size.width * 0.8)
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
                        .padding(.top, 5)
                            
                            //                    Spacer()
                            //
                            //                    Advert()
                            //
                            //                    Advert()
                            
                        Spacer()
                            .frame(height: UIScreen.main.bounds.height/4)
                    }
                        .onChange(of: indexToScroll) { value in                             // qweqweqweqweqweqweqwqweqweqweqweqweqweqweqwewqeqwe
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
//        .onLongPressGesture(minimumDuration: 0) { // Убрать клавиатуру при скроле
//            indexToScroll = nil
//            self.endEditing()
//            print("hello")
//        }
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
            
            start()
            
            print("[+] Data has been loaded")
        })
    }
    
    func labelSize(for text: String) -> CGSize {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17)
        ]

        let attributedText = NSAttributedString(string: text, attributes: attributes)

        let constraintBox = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)

        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral

        return rect.size
    }
    
    func searchShortestWay(source: String, destinationList: [String]) {
        if destinationList.isEmpty {
            print("Неизвестный тип")
        } else {
            if find(p: source) == Point() {
                fastErrorType = .all
                fastErrorInput = "Кабинет \(source) не найден"
            } else {
                var bestCommonFriend: [UnweightedEdge] = []
                var destinationName: String = ""
                
                for x in destinationList {
                    let commonFriend: [UnweightedEdge] = cityGraph.bfs(from: find(p: source), to: find(p: x))
                    
                    if x == destinationList[0] {
                        bestCommonFriend = commonFriend
                         destinationName = x
                    } else {
                        if commonFriend.count < bestCommonFriend.count {
                           bestCommonFriend = commonFriend
                            destinationName = x
                        }
                    }
                }
                
                if !bestCommonFriend.isEmpty {
                    commonFriend = bestCommonFriend
                    
                    s = parse(way: commonFriend.description)
                    sPoint = s.map {Vertex[Int($0)!].name}
                    paint = getLines()
                    
                    for x in 0...paint.count - 1 where x % 3 == 0 {
                        maps.updateValue(mapContents(name: "Maps/" + paint[x], mainContent: getSVG(resource: "Maps/" + paint[x]), image: getImage(resource: "Maps/" + paint[x], linesCode: paint[x + 1]), text: paint[x + 2], way: [source, destinationName]), forKey: x / 3)
                    }
                    
                    self.isBookmark = self.settings.selectedMaps.contains("\(source) \(destinationName)")
                    viewRouter.currentPage = .maps
                }
            }
        }
    }
    
    func searchDestinationPoint(type: String) -> [String] {
        var listDestinattionPoint: [String] = []
        
        for x in Vertex {
            if x.name.contains(type) {
                listDestinattionPoint.append(x.name)
            }
        }
        
        return listDestinattionPoint
    }
    
    func makeRouteFast(first: String, last: String) {
        commonFriend = cityGraph.bfs(from: find(p: first), to: find(p: last))
        self.isBookmark = true
        
        s = parse(way: commonFriend.description)
        sPoint = s.map {Vertex[Int($0)!].name}
        paint = getLines()
        
        for x in 0...paint.count - 1 where x % 3 == 0 {
            maps.updateValue(mapContents(name: "Maps/" + paint[x], mainContent: getSVG(resource: "Maps/" + paint[x]), image: getImage(resource: "Maps/" + paint[x], linesCode: paint[x + 1]), text: paint[x + 2], way: [first, last]), forKey: x / 3)
        }
        
        viewRouter.currentPage = .maps
    }
    
    func makeRoute() {
            if sourse == destination {
                errorInput = "Введены одинаковые кабинеты"
                errorType = .all
                
                return
            } else if find(p: sourse) == Point() && find(p: destination) == Point() {
                errorInput = "Кабинет \(sourse) и \(destination) не найдены"
                errorType = .all
                
                return
            } else if find(p: sourse) == Point() {
                errorInput = "Кабинет \(sourse) не найден"
                errorType = .start
                
                return
            } else if find(p: destination) == Point() {
                errorInput = "Кабинет \(destination) не найден"
                errorType = .end
                
                return
            } else {
                errorType = .nothing
                commonFriend = cityGraph.bfs(from: find(p: sourse), to: find(p: destination))
                self.isBookmark = self.settings.selectedMaps.contains("\(sourse) \(destination)")
            }
            
            s = parse(way: commonFriend.description)
            sPoint = s.map {Vertex[Int($0)!].name}
            paint = getLines()
            
            for x in 0...paint.count - 1 where x % 3 == 0 {
                maps.updateValue(mapContents(name: "Maps/" + paint[x], mainContent: getSVG(resource: "Maps/" + paint[x]), image: getImage(resource: "Maps/" + paint[x], linesCode: paint[x + 1]), text: paint[x + 2], way: [sourse, destination]), forKey: x / 3)
            }
            
            errorInput = ""
            
            viewRouter.currentPage = .maps
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
                print("Error in function -> Start (print 1)")
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
                print("Error in function -> Start (print 2)")
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
        let toURL = dir!.appendingPathComponent(resource.split(separator: "/").map {String($0)}.last! + ".svg")
        
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
        var Colors: String = ""
        
        if self.settings.theme == 0 {
            Colors = """
            .st0{fill:#e1e1eb;}
            .st1{fill:#e1e1eb;}
            .st8{fill:none;stroke:#3CA0F0;stroke-width:10;stroke-miterlimit:10;}
            .st9{fill:#3CA0F0;}
        """
        } else if self.settings.theme == 1 {
            Colors = """
            .st0{fill:#323c41;}
            .st1{fill:#323c41;}
            .st8{fill:none;stroke:#6300EE;stroke-width:10;stroke-miterlimit:10;}
            .st9{fill:#6300EE;}
        """
        }
        
        xml.insert("""
        \(Colors)
        """, at: 5)
        
        xml.insert("""
        \(linesCode)
        """, at: xml.count - 2)
        
        return xml.joined(separator: "\n")
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
    @Binding var indexToScroll: Int?
    
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
                        showPlaceHolder: !onTapFields[0], // sourse.isEmpty
                        placeholder: "Начальный кабинет",
                        center: true,
                        settings: settings
//                        paddingValue: -labelSize(for: "Начальный кабинет").width / 2
                    )
                )
                .onChange(of: sourse) { newValue in
                    withAnimation {
                        errorInput = ""
                    }
                    
                    if errorType == .all {
                        errorType = .end
                    } else if errorType == .start {
                        errorType = .nothing
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
//                        paddingValue: -labelSize(for: "Конечный кабинет").width / 2
                    )
                )
                .onChange(of: destination) { newValue in
                    withAnimation {
                        errorInput = ""
                    }
                        
                    if errorType == .all {
                        errorType = .start
                    } else if errorType == .end {
                        errorType = .nothing
                    }
                }
                .textContentType(.dateTime)
                .frame(height: 50)
                .multilineTextAlignment(.center)
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(errorType == .end || errorType == .all ? Color.red : Color.clear, style: StrokeStyle(lineWidth: 3.0)))
            
            Spacer()
        }
    }
    
    func labelSize(for text: String) -> CGSize {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17)
        ]

        let attributedText = NSAttributedString(string: text, attributes: attributes)

        let constraintBox = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)

        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral

        return rect.size
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
