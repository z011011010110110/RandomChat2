//
//  MessageModel.swift
//  RandomChat
//
//  Created by Hyunbin Joo on 12/24/21.
//

import Foundation

struct Chat: Identifiable{
    var id: UUID {person.id}
    let person: Person
    var messages: [Message]
    var hasReadMessage = false
}

struct Person: Identifiable{
    let id = UUID()
    let name: String
    let imgString: String
}

struct Message: Identifiable{
    enum MessageType{
        case Sent, Recieved
    }
    let id = UUID()
    //let date: Date
    let text: String
    let type: MessageType
    
    init(_ text:String, type:MessageType, date:Date){
        //self.date = date
        self.type = type
        self.text = text
    }
    
    init(_ text:String, type:MessageType){
        self.init(text, type:type, date:Date())
    }
}



