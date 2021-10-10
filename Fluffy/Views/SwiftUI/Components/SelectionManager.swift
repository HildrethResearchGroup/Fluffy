//
//  SelectionManager.swift
//  Fluffy
//
//  Created by Beta on 10/10/21.
//

import Foundation
import SwiftUI

class SelectionManager: ObservableObject {
    @Published var tableSelection: Set<File.ID> = [] {
        didSet {
            updateSelection(.tableSelection)
        }
    }
    @Published var fileSelection: Set<File> = [] {
        didSet {
            updateSelection(.itemSelection)
        }
    }
    
    private var selectionTruth: Set<File.ID> = []
    
    enum SelectionChanged {
        case tableSelection
        case itemSelection
    }
    
    
    func updateSelection(_ changed: SelectionChanged) {
        // This can create a recursive loop
        // Need to determine if any actual changes occurred
        // Check everything against the selectionTruth
        
        let itemSelectionId = Set(fileSelection.map{ nextItem in
            nextItem.id
        })
        
        if itemSelectionId != tableSelection {
            switch changed {
            case .tableSelection:
                fileSelection = self.itemsFromId(tableSelection)
            case .itemSelection:
                tableSelection = itemSelectionId
            }
        }
        
    }
    
    
    func itemsFromId(_ setOfIDs: Set<NSManagedObjectID>) -> Set<File> {
        let context = PersistenceController.shared.container.viewContext
        let items = Set(setOfIDs.compactMap{context.object(with: $0) as? File })
        return items
    }
}