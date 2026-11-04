// GameType.swift
import SwiftUI
import Foundation

enum GameType: String {   // raw value: remembering the last game played
    case game1
    case game2
    case game3
    case game4
    case game5
    case game6
    case game6Started // New case for Game 6 after selections are made.
    case game7
    case irSpectra   // Organic Games Plus: Name That Spectrum
    case irTiles     // Organic Games Plus: IR tile match
    case msPatterns  // Organic Games Plus: mass spec Name That Pattern
    case msTiles     // Organic Games Plus: mass spec tile match
    case rxnPredict  // Organic Games Plus: Ch. 11 Predict the Product
    case rxnReagents // Organic Games Plus: Ch. 11 Name the Reagents
    case rxnTiles    // Organic Games Plus: Ch. 11 Reaction Tiles (choose a pile)
    case rxnTilesAlkene, rxnTilesPropyne, rxnTilesButyne
    case rxn9Predict, rxn9Reagents, rxn9Tiles   // Organic Games Plus: Ch. 9–10 reaction summary
    case aromaticRoadmap, aromaticDirectors   // Organic Games Plus: Ch. 21 Benzene Roadmap, Director Blitz
    case mechanism   // Organic Games Plus: Which Mechanism? (Ch. 9, SN1/SN2/E1/E2)
    case synthesis   // Organic Games Plus: Synthesis Steps (multistep routes from Ch. 11 problems)
    case chiralBlitz, spotStereocenters   // Organic Games Plus: Ch. 7 Chiral or Achiral?, Spot the Stereocenters
    case isomerMatch // Organic Games Plus: Ch. 7 Isomer Match
    case fischerRS   // Organic Games Plus: Ch. 7 Fischer R and S
}
