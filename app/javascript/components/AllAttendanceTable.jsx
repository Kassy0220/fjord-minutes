import PropTypes from 'prop-types'
import { Table } from 'flowbite-react'

export default function AllAttendanceTable({ attendances }) {
  return (
    <div className="overflow-x-auto">
      <Table theme={customTheme}>
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
                />
              </Table.Cell>
            ))}
          </Table.Row>
        </Table.Body>
      </Table>
    </div>
  )
}

function AttendanceTableData({ status, time }) {
  if (status === 'present') {
    return <span>{attendance_time(time)}</span>
  } else if (status === 'absent') {
    return <span>欠席</span>
  } else {
    return <span>---</span>
  }
}

function formatDate(date) {
  const matched_date = date.match(/\d{4}-(\d{2})-(\d{2})/)
  return `${matched_date[1]}/${matched_date[2]}`
}

function attendance_time(time) {
  return { day: '昼', night: '夜' }[time]
}

const customTheme = {
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

AllAttendanceTable.propTypes = {
  attendances: PropTypes.array,
}

AttendanceTableData.propTypes = {
  status: PropTypes.string,
  time: PropTypes.string,
}
