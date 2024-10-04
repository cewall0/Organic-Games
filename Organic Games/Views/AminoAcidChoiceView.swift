//
//  AminoAcidChoiceView.swift
//  OrganicGames
//
//  Created by Chad Wallace on 9/13/24.
//

import SwiftUI
import Observation

struct AminoAcidChoiceView: View {
    @Environment(GameViewModel.self) private var viewModel
    @State private var selectedOptions: Set<String> = [] // Use Set for uniqueness
    @Binding var path: NavigationPath

    let options = ["Chemical Structure", "Name", "3-letter abbreviation", "1-letter abbreviation"]

    var body: some View {
        VStack {
            Text("Select Two Options")
                .font(.headline)
                .padding()
            

            List(options, id: \.self) { option in
                HStack {
                    Text(option)
                    Spacer()
                    if selectedOptions.contains(option) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleSelection(option)
                }
            }

            Spacer()

            Button("Start Game") {
                         if selectedOptions.count == 2 {
                             // Save the selected options to the viewModel
                             viewModel.aminoAcidSelections = Array(selectedOptions)
                             
                             // Navigate directly to GameView for game6
                             
                             path.append(GameType.game6Started)
                         }
                     }
                     .disabled(selectedOptions.count != 2)
                     .padding()
                     .background(selectedOptions.count == 2 ? Color.blue : Color.gray)
                     .foregroundColor(.white)
                     .cornerRadius(10)
                     .shadow(color: .gray, radius: 4, x: 0, y: 2)

            BannerAdView(adFormat: UIDevice.current.userInterfaceIdiom == .pad ? .leaderboard : .standardBanner, onShow: { print("Show Banner") })
                 }
                .onAppear(perform: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            requestPermission()
                        }
                    })

                 .padding()
    }

    private func toggleSelection(_ option: String) {
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            if selectedOptions.count < 2 {
                selectedOptions.insert(option)
            }
        }
    }
}
