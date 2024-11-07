import PropTypes from 'prop-types'
import AttendanceTable from './AttendanceTable.jsx'

export default function AllAttendanceTable({ attendances }) {
  const attendancesPerYear = separateAttendancesByYear(attendances)

  return (
    <div>
      {attendancesPerYear.map((annualAttendances) => (
        <div
          key={annualAttendances.year}
          className="my-8"
          data-meeting-year={annualAttendances.year}
        >
          <p className="mb-2 text-xl">{annualAttendances.year}年</p>
          {annualAttendances.attendances.length >= 13 ? (
            <>
              <div data-half-attendances="first">
                <AttendanceTable
                  attendances={annualAttendances.attendances.slice(0, 12)}
                />
              </div>
              <div data-half-attendances="second">
                <AttendanceTable
                  attendances={annualAttendances.attendances.slice(12)}
                />
              </div>
            </>
          ) : (
            <AttendanceTable attendances={annualAttendances.attendances} />
          )}
        </div>
      ))}
    </div>
  )
}

function separateAttendancesByYear(attendances) {
  return attendances.reduce((attendancesPerYear, attendance) => {
    const year = attendance.date.slice(0, 4)
    const sortedAttendances = attendancesPerYear.find(
      (attendance) => attendance.year === year
    )

    sortedAttendances
      ? sortedAttendances.attendances.push(attendance)
      : attendancesPerYear.push({ year, attendances: [attendance] })

    return attendancesPerYear
  }, [])
}

AllAttendanceTable.propTypes = {
  attendances: PropTypes.array,
}
