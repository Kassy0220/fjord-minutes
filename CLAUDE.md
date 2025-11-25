# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Application Overview

FjordMinutes is a meeting minutes management web application for Fjord Bootcamp's team development practice. It automates minute creation, tracks attendance, and exports minutes to GitHub Wiki with real-time collaborative editing.

**Tech Stack:**
- Backend: Ruby on Rails 7.2.2.1 (Ruby 3.4.2)
- Frontend: React 18.3.1 + Hotwire (Turbo/Stimulus)
- Database: PostgreSQL
- Real-time: ActionCable with Redis
- Styling: TailwindCSS + Flowbite
- Build: esbuild (via jsbundling-rails)
- Auth: Devise + GitHub OAuth

## Common Development Commands

### Setup & Running
```bash
bin/setup              # Complete setup (gems, npm, db, seed data)
bin/dev                # Start all services (Rails, esbuild, Tailwind)
```

### Testing
```bash
bin/rspec                          # Run all tests
bin/rspec spec/models              # Run specific directory
bin/rspec spec/system/minutes_spec.rb  # Run single file
bin/rspec spec/system/minutes_spec.rb:25  # Run specific line
```

### Linting
```bash
bin/run_lint                       # Run all linters
bundle exec rubocop                # Ruby only
bundle exec rubocop -a             # Auto-fix Ruby issues
bundle exec erb_lint --lint-all    # ERB templates
npm run lint:eslint                # JavaScript
npm run lint:prettier              # JavaScript formatting
```

### Database
```bash
bin/rails db:migrate
bin/rails db:rollback
bin/rails db:schema:load
bin/rails db:seed
```

### Asset Building
```bash
npm run build                      # Build JavaScript (esbuild)
bin/rails assets:precompile        # Precompile all assets
```

## Architecture & Key Patterns

### Real-time Updates with ActionCable

The application uses ActionCable for real-time collaborative editing. When an admin edits a minute, changes are broadcast to all connected clients.

**Flow:**
1. React component subscribes via `useChannel` hook (see `app/javascript/hooks/useChannel.js`)
2. Backend broadcasts changes via `MinuteChannel` (see `app/channels/minute_channel.rb`)
3. Connected clients receive updates and re-render with new data

**Example:**
```javascript
// In React component
const onReceivedData = useCallback(function (data) {
  if ('topics' in data.body) {
    setAllTopics(data.body.topics)
  }
}, [])
useChannel(minuteId, onReceivedData)
```

**Important:** When creating React components that display minute data, consider whether they need real-time updates. If yes, use `useChannel`. If no (like form components), keep them separate to avoid unnecessary re-renders.

### React Component Mounting

React components are mounted to DOM elements via `mountComponent` utility:

1. Add component to `app/javascript/application.js`:
```javascript
import MyComponent from './components/MyComponent'
mountComponent('my_component', MyComponent)
```

2. Add DOM element in ERB view:
```erb
<%= content_tag :div, id: 'my_component', data: { prop1: value1 }.to_json do %><% end %>
```

The `data` attribute is automatically passed as props to the React component.

### API Structure

RESTful JSON API under `/api` namespace. All endpoints require admin authentication.

**Pattern:**
- Controllers in `app/controllers/api/`
- Routes namespaced under `api`
- Return JSON with appropriate HTTP status codes
- Broadcast changes via ActionCable after mutations

**Example:**
```ruby
# app/controllers/api/minutes/topics_controller.rb
def create
  topic = Topic.new(topic_params)
  if topic.save
    broadcast_topics  # Notify all clients
    render json: topic, status: :created
  else
    render json: { errors: topic.errors.full_messages }, status: :unprocessable_entity
  end
end
```

### Form Objects Pattern

Complex forms with validation logic are extracted to `app/forms/`:

```ruby
# app/forms/attendance_form.rb
class AttendanceForm
  include ActiveModel::Model
  # Handles attendance creation/update for afternoon and night sessions
end
```

Use this pattern when a form involves multiple models or complex business logic.

### GitHub Wiki Export

