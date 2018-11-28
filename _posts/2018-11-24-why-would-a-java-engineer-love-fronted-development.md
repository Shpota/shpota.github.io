---
layout: post
title:  "Why would a Java Engineer Love Frontend Development"
date:   2018-11-24 10:00:00 +0200
comments: true
---
It often happens that backend developers don't like working with a frontend. 
Even more, some hate frontend development. The complaint is always
the same: JavaScript is hell, no types, hard to predict the result,
all that cross-browser stuff and many more. I was one of such guys but now
I'm on the other side as the situation with JavaScript has changed. No, they 
still invent a new framework a day. What I mean is that working with frontend 
is not a pain anymore. I'm going to explain some of the reasons why I like
frontend development and particularly why I like Angular with TypeScript. 

Test test...

{%
  include picture.html 
  href="2018-11-27-wesley-snipes.png" 
  copyright="Demolition Man (1993) by Marco Brambilla"
  alt="Two Paths"
%}



First of all, it is essentially important to choose suitable frontend technologies.
Though I didn't try that many frontend frameworks (I'm Java Developer after all),
I believe the combination of Angular and TypeScript is one of the best picks.
Angular is a well-designed framework, it is component oriented and Google takes care
of its development. TypeScript, on the other hand, is a modern object-oriented
language with strong typing. Microsoft takes care of implementing
the language. What's interesting is that here we witness the close collaboration of
Microsoft and Google which is, I'd say, a unique situation. For instance, Google
requested Microsoft to add decorators to TypeScript (known as annotations in 
Java) and they did it. Being supported by two IT giants I guess it is safe
to commit to these technologies.

And here is why you'll like them.

**It is easy to write Angular code if you know Java**

Yes, that's true. If you know Java you'll need very little to learn to work with
Angular. C-like syntax of TypeScript, heavy usage of annotations (decorators), 
dependency injection, HTML markup reminding JSP.

For instance, here is how a standard REST client might look like in TypeScript:

```typescript
@Injectable()
export class BookService {
    constructor(private http: HttpClientService) { }

    getBook(id: string): Observable<Book> {
        return this.http.get<Book>(`/api/books/${id}`)
            .map(res => plainToClass(Book, res));
    }
}
```
Looks familiar, isn't it? You can also notice the usage of generics which means that 
you can implement agile reusable interfaces and simplify your code just like you do
it in Java.

And here is how a loop might look like
```html
<ul>
  <li *ngFor="let book of boringBooks">
    {% raw %}Only today! Buy {{ book.title }} by {{ book.author }} with 30% discount.{% endraw %}
  </li>
</ul>
```

But don't get me wrong, these are different technologies, there are
plenty of complex things out there, but you don't need to
master them to be able to write decent code. In fact, you need just a tiny
subset of the language.

**No boilerplate code**

TypeScript simplifies a lot of areas that have not been updated for 20 years in Java.
You don't need getters and setters here, constructors look simpler and many more.

For instance, here is a standard Java class

```java
public class User {
    private String name;
    public User(String name) {
        this.name = name;
    }
    
    public String getName() {
        retrun name;
    }
}
```
And here is what it looks like in TypeScript:
```typescript
export class User {
    constructor(public name: string) { }
}
```

If you need to add an optional parameter to the constructor you'd have 
to implement one more constructor in Java, but In TypeScript
you only need to mark the optional argument with `?`:
```typescript
constructor(name: string, nickName?: string) { }
```
In this example `nickName` is optional.

You can also pass default values using the following constructions:
```typescript
constructor(foo: string = 'foo') { }
```

**Working with strings**

I guess every Java developer had a chance to "enjoy" writing multiline strings 
especially with some SQL code inside. No doubt it is a shame that every modern
language has this feature except Java.

In TypeScript you can easily write something like this:
```typescript
userMapkup(user: User) {  
  return `<div class="user-profile">
    <img src="${user.picture}">
    <p class="user-name">${user.name}</p>
  </div>`;
}
```
You might also notice one more great feature - String Interpolation (injection 
of variables directly into the string).

**Component-oriented Approach**

Angular is a component-based framework which means that Angular code consists of
independent units that represent small pieces of your application. Let's say you
have a web page representing a list of books. Most likely this page will be built
of several components: header and footer components, the table itself, a component
representing the dialog for adding new books, etc. They will obviously interact 
with each other but at the same time, they are independent. Each of them will have
its own layout. Each will be represented by an own class. They all will have 
different style sheets. All will be covered by unit tests separately.

In addition form structural point every component will look more or less the same:
```
+-- books
|   +-- books.component.ts
|   +-- books.component.html
|   +-- books.component.css
|   +-- books.component.spec.ts
|   +-- books.service.ts
```
The structure holds from project to project which is a huge benefit. The code is
testable and supportable.

**IDE support and Tooling**

It is not a secret that it's impossible to implement good tooling for JavaScrip
and generally for all dynamically typed languages. You simply don't know what is
the actual type of a variable and so you can't have a good code completion.
But it's not the case for TypeScript. Both Visual Studio Code and WebStorm
provide great support. Not only do they perform code completion and other basic functions, 
they also deeply integrate framework specific functionality like navigation to a component
definition, validators, linters, etc.

One more important thing is debugging. Though I cannot imagine better debugging experience than 
in Java ecosystem, but with Angular and TypeScript you get almost as good debug as in Java. 
IntelliJ IDEA and WebStorm are now [smart enough](https://blog.jetbrains.com/webstorm/2017/01/debugging-angular-apps/)
to use breakpoints directly in the TypeScript and not in the resulting JavaScript like 
you might expect. This makes the development process complete and enjoyable.

**Build Tools**

Just like in Java we have Gradle and Maven, in the frontend world they have their own tools
like NPM, Webpack, and Yarn. 

It is not a rocket science. You just need to know that these tools exist, 
they work pretty well, they are easy to use and you don't have to bundle 
your JavaScript code yourself.

One more noticeable tool is [Angular CLI](https://cli.angular.io/). It is a command 
line tool that allows creating components automatically. The following command will 
generate a minimal setup of a component including html/css/ts files, unit test 
template, etc. It will also add all needed imports.
```typescript
ng generate component books
```

In fact, Angular CLI is more than that. You can now generate a full application directly
from CLI.

**Fast updates with minimal breaking changes**

In the Java community, we are used to the fact that a code written 10 years ago
will work on a new JVM. There are some exceptions like transition from Java 8 
to Java 9, but generally, it's true. On the other hand, in frontend tendencies 
are different: you take a break for 6 months and boom, everything is changed,
everything is new for you.

Angular is somewhere in in-between. They release often, they introduce breaking
changes but at the same time, they make transitions soft.

For instance, when we migrated from Angular 3 to Angular 4 we literally changed 
a few lines of code. It was more complex to migrate from 4 to 5 as they introduced 
a new HTTP Client but there were no surprises.

The good thing is that if you take a developer who knows Angular 2 and ask them
to work with Angular 7 they won't have any problems.

**TypeScript makes it easy to write cross-browser code**

Since TypeScript is a compiled language you can always set the target JavaScript
version which will allow you to cover more browsers.

It is not a magical pill for all compatibility issues, but it solves majority
of them.

**Community**

The community is huge. You're not alone. You'll always find answers to your 
questions. Take a look on the "angular" tag [on 
stackoverflow](https://stackoverflow.com/questions/tagged/angular). Hundreds 
of questions are answered daily. 

Not to say that both Angular and TypeScript are open source technologies and 
you can often find help directly on GitHub.
