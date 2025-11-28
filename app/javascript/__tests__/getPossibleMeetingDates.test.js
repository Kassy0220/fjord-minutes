import { describe, test, expect } from 'vitest'
import getPossibleMeetingDates from '../getPossibleMeetingDates.js'

describe('getPossibleMeetingDates', () => {
  test('指定した日付から4つの隔週のweek numberを返す', () => {
    // 2025年1月1日（ISO週番号: 1）
    const oddWeekDate = new Date('2025-01-01')
    expect(getPossibleMeetingDates(oddWeekDate)).toEqual([
      '2025-01-01',
      '2025-01-15',
      '2025-01-29',
      '2025-02-12',
    ])

    // 2025年1月8日（ISO週番号: 2）
    const evenWeekDate = new Date('2025-01-08')
    expect(getPossibleMeetingDates(evenWeekDate)).toEqual([
      '2025-01-08',
      '2025-01-22',
      '2025-02-05',
      '2025-02-19',
    ])
  })

  test('週数が52週の年で、末の日付を渡した場合、年をまたぐweek numberが正しく計算される', () => {
    // 2025年12月17日（ISO週番号: 51）
    const oddWeekDate = new Date('2025-12-17')
    expect(getPossibleMeetingDates(oddWeekDate)).toEqual([
      '2025-12-17',
      '2025-12-31',
      '2026-01-14',
      '2026-01-28',
    ])

    // 2025年12月24日（ISO週番号: 52）
    const evenWeekDate = new Date('2025-12-24')
    expect(getPossibleMeetingDates(evenWeekDate)).toEqual([
      '2025-12-24',
      '2026-01-07',
      '2026-01-21',
      '2026-02-04',
    ])
  })

  test('週数が53週の年で、末の日付を渡した場合、年をまたぐweek numberが正しく計算される', () => {
    // 2026年12月23日（ISO週番号: 52）
    const evenWeekDate = new Date('2026-12-23')
    expect(getPossibleMeetingDates(evenWeekDate)).toEqual([
      '2026-12-23',
      '2027-01-13',
      '2027-01-27',
      '2027-02-10',
    ])

    // 2026年12月30日（ISO週番号: 53）
    const oddWeekDate = new Date('2026-12-30')
    expect(getPossibleMeetingDates(oddWeekDate)).toEqual([
      '2026-12-30',
      '2027-01-06',
      '2027-01-20',
      '2027-02-03',
    ])
  })
})
