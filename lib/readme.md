# Confab-Chat-App Pages

## Main Page

The main page of the Chat App serves as the entry point, orchestrating the initialization of Firebase, user authentication, and navigation through the app.

## Firebase Options Configuration

This page is responsible for configuring Firebase options, ensuring that the appropriate Firebase options are set based on the target platform.

## TopBar Widget

This custom widget provides a consistent user interface element across the application.

## RoundedImage Widgets

These widgets display images with rounded corners, either from a network source or from a local file.

## Message Bubble Widgets

These widgets display chat messages, either as text or as an image, with a unique design for the sender's own messages.

## CustomListViewTileWithActivity Widget

This custom widget displays a list tile with an activity indicator.

## CustomListViewTile Widgets

These widgets display list tiles with varying levels of detail and interactivity.

## Custom Input Fields

These custom widgets capture user input and display it in a specific format.

## Navigation Service

Handles navigation between different pages in the application.

## Media Service

Handles the process of picking images from the device's image library.

## Database Service

Handles the interaction with the Firestore database.

## Cloud Storage Service

Handles the process of saving files (such as images and voice messages) to Firebase Cloud Storage.

## User Page Provider

Manages the state of the user page, including the list of users, the currently selected users, and the search status.

## Chats Page Provider

Manages the state of the chats page, including the list of chats and the currently selected users.

## Chat Page Provider

Manages the state of the chat page, including the list of messages and the currently typed message.

## Authentication Provider

Manages the authentication state of the application.

## Users Page

Displays a list of all logged-in users. Uses a StreamBuilder to display the user’s profile image and the user’s name. Uses the Navigation Service to navigate to the Chat Page when a user is selected.

## User Profile Page

Allows users to change their display name and add a few details of themselves. Also, upload an image of themselves. Uses the Database Service to interact with Firestore and update the user's information.

## Splash Screen

Checks if the user is logged in using the Authentication Provider. If the user has already signed in with the Google Sign-In method, the user will be redirected to the home page. Otherwise, the user will be directed to the login page.

## Registration Page

Provides options for user registration. Uses the Authentication Provider to authenticate the user.

## Login Page

Provides options for user login. Uses the Authentication Provider to authenticate the user.

## Home Page

Displays a scaffold with an AppBar and a search bar for searching users. Uses the Navigation Service to navigate to the User Profile Page and the Login Page.

## Chats Page

Displays a list of all chats. Uses the Chats Page Provider to manage the state of the page.

## Chat Page

Displays a chat interface with a message portion at the top of the screen and a text field with an image and send button at the bottom of the screen. Uses the Chat Page Provider to manage the state of the page.
