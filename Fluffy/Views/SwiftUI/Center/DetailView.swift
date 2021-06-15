//
//  DetailView.swift
//  Fluffy
//
//  Created by Connor Barnes on 5/30/21.
//

import SwiftUI

/// A view displaying the given file.
struct DetailView: View {
	/// The file to display.
	var file: File
	
	/// The group to load the image in.
	var diskImageLoaderGroup: DiskImageLoaderGroup
	
	/// Creates a new detail view displaying the image of the given file.
	/// - Parameter file: The file to display the image contents of.
	init(file: File) {
		self.file = file
		diskImageLoaderGroup = .named("DetailGroup", cacheMegabyteCapacity: 512)
	}
	
	var body: some View {
		if let url = file.url {
			let loader = DiskImageLoader(in: diskImageLoaderGroup)
			LazyDiskImage(at: url, using: loader)
				.id("DetailImage")
		} else {
			Text("No URL for image")
		}
	}
}

// MARK:- Preview
struct DetailView_Previews: PreviewProvider {
	static let file: File = {
		let fetchRequest: NSFetchRequest<File> = File.fetchRequest()
		
		let viewContext = PersistenceController
			.preview
			.container
			.viewContext
		
		let fetchResult = try! viewContext.fetch(fetchRequest)
		
		return fetchResult.first!
	}()
	
	static var previews: some View {
		DetailView(file: file)
	}
}
