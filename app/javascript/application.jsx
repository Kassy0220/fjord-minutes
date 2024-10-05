import mountComponent from './mountComponent.jsx'
import ReleaseInformationForm from './components/ReleaseInformationForm.jsx'
import TopicList from './components/TopicList.jsx'
import OtherForm from './components/OtherForm.jsx'
import NextMeetingDateForm from './components/NextMeetingDateForm.jsx'

mountComponent('release_branch_form', ReleaseInformationForm)
mountComponent('release_note_form', ReleaseInformationForm)
mountComponent('topics', TopicList)
mountComponent('other_form', OtherForm)
mountComponent('next_meeting_date_form', NextMeetingDateForm)
