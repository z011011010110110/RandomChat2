//
//  ContentView.swift
//  Test2
//
//  Created by Hyunbin Joo on 12/25/21.
//

import SwiftUI

struct ContentView: View {
    
    
    @State var name = "Stranger"
    @State var distance = 0
    @State var distanceStr = "You Are 0 Miles Apart"
    @State var messageArray: [MessageBox] = [
    
        MessageBox(text: "Messagex", user: false),
        MessageBox(text: "Messagex werwerwerewr", user: true),
        MessageBox(text: "Whatcha want?", user: true),
        MessageBox(text: "Money?", user: false)
    ]
    @State private var textbox = ""
    
    
    //messageArray.append(MessageBox(text: "Messagex", user: false))
    
    var body: some View {
        VStack{
            
            //profile
            CircleView()
            VStack (alignment: .leading){
                Text(name)
                    .font(.body)
                    .fontWeight(.light)
                Button(distanceStr, action: {
                    sendMessage()
                })
            }
            
            //Message box
            ScrollView {
                viewMessage()
                Spacer()
            }
            
            //Text box + keyboard
            ChatBox(textbox: self.$textbox)

        }
        .padding()
    }
    func viewMessage() -> some View{
 
        ScrollViewReader{value in
            ForEach(0 ..< messageArray.count) {id in
                messageArray[id].id(id)
                }
                .onAppear {
                    value.scrollTo(messageArray.count-1, anchor: nil)
                }
                .onChange(of: messageArray.count, perform:{values in
                    withAnimation(.spring()){
                        value.scrollTo(values, anchor: .top)
                    }
                })
        }
    }
    func sendMessage(){
        messageArray.append(MessageBox(text: "ok", user: true))
        name = messageArray[messageArray.count-1].text
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
           DataControllerTest()
            //ChatroomView()
        }
    }
}
