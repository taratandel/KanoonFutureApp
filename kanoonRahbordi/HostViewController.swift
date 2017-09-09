//
//  File.swift
//  kanoonRahbordi
//
//  Created by Tara Tandel on 4/19/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import Foundation
import InteractiveSideMenu

class HostViewController: MenuContainerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuViewController = self.storyboard!.instantiateViewController(withIdentifier: "NavigationMenu") as! MenuViewController
        contentViewControllers = contentControllers()
        selectContentViewController(contentViewControllers.first!)
    }
    
    private func contentControllers() -> [MenuItemContentViewController] {
        var contentList = [MenuItemContentViewController]()
        contentList.append(self.storyboard?.instantiateViewController(withIdentifier: "First") as! MenuItemContentViewController)
        contentList.append(self.storyboard?.instantiateViewController(withIdentifier: "Second") as! MenuItemContentViewController)
        return contentList
    }
}
