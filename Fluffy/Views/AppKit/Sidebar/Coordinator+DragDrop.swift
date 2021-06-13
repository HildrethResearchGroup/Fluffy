//
//  SidebarViewController+DragDrop.swift
//  Fluffy
//
//  Created by Connor Barnes on 4/26/21.
//

import Cocoa

extension SidebarViewController.Coordinator {
	func outlineView(
		_ outlineView: NSOutlineView,
		pasteboardWriterForItem item: Any
	) -> NSPasteboardWriting? {
		let row = outlineView.row(forItem: item)
		let pasteboardItem = NSPasteboardItem()
		// The property list simply contains the row of the directory. The directory
		// associated with this row can be easily obtained later
		let propertyList = [DirectoryPasteboardWriter.UserInfoKeys.row : row]
		pasteboardItem.setPropertyList(propertyList, forType: .directoryRowPasteboardType)
		return pasteboardItem
	}
	
	func outlineView(
		_ outlineView: NSOutlineView,
		validateDrop info: NSDraggingInfo,
		proposedItem item: Any?,
		proposedChildIndex index: Int
	) -> NSDragOperation {
		var result = NSDragOperation()
		// Don't allow dropping on a child
		guard index != -1 else { return result }
		guard let dropDirectory = directory(fromItem: item) else { return result }
		
		if info.draggingPasteboard
				.availableType(from: [.directoryRowPasteboardType]) != nil {
			// Drag source is from within the outline view
			if okayToDropDirectories(draggingInfo: info,
															 destinationItem: dropDirectory,
															 onView: outlineView) {
				result = .move
			}
		} else if info.draggingPasteboard
								.availableType(from: [.imagePasteboardType]) != nil {
			// Drag source is an internal image
			// Images cannot be placed in the root directory
			if dropDirectory != parent.rootDirectory {
				result = .move
			}
		} else if info.draggingPasteboard.availableType(from: [.fileURL]) != nil {
			if !(item == nil && externalDropContainsFiles(draggingInfo: info)) {
				result = .link
			}
		} else if info.draggingPasteboard
								.availableType(from: [.URL]) != nil {
			var urls: [URL] = []
			
			info.enumerateDraggingItems(options: [],
																	for: outlineView,
																	classes: [NSPasteboardItem.self],
																	searchOptions: [:]) { dragItem, _, _ in
				
				guard let dragItem = dragItem.item as? NSPasteboardItem,
				let propertyList = dragItem.propertyList(forType: .URL),
				let url = NSURL(pasteboardPropertyList: propertyList,
												ofType: .URL) as URL?
				else {
					return
				}
				
				urls.append(url)
			}
			
			let coreDataObjects: [NSManagedObject] = urls
				.compactMap { url in
					guard let objectID = parent.viewContext
						.persistentStoreCoordinator?
						.managedObjectID(forURIRepresentation: url)
					else { return nil }
					
					return parent.viewContext.object(with: objectID)
				}
			
			let imageObjects = coreDataObjects
				.compactMap { $0 as? File }
			
			if !imageObjects.isEmpty {
				result = .move
			}
		} else {
			// Drag source is from outside the app, likely a file promise, so copy
			result = .copy
		}
		
		return result
	}
	
	func outlineView(
		_ outlineView: NSOutlineView,
		acceptDrop info: NSDraggingInfo,
		item: Any?,
		childIndex index: Int
	) -> Bool {
		let dropDirectory = directory(fromItem: item) ?? parent.rootDirectory
		
		if info.draggingPasteboard
				.availableType(from: [.directoryRowPasteboardType]) != nil {
			// The items that are being dragged are internal directory items
			handleInternalDirectoryDrops(outlineView,
																	 draggingInfo: info,
																	 dropDirectory: dropDirectory,
																	 childIndex: index)
			
			parent.updater.update()
		} else if info.draggingPasteboard
								.availableType(from: [.imagePasteboardType]) != nil {
			// The items being dragged are internal image items
		} else if info.draggingPasteboard
								.availableType(from: [.fileURL]) != nil {
			// The user has dropped items from Finder
			handleExternalDrops(
				outlineView,
				draggingInfo: info,
				dropDirectory: dropDirectory,
				childIndex: index
			)
		} else if info.draggingPasteboard
								.availableType(from: [.URL]) != nil {
			var urls: [URL] = []
			
			info.enumerateDraggingItems(options: [],
																	for: outlineView,
																	classes: [NSPasteboardItem.self],
																	searchOptions: [:]) { dragItem, _, _ in
				
				guard let dragItem = dragItem.item as? NSPasteboardItem,
				let propertyList = dragItem.propertyList(forType: .URL),
				let url = NSURL(pasteboardPropertyList: propertyList,
												ofType: .URL) as URL?
				else {
					return
				}
				
				urls.append(url)
			}
			
			let coreDataObjects: [NSManagedObject] = urls
				.compactMap { url in
					guard let objectID = parent.viewContext
						.persistentStoreCoordinator?
						.managedObjectID(forURIRepresentation: url)
					else { return nil }
					
					return parent.viewContext.object(with: objectID)
				}
			
			if dropDirectory != parent.rootDirectory {
				coreDataObjects
					.compactMap { $0 as? File }
					.forEach { image in
						image.parent?.removeFromFiles(image)
						dropDirectory.addToFiles(image)
						image.parent = dropDirectory
					}
				
				parent.updater.update()
			}
		}
		
		return true
	}
	
