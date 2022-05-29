//
//  LoadingView.swift
//  xxx
//
//  Created by Семен Безгин on 29.05.2022.
//

import SwiftUI

struct LoadingView<Content>: View where Content: View {
    @Binding var isShowing: Bool
    var theme: Int
    var content: () -> Content
    @State var loading: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {

                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)

                VStack {
                    ZStack {
                        Circle()
                            .trim(from: 0, to: 0.37)
                            .stroke(self.theme == 0 ? Color.lightStart : Color.purpleStart, lineWidth: 15)
                            .frame(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4, alignment: .center)
                            .rotationEffect(Angle(degrees: self.loading ? 0 : 360))
                        
                        Circle()
                            .trim(from: 0.37, to: 1)
                            .stroke(self.theme == 0 ? Color.darkStart : Color.white, lineWidth: 15)
                            .frame(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4, alignment: .center)
                            .rotationEffect(Angle(degrees: self.loading ? 0 : 360))
                            .onAppear(perform: {
                                withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                                    self.loading.toggle()
                                }
                            })
                    }
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
//                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}
