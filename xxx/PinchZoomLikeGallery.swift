//
//  PinchZoomLikeGallery.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI

struct Zoom<Content: View>: UIViewRepresentable {
    
    @Binding var zoomScale: Double
    private var content: Content
    
    init(zoomScale: Binding<Double>, @ViewBuilder content: () -> Content) {
        self._zoomScale = zoomScale
        self.content = content()
    }
    
    static func dismantleUIView(_ uiView: UIScrollView, coordinator: Coordinator) {
            uiView.delegate = nil
            coordinator.hostingController.view = nil
        }
    
    func makeUIView(context: Context) -> UIScrollView {
        
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 4
        scrollView.minimumZoomScale = 1
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        hostedView.backgroundColor = UIColor.clear
        scrollView.addSubview(hostedView)
        
        return scrollView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content), parent: self)
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
        // enable zoomScale reset, as a downside this is being set on each scrollViewDidZoom call
        uiView.zoomScale = zoomScale
        uiView.showsVerticalScrollIndicator = zoomScale == 1.0 ? false : true
        uiView.showsHorizontalScrollIndicator = zoomScale == 1.0 ? false : true
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        var parent: Zoom
        
        init(hostingController: UIHostingController<Content>, parent: Zoom) {
            self.hostingController = hostingController
            self.parent = parent
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            let zoomScale = scrollView.zoomScale
            
            if zoomScale < 1.0 {
                parent.zoomScale = 1.0
            }
            else if zoomScale > 1.0 {
                // fix for "Modifying state during view update, this will cause undefined behavior."
                // if we reset zoomScale to 1.0
                parent.zoomScale = zoomScale
            }

        }
    }
}
