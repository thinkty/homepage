---
title:  "Going global for 2021"
date:   2021-01-23
categories: Updates
---

Leaving the horrendous year 2020 behind, I wanted to start 2021 with goals that I have been procrastinating for too long.
I always wanted to have a Korean version of this blog so that my friends and family in Korea can read too.

However, it wasn't at my top priority until one of my friends actually requested a Korean translation *although she is fluent with English* 🤔.

Anyways, since it was brought to my attention, I thought it would be a nice and simple new-year-resolution to support Korean. Boy, was I wrong.

I started with a Jekyll plugin: [jekyll-multiple-languages-plugin](https://github.com/kurtsson/jekyll-multiple-languages-plugin) and went over the documentations to achieve a multilingual Jekyll website.
It didn't seem too tedious of a work and the project structure had to be modified into exactly what I was expecting as below:

~~~
/
|- _i18n/
  |- en/
  |  |- _posts/
  |  |- about/
  |- ko/
     |- _posts/
     |- about/
~~~

The planning phase was smooth as butter.
Then, when it came to actual implementation, that was when things started falling apart.

What I haven't noticed while planning was that the plugin didn't actually seemed to be actively developed/maintained.
So, it seemed to have some spots where I would have to create my own workarounds and there were also some features that didn't seem to work as documented.

![this is fine](https://cdn.vox-cdn.com/uploads/chorus_image/image/49493993/this-is-fine.0.jpg)

After countless commits and hours fixing the layout and tweaking the configs, I decided to accept the fact that it does not always have to be perfect with rainbows and unicorns.

![result](/assets/images/2021-01-23-cross-language-1.png)

Now, one can switch languages at the main page sidebar.
Although it's quite sad looking at the amount of effort that has been put in compared to the result, there has been made a lot of minor changes to the blog such as the 404 pages, layouts, and a bunch of configurations to support multiple languages.

The point of this post was to celebrate the support for another language, but looking back, it seems like a rant on the plugin. I think there can definitely be some improvements to small details to smoothen out the user experience with the blog and I am looking forward to translating all my past posts before it becomes a massive pile.