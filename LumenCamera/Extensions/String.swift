//
//  String.swift
//  Lumen
//
//  Created by Mohssen Fathi on 2/4/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import Foundation

extension String {

    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
