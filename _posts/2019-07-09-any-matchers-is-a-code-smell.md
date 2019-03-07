---
layout: post
title:  "Using 'any' Matchers in Unit Tests is a Code Smell"
date:   2019-07-09 10:00:00 +0200
comments: true
---
If you worked with JUnit and Mockito you must be familiar with matchers. 
They provide a way to verify parameters during method invocation. Among many 
of those, there is a group that allows matching *any* object as a condition. They 
all have names starting with the word 'any': `Matchers.any()`, `Matchers.anyString()`, 
`anyCollection()`, etc. If you came across your project and found many of such
calls there is a high chance that something is wrong with your code. Let me explain
why.

{%
  include picture.html 
  href="2019-07-09-a-dog-in-a-car.jpeg" 
  copyright="Snatch (2000) by Guy Ritchie"
  alt="Two men and a dog in a car"
%}

Have you ever seen or written code like this?

```java
given(userService.findById(anyString()))
        .willReturn(new User("id", "John Doe"));
```

The key element here is the `anyString()` call. It introduces potential issues 
to the test. This way the test doesn't check the method correctly.
It doesn't guaranty that `findById()` is invoked with correct parameters.
This might be obvious to you, but I repeatedly see such code in real projects.

Let's suppose such mocking is used while testing the following method;

```java
public void addToWishList(String userId, String productId) {
    User user = userService.findById(userId);
    WishList wishList = user.getWishList();
    wishList.add(productId);
}
```

If I mistakenly pass `productId` instead of `userId` into `userService.findById()` 
call the test won't fail. The mocked `findById` method will always return a valid 
`User` object, disregards to what is passed as an argument. Even if I hardcode 
something like `userService.findById("1234")` in the method body the test will still 
be green. Such an issue could not have happened had I passed a concrete 
value instead of a matcher while mocking the call. 

So, why use 'any' matchers? In my opinion, there is no reason for doing that. You do 
not need 'any' matchers in most of the cases. Even if it looks like you need them,
there is always a different approach. For instance, they are often used when
static or final methods are invoked, but you can still mock static or final methods
using other libraries like `PowerMock`, etc.


There are also cases when it is really hard to mock all the classes in the call 
chain because there are too many parties involved. Sometimes it constantly fills 
like you would need to do a lot of work if you mock everything in a proper way. 
If this is the case - it is a sign of bad design and the solution would be to 
rethink the architecture. Probably you are violating some of the key design principles
such as Single Responsibility Principle. Fix the design first and mocking will be 
much easier.    