	func outlineView(
		_ outlineView: NSOutlineView,
		draggingSession session: NSDraggingSession,
		endedAt screenPoint: NSPoint,
		operation: NSDragOperation
	) {
		if operation == .delete {
			// This is called when dragging to the trash can
			guard let items = session.draggingPasteboard.pasteboardItems else {
				return
			}
			let directoriesToRemove = items
				.compactMap { (draggedItem) -> Directory? in
					guard let plist = draggedItem
									.propertyList(forType: .directoryRowPasteboardType)
									as? [String: Any],
								let rowIndex = plist[DirectoryPasteboardWriter.UserInfoKeys.row]
									as? Int
					else {
						return nil
					}
					
					let item = outlineView.item(atRow: rowIndex)
					return directory(fromItem: item)
				}
			remove(directories: directoriesToRemove, inOutlineView: outlineView)
		}
	}
}

// MARK:- Helper Functions
extension SidebarViewController.Coordinator {
	/// Returns true if the directories being dragged can be dropped at the given location. This checks to make sure that a directory is not placed inside one of its children.
	/// - Parameters:
	///   - draggingInfo: The dragging info passed to the delegate method.
	///   - destinationItem: The directory that is being dropped onto.
	///   - view: The view being dropped on.
	/// - Returns: True if the drop is okay, and false otherwise.
	private func okayToDropDirectories(
		draggingInfo: NSDraggingInfo,
		destinationItem: Directory?,
		onView view: NSView?
	) -> Bool {
		
		guard let destinationItem = destinationItem else { return true }
		let ancestors = destinationItem.ancestors
			.union([destinationItem])
		var droppedOntoSelf = false
		draggingInfo.enumerateDraggingItems(options: [],
																				for: view,
																				classes: [NSPasteboardItem.self],
																				searchOptions: [:]) { dragItem, _, _ in
			
			guard let droppedPasteboardItem = dragItem.item
							as? NSPasteboardItem,
						let outlineView = view as? NSOutlineView,
						let dropDirectory = self
							.directoryFromPasteboardItem(droppedPasteboardItem,
																					 forOutlineView: outlineView) else {
				return
			}
			// Check if the dropped item is the parent of the location item
			if ancestors.contains(dropDirectory) {
				// Dropping a parent directory into this directory, which would create an infinite cycle, so don't allow this
				droppedOntoSelf = true
			}
		}
		return !droppedOntoSelf
	}
	
	/// Extracts the directory from an NSPasteboardItem instance.
	/// - Parameter item: The pasteboard item.
	/// - Parameter outlineView: The outline view being dragged from.
	/// - Returns: The directory associated with the pasteboard item if there is one.
	private func directoryFromPasteboardItem(
		_ item: NSPasteboardItem,
		forOutlineView outlineView: NSOutlineView?
	) -> Directory? {
		// Get the row number from the property list
		guard let plist = item.propertyList(forType: .directoryRowPasteboardType) as? [String: Any] else { return nil }
		guard let row = plist[DirectoryPasteboardWriter.UserInfoKeys.row] as? Int else { return nil }
		// Ask the sidebar for the directory at that row
		return outlineView?.item(atRow: row) as? Directory
	}
	
