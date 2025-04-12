import useSWR from 'swr'
import fetcher from '../fetcher.js'
import PropTypes from 'prop-types'

export default function UnexcusedAbsentees({ meetingId }) {
  const { data, error, isLoading } = useSWR(
    `/api/meetings/${meetingId}/attendances`,
    fetcher
  )

  if (error) return <p>エラーが発生しました</p>
  if (isLoading) return <p>読み込み中</p>

  return (
    <ul>
      {data.unexcused_absentees.map((absentee) => (
        <li key={absentee.member_id} className="mb-4">
          <a
            href={`https://github.com/${absentee.name}`}
          >{`@${absentee.name}`}</a>
        </li>
      ))}
    </ul>
  )
}

UnexcusedAbsentees.propTypes = {
  meetingId: PropTypes.number,
}
