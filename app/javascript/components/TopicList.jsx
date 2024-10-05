import PropTypes from 'prop-types'

export default function TopicList({ topics }) {
  return (
    <ul>
      {topics.map((topic) => (
        <li
          key={topic.id}
          className="pl-8 before:content-[''] before:w-1.5 before:h-1.5 before:inline-block before:bg-black before:rounded-full before:mr-2 before:align-middle"
        >
          {topic.content}
        </li>
      ))}
    </ul>
  )
}

TopicList.propTypes = {
  minuteId: PropTypes.number,
  topics: PropTypes.array,
}
