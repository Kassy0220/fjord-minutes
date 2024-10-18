import { useState, useCallback } from 'react'
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
import weekday from 'dayjs/plugin/weekday'
import holidayJP from '@holiday-jp/holiday_jp'
import PropTypes from 'prop-types'
import sendRequest from '../sendRequest.js'
import useChannel from '../hooks/useChannel.js'

dayjs.locale(ja)
dayjs.extend(weekday)

export default function NextMeetingDateForm({ minuteId, nextMeetingDate }) {
  const [date, setDate] = useState(nextMeetingDate)
  const [isEditing, setIsEditing] = useState(false)

  const onReceivedData = useCallback(function (data) {
    if ('minute' in data.body) {
      setDate(data.body.minute.next_meeting_date)
    }
  }, [])
  useChannel(minuteId, onReceivedData)

  return (
    <ul>
      <li>
        {isEditing ? (
          <EditForm
            minuteId={minuteId}
            date={date}
            setIsEditing={setIsEditing}
          />
        ) : (
          <NextMeetingDate date={date} setIsEditing={setIsEditing} />
        )}
        <ul>
          <li>
            <span>昼の部：15:00-16:00</span>
          </li>
          <li>
            <span>夜の部：22:00-23:00</span>
          </li>
        </ul>
      </li>
    </ul>
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

    const response = await sendRequest(
      `/api/minutes/${minuteId}`,
      'PATCH',
      parameter
    )

    if (response.status === 200) {
      setIsEditing(false)
    } else {
      const errorData = await response.json()
      console.error(errorData.errors.join(','))
    }
  }

  return (
    <>
      <input type="date" value={inputValue} onChange={handleInput} />
      <button
        type="button"
        onClick={handleClick}
        className="ml-2 py-1 px-2 border border-black"
      >
        更新
      </button>
    </>
  )
}

function NextMeetingDate({ date, setIsEditing }) {
  const formattedDate = dayjs(date).format('YYYY年MM月DD日')
  const weekday = dayjs(date).format('dd')
  const isHoliday = holidayJP.isHoliday(new Date(date))

  return (
    <>
      <span>{`${formattedDate} (${weekday})`}</span>
      {isHoliday && (
        <span className="text-red-600 ml-2">
          ※{holidayJP.holidays[date].name}
        </span>
      )}
      <button
        type="button"
        onClick={() => setIsEditing(true)}
        className="ml-2 py-1 px-2 border border-black"
      >
        編集
      </button>
    </>
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
