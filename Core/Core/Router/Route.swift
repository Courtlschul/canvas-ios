//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

public struct Route: Equatable {
    public let url: URLComponents

    init(_ path: String) {
        url = .parse(path)
    }

    public static let courses = Route("/courses")

    public static func course(_ courseID: String) -> Route {
        return Route("/courses/\(courseID)")
    }

    public static func course(_ courseID: String, user userID: String) -> Route {
        return Route("/courses/\(courseID)/users/\(userID)")
    }

    public static func course(_ courseID: String, assignment assignmentID: String) -> Route {
        return Route("/courses/\(courseID)/assignments/\(assignmentID)")
    }

    public static func assignments(forCourse courseID: String) -> Route {
        return Route("/courses/\(courseID)/assignments")
    }

    public static func submission(forCourse courseID: String, assignment assignmentID: String, user userID: String) -> Route {
        return Route("/courses/\(courseID)/assignments/\(assignmentID)/submissions/\(userID)")
    }

    public static func syllabus(courseID: String, includeAssignmentPath: Bool = true) -> Route {
        return Route("/courses/\(courseID)\(includeAssignmentPath ? "/assignments" : "")/syllabus")
    }

    public static let groups = Route("/groups")

    public static func group(_ groupID: String) -> Route {
        return Route("/groups/\(groupID)")
    }

    public static func pages(forCourse courseID: String) -> Route {
        return Route("/courses/\(courseID)/pages")
    }

    public static func pages(forGroup groupID: String) -> Route {
        return Route("/groups/\(groupID)/pages")
    }

    public static func quizzes(forCourse courseID: String) -> Route {
        return Route("/courses/\(courseID)/quizzes")
    }

    public static func quiz(forCourse courseID: String, quizID: String) -> Route {
        return Route("/courses/\(courseID)/quizzes/\(quizID)")
    }

    public static func takeQuiz(forCourse courseID: String, quizID: String) -> Route {
        return Route("/courses/\(courseID)/quizzes/\(quizID)/take")
    }

    public static let profileObservees = Route("/profile/observees")

    public static let logs = Route("/logs")

    public static func modules(forCourse courseID: String) -> Route {
        return Route("/courses/\(courseID)/modules")
    }

    public static func module(forCourse courseID: String, moduleID: String) -> Route {
        return Route("/courses/\(courseID)/modules/\(moduleID)")
    }

    public static func moduleItem(forCourse courseID: String, moduleID: String, itemID: String) -> Route {
        return Route("/courses/\(courseID)/modules/\(moduleID)/items/\(itemID)")
    }

    public static func people(forCourse courseID: String) -> Route {
        return Route("/courses/\(courseID)/users")
    }

    public static func people(forGroup groupID: String) -> Route {
        return Route("/groups/\(groupID)/users")
    }

    public static func errorReport(for type: String) -> Route {
        return Route("/support/\(type)")
    }

    public static let developerMenu = Route("/dev-menu")

    public static func termsOfService(forAccount accountID: String) -> Route {
        return Route("/accounts/\(accountID)/terms_of_service")
    }

    public static let actAsUser = Route("/act-as-user")

    public static func actAsUserID(_ id: String) -> Route {
        return Route("/act-as-user/\(id)")
    }

    public static let wrongApp = Route("/wrong-app")

    public static let anythingElse = Route("*")
}
