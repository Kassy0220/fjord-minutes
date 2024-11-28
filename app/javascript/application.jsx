import { Turbo } from '@hotwired/turbo-rails'
Turbo.session.drive = false

import mountComponent from './mountComponent.jsx'
import AttendeesList from './components/AttendeesList.jsx'
import ReleaseInformationForm from './components/ReleaseInformationForm.jsx'
import TopicList from './components/TopicList.jsx'
import OtherForm from './components/OtherForm.jsx'
import NextMeetingDateForm from './components/NextMeetingDateForm.jsx'
import AbsenteesList from './components/AbsenteesList.jsx'
import UnexcusedAbsenteesList from './components/UnexcusedAbsenteesList.jsx'
import MinutePreview from './components/MinutePreview.jsx'
import './toggleAttendanceForm'

import 'flowbite'

mountComponent('attendees_list', AttendeesList)
mountComponent('release_branch_form', ReleaseInformationForm)
mountComponent('release_note_form', ReleaseInformationForm)
mountComponent('topics', TopicList)
mountComponent('other_form', OtherForm)
mountComponent('next_meeting_date_form', NextMeetingDateForm)
mountComponent('absentees_list', AbsenteesList)
mountComponent('unexcused_absentees_list', UnexcusedAbsenteesList)
mountComponent('minute_preview', MinutePreview)
