---
layout: post
title:  "Role-Based Authorization with JWT Using NestJS"
date:   2022-07-16 10:00:00 +0300
comments: true
img:
    href: 2022-07-16-terminator.jpg
    copyright: Terminator 2 (1991) by James Cameron
    alt: Terminator on a bike
---
Authentication and Authorization can be implemented in different ways using NestJS.
The framework has great documentation for that purpose. However, when it
comes to implementing a concrete scenario, there are many small details that have
to be taken into account. In this article, I will walk you through the steps
needed to set up JWT-based authentication and configure authorization to handle
different roles.

{% include picture.html %}

I will follow the examples from the documentation as close as possible to make it easier
to understand details. Feel free to check the
[Authentication](https://docs.nestjs.com/security/authentication) and 
[Authorization](https://docs.nestjs.com/security/authorization) pages from the documentation
if you need more details. Also, all source code from this article is available on GitHub, if
you only want to see the end result, just 
[check the repo](https://github.com/Shpota/role-based-athorization-in-nestj).

As a first step, we will generate a NestJS application.

```shell
npx @nestjs/cli new role-based-athorization-in-nestj
```

Navigate into the newly generated project and perform:

```shell
npm run start
```
If you open http://localhost:3000/ you will see the app running.

Perform the following commands to add all the needed dependencies:

```shell
npm install --save @nestjs/passport @nestjs/jwt passport passport-local passport-jwt
npm install --save-dev @types/passport-local @types/passport-jwt
```

We will add an endpoint with basic authentication that would allow obtaining a JWT token.
With a token, a user will be able to call other endpoints that will require having
a role.

Execute the following commands to create auth module, users module, and their services:

```shell
npx @nestjs/cli g module auth
npx @nestjs/cli g module users
npx @nestjs/cli g service auth
npx @nestjs/cli g service users
```

You will see a bunch of new files, we will need them later.

Create a `model` directory in the `src` folder of the project and add two files to it:
`role.enum.ts` and `user.entity.ts`.

```typescript
// model/role.enum.ts
export enum Role {
  User = 'user',
  Admin = 'admin',
}
```

```typescript
// model/user.entity.ts
import { Role } from './role.enum';

export interface User {
    userId: number;
    username: string;
    password: string;
    roles: Role[];
}
```

Update the content of `users/users.service.ts` to look like this:

```typescript
import { Injectable } from '@nestjs/common';
import { User } from '../model/user.entity';
import { Role } from '../model/role.enum';

@Injectable()
export class UsersService {
    private readonly users = [
        {
            userId: 1,
            username: 'anna',
            password: '12345',
            roles: [Role.User],
        },
        {
            userId: 2,
            username: 'andrew',
            password: '54321',
            roles: [Role.Admin],
        },
    ];

    async findOne(username: string): Promise<User | undefined> {
        return this.users.find((user) => user.username === username);
    }
}
```

This is just a stub to mock a user database.

Add a new export statement to the `UsersModule`:

```typescript
import { Module } from '@nestjs/common';
import { UsersService } from './users.service';

@Module({
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
```

Replace the content of `auth/auth.service.ts` with this code:

```typescript
import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service';

@Injectable()
export class AuthService {
  constructor(private usersService: UsersService) {}

  async validateUser(username: string, pass: string): Promise<any> {
    const user = await this.usersService.findOne(username);
    if (user && user.password === pass) {
      const { password, ...result } = user;
      return result;
    }
    return null;
  }
}
```

It checks if there is a user with the given username and password and returns
the user object excluding the password field.

Create `local.strategy.ts` in the `auth` folder:

```typescript
import { Strategy } from 'passport-local';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';

@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy) {
  constructor(private authService: AuthService) {
    super();
  }

  async validate(username: string, password: string): Promise<any> {
    const user = await this.authService.validateUser(username, password);
    if (!user) {
      throw new UnauthorizedException();
    }
    return user;
  }
}
```

The `LocalStrategy.validate()` method will be called when a user tries
to log in and obtain a JWT token.

Update `AuthModule`:

```typescript
import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { UsersModule } from '../users/users.module';
import { PassportModule } from '@nestjs/passport';
import { LocalStrategy } from './local.strategy';

@Module({
    imports: [UsersModule, PassportModule],
    providers: [AuthService, LocalStrategy],
})
export class AuthModule {}
```

And update the controller code in `app.controller.ts`:

```typescript
import { Controller, Request, Post, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Controller()
export class AppController {
  @UseGuards(AuthGuard('local'))
  @Post('auth/login')
  async login(@Request() req) {
    return req.user;
  }
}
```

This finalizes the implementation of a local login strategy. Users are able
to call the `/auth/login` endpoint passing their login and password. Later
we will update it to issue a JWT token. For now, you can run the application
and make a POST call to verify the authentication logic.

```shell
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  --data-raw '{
    "username": "anna",
    "password": "12345"
  }'
```

This is supposed to return the user object.

```shell
{"userId":1,"username":"anna","roles":["user"]}
```

### Issuing a JWT token

Now that the login endpoint is in place, let's make it return a JWT token using which the
user would access other endpoints.

Update `AuthService` to issue a JWT access token.

```typescript
import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async validateUser(username: string, pass: string): Promise<any> {
    const user = await this.usersService.findOne(username);
    if (user && user.password === pass) {
      const { password, ...result } = user;
      return result;
    }
    return null;
  }

  async login(user: any) {
    const payload = {
      username: user.username,
      sub: user.userId,
      roles: user.roles,
    };
    return {
      access_token: this.jwtService.sign(payload),
    };
  }
}
```

In the login method, it creates a payload that will be a part of the JWT token and signs it.

Create `constants.ts` in the  `auth` folder  where a JWT signing key will be stored.

```typescript
export const jwtConstants = {
  secret: 'secretKey',
};
```

In a real application, you will not store the token in a constant but rather read it
from environment variables, but it is fine for this example.

Now we need to register a JWT module in the `AuthModule` imports.

```typescript
import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LocalStrategy } from './local.strategy';
import { UsersModule } from '../users/users.module';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { jwtConstants } from './constants';

@Module({
  imports: [
    UsersModule,
    PassportModule,
    JwtModule.register({
      secret: jwtConstants.secret,
      signOptions: { expiresIn: '1h' },
    }),
  ],
  providers: [AuthService, LocalStrategy],
  exports: [AuthService],
})
export class AuthModule {}
```

In the controller code, instead of returning a user object, we will now return
an access token.

```typescript
import { Controller, Request, Post, UseGuards } from '@nestjs/common';
import { AuthService } from './auth/auth.service';
import { AuthGuard } from '@nestjs/passport';

@Controller()
export class AppController {
  constructor(private authService: AuthService) {}

  @UseGuards(AuthGuard('local'))
  @Post('auth/login')
  async login(@Request() req) {
    return this.authService.login(req.user);
  }
}
```

Now if you perform the same curl call, it will issue a JWT access token.

```shell
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  --data-raw '{
    "username": "anna",
    "password": "12345"
  }'
```

```typescript
{"access_token":"eyJhbGciOiJIUzI1NiIsInR..."}
```

If you decode the token (you can use [jwt.io](https://jwt.io/)), you will see that
it has all the information that was formed in the login method.

```json
{
  "username": "anna",
  "sub": 1,
  "roles": [
    "user"
  ],
  "iat": 1657867982,
  "exp": 1657871582
}
```

Now let's add a JWT strategy implementation. Create `auth/jwt.strategy.ts` 
with the following content:

```typescript
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable } from '@nestjs/common';
import { jwtConstants } from './constants';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
    constructor() {
        super({
            jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
            ignoreExpiration: false,
            secretOrKey: jwtConstants.secret,
        });
    }

    async validate(payload: any) {
        return {
            userId: payload.sub,
            username: payload.username,
            roles: payload.roles,
        };
    }
}
```

The validate method will be called after the user is successfully authenticated. The returned
value of this method is propagated into the request object that can be obtained in a controller.

Register `JwtStrategy` as a provider in the `AuthModule`.

```typescript
import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LocalStrategy } from './local.strategy';
import { JwtStrategy } from './jwt.strategy';
import { UsersModule } from '../users/users.module';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { jwtConstants } from './constants';

@Module({
  imports: [
    UsersModule,
    PassportModule,
    JwtModule.register({
      secret: jwtConstants.secret,
      signOptions: { expiresIn: '1h' },
    }),
  ],
  providers: [AuthService, LocalStrategy, JwtStrategy],
  exports: [AuthService],
})
export class AuthModule {}
```

Now we can add a new `profile` endpoint which would require a JWT token. Update `AppController`
to look like this:

```typescript
import { Controller, Request, Post, UseGuards, Get } from '@nestjs/common';
import { AuthService } from './auth/auth.service';
import { AuthGuard } from '@nestjs/passport';

@Controller()
export class AppController {
  constructor(private authService: AuthService) {}

  @UseGuards(AuthGuard('local'))
  @Post('auth/login')
  async login(@Request() req) {
    return this.authService.login(req.user);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('profile')
  getProfile(@Request() req) {
    return req.user;
  }
}
```

You can perform calls to the profile endpoint by passing the JWT token.

```shell
curl http://localhost:3000/profile -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR..."
```

### Verify users roles

Cool, now the application implements authentication with JWT. Note, we store roles here,
but they are never used. It is time to actually check roles as well. This way,
users with a particular role would be able to access only what they are supposed
to access.

Add `HasRoles` decorator which will be used to mark controller methods. Create
`has-roles.decorator.ts` in the `auth` folder.

```typescript
import { SetMetadata } from '@nestjs/common';
import { Role } from '../model/role.enum';

export const HasRoles = (...roles: Role[]) => SetMetadata('roles', roles);
```

Add a guard to perform the check, `auth/roles.guard.ts`.

```typescript
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '../model/role.enum';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles) {
      return true;
    }
    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some((role) => user?.roles?.includes(role));
  }
}
```

The guard reads the metadata from the `HasRoles` decorator and checks if
an endpoint requires any role. Returning `true` from this method means allowing access.
You can play around with the logic of this method as you wish. For instance, you might
want to adjust it in the way that an admin is allowed to access everything. You just
need to check if a user has the admin role and return `true`.

Finally, let's add two other endpoints that would either allow only users or only admins.

```typescript
import { Controller, Get, Post, Request, UseGuards } from '@nestjs/common';
import { AuthService } from './auth/auth.service';
import { AuthGuard } from '@nestjs/passport';
import { HasRoles } from './auth/has-roles.decorator';
import { Role } from './model/role.enum';
import { RolesGuard } from './auth/roles.guard';

@Controller()
export class AppController {
  constructor(private authService: AuthService) {}

  @UseGuards(AuthGuard('local'))
  @Post('auth/login')
  async login(@Request() req) {
    return this.authService.login(req.user);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('profile')
  getProfile(@Request() req) {
    return req.user;
  }

  @HasRoles(Role.Admin)
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Get('admin')
  onlyAdmin(@Request() req) {
    return req.user;
  }

  @HasRoles(Role.User)
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Get('user')
  onlyUser(@Request() req) {
    return req.user;
  }
}
```

You might have noticed that we have only two users in the system,
Anna with the user role, and Andrew with the admin role.

If you get Anna's JWT, you will be able to access the `/user` endpoint, and you will get
HTTP 403 when you try to access `/admin`. With Andrew's JWT you would access the admin endpoint,
but not the user endpoint.

If you made up till this point, congratulations! You have role-based authorization in place.

### Finishing touches

Instead of using `AuthGuard('jwt')` and `AuthGuard('local')`, it would be nice to have 
`JwtAuthGuard` and `LocalAuthGuard`.

Create `auth/jwt-auth.guard.ts` with this code:

```typescript
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {}
```

Add another one for local auth: `auth/local-auth.guard.ts`.

```typescript

import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class LocalAuthGuard extends AuthGuard('local') {}
```

Update controller to use the new guards.

```typescript
import { Controller, Get, Post, Request, UseGuards } from '@nestjs/common';
import { AuthService } from './auth/auth.service';
import { HasRoles } from './auth/has-roles.decorator';
import { Role } from './model/role.enum';
import { RolesGuard } from './auth/roles.guard';
import { LocalAuthGuard } from './auth/local-auth.guard';
import { JwtAuthGuard } from './auth/jwt-auth.guard';

@Controller()
export class AppController {
  constructor(private authService: AuthService) {}

  @UseGuards(LocalAuthGuard)
  @Post('auth/login')
  async login(@Request() req) {
    return this.authService.login(req.user);
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  getProfile(@Request() req) {
    return req.user;
  }

  @HasRoles(Role.Admin)
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Get('admin')
  onlyAdmin(@Request() req) {
    return req.user;
  }

  @HasRoles(Role.User)
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Get('user')
  onlyUser(@Request() req) {
    return req.user;
  }
}
```

You might also want to configure global guards which means they
will be applied by default without adding the decorators to the
controller methods. You can also override exceptions if you want
to provide custom error messages. But that is out of the scope
of this blog.