//
//  CircleView.swift
//  RandomChat
//
//  Created by Hyunbin Joo on 12/23/21.
//

import SwiftUI
import MapKit
struct CircleView: View {
    
    var body: some View {
        VStack{
            Image("desktop")
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 5)
            //Circle().stroke(Color.white, lineWidth: 5).shadow(radius: 10)
        
    }
}

struct CircleView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView()
    }
}
}
