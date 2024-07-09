//
//  SplashView.swift
//  iProgramMe
//
//  Created by Pieter Yoshua Natanael on 28/09/23.
//


import SwiftUI

struct SplashView: View {
    @Binding var isShowingSplash: Bool
    
    var body: some View {
     
        Image("SplashImage")
            .resizable()
           // .scaledToFill()
            .edgesIgnoringSafeArea(.all)
            
            
            .onAppear {
                // After 3 seconds, hide the splash screen.
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        self.isShowingSplash = false
                    }
                }
            }
    }
}
