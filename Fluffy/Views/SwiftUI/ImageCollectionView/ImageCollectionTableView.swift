//
//  ImageCollectionTableView.swift
//  Fluffy
//
//  Created by Beta on 10/7/21.
//

import SwiftUI
import OrderedCollections

/// A view for displaying a collection of images as a table
struct ImageCollectionTableView: View {
    /// The files to display
    var filesToShow: [File]
    
    /// Manage the File and Directory selections
    @EnvironmentObject var selectionManager: SelectionManager
    
    
    /// The sort order
    @State private var order: [KeyPathComparator<File>] = [
        .init(\.organizedPath, order: SortOrder.forward),
        .init(\.displayName, order: .forward)
    ]
    
    /// An updater for manually updating the files to show
    @Binding var updater: Updater
    
    /// The group to load images in
    @State var diskImageGroup: DiskImageLoaderGroup
    
    init(filesToShow: [File],
         updater: Binding<Updater>
    ) {
        self.filesToShow = filesToShow
        _updater = updater
        diskImageGroup = .named(
            "ListView",
            cacheMegabyteCapacity: 128
        )
    }
    
    
    var body: some View {
        Table(filesToShow, selection: $selectionManager.tableSelection, sortOrder: $order) {
            TableColumn("Name", value: \.displayName)
            TableColumn("Location", value: \.organizedPath)
            TableColumn("Date Imported", value: \.dateImportedString)
            TableColumn("Size [MB]", value: \.fileSize)
            TableColumn("File Name", value: \.fileName) {file in
                HStack {
                    Text(file.fileName)
                    Spacer()
                    ShowInFinderButton(file.url)
                }
            }
        }
    }
    
    
}


// MARK: - Icon View
private extension ImageCollectionTableView {
    /// Returns an icon image of the given file
    /// - Parameter file: The file to be displayed in the item
    
    struct IconView: View {
        /// The file whose icon to display.
        var url: URL
        
        /// The group to load the icon's image.
        let diskImageGroup: DiskImageLoaderGroup = .named(
            "ListView",
            cacheMegabyteCapacity: 128
        )
        
        
        var body: some View {
            let size = 36
            let imageLoader = ThumbnailDiskImageLoader(
                in: diskImageGroup,
                imageSize: CGSize(
                    width: size,
                    height: size)
            )
            
            LazyDiskImage(at: url, using: imageLoader)
                .scaledToFit()
        }
    }
}

/**
struct ImageCollectionTableView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCollectionTableView()
    }
}
 */
