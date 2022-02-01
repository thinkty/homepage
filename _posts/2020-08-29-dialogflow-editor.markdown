---
title:  "Source Chat: a platform to manage your chatbots with an intuitive editor"
date:   2020-08-29
categories: Projects
toc: true
---

## Background

Before I go into the details, I want to state that this is one of the biggest projects I have done so far and it is a project that I sincerely think has potential.
Although my code may not be that much of a potential, I think the concept of a platform that controls the flow of various other chat platforms do.
Currently, there is a platform called [*Dialogflow*](https://cloud.google.com/dialogflow) that let's the user create natural language processing chatbots for various other platforms with a proper GUI.
However, after using Dialogflow for chatbots that require *depth*, I came to a conclusion that it may not be the solution for creating complex chatbots.

When I say *complex* chatbots, I mean chatbots that have a more sophisticated flow to it.
It differs from simple chatbots that are used for customer service that can only have non to a single digit of depths.
A complex chatbot could tell stories and I think it is something that has the best chance to get to the level of human-to-human conversation.
Although I can create multi-depth flows with Dialogflow, it sometimes shoots back up to the top context under certain conditions, disrupting the flow.
I believe this is what Dialogflow is intended for and I may have the wrong concept about the usage of Dialogflow, but one thing for sure is that I cannot use Dialogflow by itself to create the chatbot that I want.

Thus, I created a system that lets the user have better control over the flow while maintaining the natural language processing abilities from Dialogflow.

## Overview

As mentioned above, I started this project after facing several difficulties while using Dialogflow on its own to create a complex chatbot.
While using Dialogflow, I faced the following difficulties:
- Not being able to actually *see* the flow of the chatbot as I was editing it
- Unable to control the flow (the flow was controlled by Dialogflow)

This project is aimed to solve the problems above and also deliver the flow to various chat platforms such as Slack, Discord, Facebook, and more with a single source of flow (which is something that Dialogflow is already doing).
You might not understand what I am saying as I have terrible writing skills, but I will try my best to explain.

## Project Layout

I think the best way to explain about a project is to show the layout.
This project consists of two main parts: the [editor](https://github.com/thinkty/dialogflow-editor) and the [server](https://github.com/thinkty/source-chat). 

### The Editor

Dialogflow Editor (a.k.a. the editor) is a graph editor made with React.
The main components are the graph component from [Uber](https://github.com/uber/react-digraph) and the node editor that allows the user to edit individual nodes and export/import the graph.
The editor currently has the bare minimum to create a flow for a chatbot and you can actually try it out at https://editor.thinkty.net/ .
Enough said, I will explain how this editor solves the problems mentioned in the overview with pictures.

![Dialogflow Console](/assets/images/2020-08-29-dialogflow-editor-1.png)

The first image is the Dialogflow console where the user can add/edit/delete intents and do tons of cool stuff.
However, as I mentioned before, it doesn't have a graph that shows the flow.

![Dialogflow Editor](/assets/images/2020-08-29-dialogflow-editor-2.png)

This is the Dialogflow Editor with a graph that shows the flow of the chatbot (agent) and it also has all the required fields in the node editor such as training phrases, pools of responses, fallback, events, actions, contexts, and more.
However, it does not have support for entities yet.
I am still thinking on how to implement it to be as natural as possible for the user to add entities from training phrases.

One crucial difference from the Dialogflow console is that the contexts are set by the Dialogflow Editor instead of the user.
The contexts are decided by how the intent node is connected to a context node.
Basically, the circle nodes are the contexts and the squares are the intents.

Context node is the key to allowing complex flows such as loops and split-and-merge patterns.
These patterns were originally not allowed in the Dialogflow console by just using followups, but it could be done with contexts.

When the user is done editing the graph, the flow can be sent to a server running Source Chat.
From there on, it is the server's responsibility to update Dialogflow with the parsed intents, and control the flow.

### The Server

Source Chat (a.k.a. the server) has two main functionalities:
1. Handle the incoming graph from the editor (editor segment)
2. Interact with various chat platforms (chatbot segment)

#### Editor Segment

The editor segment handles the interaction between the Dialogflow Editor and this server.
After it receives the raw graph from the editor, it goes through the process of *validating*, *parsing*, and *updating*.
1. Validating step is mainly focused on making sure that the graph is formatted properly and will have no error while parsing.
In detail, it checks for dangling nodes and other custom rule sets that I have set.
2. Parsing step extracts the information required for creating intents from the graph and actually creates intents that can be sent to Dialogflow
3. Updating step sends the parsed intents to Dialogflow and also updates the state table.

The state table is a table representation of a finite automata (instead of a diagram).
If you think about it, the flow of a chatbot can actually be interpreted into a finite automata where each state is the context and the edges are the user inputs (or more like the intent in terms of Dialogflow).

![finite automata diagram](https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/DFA_example_multiplies_of_3.svg/250px-DFA_example_multiplies_of_3.svg.png)

The diagram can also be shown in a table called [*State Transition Table*](https://en.wikipedia.org/wiki/State_transition_table).
By utilizing the state table, I can have explicit control over the flow and don't have to rely on Dialogflow.

#### Chatbot Segment

When the intents are ready on Dialogflow and the state table has the most up-to-date flow, users can now interact with the chatbots on various platforms through *adapters*.
Adapter is just a name that I gave to the modules that handle the process of receiving messages from and sending responses to the dedicated chat platform.
For each chat platform, there will be an adapter module assigned.
The adapters are the crucial part of this segment that allows having multiple chat platforms connected to this single server with the single flow.

## Plans

As I mentioned earlier, the project has the minimum requirements met to serve its purpose.
I plan to add support for Entities and allow more expressive responses such as cards, images, etc.
However, I think there might be a problem with expressive responses as it differs by chat platforms.
I will have to think about it further.

## Conclusion

Making this project felt to me as creating an environment (well, I mentioned *platform* before, so yeah) rather than just a single application.
It was also the first project where I actively included tests, linting, continuous integration and deployment.
Through continuous integration, I was able to automate the process of testing, building, and deployment all within a single push.
In addition, when setting up the adapters, I had modularity as the top priority so that it will be as easy as possible to add your own adapter or disable it on demand.
Overall, this project has given me a great amount of experience on developing software that can be easily maintained, tested, and modified to suit one's needs.

## PS

I just found out that Google now has a service called [DialogflowCX](https://cloud.google.com/dialogflow/cx/docs) that literally has a graph editor...
Although it is in beta, I guess that is why Google is Google.
Maybe a change of plans?
