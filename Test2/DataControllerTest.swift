//
//  DataControllerTest.swift
//  RandomChat
//
//  Created on 12/25/21.
//

import SwiftUI
import CoreData
import Firebase
import FirebaseFirestoreSwift


class CoreDataViewModel:ObservableObject{
    
    let container: NSPersistentContainer
    @Published var savedEntities: [User] = []
    @Published var chats =
    [Chat(person:Person(name:"x", imgString:"img1"),
        messages:[Message("boioi",type:.Recieved),
        Message("Whatcha want?",type:.Sent),
        Message("Money boi",type:.Recieved)],
        hasReadMessage: false)]
    
    
    init(){
        container = NSPersistentContainer(name: "UserData")
        container.loadPersistentStores { (description, error) in
            if let error = error{
                print("\(error)")
            }
        }
        fetchData()
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
    
    func addUser(text: String){
        let newUser = User(context: container.viewContext)
        newUser.name = text
        saveData()
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
        entity.name = edit
        saveData()
        
    }
    
    func saveData(){
        do {
            try container.viewContext.save()
            fetchData()
        } catch _{
            print("error")
        }
    }
    
    func getData2(){
        
        let db = Firestore.firestore()
        
        db.collection("Chat").addSnapshotListener { [self] (snapshot, error) in
            guard let documents = snapshot?.documents else{
                return
            }
            
            self.chats = documents.compactMap { (snapshot) -> Chat in
                let data = snapshot.data()
                
                
                let hasReadMessage = data["hasReadMessage"] as? Bool ?? false

                var name = ""
                var imgString = ""
                if let person = data["person"] as? [String: Any]{
                        name = person["name"] as? String ?? ""
                        imgString = person["imgString"] as? String ?? ""
                }
                
                
                let person = Person(name:name , imgString:imgString)
                let messages:[Message] = []
                //let messages = data["messages"] as? [Message] ?? [Message("box2",type:.Recieved)]
                var newChat = Chat(person: person, messages: messages, hasReadMessage: hasReadMessage)
                
                if let messageArray = data["messages"] as? [[String:Any]]{
                    //if let message = messageArray[0] as? [String:Any]{
                        let message = messageArray[0]
                        let text = message["text"] as? String ?? "box2"
                        //let text2 = messageArray[1]["text"] as? String ?? "box3x"
                        let newMessage = Message(text,type:.Recieved)
                        newChat.messages.append(newMessage)
                    //}

                    //let text = messageArray["message"] as? String ?? "box3"
                    //let messageType = messageArray["messageType"] as? String ?? ".Recieved"
                }
      
                

                
                newChat.messages.append(Message("box4",type:.Sent))

                return newChat
            }
        }

    }
    
    func getData(){
        
        
        let db = Firestore.firestore()
        //var msg:Message = (Message("box1",type:.Recieved))

        var person = Person(name:"" , imgString:"")
        db.collection("Users").addSnapshotListener {(snapshot, error) in
            
            for document in snapshot!.documents {
                let data = document.data()
                let username = data["username"] as? String ?? ""
                let imgString = data["imgString"] as? String ?? ""
                person = Person(name:username , imgString:imgString)
                self.chats[0].person = person
                //msg = (Message(text,type:.Recieved))
                //messageArr.append(msg)
            }
        }
            
        //Update Messages
        db.collection("Messages").document("hhMpZuYMeBu6RlyNK9wM").collection("message").addSnapshotListener { [self] (snapshot, error) in
            guard let documents = snapshot?.documents else{
                return
            }

            ///Returns Chat every time "Messages" is updated
            self.chats = documents.compactMap { (snapshot) -> Chat in

                var newChat = Chat(person: person, messages:[], hasReadMessage: false)
                //newChat.person = Person(name:"x" , imgString:"t")
                
            ///Get all message documents
                for document in documents {
                    let msgData = document.data()
                    let text = msgData["text"] as? String ?? ""
                    let msg = (Message(text,type:.Recieved))
                    newChat.messages.append(msg)
                }

                return newChat
            }
        }

    }
    
}



struct DataControllerTest: View {
    
    @StateObject var viewModel = CoreDataViewModel()
    
    @State var textbox: String = ""
    var body: some View {

        NavigationView{
            VStack{


                TextField("New User", text: $textbox)
                
                Button("Submit", action:{
                    viewModel.addUser(text: textbox)
                    //textbox = ""
                }).disabled(textbox.isEmpty)
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
        DataControllerTest()
    }
}

