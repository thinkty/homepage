---
title:  "Just opened my first issue on Github"
date:   2020-06-27
---
2 days ago (2020-06-25), I opened my first [issue](https://github.com/uber/react-digraph/issues/227) on Github.
The issue was related to the graphing component provided by Uber called [React-Digraph](https://github.com/uber/react-digraph), which is extremely easy to use and customize.

I am using this React component to implement a Flow Editor (which I will describe in detail in another post) which is basically a flow chart maker.
During the process of adding my custom rendering methods and custom shapes, I found a weird error.
The detail about the error can be found in the [issue](https://github.com/uber/react-digraph/issues/227). To put it simply, the graph was failing to render when I used the name `function` as an ID for my shape (an SVG component).

I don't know how I figured out this weird phenomena and I know I can just avoid this problem by simply changing the name to `function-node`.
However, this discovery has sparked my curiosity on why a particular value for a property would cause the node to disappear when selected by the user.
I took several routes to track where the error is starting.

First, I removed each of my custom rendering method (ex: renderNode, renderText, etc.) one by one to see if the error still occurred.
As I am using the word `First`, you probably noticed that it didn't work.
Next, I removed *all* of my custom rendering methods just to see the error still happening.
I also searched for this problem in the `issues` section, but it seemed that this never happened to anyone before.
Finally, I started looking into the source code and the segments where the rendering occurs.
I looked at all of the rendering related parts, but I had no clue where it could have gone wrong.
However, I found that the graph component is using [D3](https://d3js.org/).
I was pretty confident that the developers at Uber would know better at D3 than me who have only used it once before.

This was when I decided to open an issue on the repository to get some professional help.
This was my first issue that I have ever created and it felt like I was participating in something bigger and beneficial to the public.
It was a unique feeling that I never had before.
Maybe this is how it feels like to contribute even a little bit to an open source project?
Although I didn't make a pull request to fix the code, I felt like this is a good step to take to join the open source community.
By starting one by one, I hope to see myself doing more in the future.