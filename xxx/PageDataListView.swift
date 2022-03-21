//
//  DataList.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI

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
                }
                .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.height*0.15, alignment: .center)
                
                Rectangle()
                    .fill(Color.darkStart)
                    .frame(height: 1000)
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