	/// Returns the file associated with a given pasteboard item.
	/// - Parameter item: The pasteboard item.
	/// - Returns: The file if it exists, otherwise `nil`.
	private func fileFromPasteboardItem(_ item: NSPasteboardItem) -> File? {
		// Get the row number from the property list
		guard let plist = item.propertyList(forType: .imagePasteboardType)
						as? [String: Any],
					let objectID = plist[ImagePasteboardWriter.UserInfoKeys.objectID]
						as? NSManagedObjectID,
					let image = parent.viewContext.object(with: objectID) as? File
		else {
			return nil
		}
		
		return image
	}
	
	/// Handles dropping internal items onto the sidebar.
	/// - Parameters:
	///   - outlineView: The outline view being dropped onto.
	///   - draggingInfo: The dragging info.
	///   - dropDirectory: The directory that the items are being dropped into.
	///   - index: The child index of the directory that the items are being dropped at.
	private func handleInternalDirectoryDrops(
		_ outlineView: NSOutlineView,
		draggingInfo: NSDraggingInfo,
		dropDirectory: Directory,
		childIndex index: Int
	) {
		var itemsToMove: [Directory] = []
		// If the drop location is ambiguous, add it as the last item
		let dropIndex = index == -1 ? dropDirectory.subdirectories.count : index
		draggingInfo.enumerateDraggingItems(options: [], for: outlineView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
			if let droppedPasteboardItem = dragItem.item as? NSPasteboardItem {
				if let itemToMove = self
						.directoryFromPasteboardItem(droppedPasteboardItem,
																				 forOutlineView: outlineView) {
					itemsToMove.append(itemToMove)
				}
			}
		}
		// The items may be added at a higher index if there are selected items in
		// the drop directory that are above the drop zone
		let indexOffset = itemsToMove.lazy.filter { directory -> Bool in
			// The parent of the item being moved has to be the same as the drop
			// directory
			if directory.parent != dropDirectory { return false }
			let directoryIndex = dropDirectory.subdirectories.index(of: directory)
			guard directoryIndex != -1 else {
				// The index of the item should never be -1 because it's parent is the
				// drop directory (thus it should be in the children set)
				print("[WARNING] Internal error: index of directory child was nil")
				return false
			}
			// The item being moved has to be above the drop location
			return directoryIndex < dropIndex
		}.count
		
		let insertIndex = dropIndex - indexOffset
		// Each item will have a move animation, so put in an update block to
		// improve performance
		outlineView.beginUpdates()
		// Because each item is added individually as a child, it needs to be done
		// in reverse order, otherwise the items would be pasted in the wrong order
		itemsToMove.reversed().forEach { directory in
			let originalParent =
				directory.parent == parent.rootDirectory ? nil : directory.parent
			let originalIndex = outlineView.childIndex(forItem: directory)
			// Remove the directories to be moved from their parent
			directory.parent?.removeFromSubdirectories(directory)
			directory.parent = nil
			// Then make these directories' new parent the drop parent
			dropDirectory.insertIntoSubdirectories(directory, at: insertIndex)
			
			let newParent =
				dropDirectory == parent.rootDirectory ? nil : dropDirectory
			// Then add animation
			outlineView.moveItem(at: originalIndex,
													 inParent: originalParent,
													 to: insertIndex,
													 inParent: newParent)
			// If there are no more subdirectories for the parent of the directory
			// that has just had its children moved, the disclosure triangle for that
			// row should be hidden. To do that, the parent item is reloaded if it has
			// no more subdirectories
			if (originalParent?.subdirectories.count == 0) {
				outlineView.reloadItem(originalParent, reloadChildren: false)
			}
		}
		outlineView.endUpdates()
	}
	
	/// Handles dropping internal files onto the sidebar.
	/// - Parameters:
	///   - outlineView: The outline view being dropped onto.
	///   - draggingInfo: The dragging info.
	///   - dropDirectory: The directory that the items are being dropped into.
	///   - index: The child index of the directory that the items are being dropped at.
	private func handleInternalFileDrops(
		_ outlineView: NSOutlineView,
		draggingInfo: NSDraggingInfo,
		dropDirectory: Directory,
		childIndex index: Int
	) {
		var itemsToMove: [File] = []
		
		draggingInfo.enumerateDraggingItems(options: [], for: outlineView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
			if let droppedPasteboardItem = dragItem.item as? NSPasteboardItem {
				if let itemToMove = self.fileFromPasteboardItem(droppedPasteboardItem) {
					itemsToMove.append(itemToMove)
				}
			}
		}
		
		// Move each file
		itemsToMove.forEach { file in
			file.parent?.removeFromFiles(file)
			dropDirectory.addToFiles(file)
			file.parent = dropDirectory
		}
	}
	
