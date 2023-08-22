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
        ZStack{
            VStack{
                Image("game_over")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.height)
                
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(Color("darkPurple"))

    }
}

struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        GameOverView()
    }
}
