---
layout: post
title:  "Why event sourcing is not a choice for your next project?"
date:   2017-03-04 10:00:00 +0200
comments: true
---
Event-driven architecture become very popular nowadays. It is
easy to start and it can be easily integrated with popular Java frameworks 
like Spring. I have been working with event sourcing for last half an year and 
I collected some thoughts on this subject. Despite all its features I believe 
that such architecture should be applied very carefully with understanding 
of all of its consequences. 

{% 
  include picture.html 
  href="2017-03-03-event-sourcing-is-not-a-choice.jpg" 
 copyright="Reuters"
%}

I'm not saying that my point is the single right point. May be you
have different experience. I will be glad if you share it with me.

Here are the drawbacks of using event-driven architecture:

**It is very verbose**

Java is already very verbose but ES brings it to the completely
new level. 

Suppose you want to apply ES for domain object like this.
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
You have to think on every modification of such object as about an event.
Once a user is added this should be treated as an add event, and in java
code it will reflect more or less like this:
```java
public class UserAddedEvent {
    private Long id;
    private String email;
    private String firstName;
    private String lastName;
}
```
This event then will be handled by the application to create a user
with appropriate email, name, some default set of roles.

```java
public void handle(UserAddedEvent event) {
    // handler logic
}
```
The same logic should be implemented to handle the rest of the events, 
this is the possible set:

* `UserUpdatedEvent`
* `UserEmailVerifiedEvent`
* `UserBlockedEvent`
* `UserActivatedEvent`
* `UserDeletedEvent`
* `UserRoleAddedEvent`
* `UserRoleRemovedEvent`

and every event has to have its own handler.

**It complicates changes of domain objects**

Suppose you want to add `nickname` to the `User` entity.

Sounds easy, but it is not in fact. Once you add a field most of your
events will be invalidated. You'll have to distinguish events which 
were generated before the field was added and the rest of the events.

This case usually covered by event versioning and event upcasting. You 
have to introduce an upcaster which will supplement old events with 
needed data. 

And it is not an easy task. Just think what nickname you'll give for
a user which was inactive for last 2 years? How will you fill the data if
the field should not be null...

**It complicates validation logic**

Sometimes you need to validate input data. For instance you don't want
to have two user with the same combination of first and last name (strange
rule, but it is good to illustrate the issue).

In relational databases it is not a problem at all, you only have to create 
a constraint. But here you have only set of events grouped by ids. You have
to search fro needed information across all that events.

**Performance problems**

It is not the issue in case if your application only store events but 
does not use them often. But from time to time we have to show the information
somewhere in GUI, or make a report based on the data stored as events. In
This case it is a problem.

You don't have completed domain entity you can only build it from events 
when it is needed. The more changes you have the slower the process. It will 
be extremely slow if you need to operate with bunch of entities at the 
same time. 

Of course you can apply some optimizations. For instance ES works 
well in [CQRS model](https://martinfowler.com/bliki/CQRS.html). In that case
you'll have write model and fast read model. That might solve performance issue
but it can also introduce new issues. It is always a trade-off. 

**It is hard to test**

Obviously it is very hard to cover event-driven objects with unit tests because
they always require some context and the context requires connection to storage.
Unit test become 'fat' and less readable.


**What is it good for?**

If you have preconditions like this:
* It is critical for application to restore its state at any time
* Writes dominate over reads
* There is no responsible UI to show domain entities

you can think about ES.

The best examples of applying event-driven architecture are 
[Blockchain](https://en.wikipedia.org/wiki/Blockchain_(database)) and 
[Bitcoin](https://en.wikipedia.org/wiki/Bitcoin). Of course everything
related to storing transactions is potential candidate. But not everything
that moves.
