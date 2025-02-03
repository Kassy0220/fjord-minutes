document.addEventListener('DOMContentLoaded', () => {
  const attendanceForm = document.querySelector('#attendance_form')
  if (!attendanceForm) {
    return null
  }

  // 出欠のラジオボタンでフォームの表示を切り替える処理
  const statusRadioButtons = document.querySelectorAll(
    '[name="attendance_form[status]"]'
  )
  const absentFields = document.querySelectorAll('.absent_entry_field')

  const handleChange = function () {
    toggleForm()
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

  statusRadioButtons.forEach((button) => {
    button.addEventListener('change', handleChange)
  })

  const isStatusChecked =
    attendanceForm.elements['attendance_form[status]'].value !== ''
  if (isStatusChecked) {
    toggleForm()
  } else {
    hideAbsentField()
  }
})
