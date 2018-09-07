//
//  User.swift
//  CheapHub
//
//  Created by GK on 2018/8/18.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import Foundation

struct User: DictionaryValue {
    let loginname: String
    let id: Int
    var nodeID: String
    var avatarURL: String
    var type: String
    var name: String
    var blog: String
    var location: String
    var email: String
    var bio: String
    var hirable: Bool
    var publicRepos: Int
    var publicgists: Int
    var followers: Int
    var following: Int
    var created_at: String
    var updated_at: String
}

extension User: Decodable {
    enum UserCodingKeys: String, CodingKey {
        case loginname = "login"
        case id
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case type
        case name
        case blog
        case location
        case email
        case bio
        case hirable
        case publicRepos = "public_repos"
        case publicgists = "public_gists"
        case followers
        case following
        case created_at
        case updated_at
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: UserCodingKeys.self)
      
        loginname = try container.decodeWrapper(key: .loginname, defaultValue: "")
        id = try container.decodeWrapper(key: .id, defaultValue: 0)
        nodeID = try container.decodeWrapper(key: .nodeID,defaultValue:"")
        avatarURL = try container.decodeWrapper(key: .avatarURL, defaultValue: "")
        type = try container.decodeWrapper(key: .type, defaultValue: "")
        name = try container.decodeWrapper(key: .name, defaultValue: "")
        blog = try container.decodeWrapper(key: .blog, defaultValue: "")
        location = try container.decodeWrapper(key: .location, defaultValue: "")
        email = try container.decodeWrapper(key: .email, defaultValue: "")
        bio = try container.decodeWrapper(key: .bio, defaultValue: "")
        hirable = try container.decodeWrapper(key: .hirable, defaultValue: false)
        publicRepos = try container.decodeWrapper(key: .publicRepos, defaultValue: 0)
        publicgists = try container.decodeWrapper(key: .publicgists, defaultValue: 0)
        followers = try container.decodeWrapper(key: .followers, defaultValue: 0)
        following = try container.decodeWrapper(key: .following, defaultValue: 0)
        created_at = try container.decodeWrapper(key: .created_at, defaultValue: "")
        updated_at = try container.decodeWrapper(key: .updated_at, defaultValue: "")
    }
}

extension KeyedDecodingContainer {
    func decodeWrapper<T>(key: K, defaultValue: T) throws -> T
        where T : Decodable {
            return try decodeIfPresent(T.self, forKey: key) ?? defaultValue
    }
}
