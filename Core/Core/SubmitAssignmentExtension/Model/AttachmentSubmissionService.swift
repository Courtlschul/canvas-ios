//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class AttachmentSubmissionService {
    private let uploadManager: UploadManager

    public init(uploadManager: UploadManager = UploadManager(identifier: "com.instructure.icanvas.SubmitAssignment.file-uploads", sharedContainerIdentifier: "group.instructure.shared")) {
        self.uploadManager = uploadManager
    }

    public func submit(urls: [URL], courseID: String, assignmentID: String, batchID: String, comment: String?) {
        let uploadContext = FileUploadContext.submission(
            courseID: courseID,
            assignmentID: assignmentID,
            comment: comment
        )
        uploadManager.cancel(batchID: batchID)
        var error: Error?
        ProcessInfo.processInfo.performExpiringActivity(withReason: "get upload targets") { [uploadManager] expired in
            if expired {
                Analytics.shared.logError("error_performing_background_activity")
                uploadManager.notificationManager.sendFailedNotification()
                return
            }
            uploadManager.viewContext.perform {
                do {
                    var files: [File] = []
                    for url in urls {
                        let file = try uploadManager.add(url: url, batchID: batchID)
                        files.append(file)
                    }
                    for file in files {
                        uploadManager.upload(file: file, to: uploadContext)
                    }
                } catch let e {
                    error = e
                }
            }
            if error != nil {
                uploadManager.notificationManager.sendFailedNotification()
            }
        }
    }
}

extension AttachmentSubmissionService: FileProgressListViewModelDelegate {

    public func fileProgressViewModelCancel(_ viewModel: FileProgressListViewModel) {
        uploadManager.cancel(batchID: viewModel.batchID)
    }

    public func fileProgressViewModelRetry(_ viewModel: FileProgressListViewModel) {
        uploadManager.retry(batchID: viewModel.batchID)
    }

    public func fileProgressViewModel(_ viewModel: FileProgressListViewModel, delete file: File) {
        uploadManager.cancel(file: file)
    }
}
