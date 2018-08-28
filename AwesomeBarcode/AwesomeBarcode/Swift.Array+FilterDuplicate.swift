//
//  Swift.Array+FilterDuplicate.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2018/7/11.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import Foundation


extension Array {
    func filterDuplicate<E: Equatable>(_ customFilter: (Element) -> E) -> [Element] {
        var ret = [Element]()
        for val in self {
            let key = customFilter(val)
            if !ret.map({customFilter($0)}).contains(key) {
                ret.append(val)
            }
        }
        return ret
    }
}
