//
//  DetailView.swift
//  Images
//
//  Created by Connor Barnes on 5/30/21.
//

import SwiftUI

struct DetailView: View {
	var file: File
	
	var diskImageLoaderGroup: DiskImageLoaderGroup
	
	init(file: File) {
		self.file = file
		diskImageLoaderGroup = .named("DetailGroup", cacheMegabyteCapacity: 512)
	}
	
	var body: some View {
		if let url = file.url {
			let loader = DiskImageLoader(in: diskImageLoaderGroup)
			LazyDiskImage(at: url, using: loader)
		} else {
			Text("No URL for image")
		}
	}
}

// MARK:- Helper Functions
extension DetailView {
	
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
