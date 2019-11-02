//
//  PlotPagesViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 10/29/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit
import Charts

class PlotPagesView: UIView {
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = true
        return scroll
    }()
    var pageControl: UIPageControl = {
        let page = UIPageControl()
        
        page.translatesAutoresizingMaskIntoConstraints = false
        return page
    }()
    var plots: [LineChartView]! = []
    var isAutoScrollEnabled: Bool = true
    var visibleInterval: TimeInterval = 30
    var lastUpdatedData: LineChartDataSet?
    
    func initialize(){
        //  Let's set up the scroll view and a single chart
        setupUI()
    }
    
    func initialize(data: [[[Double]]]){
        //  Use this function to initialize with data
    }
    
    func setupUI(){
        //  Adjust the UI
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
        scrollView.delegate = self
        
        //  Set up the scroll view
        self.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        scrollView.layer.borderWidth = 6
        scrollView.layer.borderColor = UIColor.green.cgColor
        
        //  Set up page control
        self.addSubview(pageControl)
        pageControl.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        pageControl.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        pageControl.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        pageControl.layer.borderWidth = 5
        pageControl.layer.borderColor = UIColor.red.cgColor
        
        //  Set the layout subviews
        self.layoutSubviews()
        self.layoutIfNeeded()
        
        //  Now lets add plots
        addPlots(count: 5)
        
        // Init the page control w/handler for when it's scrolled
        self.pageControl.numberOfPages = plots.count
        self.pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(self.changePage(_:)), for: UIControl.Event.valueChanged)
    }
    
    func addPlots(count: Int){
        //  Get size constraints of the graph
        print("Adding the graphs...")
        print(self.scrollView.frame.size)
        print(self.frame.origin.y)
        
        for i in 0...count-1{
            print("Plot: \(i+1)")
            
            //  Create the generic plot
            let plot = formattedPlot()
            plot.translatesAutoresizingMaskIntoConstraints = false
            
            //  Add the plot to list of plots and add to subview
            plots.append(plot)
            self.scrollView.addSubview(plot)
            print(scrollView.frame)
            
            
            //  Start adding constraints
            plot.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            plot.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            plot.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
            plot.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
            
            if i == 0{
                //  Just add constraint to left side for now
                plot.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            }
            else if i == count-1{
                //  At the end, so add constraint to right side = scrollview
                plot.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
                plot.leadingAnchor.constraint(equalTo: plots[i-1].trailingAnchor).isActive = true
                plots[i-1].trailingAnchor.constraint(equalTo: plot.leadingAnchor).isActive = true
            }
            else{
                plot.leadingAnchor.constraint(equalTo: plots[i-1].trailingAnchor).isActive = true
                plots[i-1].trailingAnchor.constraint(equalTo: plot.leadingAnchor).isActive = true
            }
            self.scrollView.layoutSubviews()
            self.scrollView.layoutIfNeeded()
            print(plot.frame)
            
        }
        
        //  Adjust the scrollview content size
        self.pageControl.numberOfPages = plots.count
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(plots.count), height: scrollView.frame.height)
    }
    
    func formattedPlot() -> LineChartView{
        //  Create the graph and add some preferences
        let plot = LineChartView()
        plot.borderLineWidth = 1
        plot.borderColor = .blue
        plot.translatesAutoresizingMaskIntoConstraints = false
        plot.delegate = self
        plot.chartDescription?.enabled = false
        plot.xAxis.granularityEnabled = true
        plot.xAxis.granularity = 5
        plot.leftAxis.drawZeroLineEnabled = true
        plot.legend.enabled = false
        plot.noDataText = "No data received"
        plot.layer.borderColor = UIColor.blue.cgColor
        plot.layer.borderWidth = 4
        
        return plot
    }

    //  MARK: - Changing Page
    @objc func changePage(_ sender: Any){
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
    func notifyDataSetChanged(index: Int, all: Bool){
        if all {
            //  Want to update all
            for i in 0...plots.count-1{
                notifyDataSetChanged(index: i, all: false)
            }
            return
        }
        
        //  Notify that the data for this plot has changed
        plots[index].data?.notifyDataChanged()
        plots[index].notifyDataSetChanged()
        
        //  Make sure the visible range is accurate
        plots[index].setVisibleXRangeMaximum(visibleInterval)
        plots[index].setVisibleXRangeMinimum(visibleInterval)
        
        guard let dataSet = lastUpdatedData else { return }

        //  Need to adjust view depending on autoscroll
        if isAutoScrollEnabled {
            //let xOffset = Double(dataSet.entryCount) - (context.numEntriesVisible-1)
            let xOffset = (dataSet.entries.last?.x ?? 0) - (visibleInterval-1)
            plots[index].moveViewToX(xOffset)
        }
    }
    

}

//  MARK: - Scroll View Delegate
extension PlotPagesView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}

//  MARK: - Chart View Delegate
extension PlotPagesView: ChartViewDelegate{
    
}
