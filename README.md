# Accessibility Map

A web application that helps users discover and rate the accessibility of public spaces. Users can search for locations, view accessibility features, read and write reviews, and contribute to building a comprehensive database of accessible locations.

## 🎯 Project Description

Accessibility Map is a community-driven platform where users can rate the accessibility of public areas including cafes, libraries, offices, and other indoor spaces. The application allows users to identify locations with specific accessibility features such as wheelchair ramps, accessible restrooms, elevators, braille signage, and more. Users can filter locations by accessibility features, search for places, and share their experiences through reviews.

## ✨ Features

### Core Functionality
- **Interactive Map**: Navigate an interactive map to explore accessible locations with clickable markers
- **Location Search**: Full-text search across location names, addresses, cities, and zip codes
- **Accessibility Features**: Locations can be tagged with multiple accessibility features organized by categories:
  - **Physical Accessibility**: Wheelchair accessible, accessible restrooms, elevator access, wide aisles, automatic doors
  - **Food & Diet**: Vegetarian, vegan, kosher, halal options
  - **Environment**: Quiet space, human service
  - **Family & Pets**: Pet-friendly, child-friendly, high chair available
- **Reviews**: Users can read and write reviews about locations (minimum 10 characters)
- **Favorites**: Save favorite locations for quick access
- **Image Uploads**: Add multiple images to locations with alt text support (JPG, JPEG, PNG only)
- **PDF Export**: Generate PDF reports for location details and reviews
- **Filtering**: Filter locations by accessibility features and favorites

### User Management
- **Authentication**: Custom authentication system with email/password and Google OAuth support
- **User Profiles**: User accounts with profile management
- **Authorization**: Users can only edit/delete locations and reviews they created
- **Content Moderation**: Profanity filtering for location names, addresses, reviews, and image alt text

### Technical Features
- **Geocoding**: Automatic coordinate generation from addresses using Geocoder
- **Responsive Design**: Mobile-friendly interface built with Tailwind CSS
- **Real-time Updates**: Map updates dynamically as locations are added
- **Pagination**: Efficient pagination for location listings
- **Accessibility**: Screen reader support and semantic HTML

## 🛠️ Tech Stack

### Backend
- **Ruby on Rails 8.0.3** - Web framework
- **Ruby 3.4.6** - Programming language
- **PostgreSQL** - Database
- **Puma** - Web server

### Frontend
- **Tailwind CSS 4.x** - Styling framework
- **Stimulus** - JavaScript framework
- **Turbo** - SPA-like page acceleration
- **Mapkick** - Interactive map rendering

### Key Gems
- `geocoder` - Address geocoding
- `pg_search` - Full-text search
- `mapkick-rb` - Map visualization
- `will_paginate` - Pagination
- `prawn` & `prawn-table` - PDF generation
- `omniauth` & `omniauth-google-oauth2` - OAuth authentication
- `obscenity` - Content moderation
- `aws-sdk-s3` - Image storage (production)
- `image_processing` - Image variant generation

### Development & Testing
- **RSpec** - Testing framework
- **Cucumber** - BDD testing
- **Capybara** - Integration testing
- **Brakeman** - Security scanning
- **RuboCop** - Code linting
- **ERB Lint** - Template linting

## 🚀 Getting Started

### Prerequisites
- Ruby 3.4.6
- PostgreSQL 9.3+
- Bundler
- Node.js (for asset compilation)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/NU-CS-Software-Studio-Fall-25/project-accessibility-map.git
   cd project-accessibility-map
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up the database**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed  # Optional: Load sample data
   ```

4. **Configure environment variables**
   - Set up Google OAuth credentials (if using OAuth)
   - Configure AWS S3 credentials (for production image storage)
   - Set up Geocoder API key (if required)

5. **Start the development server**
   ```bash
   bin/dev
   ```

   Or use the setup script:
   ```bash
   bin/setup
   ```

The application will be available at `http://localhost:3000`

### Running Tests

