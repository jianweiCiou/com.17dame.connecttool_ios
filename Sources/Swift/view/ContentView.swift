//
//  File.swift
//  
//
//  Created by Jianwei Ciou on 2024/3/10.
//

import SwiftUI

@available(iOS 13.0, *)
struct ContentView: View {
    @StateObject var webViewModel = WebViewModel(url: "")
    
    var body: some View {
        
        if #available(iOS 14.0, *) {
            WebViewContainer(webViewModel: webViewModel)
                .ignoresSafeArea()
        } else {
            // Fallback on earlier versions
        }
    }
}

#if DEBUG
@available(iOS 13.0, *)
struct ContentView_Previews :
    PreviewProvider {
    static var previews :some View {
        ContentView()
    }
}
#endif

