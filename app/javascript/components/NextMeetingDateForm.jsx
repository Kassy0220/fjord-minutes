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

export default function NextMeetingDateForm({
  minuteId,
  meetingId,
  scheduledDates,
  nextMeetingDate,
  isAdmin,
}) {
  const [date, setDate] = useState(nextMeetingDate)
  const [isEditing, setIsEditing] = useState(false)

  const onReceivedData = useCallback(function (data) {
    if ('meeting' in data.body) {
      setDate(data.body.meeting.next_date)
    }
  }, [])
  useChannel(minuteId, onReceivedData)

  return (
    <ul>
      <li>
        {isEditing ? (
          <EditForm
            minuteId={minuteId}
            meetingId={meetingId}
            scheduledDates={scheduledDates}
            nextMeetingDate={date}
            setIsEditing={setIsEditing}
          />
        ) : (
          <NextMeetingDate
            date={date}
            setIsEditing={setIsEditing}
            isAdmin={isAdmin}
          />
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

function EditForm({
  minuteId,
  meetingId,
  scheduledDates,
  nextMeetingDate,
  setIsEditing,
}) {
  const [selectedDate, setSelectedDate] = useState(nextMeetingDate)

  const handleDateClick = function (date) {
    setSelectedDate(date)
  }

  const handleUpdateClick = async function (e) {
    e.preventDefault()
    const parameter = {
      meeting: { next_date: selectedDate },
    }

    const response = await sendRequest(
      `/api/minutes/${minuteId}/meetings/${meetingId}`,
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
    <div className="w-[400px]">
      <ul className="list-none p-0 m-0 mb-4 space-y-2">
        {scheduledDates.map((date) => {
          const isSelected = date === selectedDate
          return (
            <li key={date}>
              <button
                type="button"
                onClick={() => handleDateClick(date)}
                className={`w-full p-3 rounded border transition-colors text-left ${
                  isSelected
                    ? 'bg-blue-500 text-white border-blue-600 font-semibold'
                    : 'bg-gray-50 border-gray-200 hover:bg-blue-100'
                }`}
                data-meeting-date={date}
              >
                {`${dayjs(date).format('YYYY年MM月DD日')}`}
                {holidayJP.isHoliday(new Date(date)) && (
                  <p className="flex mt-2! mb-0! pl-2 py-2 bg-yellow-50 border border-yellow-200 rounded-sm">
                    <svg
                      className="w-6 h-6 text-yellow-300 dark:text-white inline-block mr-1"
                      aria-hidden="true"
                      xmlns="http://www.w3.org/2000/svg"
                      width="24"
                      height="24"
                      fill="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        fillRule="evenodd"
                        d="M2 12C2 6.477 6.477 2 12 2s10 4.477 10 10-4.477 10-10 10S2 17.523 2 12Zm11-4a1 1 0 1 0-2 0v5a1 1 0 1 0 2 0V8Zm-1 7a1 1 0 1 0 0 2h.01a1 1 0 1 0 0-2H12Z"
                        clipRule="evenodd"
                      />
                    </svg>
                    <span className="text-yellow-500 font-bold">
                      {holidayJP.holidays[date].name}
                    </span>
                  </p>
                )}
              </button>
            </li>
          )
        })}
      </ul>
      <button type="button" onClick={handleUpdateClick} className="button mt-2">
        更新
      </button>
    </div>
  )
}

function NextMeetingDate({ date, setIsEditing, isAdmin }) {
  const formattedDate = dayjs(date).format('YYYY年MM月DD日')
  const weekday = dayjs(date).format('dd')
  const isHoliday = holidayJP.isHoliday(new Date(date))

  return (
    <>
      <span>{`${formattedDate} (${weekday})`}</span>
      {isAdmin && (
        <button
          type="button"
          onClick={() => setIsEditing(true)}
          className="button"
        >
          編集
        </button>
      )}
      {isHoliday && (
        <p className="flex m-0! pl-2 py-2 bg-yellow-50 rounded-sm">
          <svg
            className="w-6 h-6 text-yellow-300 dark:text-white inline-block mr-1"
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            fill="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              fillRule="evenodd"
              d="M2 12C2 6.477 6.477 2 12 2s10 4.477 10 10-4.477 10-10 10S2 17.523 2 12Zm11-4a1 1 0 1 0-2 0v5a1 1 0 1 0 2 0V8Zm-1 7a1 1 0 1 0 0 2h.01a1 1 0 1 0 0-2H12Z"
              clipRule="evenodd"
            />
          </svg>
          <span className="text-yellow-500 font-bold">
            次回開催日は{holidayJP.holidays[date].name}
            です。もしミーティングをお休みにする場合は、開催日を変更しましょう。
          </span>
        </p>
      )}
    </>
  )
}

NextMeetingDateForm.propTypes = {
  minuteId: PropTypes.number,
  meetingId: PropTypes.number,
  scheduledDates: PropTypes.array,
  nextMeetingDate: PropTypes.string,
  meetingWeekParity: PropTypes.string,
  isAdmin: PropTypes.bool,
}

EditForm.propTypes = {
  minuteId: PropTypes.number,
  meetingId: PropTypes.number,
  scheduledDates: PropTypes.array,
  nextMeetingDate: PropTypes.string,
  setIsEditing: PropTypes.func,
}

NextMeetingDate.propTypes = {
  date: PropTypes.string,
  setIsEditing: PropTypes.func,
  isAdmin: PropTypes.bool,
}
