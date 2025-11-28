import dayjs from 'dayjs'
import isoWeek from 'dayjs/plugin/isoWeek'
import isoWeeksInYear from 'dayjs/plugin/isoWeeksInYear'
import isLeapYear from 'dayjs/plugin/isLeapYear'

dayjs.extend(isoWeek)
dayjs.extend(isoWeeksInYear)
dayjs.extend(isLeapYear)

export default function getPossibleMeetingDates(date) {
  const MeetingDayOfTheWeek = 3 // 水曜日
  let year = dayjs(date).year()
  const targetWeeks = getPossibeMeetingWeeks(date)

  return targetWeeks.map((weekNumber, index) => {
    // 52週 → 2週 のように年を跨ぐ場合
    if (index >= 1 && targetWeeks[index - 1] > targetWeeks[index]) {
      year += 1
    }
    // ISO8601では、1月4日は必ず第1週に含まれるため、その週の水曜日を基準に、週番号から日付を計算する
    const firstWeekWednesday = dayjs(`${year}-01-04`).day(MeetingDayOfTheWeek)
    const meetingDay = firstWeekWednesday.isoWeek(weekNumber)
    return meetingDay.format('YYYY-MM-DD')
  })
}

function getPossibeMeetingWeeks(date) {
  const weeks = []
  const numberOfPossibleWeeks = 4
  const maxWeekNumber = dayjs(date).isoWeeksInYear()
  let weekNumber = dayjs(date).isoWeek()

  for (let i = 0; i < numberOfPossibleWeeks; i++) {
    if (weekNumber > maxWeekNumber) {
      weekNumber = dayjs(date).isoWeek() % 2 === 0 ? 2 : 1
    }

    weeks.push(weekNumber)

    weekNumber += 2
  }

  return weeks
}
