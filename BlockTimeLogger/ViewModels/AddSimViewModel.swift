import Foundation
import SwiftUI

final class AddSimViewModel: ObservableObject {
    @Published var sim = Sim.emptySim()
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    
    func validate() -> Bool {
        guard !sim.aircraftType.isEmpty else {
            validationMessage = "Aircraft type is required"
            showValidationAlert = true
            return false
        }
        
        guard !sim.registration.isEmpty else {
            validationMessage = "Registration is required"
            showValidationAlert = true
            return false
        }
        
        guard !sim.pic.isEmpty else {
            validationMessage = "PIC is required"
            showValidationAlert = true
            return false
        }
        
        return true
    }
} 
