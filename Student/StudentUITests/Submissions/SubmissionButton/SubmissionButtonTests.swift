//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

@testable import Core
@testable import CoreUITests
import TestsFoundation
import XCTest

class SubmissionButtonTests: StudentUITestCase {
    lazy var course = mock(course: .make())

    func testOnlineUpload() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(submission_types: [ .online_upload ]))
        let target = FileUploadTarget.make()
        mockData(PostFileUploadTargetRequest(
            context: .submission(courseID: course.id.value, assignmentID: assignment.id.value, comment: nil),
            body: .init(name: "", on_duplicate: .overwrite, parent_folder_id: nil, size: 0)
        ), value: target)
        mockData(PostFileUploadRequest(fileURL: URL(string: "data:text/plain,")!, target: target), value: .make())
        mockData(CreateSubmissionRequest(context: ContextModel(.course, id: "1"), assignmentID: "1", body: nil))

        logIn()
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.tap()
        FilePicker.libraryButton.tap()
        app.find(label: "All Photos").tap()
        app.find(labelContaining: "Photo, HDR").tap()
        FilePicker.submitButton.tap()
        FilePicker.submitButton.waitToVanish()
    }

    func testExternalTool() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(submission_types: [ .external_tool ]))
        mockData(GetSessionlessLaunchURLRequest(
            context: course,
            id: nil,
            url: nil,
            assignmentID: assignment.id.value,
            moduleItemID: nil,
            launchType: .assessment
        ), value: APIGetSessionlessLaunchResponse(url: URL(string: "https://canvas.instructure.com")!))

        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.tap()
        app.find(label: "Done").tap()
    }

    func testBasicLTILaunch() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(submission_types: [ .basic_lti_launch ]))
        mockData(GetSessionlessLaunchURLRequest(
            context: course,
            id: nil,
            url: nil,
            assignmentID: assignment.id.value,
            moduleItemID: nil,
            launchType: .assessment
        ), value: APIGetSessionlessLaunchResponse(url: URL(string: "https://canvas.instructure.com")!))

        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.tap()
        app.find(label: "Done").tap()
    }

    func testOnlineQuiz() {
        mockBaseRequests()
        let quiz = APIQuiz.make()
        let assignment = mock(assignment: .make(quiz_id: quiz.id, submission_types: [ .online_quiz ]))
        mockData(GetQuizRequest(courseID: course.id.value, quizID: quiz.id.value), value: .make())
        let submission = APIQuizSubmission.make()
        mockData(GetQuizSubmissionRequest(courseID: course.id.value, quizID: quiz.id.value), value: .init(quiz_submissions: [submission]))
        mockEncodableRequest("courses/\(course.id)/quizzes/\(quiz.id)/submission", value: submission)

        logIn()
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.tap()
        app.find(label: "Exit").tap()
    }

    func testDiscussionTopic() {
        mockBaseRequests()
        let topic = APIDiscussionTopic.make(html_url: URL(string: "/courses/\(course.id)/discussion_topics/1"))
        let assignment = mock(assignment: .make(submission_types: [ .discussion_topic ], discussion_topic: topic))
        mockData(GetContextPermissionsRequest(context: course), value: .make())
        mockEncodableRequest("courses/\(course.id)/discussion_topics/1?include[]=sections", value: topic)
        mockEncodableRequest("courses/\(course.id)/discussion_topics/1/view?include_new_entries=1", value: [
            "unread_entries": [String](),
            "participants": [String](),
            "view": [String](),
            "new_entries": [String](),
            "entry_ratings": [String](),
        ])

        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.tap()
        XCTAssertEqual(DiscussionDetails.titleLabel.label(), topic.title)
        NavBar.backButton.tap()
    }

    func testMediaRecording() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(submission_types: [ .media_recording ]))
        mockData(GetMediaServiceRequest(), value: APIMediaService(domain: "canvas.instructure.com"))
        mockData(PostMediaSessionRequest(), value: APIMediaSession(ks: "k"))
        mockEncodedData(PostMediaUploadTokenRequest(body: .init(ks: "k")), data: "<id>t</id>".data(using: .utf8))
        mockData(PostMediaUploadRequest(fileURL: URL(string: "data:text/plain,")!, type: .audio, ks: "k", token: "t"))
        mockEncodedData(PostMediaIDRequest(ks: "k", token: "t", type: .audio), data: "<id>2</id>".data(using: .utf8))
        mockData(CreateSubmissionRequest(context: ContextModel(.course, id: "1"), assignmentID: "1", body: nil))

        logIn()
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.tap()
        allowAccessToMicrophone {
            app.find(label: "Record Audio").tap()
        }
        AudioRecorder.recordButton.tap() // Doesn't start recording on bitrise. :( It works locally.
        AudioRecorder.stopButton.tap()
        AudioRecorder.sendButton.tap()
        app.find(label: "Successfully submitted!").waitToExist()
    }
}
