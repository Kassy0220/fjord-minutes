import mountComponent from './mountComponent.jsx'
import ReleaseInformationForm from './components/ReleaseInformationForm.jsx'
import OtherForm from './components/OtherForm.jsx'

mountComponent('release_branch_form', ReleaseInformationForm)
mountComponent('release_note_form', ReleaseInformationForm)
mountComponent('other_form', OtherForm)
