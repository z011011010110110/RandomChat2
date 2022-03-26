//
//  DataControllerTest.swift
//  RandomChat
//
//  Created on 12/25/21.
//

import SwiftUI
import CoreData
import Firebase

class CoreDataViewModel:ObservableObject{
    
    let container: NSPersistentContainer
    let db = Firestore.firestore()
    @Published var userID = ""
    @Published var savedEntities: [User] = []
    @Published var lastMessageID: UUID?
    
    @Published var chatID:String = ""
    
    @Published var chats =
    [Chat(person:Person(name:"", imgString:""),
        messages:[],
        hasReadMessage: false)]
    
    
    @Published var distance:String = "x"
    
     
    init(){
        
        container = NSPersistentContainer(name: "UserData")
        container.loadPersistentStores { (description, error) in
            if let error = error{
                print("\(error)")
            }
        }
        fetchData()
        if !(savedEntities.count == 0){
            userID = savedEntities[0].name ?? ""
        }
        else{
            addUser(name:"New User")
        }
        getData()
    }
    
    func fetchData(){
        let request = NSFetchRequest<User>(entityName: "User")
        do{
            savedEntities = try container.viewContext.fetch(request)
        } catch _{
                print("error")
            }
    }
    
    func addUser(name: String){
        if (savedEntities.count == 0)
        {
            let newUserDoc = db.collection("Users").addDocument(data: [
                "chatID": [],
                "id": "",
                "imgString": "",
                "username": name
            ])
            newUserDoc.updateData([
                "id": newUserDoc.documentID
            ])
            let newUser = User(context: container.viewContext)
            newUser.name = newUserDoc.documentID
            saveData()
        }
    }
    
    func deleteUser(indexSet: IndexSet){
        guard let index = indexSet.first else{
            return
        }
        let entity = savedEntities[index]
        container.viewContext.delete(entity)
        saveData()
    }
    func updateUser(entity: User, edit: String){
        //entity.name = edit
        //saveData()
    }
    
    func saveData(){
        do {
            try container.viewContext.save()
            fetchData()
        } catch _{
            print("error")
        }
    }
    
    //Fetches chat data from database
    func getData(){
        ///Get person name
        var person = Person(name:"" , imgString:"")
        db.collection("Users").addSnapshotListener {(snapshot, error) in
            for document in snapshot!.documents {
                let data = document.data()
                let username = data["username"] as? String ?? ""
                let imgString = data["imgString"] as? String ?? ""
                person = Person(name:username , imgString:imgString)
                self.chats[0].person = person
            }
        }
        ///Update Messages
        db.collection("Messages")
            .whereField("members", arrayContains: userID)
            .limit(to: 1)
            .getDocuments { [self] (snapshot, error) in
//
//                ///If not in any chats, find chat to join
//                if ((snapshot?.isEmpty)==true)
//                   {
//                        self.findChat()
//                   }
                ///Messages
                for document in snapshot!.documents {
                    self.chatID = document.documentID
                    self.db.collection("Messages").document(self.chatID).collection("message")
                        //.whereField("text", isNotEqualTo: "")
                        .order(by: "timestamp") //This errors because some do not have timestamp.
                        .addSnapshotListener { [self] (snapshot, error) in
                        guard let documents = snapshot?.documents else{
                            return
                        }
                        //documents.order(by: "timestamp")

                        ///Returns Chat every time "Messages" is updated
                        self.chats = documents.compactMap { (snapshot) -> Chat in
                            
                            var newChat = Chat(person: person, messages:[], hasReadMessage: false)
                        ///Get all message documents
                            for document in documents {
                                let msgData = document.data()
                                let text = msgData["text"] as? String ?? ""
                                let date = msgData["timestamp"] as? Date ?? Date()
                                let senderID = msgData["userID"] as? String ?? ""
                                let msg = (Message(text,type: (senderID == userID) ? .Sent:.Recieved, date:date, senderID: senderID))
                                lastMessageID = msg.id
                                if (text != ""){
                                    newChat.messages.append(msg)
                                }
                            }
                            return newChat
                        }
                    }
                }
            }
    }
    
