//
//  RectangleFeaturesFunnel.swift
//  Scanner
//
//  Created by Boris Emorine on 2/9/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation
import AVFoundation

final class RectangleFeaturesFunnel {
    
    class RectangleMatch {
        let rectangleFeature: CIRectangleFeature
        var matchingScore = 0
        
        init(rectangleFeature: CIRectangleFeature) {
            self.rectangleFeature = rectangleFeature
        }
        
        let treshold: CGFloat = 50.0
        
        func matches(_ rectangle: CIRectangleFeature) -> Bool {
            return rectangleFeature.isWithin(treshold, ofRectangleFeature: rectangle)
        }
    }
    
    private var rectanglesQueue = [RectangleMatch]()
    
    let maxNumberOfRectangles = 5
    let minNumberOfRectangles = 3

    func add(_ rectangleFeature: CIRectangleFeature, currentlyDisplayedRectangle previousRectangle: CIRectangleFeature?, completion: (CIRectangleFeature) -> Void) {
        let rectangleMatch = RectangleMatch(rectangleFeature: rectangleFeature)

        rectanglesQueue.append(rectangleMatch)
        
        guard rectanglesQueue.count >= minNumberOfRectangles else {
            return
        }
        
        if rectanglesQueue.count > maxNumberOfRectangles {
            rectanglesQueue.removeFirst()
        }
        
        updateRectangleMatches()
        
        if let bestRectangle = self.bestRectangle() {
            if let previousRectangle = previousRectangle,
                bestRectangle.rectangleFeature.isWithin(50.0, ofRectangleFeature: previousRectangle) {
                return
            } else {
                completion(bestRectangle.rectangleFeature)
            }
        }
        
    }
    
    private func bestRectangle() -> RectangleMatch? {
        
        var bestMatch: RectangleMatch?
        
        rectanglesQueue.reversed().forEach { (rectangle) in
            if rectangle.matchingScore > (bestMatch?.matchingScore ?? -1) {
                bestMatch = rectangle
            }
        }
        
        return bestMatch
    }
    
    private func updateRectangleMatches() {
        rectanglesQueue = rectanglesQueue.map { (rectange) -> RectangleMatch in
            rectange.matchingScore = 0
            return rectange
        }
        
        for (i, currentRect) in rectanglesQueue.enumerated() {
            for (j, rect) in rectanglesQueue.enumerated() {
                if j > i  && currentRect.matches(rect.rectangleFeature) {
                    currentRect.matchingScore += 1
                }
            }
        }
    }
    
}
