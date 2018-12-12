# Weather Alert System

This Weather Alert System is a simple application that demonstrates <br>
how business/domain logic is often spread across multiple classes <br>
when developing applications The Rails Way™.

# Domain

Alerts are bulletins derived from Sources, and broadcast to Recipients.

# Backlog

As an administrator,
In order to rapidly notify recipients of important weather news,
I want to...

* Automatically notify all Recipients upon Alert creation
* Automatically notify new Recipient of latest Alert upon Recipient creation
* Automatically notify all Recipients upon Alert publication
* Manually notify all Recipients of a specific Alert
* Manually notify a specific Recipient of the latest Alert

As an administrator,
In order to rapidly enter new alerts,
I want to...

* Import Alerts from the NWS Warnings RSS feed
* Import Alerts from the NOAA Tsunamis RSS feed
* Import Alerts from the USGS Earthquakes RSS feed
* Import Alerts from a Twitter feed
* Import Alerts from telemetry off a weather monitoring device via web sockets

As an administrator,
In order to reach people where they are paying attention,
I want to...

* Notify Recipients via SMS
* Notify Recipients via RSS
* Notify Recipients via Twitter
* Notify Recipients via Facebook Messenger
* Notify Recipients via WhatsApp
* Notify Recipients via Slack
* Notify Recipients via the web site

As an administrator,
In order to notify as many people as possible,
I want to...

* Import a telecom's cell-phone database via CSV
* Import a Recipient's Twitter followers accounts
* Import a Recipient's Facebook Messenger contacts