	private func externalDropContainsFiles(draggingInfo: NSDraggingInfo) -> Bool {
		// We look for file promises and urls
		let supportedClasses = [NSFilePromiseReceiver.self, NSURL.self]
		// For items dragged from outside the application, we want to seach for readable URLs
		let searchOptions: [NSPasteboard.ReadingOptionKey: Any] = [.urlReadingFileURLsOnly: true]
		var droppedURLs: [URL] = []
		// Process all pasteboard items that are being dropped
		draggingInfo.enumerateDraggingItems(options: [], for: nil, classes: supportedClasses, searchOptions: searchOptions) { draggingItem, _, _ in
			switch draggingItem.item {
			// TODO: Support file promises
//			case let filePromiseReceiver as NSFilePromiseReceiver:
				// The drag item is a file promise, so it isn't a directory
//				break
			case let fileURL as URL:
				// The drag item is a URL reference (not a file promise)
				droppedURLs.append(fileURL)
			default:
				break
			}
		}
		
		return droppedURLs.contains { url in
			return !url.isFolder
		}
	}
	
	/// Handles dropping external items onto the sidebar.
	/// - Parameters:
	///   - outlineView: The outlineview being dropped onto.
	///   - draggingInfo: The dragging info.
	///   - dropDirectory: The directory that the items are being dropped into.
	///   - index: The child index of the directory that the items are being dropped at.
	private func handleExternalDrops(_ outlineView: NSOutlineView, draggingInfo: NSDraggingInfo, dropDirectory: Directory, childIndex index: Int) {
		// We look for file promises and urls
		let supportedClasses = [NSFilePromiseReceiver.self, NSURL.self]
		// For items dragged from outside the application, we want to search for
		// readable URLs
		let searchOptions: [NSPasteboard.ReadingOptionKey: Any] = [
			.urlReadingFileURLsOnly: true
		]
		
		var droppedURLs: [URL] = []
		// Process all pasteboard items that are being dropped
		draggingInfo.enumerateDraggingItems(
			options: [],
			for: nil,
			classes: supportedClasses,
			searchOptions: searchOptions
		) { draggingItem, _, _ in
			switch draggingItem.item {
			case _ as NSFilePromiseReceiver:
				// TODO: Implement file promises
				break
			case let fileURL as URL:
				// The drag item is a URL reference (not a file promise)
				droppedURLs.append(fileURL)
			default:
				break
			}
		}
		
		importURLs(droppedURLs,
							 in: outlineView,
							 dropDirectory: dropDirectory,
							 childIndex: index,
							 includeSubdirectories: true)
	}
	
	/// Inserts files/directories in the given directory.
	/// - Parameters:
	///   - urls: The urls of the files and directories to add.
	///   - outlineView: The outlineview that is being dragged into.
	///   - dropDirectory: The directory that files are being added to. If `nil`, the root directory is used.
	///   - childIndex: The index of the child inside the directory that files are being added at. If `nil`, the items are added to the end of the directory.
	///   - includeSubdirectories: Whether or not to include subdirectories of the selection.
	private func importURLs(
		_ urls: [URL],
		in outlineView: NSOutlineView,
		dropDirectory: Directory?,
		childIndex: Int?,
		includeSubdirectories: Bool
	) {
		let rootDirectory = parent.rootDirectory
		// If no drop directory is specified then add it to the root directory
		let dropDirectory = dropDirectory ?? rootDirectory
		// If no child index is specified then append it
		let childIndex = childIndex ?? dropDirectory.subdirectories.count
		dropDirectory.insertFileSystemObjects(
			at: urls,
			index: childIndex,
			includeSubdirectories: includeSubdirectories
		)
		
		// Animate
		let outlineParent = dropDirectory == rootDirectory ? nil : dropDirectory
		let folderCount = urls.lazy.filter { $0.isFolder } .count
		let insertionIndexSet = IndexSet(integersIn: childIndex..<(childIndex + folderCount))
		outlineView.insertItems(at: insertionIndexSet, inParent: outlineParent, withAnimation: .slideDown)
		
		// File selection may have changed
		parent.updater.update()
	}
}
