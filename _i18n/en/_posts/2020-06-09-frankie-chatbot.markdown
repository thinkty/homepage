---
title:  "Frankie: a chatbot to train your cognitive health"
date:   2020-06-09
categories: Projects
toc: true
---
## Intro
This post is about a chatbot project that I worked on during my first internship.

### The Internship
During the Summer of 2019, I had an internship at HAII, a company in Seoul, Korea.
I learned a lot about web development thanks to the internship.
When I first started my internship, I barely knew about Javascript and just the basics of HTML.
I really felt pressured to learn quickly although no one really pushed me.
However, I think the pressure really did help.
I was able to learn how to setup a NodeJS server using express and more.

### The project
With the newly acquired skills mentioned above, I was responsible for developing a chatbot very similar to the company's already existing chatbot ([Saemi](https://saemi.haii.co.kr/)) that is on a different platform ([KakaoTalk](https://pf.kakao.com/_bFExfj)).
The goal was to create a chatbot that should
- Be able to build a bond with the user
- Be able to follow a 5-day cognitive training routine
- Be able to play various games with the user as training

## The Chatbot
To make a chatbot for Facebook, referencing the rich amount of guides on the official documentation was extremely helpful.
The main component of a chatbot is the webhook which is the server handling the requests.
[Here](http://techtales.co/2017/08/07/webhook-vs-api-whats-difference/) is an explanation about the difference between a REST API and a webhook API.
In simple words, APIs are more like communicators while webhooks are more like repliers.
Facebook provided a [quick setup](https://developers.facebook.com/docs/messenger-platform/getting-started/quick-start/) of a webhook which I followed to create a sample chatbot.
The procedure to register the chatbot was quite simple.
1. Add the URL of the webhook to the developer console
2. Verify the webhook
3. (optional) Get checked by Facebook to make it public

After trying the quick setup, I got the hang of development.

### The Structure
![structure](/assets/images/2020-06-09-frankie-chatbot-1.png)

The structure is very simple.
The users sends messages to the facebook page via the Facebook Messenger Platform.
The sent messages are relayed to the webhook with additional information about the user such as the PSID of the user.
PSIDs are unique per user and per facebook page so it can be used to identify the user.
The webhook interpretes the message and creates a reply to send to the user.
The created message has metadata such as the recipient or other options such as quick replies and media and is sent back to the Messenger Platform.
Finally, the messenger platform replies to the user with the format received from the webhook.

### Meeting the Requirements
Now, to meet the requirements mentioned above, Frankie (the chatbot) has become something very different from other common chatbots.
Since other chatbots are mostly used to assist in customer support, it doesn't really feel like a person and the options are very limited.
To make a chatbot feel like a person, the ability to talk naturally to the chatbot is crucial.
This can be achieved using a [NLP](https://en.wikipedia.org/wiki/Natural_language_processing) (Natural Language Processing) engine and **DialogFlow** is one of the places that provides a very good API.
Using the DialogFlow API, the chatbot can understand the intent of the user from the messages and pick up keywords (such as names or simple answers).

Along with the NLP, a conversation that actually feels like a conversation with natural flow is important.
Other chatbots usually have a short set of dialogues that it can send.
In case of Frankie, there are **thousands of dialogues** in a JSON file that Frankie can say based on the scenario.
Frankie is more like a story rather than a one time talk.
It has a context which the user can follow through and this process is what creates the rapport between the human user and the robot chatbot.

In addition to the rich dialogues, there is a 5-day routine where the user will train their cognitive health each day for approximately 20 minutes playing games related to the fields of
- Linguistics
- Memorization
- Calculation
- Decision Making
- Concentration

The games in each fields have been provided by the company and it has been approved by medical professionals.
The demo footage can be found in this [link](https://www.youtube.com/watch?v=pwWY2NjPAXw) and if the server is up and running, one can try it right now.

> Link to Demo: [http://m.me/100260508387789](http://m.me/100260508387789)


## Conclusion
Creating this chatbot was a valuable experience for me as not only was it a chance to learn about NodeJS and Webhooks, it was also a great opportunity to learn about the process of development.
Although I programmed the entire project, I also attended meetings and had code reviews with the manager.
In those meetings, I learned the importance of communication between someone who knows the code and someone who has no idea what it is.
In addition to communication, coding standards and comments were some of the remarkable points that I still focus heavily on today.
A great standard and descriptive comments really help not only others in your team, but also yourself in the future.
Recently, I had to take a look into the source code of Frankie and migrate the program to a hosted service.
The comments really saved my time on what I had to do in order to successfully make the program running in a different setting and it also helped me remember the context in which the code was written.