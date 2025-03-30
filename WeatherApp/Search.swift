//
//  Search.swift
//  WeatherApp
//
//  Created by User on 2025-03-29.
//

struct Search: Decodable {
    let location: String;
    let temperature: Double;
    let scale: String;
    let iconSystemName: String;
}
