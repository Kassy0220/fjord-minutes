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
    <ul>
      {data.absentees.map((absentee) => (
        <Absentee
          key={absentee.attendance_id}
          name={absentee.name}
          absence_reason={absentee.absence_reason}
          progress_report={absentee.progress_report}
        />
      ))}
    </ul>
  )
}

function Absentee({ name, absence_reason, progress_report }) {
  return (
    <li>
      <a
        href={`https://github.com/${name}`}
        className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-black before:rounded-full before:mr-2 before:align-middle text-sky-600 underline"
      >
        {name}
      </a>
      <ul>
        <li className="pl-16 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
          欠席理由: {absence_reason}
        </li>
        <li className="pl-16 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-white before:border before:border-black before:rounded-full before:mr-2 before:align-middle">
          今週の進捗: {progress_report}
        </li>
      </ul>
    </li>
  )
}

AbsenteesList.propTypes = {
  minuteId: PropTypes.number,
}

Absentee.propTypes = {
  name: PropTypes.string,
  absence_reason: PropTypes.string,
  progress_report: PropTypes.string,
}
