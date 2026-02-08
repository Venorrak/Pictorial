# Database Schema for Messaging Application
User:
- id: INT PK AI
- name: VARCHAR(50) NN UQ
- password: VARCHAR(100) NN # Hashed password for security

Channel:
- id: INT PK AI
- name: VARCHAR(50) NN UQ
- description: TEXT
- created_at: DATETIME NN DEFAULT CURRENT_TIMESTAMP
- 

Message: # content and image are optional, but at least one must be provided
- id: INT PK AI
- channel_id: INT FK -> Channel(id)
- user_id: INT FK -> User(id)
- content: TEXT # Optional text content of the message
- image: blob # Optional image (png)  
- created_at: DATETIME NN DEFAULT CURRENT_TIMESTAMP

## Relationships:
- A User can send multiple Messages (1-to-many relationship between User and Message).
- A Channel can have multiple Messages (1-to-many relationship between Channel and Message).

## Constraints:
- User.name must be unique.
- Channel.name must be unique
- Message must have at least one of content or image not null
- Foreign keys in Message must reference existing User and Channel records.

# App needs
- Backend written in go
- Database: MySQL or PostgreSQL
- must use ORM
- RESTful API design
- Authentication, Authorization & Session Management
- Input validation & error handling
- must be containerized using Docker
- must be scalable and maintainable
- Documentation for API endpoints and database schema