The `Minute#export_to_github_wiki` method uses GitHub App authentication to push minutes to wiki repositories.

**Key points:**
- Uses JWT + Installation tokens for GitHub App auth
- Clones wiki repo to temporary directory (`bootcamp_wiki_repository/` or `agent_wiki_repository/`)
- Renders minute using ERB template (`config/templates/minute.md`)
- Commits and pushes to wiki's master branch
- GitHub App private key stored in Rails credentials (`EDITOR="vim" bin/rails credentials:edit`)

### Authentication & Authorization

Two user types with different permissions:
- **Admin:** Full access (edit all fields, export to wiki)
- **Member:** Limited access (add topics, register attendance)

Both authenticate via GitHub OAuth. Use `authenticate_development_member!` for routes accessible by both types.

**Hibernation handling:** Members can be marked as hibernating. Hibernated members are automatically signed out via `before_action :sign_out_hibernated_member` in ApplicationController.

## Important Development Notes

### Running System Tests

System tests use Capybara + Selenium. For JavaScript-enabled tests:
```ruby
scenario 'can create topic', :js do
  # Test code with real-time updates
end
```

When testing real-time features, ensure Redis is running locally.

### Real-time Feature Dependencies

- **Development:** Redis is optional but recommended for testing real-time features
- **Production:** Redis is required (configured via `REDIS_URL`)

Install Redis: https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/

### Version Management

- **Ruby:** Managed by mise (see `mise.toml`)
- **Node.js:** See `.node-version` (22.8.0)

To switch Ruby version:
```bash
mise install
```

### Environment Variables

Required for full functionality (see README.md for complete list):
- `AUTH_APP_ID`, `AUTH_APP_SECRET` - GitHub OAuth
- `KOMAGATA_EMAIL`, `MACHIDA_EMAIL`, `KASSY_EMAIL` - Admin emails
- `BOOTCAMP_WIKI_URL`, `AGENT_WIKI_URL` - Wiki repository URLs
- `GITHUB_USER_NAME`, `GITHUB_USER_EMAIL` - Git commit author
- `GITHUB_APP_ID`, `GITHUB_APP_INSTALLATIONS_ID` - GitHub App credentials
- Discord webhook URLs and role IDs

For local development, see: [Development環境でログインする方法](https://github.com/Kassy0220/fjord-minutes/wiki/Development%E7%92%B0%E5%A2%83%E3%81%A7%E3%83%AD%E3%82%B0%E3%82%A4%E3%83%B3%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95)

### Code Style & Conventions

- **Ruby:** RuboCop with rubocop-fjord config + Rails/Performance/RSpec plugins
- **ERB:** erb_lint for template linting
- **JavaScript:** ESLint (React, React Hooks, jsx-a11y) + Prettier

Auto-fix where possible with `bundle exec rubocop -a` and ensure `bin/run_lint` passes before committing.

### Database Schema Key Points

- **courses:** Two types - `back_end` (bootcamp) and `front_end` (agent)
- **meetings:** Associated with course, stores meeting date and schedule
- **minutes:** Associated with meeting, stores release info and content
- **attendances:** Tracks afternoon/night session attendance per member
- **topics:** Polymorphic association - belongs to either Member or Admin
- **hibernations:** Tracks member hibernation status with start/end dates

### Automatic Meeting Schedule

Meetings are scheduled based on odd/even weeks:
- Next meeting date calculated by `Meeting#set_next_date` callback
- Discord notifications sent on meeting day via `Meeting#notify_meeting_day`
- New minute automatically created the day after meeting

### Working with React Components

When modifying React components that subscribe to ActionCable:

1. **Avoid unnecessary re-renders:** If a component doesn't need real-time updates (e.g., form inputs), keep it separate from components that do
2. **Example:** `TopicForm` is separate from `Topics` to prevent input loss when topics update
3. **Use stable keys:** For list items that can be reordered, always provide stable `key` props

## Deployment

- Platform: Heroku
- Database: PostgreSQL 16.4
- Redis: Required for ActionCable
- CI/CD: GitHub Actions runs tests and linters on every push
