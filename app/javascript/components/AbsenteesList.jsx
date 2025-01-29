import useSWR from 'swr'
import fetcher from '../fetcher.js'
import PropTypes from 'prop-types'

export default function AbsenteesList({ minuteId }) {
  const { data, error, isLoading } = useSWR(
    `/api/minutes/${minuteId}/attendances`,
    fetcher
  )

  if (error) return <p>エラーが発生しました</p>
  if (isLoading) return <p>読み込み中</p>

  return (
    <ul id="absentees">
      {data.absentees.map((absentee) => (
        <Absentee key={absentee.attendance_id} absentee={absentee} />
      ))}
    </ul>
  )
}

function Absentee({ absentee }) {
  return (
    <li className="mb-4">
      <a href={`https://github.com/${absentee.name}`}>{`@${absentee.name}`}</a>
      <ul className="!mt-2">
        <li>
          欠席理由
          <ul>
            <li>{absentee.absence_reason}</li>
          </ul>
        </li>
        <li>
          今週の進捗
          <ul>
            {absentee.progress_report.split('\r\n').map((report, index) => (
              <li key={index}>{report}</li>
            ))}
          </ul>
        </li>
      </ul>
    </li>
  )
}

AbsenteesList.propTypes = {
  minuteId: PropTypes.number,
}

Absentee.propTypes = {
  absentee: PropTypes.object,
}
