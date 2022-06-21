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
    @State var activePerson: Person = Person(name: "None", nationality: "TR", averageDelayMinutes: 0)
    @State var newPersonName = ""
    @State var newPersonDelay = ""
    @State private var selectedCountry: String = ""
    
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
                        AddPersonView(people: $people, activePerson: $activePerson, newPersonName: $newPersonName, newPersonDelay: $newPersonDelay, selectedCountry: $selectedCountry, stateManager: stateManager)
                    }
                    
                    Section {
                        Picker("People", selection: $activePerson) {
                            ForEach(people.sorted(by: { p1, p2 in
                                p1.name < p2.name
                            }), id: \.self) {
                                
                                if ($0.averageDelayMinutes > 0) {
                                    Text("\($0.name) delayed \($0.averageDelayMinutes) minutes")
                                } else {
                                    Text("\($0.name) early \(-$0.averageDelayMinutes) minutes")
                                }
                                
                            }
                        }.onChange(of: activePerson) { tag in
                            withAnimation {
                                if(!stateManager.isShowingActivePerson) {
                                    stateManager.isShowingActivePerson.toggle()
                                }
                            }
                        }
                    }
                    
                    if stateManager.isShowingActivePerson {
                        Section {
                            Text(activePerson.name)
                        }header: {
                            Text("Person name")
                        }
                        
                        Section {
                            Text(String(activePerson.averageDelayMinutes))
                        }header: {
                            Text("Person delay/early")
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

// Struct to store the country name and ID

fileprivate struct Country {
    var id: String
    var name: String
}

// Function to put United States at the top of the list

fileprivate func getLocales() -> [Country] {
    let engLocale = Locale(identifier: "en_US")
    let locales = Locale.isoRegionCodes
        .compactMap { Country(id: $0, name: engLocale.localizedString(forRegionCode: $0) ?? $0)}
    return locales.sorted { c1, c2 in
        c1.name < c2.name
    }
}

private func convertNameToLocale(for fullCountryName : String) -> String {
    var locales : String = ""
    for localeCode in NSLocale.isoCountryCodes {
        let identifier = NSLocale(localeIdentifier: localeCode)
        let countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: localeCode)
        if fullCountryName.lowercased() == countryName?.lowercased() {
            return localeCode as! String
        }
    }
    return locales
}

struct AddPersonView: View {
    @Binding var people: [Person]
    @Binding var activePerson: Person
    @Binding var newPersonName: String
    @Binding var newPersonDelay: String
    @Binding var selectedCountry: String

    @ObservedObject var stateManager : StateManager
    
    


    var body: some View {
        
        Section(header: Text("Name")) {
            TextField("Enter person name", text: $newPersonName)
        }
        
        Picker("Nationality", selection: $selectedCountry) {
                         ForEach(getLocales(), id: \.id) { country in
                         Text(country.name).tag(country.id)
                         }
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
            let newPerson = Person(name: "\(newPersonName + Flags.flag(country: selectedCountry))", nationality: selectedCountry, averageDelayMinutes: (Int(newPersonDelay) ?? 100)-100)
            people.append(newPerson)
            stateManager.changeAddPersonStatus(state: false)
            newPersonName = ""
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
    @Published var isShowingActivePerson = false

    
    func changeAddPersonStatus(state: Bool) {
        withAnimation {
            isShowingAddPerson = state
        }
    }
    
    func changeActivePersonStatus(state: Bool) {
        withAnimation {
            isShowingActivePerson = state
        }
    }
}
