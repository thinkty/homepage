---
title:  "Searching with StackExchange VS GoogleCustomSearch"
date:   2020-06-04
categories: Thoughts
toc: true
---

## Intro
Today, I needed to find an API to search especially for [Stackoverflow](https://stackoverflow.com/).
I needed this API as it is a core part of my project 'Darc'.
Darc is a note taking web application that I am currently developing to aid students and software engineers.
The main feature is to make a note about a bug or a problem that one has encountered.
When the programmer encounters that bug later on, they can easily open up Darc and look at their notes.
Although this may seem like a task that any other application can do, I intend to make Darc specialized for this situation.
Another core feature is to allow the user to search in Darc without having to leave the website.
To achieve this, I needed a good search API that can get me and the users satisfying results.

## StackExchange's Search API

The API provided by StackExchange is very simple to use and one can try it right away in the [website](https://api.stackexchange.com/docs/search).

![Filter Demo](/assets/images/2020-06-04-search_stackoverflow-1.png)
In the demo, one can set the page number, number of questions per page, and more.
It is very simple, but this is also a problem as it is too simple.
When I try to search for the following:
> How to exit vim - [(query)](https://api.stackexchange.com/2.2/search?order=desc&sort=votes&intitle=how%20to%20exit%20vim&site=stackoverflow)

The expected result is an array of questions.
However, it seems that the API literally just compares the title with the query as I do not get any results.
Therefore, I decided to find other ways to make the search.

## Google Custom Search
After some research, I finally landed on Google Custom Search.
Put it simply, you can customzie the google search engine to suit your needs.
Such customization can be
- Restrict the search result to specific domain (ex: github.com, stackoverflow.com)
- Image search
- Safe search (exclude adult content)
- Customize the layout and theme
- And more!

By setting the search result domain to github.com and stackoverflow.com, I can get a far better result than the API before.
After fidgeting with the theme and layout, I can go back to the *Setup* and under the *Basics* tab, I can get the code required to render the search engine in my application.
One could take the JSON API approach to get the search results, but that method has restrictions on queries per day for the free version.

### Implementing to React
Now that I have the code snippet ready, let's put it into my react application.
If I just paste the given code, it will not work.
According to [this website](https://www.newline.co/fullstack-react/articles/Declaratively_loading_JS_libraries/), this happens as the script is being loaded into the website and blocks the rendering.
Although it does not seem like a same situation for here, there is a solution.
In the previously mentioned website, the author creates a method to dynamically create a *script* tag.
However, since we are using React, I think it will be better to put it in the *componentDidMount* method so that the script will automatically be loaded as soon as our component is mounted.
The example code would be like the following:

{% highlight javascript %}
componentDidMount() {

  // create element and set parameters
  let customSearch = document.createElement("script");
  customSearch.type = "text/javascript";
  customSearch.async = true;

  // Make sure to keep the CX code secure
  customSearch.src = "https://cse.google.com/cse.js?cx=" + <YOUR_CX_HERE>;

  // insert script
  var s = document.getElementsByTagName('script')[0];
  s.parentNode.insertBefore(customSearch, s);
}

render() {
  return (
    <div className="gcse-search"/>
  );
}
{% endhighlight %}

With the script ready, when I reload the app, my customized search bar appears.

![custom search bar](/assets/images/2020-06-04-search_stackoverflow-2.png)