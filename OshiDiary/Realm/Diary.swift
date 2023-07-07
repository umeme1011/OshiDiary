//
//  Diary.swift
//  OshiDiary
//
//  Created by umeme on 2023/07/06.
//

import RealmSwift

class Diary: RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var date: Date = Date()
    @objc dynamic var dateString: String = ""
//    @objc dynamic var year: Int = 0
//    @objc dynamic var month: Int = 0
//    @objc dynamic var day: Int = 0
//    @objc dynamic var week: Int = 0
//    @objc dynamic var hour: Int = 0
//    @objc dynamic var minute: Int = 0
//    @objc dynamic var second: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var content: String = ""
    @objc dynamic var createDate = Date()
    @objc dynamic var createUser: String = "system"
    @objc dynamic var updateDate = Date()
    @objc dynamic var updateUser: String = "system"

    override static func primaryKey() -> String? {
        return "id"
    }

    enum Types: String {
        case id
        case date
        case dateString
//        case year
//        case month
//        case day
//        case week
//        case hour
//        case minuts
//        case second
        case title
        case content
        case createDate
        case createUser
        case updateDate
        case updateUser
    }
}

