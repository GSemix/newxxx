//
//  ClassMaps.swift
//  xxx
//
//  Created by Семен Безгин on 05.04.2022.
//

import SwiftUI
import SwiftGraph
import SVGKit

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

struct mapContents: Hashable {
    var name: String = String()
    var mainContent: String = String()
    var image: UIImage = UIImage()
    var text: String = String()
    var blur: Bool = false
    var way: [String] = ["", ""]
}

struct PointRouting {
    private var Vertex: [Point]
    private var Edges: [UnweightedEdge]
    private var Graph: UnweightedGraph<Point>
    private var Maps: Dictionary<Int, mapContents>
    private var fileVertex: FileJSON
    private var fileEdges: FileJSON
    @State public var Errors: FieldErrors
    private var isBookmark: Bool
    private var theme: Int
    
    init(nameOfFileVertex: String, nameOfFileEdges: String) {
        self.fileVertex = FileJSON(bundleFileName: nameOfFileVertex)
        self.fileEdges = FileJSON(bundleFileName: nameOfFileEdges)
        self.Vertex = []
        self.Edges = []
        self.Graph = UnweightedGraph<Point>(vertices: [])
        self.Maps = Dictionary()
        self.Errors = FieldErrors()
        self.isBookmark = false
        self.theme = 0
        
        self.setVertex()
        self.setEdges()
        
        print("[+] Start Graph with loaded data")
    }
    
    public func getIsBookmark() -> Bool {
        return self.isBookmark
    }
    
    mutating public func setIsBookmark(isBookmark: Bool) {
        self.isBookmark = isBookmark
    }
    
    mutating public func clearMaps() {
        self.Maps = Dictionary()
    }
    
    mutating private func setVertex() {
        if let dictionary = fileVertex.getContentJSON() as? Dictionary<String, Dictionary<String, String>> {
            for x in dictionary.keys {
                Vertex.append(Point(newName: x, newHousing: dictionary[x]!["housing"]!, newFloor: dictionary[x]!["floor"]!, newX: dictionary[x]!["x"]!, newY: dictionary[x]!["y"]!, newX0: dictionary[x]!["x0"]!, newY0: dictionary[x]!["y0"]!))
            }
                
            Graph = UnweightedGraph<Point>(vertices: Vertex)
        }
    }
    
    private func setEdges() {
        if let dictionary = fileEdges.getContentJSON() as? Dictionary<String, [String]> {
            for x in dictionary.keys {
                for y in dictionary[x]! {
                    Graph.addEdge(from: find(p: x), to: find(p: y))
                }
            }
        }
    }
    
    private func parse (way: String) -> [String] {
        var newWay = way.replacingOccurrences(of: " ", with: "")
        newWay = newWay.replacingOccurrences(of: "->", with: ",")
        newWay = newWay.replacingOccurrences(of: "[", with: "")
        newWay = String(newWay.replacingOccurrences(of: "]", with: ""))
        
        return newWay.split(separator: ",").map {String($0)}
    }
    
    public func getMaps() -> Dictionary<Int, mapContents> {
        return self.Maps
    }
    
    mutating public func makeRouteFast(first: String, last: String, theme: Int) {
        self.theme = theme
        self.Edges = self.Graph.bfs(from: find(p: first), to: find(p: last))
        
        let s = parse(way: Edges.description)
        let sPoint = s.map {Vertex[Int($0)!].name}
        let paint = getLines(s: s, sPoint: sPoint)
        
        for x in 0...paint.count - 1 where x % 3 == 0 {
            self.Maps.updateValue(mapContents(name: "Maps/" + paint[x], mainContent: getSVG(resource: "Maps/" + paint[x]), image: getImage(resource: "Maps/" + paint[x], linesCode: paint[x + 1]), text: paint[x + 2], way: [first, last]), forKey: x / 3)
        }
    }
    