```bash
# Run RSpec tests
bundle exec rspec

# Run Cucumber features
bundle exec cucumber
```

## 📋 Key Models

- **Location**: Stores location information (name, address, coordinates, features)
- **Review**: User reviews for locations
- **Feature**: Accessibility features that can be associated with locations
- **User**: User accounts with authentication
- **Session**: User session management

## 🌐 Deployment

The application is deployed on Heroku and can be accessed at:
**https://project-accessibility-map-50cd81ed0a73.herokuapp.com**

The application can also be containerized using Docker (see `Dockerfile`) and deployed with Kamal.

### Deploying to Heroku

#### Initial Setup (First Time Only)

1. **Install Heroku CLI** (if not already installed)
   ```bash
   # macOS
   brew tap heroku/brew && brew install heroku

   # Or download from https://devcenter.heroku.com/articles/heroku-cli
   ```

2. **Login to Heroku**
   ```bash
   heroku login
   ```

3. **Create a Heroku app** (if not already created)
   ```bash
   heroku create project-accessibility-map
   # Or use existing app
   heroku git:remote -a project-accessibility-map-50cd81ed0a73
   ```

4. **Set up PostgreSQL addon**
   ```bash
   heroku addons:create heroku-postgresql:mini
   ```

5. **Configure environment variables**
   ```bash
   heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
   heroku config:set GOOGLE_OAUTH_CLIENT_ID=your_client_id
   heroku config:set GOOGLE_OAUTH_CLIENT_SECRET=your_client_secret
   # Add other required environment variables
   ```

#### Deploying with Database Schema Updates

Your `Procfile` includes a `release` task that automatically runs migrations on each deploy:

```procfile
release: bundle exec rails db:migrate
web: bundle exec puma -C config/puma.rb
```

**To deploy and update the database schema:**

1. **Commit your changes** (including new migrations)
   ```bash
   git add .
   git commit -m "Add database migrations"
   ```

2. **Push to Heroku**
   ```bash
   git push heroku main
   # Or if your branch is different:
   git push heroku your-branch-name:main
   ```

   Heroku will automatically:
   - Build your application
   - Run the `release` task (which executes `rails db:migrate`)
   - Restart the web dyno

3. **Verify the deployment**
   ```bash
   heroku logs --tail
   ```

#### Manual Migration (If Needed)

If you need to run migrations manually (e.g., if the release task failed):

```bash
# Run pending migrations
heroku run rails db:migrate

# Check migration status
heroku run rails db:migrate:status

# Rollback last migration (if needed)
heroku run rails db:rollback
```

#### Troubleshooting

**If migrations fail during deploy:**

1. **Check the logs**
   ```bash
   heroku logs --tail
   ```

2. **Run migrations manually**
   ```bash
   heroku run rails db:migrate
   ```

3. **Check database connection**
   ```bash
   heroku pg:info
   heroku pg:psql
   ```

4. **Verify migration files are committed**
   ```bash
   git log --oneline db/migrate/
   ```

**Common Issues:**

- **Migration errors**: Check that all migrations are compatible with your production database state
- **Missing environment variables**: Ensure all required config vars are set with `heroku config`
- **Database connection issues**: Verify PostgreSQL addon is provisioned and active

#### Useful Heroku Commands

```bash
# View app info
heroku info

# Open app in browser
heroku open

# Run Rails console
heroku run rails console

# View environment variables
heroku config

# View database info
heroku pg:info

# Access PostgreSQL console
heroku pg:psql

# Restart the app
heroku restart

# Scale dynos
heroku ps:scale web=1
```

## 👥 Team Members

- Brandon Do
- Darian Liang
- Larry Ling
- Chisa Yan

## 📝 License

This project is part of an academic/educational project.

## 🔮 Future Enhancements

- Additional accessibility features based on ADA and WCAG standards
- Disability-specific needs and filters
- Enhanced search and filtering capabilities
- Mobile app version
- Community moderation features
- Location verification system
