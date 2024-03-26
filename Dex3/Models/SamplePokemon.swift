//
//  SamplePokemon.swift
//  Dex3
//
//  Created by Justin Maronde on 3/26/24.
//

import Foundation
import CoreData

struct SamplePokemon {
    static let samplePokemon = {
        let context = PersistenceController.preview.container.viewContext
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.fetchLimit = 1
        let results = try! context.fetch(fetchRequest)
        
        return results.first!
    }()
}
