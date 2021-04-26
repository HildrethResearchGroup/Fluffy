//
//  ImageCollectionView.swift
//  Images
//
//  Created by Connor Barnes on 3/15/21.
//

import SwiftUI

struct ImageCollectionView: View {
	@Environment(\.managedObjectContext) private var viewContext
	static let group = "ImageCollectionView"
	
	var selectedDirectories: Set<Directory>
	
	var body: some View {
		List {
			ForEach(filesToShow) { file in
				HStack {
					if let url = file.url {
						LazyDiskImage(at: url, in: Self.group)
							.scaledToFit()
							.frame(width: 24, height: 24)
					} else {
						Text("X")
					}
					Text(file.displayName)
				}
				.onDrag {
					let uri = file.objectID.uriRepresentation() as NSURL
					return NSItemProvider(object: uri)
				}
			}
		}
	}
	
	init(selectedDirectories: Set<Directory>) {
		self.selectedDirectories = selectedDirectories
		DiskImageLoader.clearQueue(for: Self.group)
	}
}

extension ImageCollectionView {
	var filesToShow: [File] {
		func filesToShow(in directory: Directory) -> [File] {
			directory.files
				.map { $0 as! File }
				+ directory.subdirectories
				.flatMap { filesToShow(in: $0 as! Directory) }
		}
		
		return selectedDirectories
			.flatMap { filesToShow(in: $0) }
	}
}

// MARK: Previews
struct ImageCollectionView_Previews: PreviewProvider {
	@State static var selectedDirectories: Set<Directory> = makeSelectedDirectories()
	
	static func makeSelectedDirectories() -> Set<Directory> {
		let fetchRequest: NSFetchRequest<Directory> = Directory.fetchRequest()
		
		let viewContext = PersistenceController
			.preview
			.container
			.viewContext
		
		let fetchResult = try! viewContext.fetch(fetchRequest)
		
		return Set(fetchResult)
	}
	
	static var previews: some View {
		ImageCollectionView(selectedDirectories: selectedDirectories)
	}
}
