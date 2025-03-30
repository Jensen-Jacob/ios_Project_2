//
//  Location.swift
//  WeatherApp
//
//  Created by User on 2025-03-28.
//


struct Location: Decodable {
    let name: String;
    let region: String;
    let country: String;
    let lat: Double;
    let lon: Double;
    let tz_id: String;
    let localtime_epoch: UInt64;
    let localtime: String;
}



