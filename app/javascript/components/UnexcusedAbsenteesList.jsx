import useSWR from 'swr'
import fetcher from '../fetcher.js'
import PropTypes from 'prop-types'

export default function UnexcusedAbsenteesList({ minuteId }) {
  const { data, error, isLoading } = useSWR(
    `/api/minutes/${minuteId}/attendances`,
    fetcher
  )

  if (error) return <p>エラーが発生しました</p>
  if (isLoading) return <p>読み込み中</p>

  return (
    <ul>
      {data.unexcused_absentees.map((absentee) => (
        <li
          key={absentee.member_id}
          className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-black before:rounded-full before:mr-2 before:align-middle text-sky-600 underline"
        >
          <a
            href={`https://github.com/${absentee.name}`}
          >{`@${absentee.name}`}</a>
        </li>
      ))}
    </ul>
  )
}

UnexcusedAbsenteesList.propTypes = {
  minuteId: PropTypes.number,
}
