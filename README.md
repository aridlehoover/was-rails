[![Maintainability](https://api.codeclimate.com/v1/badges/0a5e9939cb8c216913e9/maintainability)](https://codeclimate.com/github/aridlehoover/was-rails/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/0a5e9939cb8c216913e9/test_coverage)](https://codeclimate.com/github/aridlehoover/was-rails/test_coverage) [![Build Status](https://travis-ci.com/aridlehoover/was-rails.svg?branch=master)](https://travis-ci.com/aridlehoover/was-rails)

# Weather Alert System - The Rails Way™

This is a sample Weather Alert System. `Alerts` are weather bulletins
derived from `Sources` and broadcast to `Recipients`.

The purpose of this application is to demonstrate how The Rails Way™
obscures business/domain logic, making it difficult to know what an
application is doing and where it is doing it.

The master branch represents the application in its Rails-iest form.
Other branches represent various refactors along the path to a more
hexagonal architecture using the Ports & Adapters design pattern.

## Backlog

As an administrator,
In order to rapidly notify recipients of important weather news,
I want to...

* ✅ Automatically notify all Recipients upon Alert creation if published and not expired
* ✅ Automatically notify new Recipient of latest published Alert upon Recipient creation
* ✅ Automatically notify all Recipients upon Alert publication
* ✅ Manually notify all Recipients of a specific Alert
* ✅ Manually notify a specific Recipient of the latest Alert

As an administrator,
In order to rapidly enter new alerts,
I want to...

* ✅ Import Alerts from the NWS Warnings ATOM feed
* ✅ Import Alerts from the USGS Earthquakes ATOM feed
* ✅ Import Alerts from the PTWC - Pacific Ocean Bulletins RSS feed
* ✅ Import Alerts from telemetry off a weather monitoring device via a queue
* Import Alerts from a Twitter feed

As an administrator,
In order to reach people where they are paying attention,
I want to...

* ✅ Notify Recipients via SMS
* ✅ Notify Recipients via email
* ✅ Notify Recipients via Twitter
* ✅ Notify Recipients via Facebook Messenger
* ✅ Notify Recipients via WhatsApp
* ✅ Notify Recipients via Slack
* Notify Recipients via RSS
* Notify Recipients via the web site

As an administrator,
In order to notify as many people as possible,
I want to...

* ✅ Import a CSV file containing Recipient data
* ✅ Import Recipient data from a queue
* ✅ Unsubscribe Recipient via a queue
Import a Recipient's Twitter followers accounts
Import a Recipient's Facebook Messenger contacts
