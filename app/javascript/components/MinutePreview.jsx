import { Tabs } from 'flowbite-react'
import { marked } from 'marked'
import DOMPurify from 'dompurify'
import PropTypes from 'prop-types'

export default function MinutePreview({ markdown }) {
  const sanitizedHTML = {
    __html: DOMPurify.sanitize(marked.parse(markdown, [{ gfm: true }])),
  }

  return (
    <Tabs aria-label="Default tabs" variant="default" theme={customTheme}>
      <Tabs.Item active title="Markdown">
        <pre className="p-4 border">{markdown}</pre>
      </Tabs.Item>
      <Tabs.Item title="Preview">
        <div
          className="p-4 border markdown-body"
          dangerouslySetInnerHTML={sanitizedHTML}
        />
      </Tabs.Item>
    </Tabs>
  )
}

const customTheme = {
  base: 'flex flex-col gap-2',
  tablist: {
    tabitem: {
      base: 'flex items-center justify-center rounded-t-lg p-4 text-sm font-medium first:ml-0 focus:outline-none focus:ring-2 focus:ring-gray-500 disabled:cursor-not-allowed',
      variant: {
        default: {
          base: 'rounded-t-lg',
          active: {
            on: 'bg-gray-400 text-white dark:bg-gray-800 dark:text-cyan-500',
            off: 'text-gray-500 hover:bg-gray-50 hover:text-gray-600 dark:text-gray-400 dark:hover:bg-gray-800 dark:hover:text-gray-300',
          },
        },
      },
    },
  },
}

MinutePreview.propTypes = {
  markdown: PropTypes.string,
}
