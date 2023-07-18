//
//  ScheduleDetail.swift
//  OshiDiary
//
//  Created by umeme on 2023/07/17.
//

import RealmSwift

class ScheduleDetail: RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var scheduleId: Int = 0
    @objc dynamic var dayNo: Int = 0
    @objc dynamic var date: Date = Date()
    @objc dynamic var ymString: String = ""
    @objc dynamic var createDate = Date()
    @objc dynamic var createUser: String = "system"
    @objc dynamic var updateDate = Date()
    @objc dynamic var updateUser: String = "system"

    override static func primaryKey() -> String? {
        return "id"
    }

    enum Types: String {
        case id
        case scheduleId
        case dayNo
        case date
        case ymString
        case createDate
        case createUser
        case updateDate
        case updateUser
    }
}

