//
//  ChatroomView.swift
//  RandomChat
//
//  Created by Hyunbin Joo on 12/24/21.
//

import SwiftUI

struct ChatroomView: View {
    
        @State var name = "Stranger"
        @State var distance = 0
        @State var distanceStr = "You Are 0 Miles Apart"
  
        @State private var textbox = ""

        
        @StateObject var chatData:CoreDataViewModel = CoreDataViewModel()
        //@Binding var chats:CoreDataViewModel = chatData
    
        @State var lastMessageID: UUID?
            
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
                    value.scrollTo(lastMessageID, anchor: nil)
                    name = chatData.chats[0].person.name
                    //name = chatData
                }
                .onChange(of: lastMessageID, perform:{values in
                    if let lastMessageID = chatData.chats[0].messages.last?.id{
                        //DispatchQueue.main.async{
                                withAnimation(.spring()){
                                    value.scrollTo(lastMessageID, anchor: .bottomTrailing)
                                }
                            //}
                        //name = lastMessageID.uuidString
                        }
                    })
        }
    }

    //Creates a mesage bubble
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
    
    //Creates where the messages go
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
//                if textbox.isEmpty {
//                        Text("Message...")
//                            .foregroundColor(Color(UIColor.placeholderText))
//                            .allowsHitTesting(false)
//                    }
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
    
    func sendMessage(){
        
        let newMessage = Message(textbox,type:.Sent)
        chatData.chats[0].messages.append(newMessage)
        //name = String(chatData.chats[0].messages.count)
        lastMessageID = newMessage.id
        textbox = ""
    }
    
    struct ChatroomView_Previews: PreviewProvider {
        static var previews: some View {
            ChatroomView()
        }
    }
}
