---
layout: post
title:  "Implementing do-while loop in Scala"
date:   2017-02-28 21:00:00 +0200
comments: true
---
I recently completed Scala course on Coursera, that doesn't turn 
me into Scala programmer however I find the course helpful in my everyday 
projects especially applying the knowledge to Java stream API. One of the 
the tasks proposed by [Martin Odersky](https://twitter.com/odersky)
was to implement do-while loop using only Scala built-in features.
That task made a great impression. It shows all the power of the
language and it's features. And I want to share the implementation 
with you.

{% 
  include picture.html 
  href="2017-02-28-do-while-loop-in-scala.jpg" 
 copyright="BBC"
%}

Scala already has its own do-while loop (even if it contradicts to 
functional paradigm). Here is how it looks like:

```scala
do {
  // repeat operation while condition is true
} while (condition)
```
Obviously every programming language has something like this, but 
there are no so many languages that allow me to implement such constructions
by myself.

Instead of `do-while` keywords I use `repeat-until` because I can't use the 
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
Here is the example of client code:
```scala
var i = 0
repeat {
  println("Iteration #" + i)
  i = i + 1
} until (i < 5)
```
Ok, let's try to understand what's happening here.

First line of the code is declaration of `repeat` function which takes `command` 
function as an argument. The important thing here is `=>` sign - it means
that the `command` will be evaluated only when it is first needed. Parameters 
declared with `=>` are called call-by-name parameters.

The next part is creation of anonymous object using `new {}` construction. The 
object has only one method: `until` which takes call-by-name parameter as well.

In the function body you can see the `command` call. And it is actually the 
place where it will be first evaluated.

The next code is simple, if `condition` is `true` the `until` function will
be invoked recursively otherwise the empty result will be returned.

And finally such construction becomes real because Scala does not require 
using dots during function invocation.