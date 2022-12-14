//
//  NetworkRequestConvertable.swift
//  SixtApp
//
//  Created by Yawar Ali on 23/03/2022.
//

import Foundation

public protocol NetworkRequestConvertable {
    
    typealias RequestParameters = [String: String]
    
    var params: RequestParameters { get set }
}
