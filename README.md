# Web Scraping Application

## Overview
This is a full-stack web application built using **Ruby on Rails** for the backend and **React** for the frontend. The application scrapes product details from an e-commerce webpage (e.g., Flipkart) and displays the information in a user-friendly interface. 

The project demonstrates key technical strengths in full-stack development, including web scraping, data management, and responsive UI implementation.

---

## Features

### 1. Web Scraping & Data Storage
- Scrapes product details such as **title**, **description**, **price**, **size**, and **category** from a provided e-commerce product URL.
- Stores scraped data in a **PostgreSQL database**.
- Data is categorized by product type.

### 2. Product Display and Management
- Responsive UI for users to:
  - Submit URLs for scraping.
  - View listed products categorized by type.
- Automatically updates product data if it is older than one week, with updates handled asynchronously.

### 3. Search and Interaction
- Search and filter products based on keywords and categories.
- Implements an asynchronous search feature with a debounce mechanism for better user experience.

---

## Tech Stack

### Backend
- **Ruby on Rails**: Backend framework for API development and data management.
- **Nokogiri**: Library for web scraping.
- **selenium-webdriver**: Selenium implements the W3C WebDriver protocol to automate popular browsers.
- **Sidekiq**: For background jobs, including asynchronous updates of product data.
- **PostgreSQL**: Database for storing product details.


## Setup Instructions

### Prerequisites
Ensure the following tools are installed:
- **Ruby** (version `3.2.0`)
- **Rails** (version `8.0.1` or later)

### Backend Setup
1. Clone the repository:
   ```bash
   https://github.com/shahnawaz-ror/scraper_product_backend.git
   cd scraper_product_backend
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   rails db:create db:migrate
   ```

4. Add Sidekiq gem:
   ```bash
   gem 'sidekiq'   

   bundle install   

   bundle exec sidekiq
   ```

5. Run the Rails server:
   ```bash
   rails server
   ```



---

## License
This project is licensed under the MIT License.
