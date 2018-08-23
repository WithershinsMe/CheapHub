//
//  CountriesTableViewController.swift
//  CheapHub
//
//  Created by GK on 2018/8/23.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import UIKit


private let maxVisibleContentHeight: CGFloat = 400

private let numberOfCountries = 20
private let countries = Locale.isoRegionCodes.prefix(numberOfCountries).map(Locale.current.localizedString(forRegionCode:))
private let reuseIdentifier = "cell"

class CountriesTableViewController: UITableViewController, BottomSheet {
    
    var bottomSheetDelegate: BottomSheetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.contentInset.top = maxVisibleContentHeight
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.decelerationRate = 1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bottomSheetDelegate?.bottomSheet(self, didScrollTo: tableView.contentOffset)
        
        // Make sure the content is always at least as high as the table view, to prevent the sheet
        // getting stuck half-way.
        if tableView.contentSize.height < tableView.bounds.height {
            tableView.contentSize.height = tableView.bounds.height
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)!
        cell.textLabel?.text = countries[indexPath.row]
        cell.backgroundColor = .clear
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Scroll view delegate
    
  
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee.y
        let pulledUpOffset: CGFloat = 0
        let pulledDownOffset: CGFloat = -maxVisibleContentHeight
        
        if (pulledDownOffset...pulledUpOffset).contains(targetOffset) {
            let mid = pulledDownOffset / 2
            
            if velocity.y == 0 {
                if (mid ... pulledUpOffset).contains(targetOffset) {
                    targetContentOffset.pointee.y = pulledUpOffset
                } else {
                    targetContentOffset.pointee.y = pulledDownOffset
                }
            }
            if velocity.y < 0 {
                if (mid ... pulledUpOffset).contains(targetOffset) {
                    targetContentOffset.pointee.y = pulledUpOffset
                } else {
                    targetContentOffset.pointee.y = pulledDownOffset
                }
             //   targetContentOffset.pointee.y = pulledDownOffset
            } else {
                if (mid ... pulledUpOffset).contains(targetOffset) {
                    targetContentOffset.pointee.y = pulledUpOffset
                } else {
                    targetContentOffset.pointee.y = pulledDownOffset
                }
               // targetContentOffset.pointee.y = pulledUpOffset
            }
        }
    }
}