    ///Sends data to database
    func sendData(text: String){
        db.collection("Messages").document(chatID).collection("message").addDocument(data: [
            "text": text,
            "timestamp": Timestamp(date: Date()),
            "userID": userID
        ])
    }
    

    
    
    ///join chat that matches chatID
    func joinChat(){
        let docRef = db.collection("Messages").document(chatID)
        docRef.getDocument { (document, error) in
            let docData = document!.data()
            var docArray = docData!["members"] as? [String] ?? []
            docArray.append(self.userID)
            docRef.updateData([
                "full": (docArray.count >= 2) ? true:false,
                "members":docArray
            ])
            
            
            self.getData()
        }
        
        sendData(text: String(userID) + " joined the chat")
        //chatID isnt updated fast enough, therefore, not updating the joined chat.

    }
    
    ///create new chat and join it
    func newChat(){
        
        ///Create a chat in the database and add yourself
        chatID = db.collection("Messages").addDocument(data: [
            "full": false,
            "members": [userID]
        ]).documentID
        
        getData()
        ///only way to make a collection is to add  document. Create the first message
        sendData(text: String(userID) + " joined the chat")

    }
    
    ///find random empty chat and join. (Need to be randomized later)
    func findChat(){
        db.collection("Messages")
            .whereField("full", isEqualTo: false)
            //.whereField("members", arrayContainsAny: [chatID]])

            .limit(to: 1)
            .getDocuments(){ (snapshot, err) in
                ///If no available empty chat, create new chat
                if ((snapshot?.isEmpty)==true)
                   {
                       self.newChat()
                   }
                 ///if empty chat found, join
               for document in snapshot!.documents {
                   self.chatID = document.documentID
                   self.joinChat()
               }
            }
        getData()
    }
    
    
    ///delete old chat if both person leaves chat. Does nothing if only one in chat.
    func leaveChat(){
        
        ///Matches chatID so you can delete it. It crashes if it does not have a chatID match.
        ///Empty chat
        if (chatID == ""){
            chatID = "hhMpZuYMeBu6RlyNK9wM"
        }

        
        let docRef = db.collection("Messages").document(chatID)
            docRef.getDocument { (document, err) in
                if let document = document {
                    let docData = document.data()
                    let docFull = docData!["full"] as? Bool ?? true
                    var docArray = docData!["members"] as? [String] ?? []
                    
                    ///If current chat was full, find a new chat and delete old chat.
                    if (docFull == true){
                        self.findChat()
                        docArray.removeAll(where: {$0 == self.userID})

                        docRef.updateData([
                            "members":docArray
                            ])
                        
                        ///deletes document after leaving
                        if (docArray.count == 0 && docFull == true){
//                            ///remove all subcollections, but crashes.
//                            docRef.collection("message").getDocuments(){ (querySnapshot, err) in
//                                //querySnapshot.delete()
//                                for document in querySnapshot!.documents {
//                                    document.reference.delete()
//                                    //document.delete()
//                                }
//                            }
                            docRef.delete()
                        }
                    }
                    
                    
                }
                ///If no chat found, create chat chat()
                else{
                    self.findChat()
                }
                ///If document found but not full(Is the only one in chat), do nothing
            }
    }

}



struct DataControllerTest: View {
    
    @StateObject var viewModel = CoreDataViewModel()
    
    @State var textbox: String = ""
    var body: some View {

        NavigationView{
            VStack{


                TextField(viewModel.chatID, text: $textbox)
                
                Button("Submit", action:{
                    viewModel.addUser(name: textbox)
                    //textbox = ""
                })
                    .onAppear{
                        viewModel.fetchData()
                    }
                
                
                List{
                    ForEach(viewModel.savedEntities){user in
                        Text(user.name ?? "")
                            .onTapGesture {
                                viewModel.updateUser(entity: user, edit: textbox)
                            }
                    }
                    .onDelete(perform: viewModel.deleteUser)
                }
                Spacer()
                
            }

        }
    }
}

struct DataControllerTest_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatroomView()

            //DataControllerTest()
        }
    }
}

