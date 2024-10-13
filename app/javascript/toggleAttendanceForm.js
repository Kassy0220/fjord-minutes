document.addEventListener('DOMContentLoaded', () => {
  const attendanceForm = document.querySelector('#attendance_form')
  if (!attendanceForm) {
    return null
  }

  // 出欠のラジオボタンでフォームの表示を切り替える処理
  const statusRadioButtons = document.querySelectorAll(
    '[name="attendance[status]"]'
  )
  const presentFields = document.querySelectorAll('.present_entry_field')
  const absentFields = document.querySelectorAll('.absent_entry_field')

  const handleChange = function () {
    toggleForm()
  }

  const toggleForm = function () {
    const checkedStatus = attendanceForm.elements['attendance[status]'].value
    if (checkedStatus === 'present') {
      showPresentField()
      hideAbsentField()
    } else if (checkedStatus === 'absent') {
      hidePresentField()
      showAbsentField()
    }
  }

  const showPresentField = function () {
    presentFields.forEach((field) => {
      field.style.display = 'block'
    })
  }

  const hidePresentField = function () {
    presentFields.forEach((field) => {
      field.style.display = 'none'
    })
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

  toggleForm()

  // 出席時間帯のラジオボタンを2度クリックするとチェックを消せるようにする処理
  const timeRadioButtons = document.querySelectorAll(
    '[name="attendance[time]"]'
  )
  let lastCheckedTimeRadioButton = null

  timeRadioButtons.forEach((button) => {
    button.addEventListener('click', function () {
      if (lastCheckedTimeRadioButton === this) {
        this.checked = false
        lastCheckedTimeRadioButton = null
      } else {
        lastCheckedTimeRadioButton = this
      }
    })
  })
})
