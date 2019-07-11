---
layout: post
title:  "Implementing do-while Loop in Scala"
date:   2017-02-28 21:00:00 +0200
comments: true
img:
  href: 2017-02-28-do-while-loop-in-scala.jpg
  copyright: BBC
  alt: Roller Coaster
---
I have recently completed a Scala course on Coursera. Now that doesn't turn 
me into a Scala programmer; however, the knowledge I acquired certainly has been
very helpful with my everyday projects, especially when it comes to applying 
that knowledge to Java stream API. One of 
the tasks proposed by [Martin Odersky](https://twitter.com/odersky)
was to implement a do-while loop using only Scala built-in features.
This statement made a great impression on me. It's proof of the power of
the language and its features. In this blog post, I want to share the implementation
of the do-while loop in Scala with you.

{% include picture.html %}

Scala already has its own do-while loop (even if it contradicts the 
functional paradigm). Here is what it looks like:

```scala
do {
  // repeat operation while condition is true
} while (condition)
```
Obviously, every programming language has something like this, but 
there are not so many languages that will allow me to implement such constructions
by myself.

Instead of `do-while` keywords, I have to use `repeat-until` because I can't use the 
reserved keywords.
Here is my implementation:
```scala
def repeat(command: => Unit) = {
  new {
    def until(condition: => Boolean): Unit = {
      command
      if (condition)
        until(condition)
      else ()
    }
  }
}
```
Here is an example of client code:
```scala
var i = 0
repeat {
  println("Iteration #" + i)
  i = i + 1
} until (i < 5)
```
Okay, let's try to understand what's happening here.

The first line of the code is a declaration of the `repeat` function, which takes the `command` 
function as an argument. The important thing here is the `=>` sign - it means
that the `command` will be evaluated only when it is first needed. The terminology for 
parameters declared with the `=>` sign is "call-by-name parameters".

The next part is the creation of an anonymous object using the `new {}` construction. The 
object has only one method: `until` which takes call-by-name parameter as well.

In the function body you can see the `command` call. And it is actually the 
place where it will first be evaluated.

The next code is simple, if `condition` is `true`, then the `until` function will
be invoked recursively. Otherwise an empty result will be returned.

Finally, the construction of a do-while loop becomes possible because Scala does not require 
using dots during function invocation.
