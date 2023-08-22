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
//    @State var isShrunk = false
    
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
                            //                        Text("Multiplayer")
                            Image("home_button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250.0)
                        }
//                        .frame(width: isShrunk ? 50 : 100, height: isShrunk ? 50 : 100)
//                        .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true))
//                        .onTapGesture {
//                            isShrunk.toggle()
//                        }
                        
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
            }
            
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
