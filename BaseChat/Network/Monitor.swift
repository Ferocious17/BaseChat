//
//  Monitor.swift
//  BaseChat
//
//  Created by Caner Kaya on 08.01.21.
//

import Foundation
import Network

class Monitor
{
    private static func CheckInternet()
    {
        //leaving the constructor empty checks for any type of internet connection
        //We want to check both cellular and wifi so we leave it empty
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied
            {
                DispatchQueue.main.async
                {
                    //...
                }
            }
            else
            {
                DispatchQueue.main.async
                {
                    //...
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}
