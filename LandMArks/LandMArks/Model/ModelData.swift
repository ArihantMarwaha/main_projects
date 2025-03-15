//
//  ModelData.swift
//  LandMArks
//
//  Created by Arihant Marwaha on 02/12/24.
//

import Foundation



@Observable
class ModelData {
    
    //array of landmarks that calls the load function created by us to retrive data from the file
    var landmarks: [Landmark] = load("landmarkData.json")
    var hikes: [Hike] = load("hikeData.json")
    
    // include an instance of the user profile that persists even after the user dismisses the profile view
    var profile = Profile.default
    
    //new computed features array, which contains only the landmarks that have isFeatured set to true.
    var features: [Landmark] {
           landmarks.filter { $0.isFeatured }
       }

    //addingcomputed categories dictionary, with category names as keys, and an array of associated landmarks for each key
    var categories: [String: [Landmark]] {
            Dictionary(
                grouping: landmarks,
                by: { $0.category.rawValue }
            )
        }
    
}


//function to load data
func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    //find the file using the url
    //load that file from the said url
    //decode the follwing data using a jason format 


    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
            
    else {
        //finding the file
        fatalError("Couldn't find \(filename) in main bundle.")
    }


    do {
        data = try Data(contentsOf: file)
    } catch {
        //loading the file
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }


    do {
        let decoder = JSONDecoder()
        //decoding and reurning the file for refernce and turning it into a data structure for our use
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
