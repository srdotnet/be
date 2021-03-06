//
//  UserMappingProvider.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class UserMappingProvider: NSObject
{
    class func loginRequestMapping()->RKObjectMapping
    {
        let mapping=RKObjectMapping.request()
        mapping?.addAttributeMappings(from: ["id", "token", "secret", "type", "apn", "password", "username"])
        
        return mapping!
    }
    
    class func loginResponseMapping()->RKObjectMapping
    {
        let mapping=RKObjectMapping(for:NSMutableDictionary.self)
        mapping?.addAttributeMappings(from: ["session"])
        
        let userMapping=UserMappingProvider.userResponseMapping()
        let userRelationshipMapping=RKRelationshipMapping(fromKeyPath:"user", toKeyPath:"user", with:userMapping)
        mapping?.addPropertyMapping(userRelationshipMapping)
        
        return mapping!
    }
    
    class func weChatLoginResponseMapping()->RKObjectMapping
    {
        let mapping=RKObjectMapping(for:NSMutableDictionary.self)
        mapping?.addAttributeMappings(from: ["access_token", "expires_in", "refresh_token", "openid", "scope", "unionid"])
        
        return mapping!
    }
    
    class func userRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.request()
        
        mapping?.addAttributeMappings(from: [
            "id"        : "id",
            "name"      : "name",
            "sname"     : "sname",
            "avatar"    : "avatar",
            "likes"     : "likes",
            "recent"    : "recent",
            "followers" : "followers",
            "following" : "following",
            "streams"   : "streams",
            "blocked"   : "blocked",
            "desc"      : "description",
            "isLive"    : "islive",
            "isFollowed": "isfollowed",
            "isBlocked" : "isblocked",
            "subscription" : "subscription"
        ])
        
        return mapping!
    }
    
    class func userResponseMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: User.self)
        mapping?.addAttributeMappings(from: [
            "id"        : "id",
            "name"      : "name",
            "sname"     : "sname",
            "avatar"    : "avatar",
            "likes"     : "likes",
            "recent"    : "recent",
            "streams"   : "streams",
            "followers" : "followers",
            "following" : "following",
            "blocked"   : "blocked",
            "description" : "desc",
            "islive"    : "isLive",
            "isfollowed": "isFollowed",
            "isblocked" : "isBlocked",
            "subscription" : "subscription"
            ])
                
        return mapping!
    }
}
