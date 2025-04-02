//
//  Search.swift
//  WeatherApp
//
//  Created by User on 2025-03-29.
//

struct Search: Decodable {
    var location: String;
    var temperature: Double;
    var scale: String;
    var iconSystemName: String;
}
