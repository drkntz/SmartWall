# SmartWall
MagicMirror2/Google Calendar wall mounted display

# How to create a magic mirror calendar
Zach Martin   
28 December 2021

The purpose of this document is to document the steps taken to create a “magic mirror” type of digital calendar/information station.
The goal of this digital calendar, dubbed “SmartWall," is for my Dad's business google calendar to be displayed on the wall on a TV monitor.
A secondary goal of this project is to show weather forecasting and a large digital clock. 

## Materials required  
    • Raspberry pi 3,3b+, or 2
    • HDMI capable monitor
    • HDMI cables, power adapters
    • SD card for pi image

## Configuration
### Pi Image
Setup the raspberry pi image using the raspberry pi imager software https://www.raspberrypi.com/software/  
Install the imager (usually .deb if for Debian-based Linux). Once installed, run the imager program.  
This program is very straightforward. Choose the SD card and type of OS. Select raspbian for the desktop environment.  
Use the advanced settings to setup SSH and wifi by using the key combo control + shift + x while in the raspbian installer. This brings up the menu below.

FIGURE 1

FIGURE 2

### Pi Config

#### Disable screen blanking
Disable screen saver / screen blanking by setting the raspberry pi configuration screen blanking to “disabled.” There’s probably a CLI way to do this. Supposedly you can do this via “xset s off” in cli, but it did not work via SSH.
courtesey of Pi My Life Up: 
FIGURE 3
FIGURE 4

#### Rotate Screen
As the raspberry pi has switched from “legacy” display drivers to x11 display drivers, the old trick of using display_rotate=1,2, or 3 in the configuration text file does not work anymore. Instead, the display has to be rotated using xrandr. For some reason I was having trouble getting the .xprofile or .xinitrc trick to work, so I added an xrandr config to my startup.sh. However, there needs to be a delay in order for this to work. 15 seconds works OK. 
Create a script "startup.sh"
```
$ touch startup.sh
$ nano startup.sh
```
Here's the contents of that script:
```
#!/bin/sh 
export XAUTHORITY=/home/pi/.Xauthority 
export DISPLAY=:0.0 
sleep 15 
xrandr --output HDMI-1 --rotate right 
```
Set this up to start automatically via cron
```
$ chmod +x startup.sh
$ crontab -e
```
Add the cron entry at the bottom of the text file
```
@reboot export DISPLAY=:0 && sh /home/pi/startup.sh
```
### MagicMirror2 Install/Config
  1. Download and install the latest Node.js version:
  ```
  $ curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - 
  $ sudo apt install -y nodejs
  ```
  2. Clone the repository and check out the master branch: git clone https://github.com/MichMich/MagicMirror 
  3. Enter the repository: cd MagicMirror/ 
  4. Install the application: npm install 
  5. Make a copy of the config sample file: cp config/config.js.sample config/config.js 
  6. Start the application: npm run start 
This concludes a basic setup of the magicmirror software. It will launch with a default page.  

Settings for the program are stored in config/config.js. Open that file in a text editor (IE vi or nano) and  you can change the time settings (24/12h) the measurements (metric/imperial) and which modules are enabled as shown below.

### Google Calendar Setup

There needs to be a google calendar for this project in Ical format. Supposedly this is a URL to a “secret” address.
Meaning, the calendar is not “public” but the address can really be accessed by anyone if given the URL. Go to calendar.google.com, to your settings, and click on your calendar in the bottom left as in the image below.

FIGURE 5
FIGURE 6

Scroll down to the “Secret Address” section in the bottom of the page and click the eye icon to the right to view the address. Copy this address in the MM2 config file in the “modules” section under “calendar” 

FIGURE 7 

This sets up a pretty basic calendar with a scrolling “agenda” style of window. For a full screen full calendar setup, I can use the MMM-MonthlyCalendar module. https://github.com/kolbyjack/MMM-MonthlyCalendar 

#### Installation of MMM-MonthlyCalendar Module
In your terminal, go to your MagicMirror's Module folder and download the module:
```
$ cd ~/MagicMirror/modules
$ git clone https://github.com/kolbyjack/MMM-MonthlyCalendar.git
```
Configure the module in your config.js file.
Note: After starting the Mirror, it will take a few seconds before events start to appear.

#### Using MMM-MonthlyCalendar
To use this module, add it to the modules array in the config/config.js file:
```
modules: [
  {
    module: "MMM-MonthlyCalendar",
    position: "bottom_bar",
    config: { // See "Configuration options" for more information.
      mode: "fourWeeks",
    }
  }
]
```

#### Configuring MMM-MonthlyCalendar
The following properties can be configured:

TABLE 1 FIGURE 

NOTE: the built in calendar module MUST be enabled with the google ical URL otherwise the MMM-cal module will not work. You can leave the position line blank for the default calendar this way the default calendar is not displayed.

### Weather
There is a built in weather forecaster that may be useful for this application. Use the following settings
```
                {
                        module: "weather",
                        position: "top_right",
                        config: {
                                weatherProvider: "openweathermap",
                                type: "current",
                                location: "New York",
                                locationID: "5128581", //ID from http://bulk.openweathermap.org/sample/city.list.json.gz; unzip the gz file and find your city
                                apiKey: "YOUR_OPENWEATHER_API_KEY"
                        }
                },
                {
                        module: "weather",
                        position: "top_right",
                        header: "Weather Forecast",
                        config: {
                                weatherProvider: "openweathermap",
                                type: "forecast",
                                location: "New York",
                                locationID: "5128581", //ID from http://bulk.openweathermap.org/sample/city.list.json.gz; unzip the gz file and find your city
                                apiKey: "YOUR_OPENWEATHER_API_KEY"
                        }
                },
```
Find an API key by creating a free account with openweathermap and clicking the “subscribe” button for an API key via email. 

FIGURE 8

### Using MM2 and Chromium in side-by side Mode
Ultimately, I decided to remove the MM-calendar and instead run a window with chromium below a window with MM2. This way we could have a full color google calendar in addition to the features that MM2 allows. The settings are as follows:

#### Magic Mirror Config
change your MagicMirror/config/config.js to have the following after “let config = { “
```
 electronOptions: {y: 1080, width: 1080, height: 840, fullscreen: false, kiosk: false },
```
This way you can choose the y-coordinate or x-coordinate, height, width, etc of the magic mirror section.

#### Startup Config
Edit your startup.sh to contain the following after the xrandr rotation:
```
chromium-browser --app=https://calendar.google.com/calendar/u/0/r --window-size=1080,1080 --disable-translate --fast --fast-start --disable-infobars & 
npm run start --prefix /home/pi/MagicMirror/
```
# Conclusion
This project was a great dive into the MagicMirror software and productivity automation. The end user, my Dad, was thrilled that his new wall calendar
synced with his business calendar, and the weather forecasting and whatnot was a definite plus.
