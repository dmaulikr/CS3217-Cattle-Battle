//
//  Animal.swift
//  CattleBattle
//
//  Created by Ding Ming on 27/3/15.
//  Copyright (c) 2015 Cattle Battle. All rights deployed.
//

import SpriteKit

class Animal {
    
    enum Side: String {
        case LEFT = "left"
        case RIGHT = "right"
        
        internal var index: Int {
            return (self == .LEFT) ? 0 : 1
        }
        
        internal static var allSides = [LEFT, RIGHT]
    }
    
    enum Size: String {
        case TINY = "1"
        case SMALL = "2"
        case MEDIUM = "3"
        case LARGE = "4"
        case HUGE = "5"
        
        internal static let allSizes = [TINY, SMALL, MEDIUM, LARGE, HUGE]
        internal static let probability = [5, 4, 3, 2, 1]
        internal static let mass: [CGFloat] = [20, 40, 50, 70, 100]
        internal static let point: [Int] = [80, 60, 50, 35, 20]

        internal static func generateRandomAnimal() -> Size {
            var total = probability.reduce(0, combine: +)
            var rand = Int(arc4random_uniform(UInt32(total)))
            for i in 0..<allSizes.count {
                var prob = probability[i]
                if rand < prob {
                    return allSizes[i]
                } else {
                    rand -= prob
                }
            }
            return .TINY
        }
    }
    
    enum Status: String {
        case DEPLOYED = "deployed"
        case BUMPING = "bumping"
        case BUTTON = "button"
        
        internal static let allStatuses = [DEPLOYED, BUMPING, BUTTON]
    }
    
    struct Constants {
        internal static let GOAT_KEYWORD = "goat"
        internal static let IMAGE_EXT = ".png"

        internal static let SPRITE_SHEET_ROWS = 2
        internal static let SPRITE_SHEET_COLS = 5

        internal static let scale: [[CGFloat]] = [[0.25, 0.35, 0.4, 0.5, 0.6], [0.3, 0.4, 0.45, 0.55, 0.65]]
        
        internal static var deployedTextures = Side.allSides.map() { (side) -> [[SKTexture]] in
            return Size.allSizes.map() { (size) -> [SKTexture] in
                return Constants.getTextureList(side: side, size: size, status: .DEPLOYED)
            }
        }
        
        internal static var bumpingTextures = Side.allSides.map() { (side) -> [[SKTexture]] in
            return Size.allSizes.map() { (size) -> [SKTexture] in
                return Constants.getTextureList(side: side, size: size, status: .BUMPING)
            }
        }
        
        internal static var buttonTextures = Side.allSides.map() { (side) -> [SKTexture] in
            return Size.allSizes.map() { (size) -> SKTexture in
                return SKTexture(imageNamed: Animal(side: side, size: size, status: .BUTTON)._getImageFileName())
            }
        }
        
        //get the array of textures from a texture sheet for running animation
        internal static func getTextureList(#side: Side, size: Size, status: Status) -> [SKTexture] {
            var spriteSheet = SKTexture(imageNamed:  Animal(side: side, size: size, status: status)._getImageFileName())
            if status == .DEPLOYED || status == .BUMPING {
                spriteSheet.filteringMode = SKTextureFilteringMode.Nearest
            }
            var result = [SKTexture]()
            var x = 1.0 / CGFloat(SPRITE_SHEET_COLS)
            var y = 1.0 / CGFloat(SPRITE_SHEET_ROWS)
            for i in 0..<SPRITE_SHEET_ROWS {
                 for j in 0..<SPRITE_SHEET_COLS {
                    var rectFrame = CGRectMake(CGFloat(j) * x, CGFloat(i) * y, x, y)
                    result.append(SKTexture(rect: rectFrame, inTexture: spriteSheet))
                }
            }
            return result
        }
    }
    
    internal var side: Side
    internal var size: Size
    internal var status: Status
    
    private func _getImageFileName() -> String {
        var fileName = join("-", [Constants.GOAT_KEYWORD, status.rawValue, side.rawValue, size.rawValue])
        return fileName + Constants.IMAGE_EXT
    }
    
    internal func getTexture() -> SKTexture {
        if status == .BUTTON {
            return Constants.buttonTextures[find(Side.allSides, side)!][find(Size.allSizes, size)!]
        } else if status == .DEPLOYED {
            return Constants.deployedTextures[find(Side.allSides, side)!][find(Size.allSizes, size)!][0]
        } else {
            return Constants.bumpingTextures[find(Side.allSides, side)!][find(Size.allSizes, size)!][0]
        }
    }
    
    internal func getDeployedTexture() -> [SKTexture] {
        return Constants.deployedTextures[find(Side.allSides, side)!][find(Size.allSizes, size)!]
    }
    
    internal func getBumpingTexture() -> [SKTexture] {
        return Constants.bumpingTextures[find(Side.allSides, side)!][find(Size.allSizes, size)!]
    }
    
    init(side: Side, size: Size, status: Status) {
        self.side = side
        self.size = size
        self.status = status
    }
    
    internal func getImageScale() -> CGFloat {
        return Constants.scale[find(Status.allStatuses, status)!][find(Size.allSizes, size)!]
    }
    
    internal func getMass () -> CGFloat {
        return Size.mass[find(Size.allSizes, size)!]
    }
    
    internal func getPoint() -> Int {
        return Size.point[find(Size.allSizes, size)!]
    }
}
 