//
//  ChatroomView.swift
//  RandomChat
//
//  Created by on 12/24/21.
//

import SwiftUI
struct ChatroomView: View {
    
        @State var name = "Stranger" //not sure if in use.
        @State private var textbox = ""
        @StateObject var chatData:CoreDataViewModel = CoreDataViewModel()
        @StateObject var geolocation:ContentViewModel = ContentViewModel()
    
        var body: some View {
            VStack{
                
                ///profile
                HStack{
                    Button("Back", action:{})
                    Spacer()
                    CircleView()
                    Spacer()
                    Button("Next Chat", action:{
                        chatData.leaveChat()
                    })
                }
                VStack (alignment: .leading){
                    Text(chatData.userID)
                    viewGeolocation()
                    //Geolocation()
                }
                
                
                ///Message box
                ScrollView {
                    viewMessage()
                    Spacer()
                }
                
                
                //Text box + keyboard
                createTextBox()
            }
            .padding()
        }

    
    func viewMessage() -> some View{
        
        ScrollViewReader{value in
            ForEach(chatData.chats[0].messages) {message in
                createMessage(message)
                }
                .onAppear {
                    value.scrollTo(chatData.lastMessageID, anchor: nil)
                    //name = chatData
                }
                .onChange(of: chatData.lastMessageID, perform:{values in
                    if let lastMessageID = chatData.chats[0].messages.last?.id{
                        //DispatchQueue.main.async{
                                withAnimation(.spring()){
                                    value.scrollTo(lastMessageID, anchor: .bottomTrailing)
                                }
                        }
                    })

        }
    }

///Creates a mesage bubble
    func createMessage(_ message: Message)-> some View{
        HStack{
            (message.type == .Sent) ? Spacer():nil
            Text(message.text)
                .foregroundColor((message.type == .Sent) ? Color.white:Color.black)
                .padding()
                .background((message.type == .Sent) ? Color.cyan:Color.gray)
                .cornerRadius(15)
                .id(message.id)
            (message.type == .Sent) ? nil:Spacer()
        }
    }
    
///Creates textbox where you type
    func createTextBox()-> some View{
        HStack{
            Button("Img", action: {
            }).padding(7)
            //"Message...",
            ZStack(alignment: .leading){
                

                TextField("Message...", text: $textbox)
                    .multilineTextAlignment(.leading)
                    .frame(minHeight:10,maxHeight: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(0)
            }
            
            Button("Send", action: {
                sendMessage()
            })
                .foregroundColor(textbox.isEmpty ? Color.gray:Color.blue)
                .padding(7)
                .disabled(textbox.isEmpty)
        }
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.blue, lineWidth: 2))
    }
    
    ///sends message to server, clears textbox
    func sendMessage(){
        chatData.sendData(text:textbox)
        textbox = ""
    }
    
    func viewGeolocation() -> some View{
        
        VStack{
            Button(geolocation.distanceString, action: {
                geolocation.privacyCheck()
                geolocation.getDistanceFromEachOther(person1: chatData.people[0], person2: chatData.people[1])
                geolocation.saveLocation()
            })
            .onAppear {
                geolocation.privacyCheck()
            }
        }
    }
    
    struct ChatroomView_Previews: PreviewProvider {
        static var previews: some View {
            ChatroomView()
        }
    }
}
