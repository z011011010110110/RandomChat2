//
//  FirebaseData.swift
//  Test2
//
//  Created by Hyunbin Joo on 1/1/22.
//

import SwiftUI
import Firebase



struct FirebaseData: View {
    @State var list = ["y","e","xd"]
    //@ObservedObject var model
    
    var body: some View {
        
        //Text("asd")
        ScrollViewReader{_ in
            List{
                ForEach (list, id: \.self){ item in
                        Text(item)
                }
                  
            }
                .onTapGesture {
                    getData()
                }
            }
        }
    
    
    
    func getData(){
        
        let db = Firestore.firestore()
        db.collection("Chat").addSnapshotListener { (snapshot, error) in
            guard let documents = snapshot?.documents else{
                
                list.append("No Documents")
                return
            }
            
            self.list = documents.map { (snapshot) -> String in
                let data = snapshot.data()
                let id = data["id"] as? String ?? "x"
                return id
            }
        }
    }


}

func getDocumet() -> String{
    //let db = Firestore.firestore()
    //return db.collection("Chat").document("gxjj3CTyJunEVCxsczvO").["id"]
    return ""
}

struct FirebaseData_Previews: PreviewProvider {
    static var previews: some View {
        
        FirebaseData()
    }
}

