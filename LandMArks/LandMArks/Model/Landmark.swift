//
//  Landmark.swift
//  LandMArks
//
//  Created by Arihant Marwaha on 02/12/24.
//

import Foundation
import SwiftUI
import CoreLocation

struct Landmark: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var park: String
    var state: String
    var description: String
    var isFavorite: Bool
    var isFeatured: Bool
    
    //category addition
    var category : Category
    
    enum Category : String,CaseIterable,Codable{
        case lakes = "Lakes"
        case rivers = "Rivers"
        case mountains = "Mountains"
    }
    
    //used for reading the image names
    private var imageName: String
    
        var image: Image {
            Image(imageName)
        }
    
    //used for retreiving the coordinates for the app
    
    struct Coordinates: Hashable, Codable {
        var latitude: Double
        var longitude: Double
    }
    
    private var coordinates: Coordinates
    
    var locationCoordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude)
        }
    
        
    
}
