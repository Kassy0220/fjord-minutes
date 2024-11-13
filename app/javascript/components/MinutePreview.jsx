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
        <pre id="raw_markdown" className="p-4 border">
          {markdown}
        </pre>
      </Tabs.Item>
      <Tabs.Item title="Preview">
        <div
          id="markdown_preview"
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
      base: 'flex items-center justify-center rounded-t-lg p-4 me-2 border border-b-0 border-gray-300 text-sm font-medium',
      variant: {
        default: {
          base: 'rounded-t-lg',
          active: {
            on: 'bg-blue-700 text-white font-bold',
            off: 'text-gray-500 hover:bg-blue-50',
          },
        },
      },
    },
  },
}

MinutePreview.propTypes = {
  markdown: PropTypes.string,
}
