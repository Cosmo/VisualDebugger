//
//  CoordinateSystem.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import UIKit

public class CoordinateSystem : CALayer {
    
    public let minWidth: CGFloat = 250
    
    public var type:CoordinateSystemType
    public var area:CGRect
    public var segmentLength:CGFloat = 50
    public var scale: CGFloat = 1.5
    public var numSegments:Int
    public var showOrigin:Bool
    
    // for transform values to current coordinate system space
    public internal(set) var matrix = CGAffineTransform.identity
    
    internal var colorIndex:Int = 0
    internal var minSegmentLength: CGFloat {
        return minWidth / CGFloat(numSegments)
    }
    
    public init(type: CoordinateSystemType, area:CGRect, scale:CGFloat, numSegments:Int, showOrigin:Bool, precision:Int = 5) {
        self.type = type
        self.area = area
        self.scale =  scale
        self.numSegments = numSegments
        self.showOrigin = showOrigin
        super.init()
        
        let rect = showOrigin ? self.getRectFromOrigin(by: area) : area
        let maxValue = max(rect.size.width, rect.size.height)
        let segmentValue = CGFloat(getDivision(Double(maxValue), segments: numSegments))
        
        let xAxisData = AxisData(min: rect.minX, max: rect.maxX, segmentValue: segmentValue)
        let yAxisData = AxisData(min: rect.minY, max: rect.maxY, segmentValue: segmentValue)
        
        let valueRect = CGRect(x: xAxisData.startValue, y: yAxisData.startValue, width: xAxisData.lengthValue, height: yAxisData.lengthValue)
        let xAxisY: CGFloat = (valueRect.minY < 0 && valueRect.maxY >= 0) ? 0 : yAxisData.startValue
        let yAxisX: CGFloat = (valueRect.minX < 0 && valueRect.maxX >= 0) ? 0 : xAxisData.startValue
        
        // calculate axis segments in value space
        let xAxisSegment = AxisSegment(start: CGPoint(x: xAxisData.startValue, y: xAxisY), end: CGPoint(x: xAxisData.endValue, y: xAxisY))
        let yAxisSegment = AxisSegment(start: CGPoint(x: yAxisX, y: yAxisData.startValue), end: CGPoint(x: yAxisX, y: yAxisData.endValue))
        
        // get axis labels and transform to render space
        let precision = calculatePrecision(Double(segmentValue))
        let formater = NumberFormatter(precision: precision)
        var xAxisLabels = xAxisSegment.getLabels(axis: .x, segmentValue: segmentValue, numSegments: xAxisData.numSegments, numFormater: formater)
        var yAxisLabels = yAxisSegment.getLabels(axis: .y, segmentValue: segmentValue, numSegments: yAxisData.numSegments, numFormater: formater)
        
        // calculate the proper segment length
        let xLabelBounds = xAxisLabels.reduce(CGRect.zero) { $0.union($1.label.bounds) }
        self.segmentLength = xLabelBounds.width < minSegmentLength ? minSegmentLength : xLabelBounds.width
        self.segmentLength = ceil(segmentLength * scale)
        
        // calculate the matrix for transform value from value space to render space
        let scale = self.segmentLength / segmentValue
        self.matrix = CGAffineTransform(translationX: -valueRect.origin.x, y: -valueRect.origin.y)
        self.matrix.scaleBy(x: scale, y: scale)
        
        if self.type == .yUp {
            let renderHeight = valueRect.height * scale
            self.matrix.scaleBy(x: 1, y: -1)
            self.matrix.translateBy(x: 0, y: renderHeight)
        }
        
        // get axis labels and transform to render space
        xAxisLabels = xAxisLabels * self.matrix
        yAxisLabels = yAxisLabels * self.matrix
        
        // render axis to self
        let thickness: CGFloat = 8
        renderAxis(axis: .x, coordinate: self.type, labels: xAxisLabels, labelOffset: ceil(xLabelBounds.height), thickness: thickness, to: self)
        renderAxis(axis: .y, coordinate: self.type, labels: yAxisLabels, labelOffset: ceil(xLabelBounds.width/2) + thickness, thickness: thickness, to: self)
        
        // setup frame
        self.frame = valueRect.applying(self.matrix)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getRectFromOrigin(by bounds:CGRect) -> CGRect {
        let minX = min(0, bounds.minX)
        let minY = min(0, bounds.minY)
        let maxX = max(0, bounds.maxX)
        let maxY = max(0, bounds.maxY)
        return CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
    }
    
    public func getNextColor() -> AppColor {
        let color = AppColor.get(self.colorIndex % colors.count)
        self.colorIndex += 1
        return color
    }
    
    public func render(object: Debuggable, color: AppColor? = nil) {
        object.debug(in: self, with: self.matrix, color: color ?? getNextColor())
    }
}







