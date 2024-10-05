import { useState } from 'react'
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
import weekday from 'dayjs/plugin/weekday'
import PropTypes from 'prop-types'

dayjs.locale(ja)
dayjs.extend(weekday)

export default function NextMeetingDateForm({ minuteId, nextMeetingDate }) {
  const [isEditing, setIsEditing] = useState(false)

  return (
    <>
      {isEditing ? (
        <EditForm
          minuteId={minuteId}
          date={nextMeetingDate}
          setIsEditing={setIsEditing}
        />
      ) : (
        <NextMeetingDate date={nextMeetingDate} setIsEditing={setIsEditing} />
      )}
      <div className="pl-16 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
        <span>昼の部：15:00-16:00</span>
      </div>
      <div className="pl-16 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
        <span>夜の部：22:00-23:00</span>
      </div>
    </>
  )
}

function EditForm({ minuteId, date, setIsEditing }) {
  const [inputValue, setInputValue] = useState(date)

  const handleInput = function (e) {
    setInputValue(e.target.value)
  }

  const handleClick = async function (e) {
    e.preventDefault()
    const parameter = { minute: { next_meeting_date: inputValue } }
    const csrfToken = document.head.querySelector(
      'meta[name=csrf-token]'
    )?.content

    const response = await fetch(`/api/minutes/${minuteId}`, {
      method: 'PATCH',
      body: JSON.stringify(parameter),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-CSRF-Token': csrfToken,
      },
    })

    if (response.status === 200) {
      setIsEditing(false)
    } else {
      const errorData = await response.json()
      console.error(errorData.errors.join(','))
    }
  }

  return (
    <div className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-black before:rounded-full before:mr-2 before:align-middle">
      <input type="date" value={inputValue} onChange={handleInput} />
      <button
        type="button"
        onClick={handleClick}
        className="ml-2 py-1 px-2 border border-black"
      >
        更新
      </button>
    </div>
  )
}

function NextMeetingDate({ date, setIsEditing }) {
  const formattedDate = dayjs(date).format('YYYY年MM月DD日')
  const weekday = dayjs(date).format('dd')

  return (
    <div className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-black before:rounded-full before:mr-2 before:align-middle">
      <span>{`${formattedDate} (${weekday})`}</span>
      <button
        type="button"
        onClick={() => setIsEditing(true)}
        className="ml-2 py-1 px-2 border border-black"
      >
        編集
      </button>
    </div>
  )
}

NextMeetingDateForm.propTypes = {
  minuteId: PropTypes.number,
  nextMeetingDate: PropTypes.string,
}

EditForm.propTypes = {
  minuteId: PropTypes.number,
  date: PropTypes.string,
  setIsEditing: PropTypes.func,
}

NextMeetingDate.propTypes = {
  date: PropTypes.string,
  setIsEditing: PropTypes.func,
}