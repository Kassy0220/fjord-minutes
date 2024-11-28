import { useState } from 'react'
import { marked } from 'marked'
import DOMPurify from 'dompurify'
import PropTypes from 'prop-types'

export default function MinutePreview({ markdown }) {
  const [selectedTab, setSelectedTab] = useState('markdown')

  const sanitizedHTML = {
    __html: DOMPurify.sanitize(marked.parse(markdown, [{ gfm: true }])),
  }

  return (
    <div>
      <div className="mb-8">
        <ul className="flex flex-wrap text-sm text-center border-b border-gray-300 !list-none">
          <li className="me-2">
            <button
              onClick={() => setSelectedTab('markdown')}
              className={
                selectedTab === 'markdown'
                  ? 'active_large_tab_item'
                  : 'large_tab_item'
              }
            >
              Markdown
            </button>
          </li>
          <li className="me-2">
            <button
              onClick={() => setSelectedTab('preview')}
              className={
                selectedTab === 'preview'
                  ? 'active_large_tab_item'
                  : 'large_tab_item'
              }
            >
              Preview
            </button>
          </li>
        </ul>
      </div>

      <div>
        {selectedTab === 'markdown' ? (
          <pre id="raw_markdown" className="p-4 border border-gray-300">
            {markdown}
          </pre>
        ) : (
          <div
            id="markdown_preview"
            className="p-4 border border-gray-300 markdown-body"
            dangerouslySetInnerHTML={sanitizedHTML}
          />
        )}
      </div>
    </div>
  )
}

MinutePreview.propTypes = {
  markdown: PropTypes.string,
}