    mutating public func mainRoute(source: String, destination: String, theme: Int, selectedMaps: [String]) -> FieldErrors {
        if source == destination {
            self.Errors.setErrorInput(text: "Введены одинаковые кабинеты")
            self.Errors.setErrorType(error: .all)
            
            return self.Errors
        } else if find(p: source) == Point() && find(p: destination) == Point() {
            self.Errors.setErrorInput(text: "Кабинет \(source) и \(destination) не найдены")
            self.Errors.setErrorType(error: .all)
            
            return self.Errors
        } else if find(p: source) == Point() {
            self.Errors.setErrorInput(text: "Кабинет \(source) не найден")
            self.Errors.setErrorType(error: .start)
            
            return self.Errors
        } else if find(p: destination) == Point() {
            self.Errors.setErrorInput(text: "Кабинет \(destination) не найден")
            self.Errors.setErrorType(error: .end)
            
            return self.Errors
        } else {
            self.Errors.setErrorType(error: .nothing)
            self.Edges = self.Graph.bfs(from: find(p: source), to: find(p: destination))
            self.theme = theme
        }
        
        let s = parse(way: Edges.description)
        let sPoint = s.map {Vertex[Int($0)!].name}
        let paint = getLines(s: s, sPoint: sPoint)
        
        for x in 0...paint.count - 1 where x % 3 == 0 {
            Maps.updateValue(mapContents(name: "Maps/" + paint[x], mainContent: getSVG(resource: "Maps/" + paint[x]), image: getImage(resource: "Maps/" + paint[x], linesCode: paint[x + 1]), text: paint[x + 2], way: [source, destination]), forKey: x / 3)
        }
        
        Errors.setErrorInput(text: "")
        
        setIsBookmark(isBookmark: selectedMaps.contains("\(source) \(destination)"))
        
        return self.Errors
    }
    
    mutating public func searchShortestWay(source: String, destinationList: [String], theme: Int, selectedMaps: [String]) -> FieldErrors {
        var destinationName: String = ""
        self.theme = theme
        
        if destinationList.isEmpty {
            print("Неизвестный тип")
        } else {
            if find(p: source) == Point() {
                self.Errors.setFastErrorType(error: .all)
                self.Errors.setFastErrorInput(text: "Кабинет \(source) не найден")
            } else {
                var bestCommonFriend: [UnweightedEdge] = []
                destinationName = ""

                for x in destinationList {
                    let commonFriend: [UnweightedEdge] = self.Graph.bfs(from: find(p: source), to: find(p: x))
                    
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
                    self.Edges = bestCommonFriend
                    
                    let s = parse(way: Edges.description)
                    let sPoint = s.map {Vertex[Int($0)!].name}
                    let paint = getLines(s: s, sPoint: sPoint)
                    
                    for x in 0...paint.count - 1 where x % 3 == 0 {
                        self.Maps.updateValue(mapContents(name: "Maps/" + paint[x], mainContent: getSVG(resource: "Maps/" + paint[x]), image: getImage(resource: "Maps/" + paint[x], linesCode: paint[x + 1]), text: paint[x + 2], way: [source, destinationName]), forKey: x / 3)
                    }
                    
                    self.isBookmark = selectedMaps.contains("\(source) \(destinationName)")
                }
            }
        }
        
        return self.Errors
    }
    
    public func searchDestinationPoint(type: String) -> [String] {
        var listDestinattionPoint: [String] = []
        
        for x in Vertex {
            if x.name.contains(type) {
                listDestinattionPoint.append(x.name)
            }
        }
        
        return listDestinattionPoint
    }
    
    private func find (p: String) -> Point {
        for x in Vertex {
            if x == p {
                return x
            }
        }
        
        return Point()
    }
    
    private func getSourcePoint (x1: String, y1: String) -> String {
        return "<circle class=\"st9\" cx=\"\(x1)\" cy=\"\(y1)\" r=\"6.4\"/>"
    }
    
    func getImage (resource: String, linesCode: String) -> UIImage {
        let url = urlSVGWithLines(resource: resource, linesCode: linesCode)
        
        return SVGToUIImage(url: url)
    }
    
    func SVGToUIImage (url: URL) -> UIImage {
        let mySVGImage: SVGKImage = SVGKImage(contentsOf: url)
        let image: UIImage = mySVGImage.uiImage
        
        return image
    }
    
    func appendLinesToSVG (xmlString: String, linesCode: String) -> String { // $$$
        var xml = xmlString.components(separatedBy: "\n")
        var Colors: String = ""
        
        if self.theme == 0 {
            Colors = """
            .st0{fill:#e1e1eb;}
            .st1{fill:#e1e1eb;}
            .st8{fill:none;stroke:#3CA0F0;stroke-width:10;stroke-miterlimit:10;}
            .st9{fill:#3CA0F0;}
        """
        } else if self.theme == 1 {
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
    
    func getSVG (resource: String) -> String {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: resource, ofType: "svg")!)
        
        if let urlContents = try? String(contentsOf: url) {
            return urlContents
        }
        
        return String() // !!!
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
    
    private func getLines (s: [String], sPoint: [String]) -> [String] {
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
}
