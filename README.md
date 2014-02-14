CEDEC AI CHALLENGE 2014
=======================

## Architecture

https://docs.google.com/presentation/d/1qPkDdKSJC96pJ3jnn36UiV8LYhu1dpjTUWUi4-Fj7mw/edit?usp=sharing

## How to Play

To test our contest platform, this platform has a sample game (rock-paper-scissors).

1. Open the following URL
http://www.ai-comp.net/CEDEC2014/GameEngine/
1. Run ProxyServer if you want to use URL instead of Code
1. Enter URL or Code
1. Push OK

## Setup Development Environment

### Prepare Eclipse Environment with Maven
1. Install Maven 3
http://maven.apache.org/download.cgi
1. Install Eclipse
  * Eclipse IDE for Java Developers (*not Standard*) Kepler (4.3.1)
http://www.eclipse.org/downloads/
1. Run Eclipse
1. Menu > Help > Install new software
1. Install Xtend plugin on Eclipse (Copy & Paste the following URL)
http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/  
Note that you can see the language specification of Xtend here (https://www.eclipse.org/xtend/).


### Import the ProxyServer Project into Your Eclipse Workspace
1. Run Eclipse
1. Import > Existing Maven Projects
1. Enter the ```ProxyServer``` directory containing pom.xml in "root directory"
1. Select Projects
1. Finish
1. Right click the imported project > Maven > Update Project Configuration > OK

Note that when you modify the ```resources``` directory, you should build with Maven entering ```mvn clean package``` in the ```CEDEC2014``` directory.
