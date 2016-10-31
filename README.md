# ECommerce-Mobile-Tests
Simple mobile clients to test Mobile RUM beacon generation for the [ECommerce](https://github.com/Appdynamics/ECommerce-Docker) application.

These applications use a variety of languages and networking frameworks, with simple "bare-bones" user interfaces. Their primary purpose is to test beacon generation and server request correlation using the AppDynamics Mobile RUM Agents.

For each project, you will need to import the AppDynamics Mobile Agent for your target platform using Cocoapods (instructions below) and configure the mobile application for your ECommerce target and EUM Collector/AppKey.  Each project has an information properties file (ECommerce.plist) to set those properties.

To build the projects:

1. Install [Cocoapods](https://cocoapods.org/)
2. Run `pod install`
3. Open the .xcworkspace for the project  