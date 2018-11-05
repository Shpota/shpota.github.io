---
layout: post
title:  "Why Event Sourcing Is Not a Choice for Your Next Project?"
date:   2017-03-04 10:00:00 +0200
comments: true
---
Event-driven architecture has become extemely popular nowadays. It is
easy to start and it can easily be integrated with popular Java frameworks 
like Spring. I have been working on event sourcing for the past six months. In this period,
I have collected some thoughts on the subject of event-driven architecture. 
Despite all its features, I believe that such architecture should be applied 
very carefully in terms of understanding its consequences. 

{% 
  include picture.html 
  href="2017-03-03-event-sourcing-is-not-a-choice.jpg" 
 copyright="Reuters"
%}

I want to list some drawbacks that I found while working with event-driven architecture. 
Now I’m not saying that you shouldn't use it, these are just my observations. 
You may have different views on the matter. Feel free to share these with me!

**It is very verbose**

Java is already very verbose, but ES takes it to the completely
new level. 

Suppose you want to apply ES for a domain object like this.
```java
public class User {
    private Long id;
    private String email;
    private String firstName;
    private String lastName;
    private boolean emailVerified;
    private boolean blocked;
    private Set<Role> roles;
}
```
You have to think about every modification of the object, for instance an event.
Once a user is added, it should be treated as an added event. In Java
code, this will be reflected more or less as following:
```java
public class UserAddedEvent {
    private Long id;
    private String email;
    private String firstName;
    private String lastName;
}
```
This event then will be handled by the application to create a user
with appropriate email, name, or any other default set of roles.

```java
public void handle(UserAddedEvent event) {
    // handler logic
}
```
The same logic should be applied to handle the rest of the events.  
This is the possible set:

* `UserUpdatedEvent`
* `UserEmailVerifiedEvent`
* `UserBlockedEvent`
* `UserActivatedEvent`
* `UserDeletedEvent`
* `UserRoleAddedEvent`
* `UserRoleRemovedEvent`

and every event requires its own handler.

**It complicates changing domain objects**

Suppose you want to add a `nickname` to the `User` entity.

Sounds easy, right? Yet once you add a field, most of your events will be invalidated. 
You'll have to distinguish events, which were generated before the field was added. 
Needless to say, the same applies for all the other events as well.

This case is usually covered by event versioning and event upcasting. You 
have to introduce an upcaster, which will supplement old events with 
the needed data. 

This is a very tedious job. Just think about what nickname you'll give
a user, which has been inactive for the past 2 years? How will you fill data if
the field should not be null...

**It complicates validation logic**

Sometimes you need to validate input data. For instance, you don't want
to have two users with the same combination of first and last name 
(strange rule, but it is good to illustrate this issue).

In relational databases it is not a problem at all, you only have to create 
a constraint. But here you only have a set of events grouped by ids. You'd need
to search for needed information across all the events.

**Performance problems**

It's not a problem in case your application only stores events without using them too often. 
But from time to time you have to show the information
somewhere in a GUI, or you have to make a report based on the data stored as events. 
In these cases you will encounter problems. 

If you haven't completed the domain entity, then you can only build it from events 
when needed. The more changes you have, the slower the process becomes. It will 
be extremely slow if you need to operate with a bunch of entities at the 
same time. 

Of course, you can apply some optimizations. For instance, ES works 
well in [CQRS model](https://martinfowler.com/bliki/CQRS.html). In this case,
you'll have a "write model" and a fast "read model". That might solve performance issues,
but on the flip side of the coin, it might also introduce new issues. 
The procedure is ultimately always a trade-off. 

**It is hard to test**

Obviously, it is very hard to cover event-driven objects with unit tests because
they always require form some context - and context requires connection to storage.
Unit test becomes 'overblown' and less readable.


**What is it good for?**

If you have preconditions like this:

* It is critical for the application to restore its state at any time
* Writing is more important than reading
* There is no responsible UI to show domain entities

Well, then perhaps you can think about ES.

The best examples of applying event-driven architecture are 
[Blockchain](https://en.wikipedia.org/wiki/Blockchain_(database)) and 
[Bitcoin](https://en.wikipedia.org/wiki/Bitcoin). Essentially, anything
related to storing transactions could come to mind here. However, as my blog post has shown, 
ES becomes problematic when dealing with anything "on-the-move". 
