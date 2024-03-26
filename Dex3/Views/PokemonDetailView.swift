//
//  PokemonDetailView.swift
//  Dex3
//
//  Created by Justin Maronde on 3/26/24.
//

import SwiftUI
import CoreData

struct PokemonDetailView: View {
    @EnvironmentObject var pokemon: Pokemon
    var body: some View {
        Text("Hello world")
    }
}

#Preview {
    PokemonDetailView()
        .environmentObject(SamplePokemon.samplePokemon)
}
