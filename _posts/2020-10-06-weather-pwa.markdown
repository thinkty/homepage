---
title:  "A Simple SPA & PWA Application"
date:   2020-10-06
categories: projects
---

Recently, I started learning about cross-platform applications such as Electron, Ionic and what caught my attention was PWA.
Also known as Progressive Web Application, like all other cross-platform applications, the app can be distributed to various platforms through a single source.
However, I would say the main difference to Electron or Ionic would be that it is a "web" application so the platforms would be various web browsers such as Firefox, Chrome, etc.

In my opinion, I think this is quite brilliant as almost everyone uses a browser and it is [highly likely](https://en.wikipedia.org/wiki/Usage_share_of_web_browsers#/media/File:StatCounter-browser-ww-monthly-202009-202009-bar.png) that the browser they are using [will support](https://caniuse.com/?search=PWA) PWA.
As a side note, if I am not mistaken, I think this is similar to Java as it is also cross platform if JVM is installed.

## The Application

Enough said, I wanted try out PWA so I went with everyone's "hello world" project: a [simple weather app](https://weather.thinkty.net).
The app itself is very simple, it takes two inputs: latitude and longitude to print out the result.

![simple weather app](/assets/images/2020-10-06-weather-pwa-1.png)

I really don't like it when apps "ask" me for location permission so I decided to go with a simpler solution.
At first, I wanted to integrate a simple map to let the user select the location, but I never knew that just putting a map would require me to sign up and get an API key.
Maybe I didn't search enough, but I didn't want to put too much time in the app itself.
I just have to remember two numbers, how hard would that be?

## The Checklist

Once I got the basic app done, this is where the fun began.
Although there is a common standard for PWA regardless of the browser, some were browser specific when it came to making the application installable.
The common standard is explained very well [here](https://web.dev/pwa-checklist/) and I think it is a good opportunity for me to go through each one.
You can also use the [Google Lighthouse](https://developers.google.com/web/tools/lighthouse) to test your website.
Although it isn't specialized for PWA only, but it does cover PWA too.

### Starts fast, stays fast

This part is closely related to optimization and the speed at which your webpages can be delivered to the client.
Everyone hates slow loading websites, so I would recommend putting some effort into this part to reach 100% on LightHouse.

As I used Create-React-App to build the app, the optimization part for the webpages was done automatically.
For the server, I used AWS CloudFront and I would recommend enabling [`Compress Objects Automatically`](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/ServingCompressedFiles.html) so that your contents would be compressed with either gzip or br based on the headers and if available.

In addition, using [web safe fonts](https://www.w3schools.com/cssref/css_websafe_fonts.asp) is another way of increasing performance with style alongside with removing unused scripts.

### Works in any browser

![mdn compatibility](/assets/images/2020-10-06-weather-pwa-2.png)

When reading through MDN documents, one can easily encounter a table that shows the compatibility of the feature with various browsers.
Some npm modules might work well with Chrome but not with Safari.
You should aim to make your app as compatible as possible and I think this is something that isn't restricted to only PWA but in web applications in general.

### Responsive to any screen size

A crucial part of a PWA is that there is one source to rule them all.
Therefore, when designing the layout of the application, one must consider the mobile display as well.
As far as I know, Chrome and Firefox has the developer tools accessible (usually by pressing `F12`) and using the tool, one can see the mobile display as well.

Another key point is Viewport.
According to [W3Schools](https://www.w3schools.com/css/css_rwd_viewport.asp) the viewport is the user's visible area of a web page.

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

By specifying the viewport, the browser is able to show the appropriate page dimension and scale based on the physical device.
The link above shows a great example on the difference with and without the viewport specified.

### Provides a custom offline page

A charm about PWA is that it can be installable.
When it is installed, it means that the user can request an access simply by clicking on the app icon even if there is no internet.
To provide the best user experience, the app should display something even if the user is offline.

A great method used in Create-React-App is service workers that has been already provided in the boilerplate code of CRA so that one can just simply change one line to enable it.
When a user first receives access to the web application, if supported by the browser, the application will register a service worker.
A service worker will then cache the webpage for later use after a successful registration.
When a user goes offline, the cached webpage will then be served.

Otherwise, one can also customize the service worker script to show users a custom `offline.html` page.

### Is installable

A great feature of PWA is the ability to be installed straight from the browser.
The ease of accessibility allows the user to use the app more often and based on personal experience, it really does feel like a native app when installed on my phone.
I was able to create an ad-less and simple weather app for my daily use that works the same on every device.

In order to make it installable, it requires an installable script and an app icon.
There are plenty of [guides](https://web.dev/customize-install/) online for the script.
I recommend using [Favicon Generator](https://realfavicongenerator.net/) for creating icons for various platforms and also a web manifest for it.

As Lillian Mesber pointed out, `Favicon Generator` only takes file sizes up to 2 MB.
For files up to 5 MB, one can use [websiteplanet.com](https://www.websiteplanet.com/webtools/favicon-generator/).
`Website Planet` lacks the cross-platform aspect and outputs a single `png` file, but it can be used with `Favicon Generator` to make it available on every platform.

![installable icon on Chrome](/assets/images/2020-10-06-weather-pwa-3.png)

Once everything is set and installable, on Chrome for example, the install icon should be visible.

### Utilize Google's Lighthouse

For the best result, using Google's [Lighthouse](https://developers.google.com/web/tools/lighthouse) will lead the way.
It is open source and has detailed explanation about each criteria.
I highly recommend it.

## Conclusion

After having a simple weather application that only does what it is supposed to do and without ads, it was just amazing.
Having it on my home screen is very different from bookmarking it.
It felt like a native app but since it is still a web application, it will have some restrictions.
However, I think PWA has potential compared to other frameworks for cross-platform applications.
