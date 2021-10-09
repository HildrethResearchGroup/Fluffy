//
//  ImageCollectionTableView.swift
//  Fluffy
//
//  Created by Beta on 10/7/21.
//

import SwiftUI

/// A view for displaying a collection of images as a table
struct ImageCollectionTableView: View {
    /// The files to display
    var filesToShow: [File]
    
    /// The files selected
    @Binding var fileSelection: Set<File>
    
    ///  Local storage for files selected.  Table only
    @State var localFileSelection: Set<File.ID> = []
    
    
    /// An updater for manually updating the files to show
    @Binding var updater: Updater
    
    /// The group to load images in
    @State var diskImageGroup: DiskImageLoaderGroup
    
    
    var body: some View {
        Table(filesToShow) {
            TableColumn("Name", value: \.displayName)
            TableColumn("Location", value: \.organizedPath)
            TableColumn("Date Imported", value: \.dateImportedString)
            TableColumn("Size", value: \.fileSize)
        }
    }
    
    func updateFileSelection() {
        
    }
}

/**
struct ImageCollectionTableView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCollectionTableView()
    }
}
 
 
 rows: {
    ForEach(filesToShow) {
        TableRow($0)
    }.onChange(of: localFileSelection) {
        print("Changed Selection")
    }
}
 */
