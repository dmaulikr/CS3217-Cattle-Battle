//
//  MenuButtonNode.swift
//  CattleBattle
//
//  Created by jarvis on 4/16/15.
//  Copyright (c) 2015 Cattle Battle. All rights reserved.
//

import UIKit
import SpriteKit

class MenuButtonNode: SKSpriteNode {
    struct Constants {
        internal static var IDENTIFIER = "buttonNode"
        internal static var reactions: [(() -> ())]!
    }
    
    internal var clicked: (() -> ())!
    
    init(buttonType: MenuButton.ButtonType, scale: CGFloat) {
        var button = MenuButton(type: buttonType)
        super.init(texture: button.getTexture(), color: UIColor.clearColor(), size: button.getTexture().size())
        
        self.clicked = Constants.reactions[find(MenuButton.ButtonType.allTypes, buttonType)!]
        self.name = Constants.IDENTIFIER
        self.xScale = scale
        self.yScale = scale

    }
    
    override init(texture:SKTexture, color:SKColor, size:CGSize) {
        super.init(texture:texture, color:color, size:size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}