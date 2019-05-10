//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import SwiftUITest

enum SubmissionComments: String, CaseIterable, ElementWrapper {
    case addCommentButton
    case addMediaButton
    case commentTextView

    private static let className = String(describing: SubmissionComments.self)

    static func attemptCell(submissionID: String, attempt: Int) -> Element {
        return app.find(id: "\(className).attemptCell.submission-\(submissionID)-\(attempt)")
    }

    static func attemptView(attempt: Int) -> Element {
        return app.find(id: "\(className).attemptView.\(attempt)")
    }

    static func audioCell(commentID: String) -> Element {
        return app.find(id: "\(className).audioCell.\(commentID)")
    }

    static func audioCellPlayPauseButton(commentID: String) -> Element {
        return app.find(id: "\(className).audioCell.\(commentID).playPauseButton")
    }

    static func fileView(fileID: String) -> Element {
        return app.find(id: "\(className).fileView.\(fileID)")
    }

    static func textCell(commentID: String) -> Element {
        return app.find(id: "\(className).textCell.\(commentID)")
    }

    static func videoCell(commentID: String) -> Element {
        return app.find(id: "\(className).videoCell.\(commentID)")
    }
}
