# Election Alert App

A real-time danger alert monitoring system for electoral officials and security 

## Table of Content

* [Project Description](#project-description)

* [Design Methodology](#design-methodology)

* [Tools and Technologies Used](#tools-and-technologies-used)  
    * [Frontend](#frontend)
    * [Backend](#backend)
    * [Database](#database)
    
* [System Design](#system-design)  
    * [Use Case Designs](#use-case-designs)
        * [Alerting Use Case Design](#alerting-use-case-design)  
        * [Account Management Use Case Design](#account-management-use-case-design)
        * [In-App Call Use Case Design](#in-app-call-use-case-design)
        * [Login/Signup Use Case Design](#login-signup-use-case-design)
        
    * [Activity Design](#activity-design)
        
    * [Database Design](#database-design)

* [System Architecture](#system-architecture)
    
* [Some App Components Screenshots](#some-app-components-screenshots)
    * [Login Screen](#login-screen)
    * [Sign up Screen](#signup-screen)
    * [Home Screen](#home-screen)
    * [Police Hotline Screen](#police-hotline-screen)
    
* [Security Data Features](#security-data-features)

## Project Description

The project idea was awarded as my final year undergraduate project where I was tasked to research, design, and develop a real-time danger alert monitoring system for electoral officials and security agencies using Nigeria as the case study.

## Design Methodology 

* Choice of design methodology is Lean agile. Not a traditional software design methodology but an approach combining principles from lean and agile. It aims to deliver customer value efficiently and effectively while being flexible and adaptable to changes throughout the development lifecycle. 


## Languages, Frameworks, and Technologies Used
#### Frontend
* Flutter (Dart)

#### Backend
* NodeJs
* SocketIO (For sending alerts/notifications across all users in real-time)
* Termii (For verification of users' phone numbers through text message)
* Google Maps API

#### Database
* Firebase Authentication (For storage and authentication of users' login details)
* Firebase Storage (For the storage of users' profile pictures and other media)  
* Firebase Firestore (For the storage of other users' personal details, election alerts, location, etc)

## System Design

#### Use Case Designs
![](https://raw.githubusercontent.com/CodeDeveloper19/Images/main/ElectionAlert/use_Case_simplified.png)

###### Alerting Use Case Design
![](https://raw.githubusercontent.com/CodeDeveloper19/Images/main/ElectionAlert/alert_use_case.png)

###### Account Management Use Case Design
![](https://raw.githubusercontent.com/CodeDeveloper19/Images/main/ElectionAlert/accountmanagement_use_case_diagram.png)

###### In App Call Use Case Design
![](https://raw.githubusercontent.com/CodeDeveloper19/Images/main/ElectionAlert/in-app_call_use_case.png)

###### Login Signup Use Case Design
![](https://raw.githubusercontent.com/CodeDeveloper19/Images/main/ElectionAlert/loginsignup_use_case_diagram.png)

#### Activity Design
![](https://raw.githubusercontent.com/CodeDeveloper19/Images/main/ElectionAlert/activity.png)

#### Database Design
![](https://raw.githubusercontent.com/CodeDeveloper19/Images/main/ElectionAlert/Er_model.png)

## System Architecture
![](https://raw.githubusercontent.com/CodeDeveloper19/Images/main/ElectionAlert/lalaa.png)

## Implementation Architecture
![](https://raw.githubusercontent.com/CodeDeveloper19/Images/main/ElectionAlert/la.png)

## Some App Components Screenshots
#### Login Screen    
<img src="https://raw.githubusercontent.com/CodeDeveloper19/Images/main/ElectionAlert/signin.png" width="200" height="500">

#### Signup Screen
<img src="https://raw.githubusercontent.com/CodeDeveloper19/Images/main/ElectionAlert/signinup.png" width="200" height="500">

#### Home Screen
<img src="https://raw.githubusercontent.com/CodeDeveloper19/Images/main/ElectionAlert/homepage.png" width="250" height="500">

#### Police Hotline Screen
<img src="https://raw.githubusercontent.com/CodeDeveloper19/Images/main/ElectionAlert/police_hotlines.png" width="250" height="500">

## Security Data Features
* Ensured only verified users on the system can send out alert reports and make phone calls.
* Ensured verified users can only send reports about their polling units within a 200m radius.
* Increased network connectivity by saving crucial data such as JSON files and user information the system uses on the user’s phone.
* Ensured that only authorized users can create, read, update, and delete information on the database.



