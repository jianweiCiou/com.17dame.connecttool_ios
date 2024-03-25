//
//  File.swift
//  
//
//  Created by Jianwei Ciou on 2024/3/10.
//

import Foundation

@available(iOS 13.0, *)
public class WebViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var shouldGoBack: Bool = false
    @Published var title: String = ""

    var url: String

    init(url: String) {
        self.url = url
    }
}
