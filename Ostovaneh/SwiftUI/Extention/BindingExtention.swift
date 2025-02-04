//
//  BindingExtention.swift
//  Master
//
//  Created by Sina khanjani on 12/1/1399 AP.
//

import SwiftUI

extension Binding {
    /// SwiftUI lets us attach an onChange() modifier to any view, which will run code of our choosing when some state changes in our program. This is important, because we can’t always use property observers like didSet with something like @State.
///    struct ContentView : View {
///        @State private var name = ""
///
///        var body: some View {
///            TextField("Enter your name:", text: $name.onChange(nameChanged))
///                .textFieldStyle(RoundedBorderTextFieldStyle())
///       }
///
///        func nameChanged(to value: String) {
///            print("Name changed to \(name)!")
///        }
///    }
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
