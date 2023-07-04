//
//  Setting.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/29.
//

import RealmSwift

class OshiSetting: RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String?
    @objc dynamic var imageColorCd: Int = 0
    @objc dynamic var createDate = Date()
    @objc dynamic var createUser: String = "system"
    @objc dynamic var updateDate = Date()
    @objc dynamic var updateUser: String = "system"

    override static func primaryKey() -> String? {
        return "id"
    }

    enum Types: String {
        case id
        case name
        case imageColorCd
        case createDate
        case createUser
        case updateDate
        case updateUser
    }
}
