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
            Image("home_asset")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width)
                .opacity(0.5)
            
            VStack{
                Image("game_over")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.height)
                    .padding(.horizontal, 10)
                
//                pengecekan di host
                if matchManager.localPlayerData.role == Role.host{
//                    kalau host menang
                    if matchManager.coreGameData?.endOfGame?.gameWinner == matchManager.localPlayerData.gamePlayerID {
                        
                        Image("winner_biru") //kalo biru, "winner_biru"
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width / 5)
                            .padding(.horizontal, 10)
                        
                    }else{
                        Image("winner_kuning") //kalo biru, "winner_biru"
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width / 5)
                            .padding(.horizontal, 10)
                    }
                   
                }else{
                    
//                    pengecekan di player
//                    kalau player menang
                    
                    if matchManager.coreGameData?.endOfGame?.gameWinner == matchManager.localPlayerData.gamePlayerID {
                        
                        
                        Image("winner_kuning") //kalo biru, "winner_biru"
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width / 5)
                            .padding(.horizontal, 10)
                        
                    }else{
                        Image("winner_biru") //kalo biru, "winner_biru"
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width / 5)
                            .padding(.horizontal, 10)
                    }

                }
                
                
            }
            
            VStack{
                HStack{
                    Button(action: {
                        matchManager.handleBackToHome()
                    }, label: {
                        Image("home_btn")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                    })
                    .padding(30)
                    Spacer()
                }
                Spacer()

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
