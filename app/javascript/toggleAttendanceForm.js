document.addEventListener('DOMContentLoaded', () => {
  const attendanceForm = document.querySelector('#attendance_form')
  if (!attendanceForm) {
    return null
  }

  const statusRadioButtons = document.querySelectorAll(
    '[name="attendance_form[status]"]'
  )
  const absentFields = document.querySelectorAll('.absent_entry_field')
  const submitButton = document.querySelector('#submit_button')

  const handleChange = function () {
    toggleForm()
    activeSubmitButton()
  }

  const toggleForm = function () {
    const checkedStatus =
      attendanceForm.elements['attendance_form[status]'].value
    if (checkedStatus === 'absent') {
      showAbsentField()
    } else {
      hideAbsentField()
    }
  }

  const showAbsentField = function () {
    absentFields.forEach((field) => {
      field.style.display = 'block'
    })
  }

  const hideAbsentField = function () {
    absentFields.forEach((field) => {
      field.style.display = 'none'
    })
  }

  const activeSubmitButton = function () {
    submitButton.disabled = false
    submitButton.classList.remove('cursor-not-allowed')
    submitButton.classList.add('cursor-pointer')
  }

  statusRadioButtons.forEach((button) => {
    button.addEventListener('change', handleChange)
  })

  const isStatusChecked =
    attendanceForm.elements['attendance_form[status]'].value !== ''
  if (isStatusChecked) {
    toggleForm()
  } else {
    hideAbsentField()
    submitButton.disabled = true
    submitButton.classList.add('cursor-not-allowed')
  }
})
