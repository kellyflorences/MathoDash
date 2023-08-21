//
//  GameOverView.swift
//  MathoDash
//
//  Created by Kelly Florences Tanjaya on 02/08/23.
//

import SwiftUI

struct GameOverView: View {
    @StateObject var matchManager = MatchManager()
    
    var body: some View {
        Text("Game over!")
    }
}

struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        GameOverView()
    }
}
