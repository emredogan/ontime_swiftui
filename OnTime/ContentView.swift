//
//  ContentView.swift
//  OnTime
//
//  Created by Emre Dogan on 19/06/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var stateManager = StateManager()
    @State var people = [Person]()
    @State var activePerson: Person = Person(name: "Emre", averageDelayMinutes: 100)
    @State var newPersonName = ""
    @State var newPersonDelay = ""
    
    
    
    var body: some View {
        
        NavigationView {
            VStack {
                Form {
                    Button("Add new person") {
                        withAnimation {
                            stateManager.isShowingAddPerson.toggle()
                        }
                    }
                    
                    if stateManager.isShowingAddPerson {
                        AddPersonView(people: $people, activePerson: $activePerson, newPersonName: $newPersonName, newPersonDelay: $newPersonDelay, stateManager: stateManager)
                    }
                    
                    Section {
                        Picker("People", selection: $activePerson.name) {
                            ForEach(people.sorted(by: { p1, p2 in
                                p1.name < p2.name
                            }), id: \.self) {
                                if ($0.averageDelayMinutes > 0) {
                                    Text("\($0.name) is usually delayed \($0.averageDelayMinutes) minutes")
                                } else {
                                    Text("\($0.name) is usually early \(-$0.averageDelayMinutes) minutes")
                                }
                                
                            }
                        }
                    }
                }
                
            }
            .navigationTitle("OnTime")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AddPersonView: View {
    @Binding var people: [Person]
    @Binding var activePerson: Person
    @Binding var newPersonName: String
    @Binding var newPersonDelay: String
    @ObservedObject var stateManager : StateManager


    var body: some View {
        
        Section(header: Text("Name")) {
            TextField("Enter person name", text: $newPersonName)
        }
        Section(header: Text("Delayed or early")) {
            Picker("How much delayed / early?", selection: $activePerson.averageDelayMinutes) {
                ForEach(-100..<101) {
                    if($0 < 0) {
                        Text("\(-$0) minutes early")
                    } else if ($0 == 0) {
                        Text("On time")
                    } else {
                        Text("\($0) minutes late")
                    }
                }
            }
            .pickerStyle(.wheel)
            
        }
        
        Button("Add") {
            let newPerson = Person(name: newPersonName, averageDelayMinutes: Int(activePerson.averageDelayMinutes-100))
            people.append(newPerson)
            stateManager.changeLogin(state: false)
            newPersonName = ""
            activePerson.averageDelayMinutes = 100
            newPersonDelay = ""
            
        }   .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(Color.black.cornerRadius(8))
            .foregroundColor(Color.white)

        
    }
}

class StateManager : ObservableObject {
    @Published var isShowingAddPerson = false
    
    func changeLogin(state: Bool) {
        withAnimation {
            isShowingAddPerson = state
        }
    }
}
