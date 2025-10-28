# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LMImageMgic is an iOS image creation and manipulation application with AI-powered features. The app allows users to create, edit, and manage image creations using various AI tools and templates.

## Development Environment

### Build Commands
- **Build the project**: Use Xcode to build the `LMImageMgic` scheme
- **Install dependencies**: `pod install` (CocoaPods dependency manager)
- **Clean build**: Clean build folder in Xcode, then `pod install` and rebuild
- **Run on simulator/device**: Select target in Xcode and press Cmd+R

### Project Structure
- **LMImageMgic/**: Main application source code
  - **Application/**: App lifecycle and setup (AppDelegate, MainApplication)
  - **Bussniess/**: Core business logic and feature implementations
  - **CoreService/**: Shared services (Account, Cache, Network, Upload, etc.)
  - **Model/**: Data models and entities
  - **UIKit/**: Custom UI components and views
  - **ViewModel/**: View models for MVVM architecture
  - **Base/**: Base classes and utilities
  - **Resource/**: Assets, JSON files, and resources

### Dependencies
The project uses CocoaPods with the following key dependencies organized by function:

**Network & Data**:
- Alamofire (HTTP networking)
- SDWebImage (image loading/caching)
- CocoaLumberjack (logging)

**UI Components**:
- MJRefresh (pull-to-refresh)
- Lottie (animations)
- HWPanModal (modal presentations)
- Toast-Swift (toast notifications)

**Utilities**:
- YYKit (cache, categories, text)
- RxSwift/RxCocoa (reactive programming)
- SwiftyStoreKit (in-app purchases)
- KeychainAccess (secure storage)

**Analytics & Reporting**:
- Firebase Analytics
- Facebook SDK
- Adjust

**JavaScript Bridge**:
- dsBridge (JavaScript-Native communication)

### Core Architecture

#### Application Setup
- **MainApplication**: Centralized app setup and configuration manager
- **AppDelegate**: Handles app lifecycle, window setup, and initial configuration
- **TabbarViewController**: Main navigation controller

#### Service Layer
- **AccountManager**: User authentication and token management
- **NetworkCore/NetworkMonitor**: Network operations and connectivity monitoring
- **CacheManager**: Data caching strategies using YYCache
- **ConfigManager**: App configuration and feature flags
- **Reporter**: Analytics and event tracking
- **S3Uploader/UploadUtils**: File upload functionality

#### Business Logic
- **AI API Integration**: `AIApi` class handles AI service communication
- **Creation Management**: Image creation workflow and processing
- **Library Management**: User's creation library and history

#### Key Models
- **AssetsInfo**: User account and asset information
- **CreationInfo**: Image creation data and metadata
- **OrderInfo**: Purchase and order information
- **ProductInfo**: Product and pricing data
- **PromptInfo**: AI prompt and generation data

### Development Notes

#### Module Organization
- Follows MVVM pattern with ViewModels in separate directory
- Core services are modularized and reusable
- Business logic separated into feature-based modules
- UI components organized by functionality

#### Configuration
- Minimum iOS version: 13.0 (specified in Podfile)
- M1 CPU support configured for simulator builds
- Dark mode enabled by default
- Modular headers enabled for CocoaPods

#### Networking
- Token-based authentication with automatic refresh
- Centralized network configuration through `NetworkConfig`
- Error handling and retry mechanisms built into NetworkCore

#### Development Workflows
1. **Adding new features**: Create corresponding folders in Bussniess/
2. **UI components**: Add to UIKit/ with appropriate categorization
3. **Service modifications**: Update CoreService/ modules
4. **Model changes**: Update Model/ and corresponding ViewModels

#### Build Considerations
- Post-install script handles M1 simulator compatibility
- All warnings inhibited during build
- Workspace structure: `LMImageMgic.xcworkspace`
- Main target: `LMImageMgic`