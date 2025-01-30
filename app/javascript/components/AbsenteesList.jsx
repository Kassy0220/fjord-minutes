import useSWR from 'swr'
import fetcher from '../fetcher.js'
import DOMPurify from 'dompurify'
import PropTypes from 'prop-types'

export default function AbsenteesList({ minuteId, course_name }) {
  const { data, error, isLoading } = useSWR(
    `/api/minutes/${minuteId}/attendances`,
    fetcher
  )

  if (error) return <p>エラーが発生しました</p>
  if (isLoading) return <p>読み込み中</p>

  return (
    <ul id="absentees">
      {data.absentees.map((absentee) => (
        <Absentee
          key={absentee.attendance_id}
          absentee={absentee}
          course_name={course_name}
        />
      ))}
    </ul>
  )
}

function Absentee({ absentee, course_name }) {
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
              <li key={index}>
                <span
                  dangerouslySetInnerHTML={{
                    __html: DOMPurify.sanitize(
                      convertIssueNumberToLink(report, course_name)
                    ),
                  }}
                ></span>
              </li>
            ))}
          </ul>
        </li>
      </ul>
    </li>
  )
}

function convertIssueNumberToLink(progress_report, course_name) {
  const repositoryUrl =
    course_name === 'Railsエンジニアコース'
      ? 'https://github.com/fjordllc/bootcamp'
      : 'https://github.com/fjordllc/agent'

  return progress_report.replaceAll(
    /#(\d+)/g,
    `<a href="${repositoryUrl}/issues/$1" target="_blank">#$1</a>`
  )
}

AbsenteesList.propTypes = {
  minuteId: PropTypes.number,
  course_name: PropTypes.string,
}

Absentee.propTypes = {
  absentee: PropTypes.object,
  course_name: PropTypes.string,
}
