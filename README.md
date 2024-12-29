This project implemented with Clean Layered Architecture and MVVM+C

This project is an iOS application dedicated to enhancing user gallery categorization using Artificial Intelligence. It offers a seamless experience for users to explore their image gallery and map views, along with a detailed screen for deeper insights into specific items. The architecture is designed to ensure scalability, maintainability, and testability.

## Application Features
1. **Gallery Screen**: Displays a curated collection of user images.
2. **Map Screen**: Visualizes the geographical locations associated with the images.
3. **Detailed Screen**: Provides in-depth details for a selected image, including AI-generated metadata.

## Architectural Overview
The app adheres to a Clean Layered Architecture, with the following layers:

![Clean Architecture + MVVM](README_FILES/CA.png?raw=true "Clean Architecture + MVVM")
![Clean Architecture + MVVM](README_FILES/appLayers.png?raw=true "")
### 1. Domain Layer
- **Responsibilities**:
  - Defines essential protocols and entities required by the application.
  - Acts as the core, independent of other layers.
- **Key Components**:
  - Protocols for repository interfaces.
  - Entities representing the core data models.

### 2. Data Layer
- **Responsibilities**:
  - Implements the requirements specified by the Domain layer.
  - Bridges the Domain and Infrastructure layers.
- **Key Components**:
  - Repositories that adhere to Domain protocols.

### 3. Infrastructure Layer
- **Responsibilities**:
  - Implements necessary services for interacting with Core Data and Core ML.
  - Manages persistent storage and AI processing.
- **Key Components**:
  - Core Data stack for persistent storage.
  - Core ML integration for image categorization and metadata generation.

### 4. Presentation Layer
- **Responsibilities**:
  - Manages the user interface and user interactions.
  - Utilizes the MVVM+C (Model-View-ViewModel + Coordinator) pattern to organize the UI flow.
- **Key Components**:
  - **ViewModel**: Handles business logic, consumes input streams, and produces output streams.
  - **Coordinator**: Manages navigation between screens and scopes.
  - **View**: Subscribes to output streams from the ViewModel to update the UI.

## Scope-based Organization
The application is divided into distinct scopes, ensuring modularity and isolation:
1. **Main Scope**: Sets up the initial application context.
2. **TabBar Scope**: Provides a tab-based navigation interface.
3. **Gallery Scope**: Manages the Gallery screen.
4. **Map Scope**: Handles the Map screen.
5. **Detailed Scope**: Controls the Detailed screen.

Each scope:
- Is isolated, exposing only the necessary dependencies to its parent scope.
- Ensures a clear separation of concerns and streamlined dependency management.

![Clean Architecture + MVVM](README_FILES/dependancy.png?raw=true "Clean Architecture + MVVM")

## MVVM+C Pattern in Detail
- **ViewModel**:
  - Consumes Events (inputs) from streams, usually provided by the View.
  - Processes inputs using business logic and generates Output Streams for the View.
  - Inputs and outputs are type-safe, defined explicitly in code to reduce errors.
![MVVM inout](README_FILES/inoutVM.webp?raw=true "MVVM + inout contract")

- **Coordinator**:
  - Connects with specific scopes to manage navigation and transitions.
  - Populates ViewControllers and ViewModels with use cases.

## Technology Stack
- **Core Data**: Persistent storage for images and metadata.
- **Core ML**: AI-powered image categorization and metadata generation.
- **UIKit** & **SwiftUI**: UI frameworks for building the app’s interface.
- **Combine**: Reactive programming framework for managing data streams.