Почему-то сильно загружает CPU, при вводе textfield:
  Image("B2WithoutLines")
                                        getImage(resource: "Maps/B2_main_test", linesCode: "")
                                        ZStack{
                                            Image(uiImage: getImage(resource: "Maps/B2_main_test", linesCode: ""))
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .pinchToZoom()
                                        }
                                        
                                        Image(img)
                                        Image(uiImage: UIImage(contentsOfFile: URL(fileURLWithPath: Bundle.main.path(forResource: "B2_main_t", ofType: "svg")!).path) ?? UIImage())
                                        Image(uiImage: SVGToUIImage(url: URL(fileURLWithPath: Bundle.main.path(forResource: "Maps/B2_main копия", ofType: "svg")!)))
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .pinchToZoom()
