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
