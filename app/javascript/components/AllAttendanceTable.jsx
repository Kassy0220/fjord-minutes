import PropTypes from 'prop-types'
import { Table, Tooltip } from 'flowbite-react'

export default function AllAttendanceTable({ attendances }) {
  const attendancesPerYear = separateAttendancesByYear(attendances)

  return (
    <div>
      {attendancesPerYear.map((annualAttendances) => (
        <div key={annualAttendances.year} className="my-8">
          <p className="mb-2 text-xl">{annualAttendances.year}年</p>
          {annualAttendances.attendances.length >= 13 ? (
            <>
              <AttendanceTable
                attendances={annualAttendances.attendances.slice(0, 12)}
              />
              <AttendanceTable
                attendances={annualAttendances.attendances.slice(12)}
              />
            </>
          ) : (
            <AttendanceTable attendances={annualAttendances.attendances} />
          )}
        </div>
      ))}
    </div>
  )
}

function AttendanceTable({ attendances }) {
  return (
    <div className="overflow-x-auto mb-2">
      <Table theme={customTableTheme}>
        <Table.Head>
          {attendances.map((attendance) => (
            <Table.HeadCell key={attendance.minute_id}>
              {formatDate(attendance.date)}
            </Table.HeadCell>
          ))}
        </Table.Head>
        <Table.Body className="divide-y">
          <Table.Row>
            {attendances.map((attendance) => (
              <Table.Cell key={attendance.minute_id}>
                <AttendanceTableData
                  status={attendance.status}
                  time={attendance.time}
                  absence_reason={attendance.absence_reason}
                />
              </Table.Cell>
            ))}
          </Table.Row>
        </Table.Body>
      </Table>
    </div>
  )
}

function AttendanceTableData({ status, time, absence_reason }) {
  if (status === 'present') {
    return <span>{attendance_time(time)}</span>
  } else if (status === 'absent') {
    return (
      <Tooltip content={absence_reason} theme={customTooltipTheme}>
        <span>欠席</span>
      </Tooltip>
    )
  } else if (status === 'hibernation') {
    return <span>休止</span>
  } else {
    return <span>---</span>
  }
}

function separateAttendancesByYear(attendances) {
  return attendances.reduce((attendancesPerYear, attendance) => {
    const year = attendance.date.slice(0, 4)
    const record = attendancesPerYear.find((record) => record.year === year)

    record
      ? record.attendances.push(attendance)
      : attendancesPerYear.push({ year, attendances: [attendance] })

    return attendancesPerYear
  }, [])
}

function formatDate(date) {
  const matched_date = date.match(/\d{4}-(\d{2})-(\d{2})/)
  return `${matched_date[1]}/${matched_date[2]}`
}

function attendance_time(time) {
  return { day: '昼', night: '夜' }[time]
}

const customTableTheme = {
  root: {
    base: 'text-left text-sm',
    shadow:
      'absolute left-0 top-0 -z-10 h-full w-full rounded-lg bg-white drop-shadow-md',
    wrapper: 'relative',
  },
  body: {
    base: 'group/body',
    cell: {
      base: 'px-2 py-2 border border-gray-400 w-16 h-10 text-center',
    },
  },
  head: {
    base: 'group/head text-xs uppercase text-gray-700',
    cell: {
      base: 'bg-gray-200 px-2 py-2 border border-gray-400 w-16 h-10 text-center',
    },
  },
}

const customTooltipTheme = {
  target: '', // デフォルトで設定されているw-fitを削除
}

AllAttendanceTable.propTypes = {
  attendances: PropTypes.array,
}

AttendanceTable.propTypes = {
  attendances: PropTypes.array,
}

AttendanceTableData.propTypes = {
  status: PropTypes.string,
  time: PropTypes.string,
  absence_reason: PropTypes.string,
}
