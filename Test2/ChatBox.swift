//
//  ChatBox.swift
//  RandomChat
//
//  Created by Hyunbin Joo on 12/23/21.
//

import SwiftUI

struct ChatBox: View {
    
    @Binding var textbox: String
    let contentView = ContentView()
    var body: some View {
        
        //Keyboard text
        HStack(alignment: .bottom){
            Button("Img", action: {
            }).padding(7)
            TextField("Message...", text: $textbox)
                .multilineTextAlignment(.leading)
                .padding(7)
            Spacer()
            Button("Send", action: {
                ContentView().sendMessage()
                print("ok")
            }).padding(7)
        }
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
    }
}
