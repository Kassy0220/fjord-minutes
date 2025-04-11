import { Turbo } from '@hotwired/turbo-rails'
Turbo.session.drive = false

import mountComponent from './mountComponent.jsx'
import Attendees from './components/Attendees.jsx'
import Release from './components/Release.jsx'
import Topics from './components/Topics.jsx'
import OtherForm from './components/OtherForm.jsx'
import NextMeetingDateForm from './components/NextMeetingDateForm.jsx'
import Absentees from './components/Absentees.jsx'
import UnexcusedAbsentees from './components/UnexcusedAbsentees.jsx'
import MinutePreview from './components/MinutePreview.jsx'
import './toggleAttendanceForm'

import 'flowbite'

mountComponent('attendees', Attendees)
mountComponent('absentees', Absentees)
mountComponent('unexcused_absentees', UnexcusedAbsentees)
mountComponent('release_branch', Release)
mountComponent('release_note', Release)
mountComponent('topics', Topics)
mountComponent('other_form', OtherForm)
mountComponent('next_meeting_date_form', NextMeetingDateForm)
mountComponent('minute_preview', MinutePreview)
