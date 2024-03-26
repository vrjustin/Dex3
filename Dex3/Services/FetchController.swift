//
//  FetchController.swift
//  Dex3
//
//  Created by Justin Maronde on 3/25/24.
//

import Foundation
import CoreData

struct FetchController {
    enum NetworkError: Error {
        case badURL, badResponse, badData
    }
    
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon")!
    
    func fetchAllPokemon() async throws -> [TempPokemon]? {
        
        if hasPokemonLocal() {
            return nil
        }
        
        var allPokemon: [TempPokemon] = []
        
        var fetchComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        fetchComponents?.queryItems = [URLQueryItem(name: "limit", value: "386")]
        
        guard let fetchURL = fetchComponents?.url else {
            throw NetworkError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        guard let pokeDict = try JSONSerialization.jsonObject(with: data) as? [String : Any], let pokeDex = pokeDict["results"] as? [[String : String]] else {
            throw NetworkError.badData
        }
        
        for pokemon in pokeDex {
            if let url = pokemon["url"] {
                allPokemon.append(try await fetchPokemon(from: URL(string: url)!))
            }
        }
        
        return allPokemon
    }
    
    private func fetchPokemon(from url: URL) async throws -> TempPokemon {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        let tempPokemon = try JSONDecoder().decode(TempPokemon.self, from: data)
        
        print("Fetched Pokemon: \(tempPokemon.id) :: \(tempPokemon.name)")
        
        return tempPokemon
    }
    
    private func hasPokemonLocal() -> Bool {
        let context = PersistenceController.shared.container.newBackgroundContext()
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        //Create a predicate to reach into core data and see if we have Pokemon objects with id of 1 and 386. If we
        //do that means we already fetched from online. So return true if that's the case.
        fetchRequest.predicate = NSPredicate(format: "id IN %@", [1, 386])
        
        do {
            let checkPokemon = try context.fetch(fetchRequest)
            if checkPokemon.count == 2 {
                return true
            }
        } catch {
            print("fetch failed: \(error)")
            return false
        }
        
        return false
    }
}
