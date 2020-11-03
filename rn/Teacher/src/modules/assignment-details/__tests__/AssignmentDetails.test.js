//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import React from 'react'
import { AssignmentDetails } from '../AssignmentDetails'
import renderer from 'react-test-renderer'
import * as LTITools from '../../../common/LTITools'

const template = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/helm'),
  ...require('../../../__templates__/external-tool'),
  ...require('../../../__templates__/error'),
  ...require('../../../__templates__/session'),
}

jest
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('../components/SubmissionBreakdownGraphSection', () => 'SubmissionBreakdownGraphSection')

let course: any = template.course()
let assignment: any = template.assignment()

let defaultProps = {
  navigator: template.navigator(),
  courseID: course.id,
  course: course,
  assignmentID: assignment.id,
  refreshAssignmentDetails: (courseID: string, assignmentID: string) => {},
  assignmentDetails: assignment,
  pending: 0,
  stubSubmissionProgress: true,
  refresh: jest.fn(),
  refreshing: false,
  getSessionlessLaunchURL: jest.fn(),
}

test('renders', () => {
  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders with no submission types', () => {
  defaultProps.assignmentDetails = template.assignment({ submission_types: ['none'] })
  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders with no assignment', () => {
  let props = {
    ...defaultProps,
    assignmentDetails: null,
  }
  let tree = renderer.create(
    <AssignmentDetails {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders as a designer', () => {
  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} showSubmissionSummary={false} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders with not_graded submission type', () => {
  defaultProps.assignmentDetails = template.assignment({ submission_types: ['not_graded'] })
  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders loading', () => {
  defaultProps.pending = 1
  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders without description', () => {
  let props = {
    ...defaultProps,
    assignmentDetails: { ...assignment, description: null },
  }
  let tree = renderer.create(
    <AssignmentDetails {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('calls navigator.show when the edit button is pressed', () => {
  let navigator = template.navigator({
    showModal: jest.fn(),
  })
  let tree = renderer.create(
    <AssignmentDetails {...defaultProps} navigator={navigator} />
  )

  tree.getInstance().editAssignment()

  expect(navigator.show).toHaveBeenCalledWith(
    `/courses/${defaultProps.courseID}/assignments/${defaultProps.assignmentDetails.id}/edit`,
    { modal: true }
  )
})

test('routes to the right place when due dates details is requested', () => {
  let navigator = template.navigator({
    show: jest.fn(),
  })
  let details = renderer.create(
    <AssignmentDetails {...defaultProps} navigator={navigator} />
  ).getInstance()
  details.viewDueDateDetails()
  expect(navigator.show).toHaveBeenCalledWith(
    `/courses/${defaultProps.courseID}/assignments/${defaultProps.assignmentDetails.id}/due_dates`,
    { modal: false },
  )
})

test('routes to the right place when submissions is tapped', () => {
  let navigator = template.navigator({
    push: jest.fn(),
  })
  let details = renderer.create(
    <AssignmentDetails {...defaultProps} navigator={navigator} />
  ).getInstance()
  details.viewAllSubmissions()
  expect(navigator.show).toHaveBeenCalledWith(
    `/courses/${defaultProps.courseID}/assignments/${defaultProps.assignmentDetails.id}/submissions`
  )
})

test('routes to the right place when submissions dial is tapped', () => {
  let navigator = template.navigator({
    push: jest.fn(),
  })
  let details = renderer.create(
    <AssignmentDetails {...defaultProps} navigator={navigator} />
  ).getInstance()
  details.onSubmissionDialPress('graded')
  expect(navigator.show).toHaveBeenCalledWith(
    `/courses/${defaultProps.courseID}/assignments/${defaultProps.assignmentDetails.id}/submissions?filter=graded`,
    { modal: false }
  )
})

describe('external tool', () => {
  describe('happy path', () => {
    const url = 'https://canvas.instructure.com/external_tool'
    let props
    beforeEach(() => {
      LTITools.launchExternalTool = jest.fn()
      props = {
        ...defaultProps,
        assignmentDetails: template.assignment({
          url,
          submission_types: ['external_tool'],
        }),
      }
    })

    it('launches from submission types', () => {
      let view = shallow(<AssignmentDetails {...props} />)
      const submissionTypes = view.find('[testID="assignment-details.assignment-section.submission-type"]')
      submissionTypes.simulate('press')
      expect(LTITools.launchExternalTool).toHaveBeenCalledWith(
        null,
        `course_${course.id}`,
        undefined,
        'assessment',
        assignment.id
      )
    })

    it('launches from button', () => {
      let view = shallow(<AssignmentDetails {...props} />)
      const button = view.find('[testID="assignment-details.launch-external-tool.button"]')
      button.simulate('press')
      expect(LTITools.launchExternalTool).toHaveBeenCalledWith(
        null,
        `course_${course.id}`,
        undefined,
        'assessment',
        assignment.id
      )
    })

    it('launches with tool id', () => {
      props.courseID = '1'
      props.assignmentID = '2'
      props.assignmentDetails.external_tool_tag_attributes = { content_id: '3' }
      let view = shallow(<AssignmentDetails {...props} />)
      view.find('[testID="assignment-details.launch-external-tool.button"]').simulate('press')
      expect(LTITools.launchExternalTool).toHaveBeenCalledWith(
        null,
        'course_1',
        '3',
        'assessment',
        '2'
      )
    })
  })
})
