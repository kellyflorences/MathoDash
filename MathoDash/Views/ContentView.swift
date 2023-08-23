//
//  ContentView.swift
//  MathoDash
//
//  Created by Kelly Florences Tanjaya on 01/08/23.
//

import SwiftUI
import SpriteKit
import CoreMotion
import GameKit

struct ContentView: View {
    @StateObject var matchManager = MatchManager()
    @State var scale = 1.0
    
    var body: some View {
        NavigationStack{
            if matchManager.gameState.rawValue == 0 {
                ZStack{
                    //            if matchManager.isGameOver{
                    //                GameOverView(matchManager: matchManager)
                    //            } else{
                    //                GameView(matchManager: matchManager)
                    //            }
                    
                    
                    Image("home_asset")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width)
                    
                    VStack{
                        Image("home_title")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width * 4/5)
                        
                        Button{
                            matchManager.matchMaking()
                        } label: {
                            Image("home_button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250.0)
                        }
                        .scaleEffect(scale)
                        .onAppear {
                            let baseAnimation = Animation.easeInOut(duration: 2)
                            let repeated = baseAnimation.repeatForever(autoreverses: true)

                            withAnimation(repeated) {
                                scale = 0.9
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 50)
                    
                }.onAppear{
                    matchManager.authenticateUser()
                }
                .background(Color("darkPurple"))
            } else if matchManager.gameState.rawValue > 0 &&  matchManager.gameState.rawValue  < 3 {
                GameView(matchManager: matchManager)
            }else{
                //                panggil game over view
                GameOverView(matchManager: matchManager)
            }
            
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
