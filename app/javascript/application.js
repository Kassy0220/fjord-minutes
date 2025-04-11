import { Turbo } from '@hotwired/turbo-rails'
Turbo.session.drive = false

import mountComponent from './mountComponent'
import Attendees from './components/Attendees'
import Release from './components/Release'
import Topics from './components/Topics'
import OtherForm from './components/OtherForm'
import NextMeetingDateForm from './components/NextMeetingDateForm'
import Absentees from './components/Absentees'
import UnexcusedAbsentees from './components/UnexcusedAbsentees'
import MinutePreview from './components/MinutePreview'
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
