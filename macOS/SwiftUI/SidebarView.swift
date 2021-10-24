//
//  SidebarView.swift
//  Done-macOS
//
//  Created by Anton Cherkasov on 21.10.2021.
//

import SwiftUI

struct Item2: Identifiable {
	var id: String {
		return title
	}
	var title: String
}

struct SidebarView2: View {
	
	typealias List = SwiftUI.List
	var items = [Item2(title: "Inbox"), Item2(title: "Favorites"), Item2(title: "Inbox")]
	@State var selected: String?
    var body: some View {
		List(selection: $selected) {
			Group {
				Text("Inbox")
					.tag("tray")
				Text("Favorites")
					.tag("star")
				Text("Completed")
					.tag("completed")
			}
			
			.listItemTint(.accentColor)
			
			Divider()
			Section(header: Text("List")) {
				ForEach(0..<10) { row in
					Label("List", systemImage: "text.badge.checkmark")
				}
			}
			
		}
		.listStyle(SidebarListStyle())
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView2()
    }
}
