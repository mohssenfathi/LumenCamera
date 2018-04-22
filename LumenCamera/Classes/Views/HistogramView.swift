//
//  HistogramView.swift
//  LumenCamera
//
//  Created by Mohssen Fathi on 3/13/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit
import Charts

class HistogramView: LineChartView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func update(with data: (red: [UInt32], green: [UInt32], blue: [UInt32], alpha: [UInt32])) {

        var red = data.red
        var green = data.green
        var blue = data.blue
        
        redData.values = chartEntries(from: &red)
        greenData.values = chartEntries(from: &green)
        blueData.values = chartEntries(from: &blue)
        
        DispatchQueue.main.async {
            self.data = LineChartData(dataSets: [self.redData, self.greenData, self.blueData])
        }
    }
    
    func commonInit() {
    
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.drawLabelsEnabled = false
        xAxis.spaceMin = 0.0
        xAxis.spaceMax = 0.0
        rightAxis.enabled = false
        leftAxis.enabled = false
        minOffset = 0.0
        drawGridBackgroundEnabled = false
        drawBordersEnabled = false
        chartDescription?.enabled = false
        pinchZoomEnabled = false
        dragEnabled = false
        legend.enabled = false
        
        redData = dataSet(with: [], color: .histogramRed)
        greenData = dataSet(with: [], color: .histogramGreen)
        blueData = dataSet(with: [], color: .histogramBlue)
        
        data = LineChartData(dataSets: [redData, greenData, blueData])
    }
    
    func chartEntries(from values: inout [UInt32]) -> [ChartDataEntry] {
        return values.enumerated().map {
            ChartDataEntry(x: Double($0.offset), y: Double($0.element))
        }
    }
    
    func dataSet(with values: [UInt32], color: UIColor) -> LineChartDataSet {
        let dataSet = LineChartDataSet(
            values: values.enumerated().map { ChartDataEntry(x: Double($0.offset), y: Double($0.element)) },
            label: nil
        )
        
        dataSet.drawCirclesEnabled = false
        dataSet.setColor(color)
        dataSet.fillColor = color
        dataSet.fillAlpha = 0.5
        dataSet.drawFilledEnabled = true
        
        return dataSet
    }
    
    var redData: LineChartDataSet!
    var greenData: LineChartDataSet!
    var blueData: LineChartDataSet!
    
}
