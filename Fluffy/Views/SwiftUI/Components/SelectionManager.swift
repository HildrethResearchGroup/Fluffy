//
//  SelectionManager.swift
//  Fluffy
//
//  Created by Beta on 10/10/21.
//

import Foundation
import OrderedCollections
import SwiftUI

class SelectionManager: ObservableObject {
    /// The File ID's selected in the Table view.
    /// Note that the Table view can only select File.ID's not direct Files
    @Published var tableSelection: Set<File.ID> = [] {
        didSet {
            updateSelection(.tableSelection)
        }
    }
    
    /// The Files selected in ImageCollectinIconsView and ImageCollectionsListView
    /// Note that these views directly select Files
    @Published var fileSelection: Set<File> = [] {
        didSet {
            updateSelection(.itemSelection)
            fileSelectionArray = Array(fileSelection)
        }
    }
    
    ///  A flattend array of the selected files
    @Published var fileSelectionArray: Array<File> = []
    
    /// The currently selected directories in the sidebar.
    @Published var directorySelection: Set<Directory> = []
    
    /// The Files located within the selected Directory (directorySelection)
    @Published var filesToShow: Array<File> = []
    
    /// Local enum to determine which selection source changed
    enum SelectionChanged {
        case tableSelection
        case itemSelection
    }
    
    /// A selection has changed.  Need to update any relevant selections.
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
    
    
    /// Convert a Set of NSManagedObjectID to a Set of File
    func itemsFromId(_ setOfIDs: Set<NSManagedObjectID>) -> Set<File> {
        let context = PersistenceController.shared.container.viewContext
        let items = Set(setOfIDs.compactMap{context.object(with: $0) as? File })
        return items
    }
}
