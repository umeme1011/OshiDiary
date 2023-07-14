//
//  Schedule.swift
//  OshiDiary
//
//  Created by umeme on 2023/07/14.
//

import RealmSwift

class Schedule: RealmSwift.Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var iconCd: Int = 0
    @objc dynamic var iconColorCd: Int = 0
    @objc dynamic var allDay: Bool = true
    @objc dynamic var startDate: Date = Date()
    @objc dynamic var startDateStr: String = ""
    @objc dynamic var startTimeStr: String = ""
    @objc dynamic var endDate: Date = Date()
    @objc dynamic var endDateStr: String = ""
    @objc dynamic var endTimeStr: String = ""
    @objc dynamic var repeatCd: Int = 0
    @objc dynamic var notificationCd: Int = 0
    @objc dynamic var memo: String = ""
    @objc dynamic var createDate = Date()
    @objc dynamic var createUser: String = "system"
    @objc dynamic var updateDate = Date()
    @objc dynamic var updateUser: String = "system"

    override static func primaryKey() -> String? {
        return "id"
    }

    enum Types: String {
        case id
        case title
        case iconCd
        case iconColorCd
        case allDay
        case startDate
        case startDateStr
        case startTimeStr
        case endDate
        case endDateStr
        case endTimeStr
        case repeatCd
        case notificationCd
        case memo
        case createDate
        case createUser
        case updateDate
        case updateUser
    }
}
