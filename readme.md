This is the LUA code for the FAF coop mod.

How do I start contributing?
----------------------------
If you want to contribute, then you'll need to know how **git** works. 
Here is a nice short [tutorial](http://wiki.faforever.com/index.php?title=FAF_Dev_School_Git) to get you started.

You should get local copies of both fa-coop and faf-coop-missions.

#### Use your lua code in a game
You should have a local copy of the code (both fa-coop and faf-coop-missions) on your computer.
Now you'll want to set up your test environment, i.e. running the game based on your local copies.

Inside of the fa-coop repository is an `init_coop_beta.lua` file that you need to **copy** inside ```C:\ProgramData\FAForever\bin\```
If you didn't use the default location for your GitHub folders, then you'll have to edit the file and change some file paths. The lines are at the start of the file, so you can't miss them.
*( Make sure you don't edit the original file, to avoid problems later )*

Inside the same folder, ```C:\ProgramData\FAForever\bin\```, you'll find `ForgedAlliance.exe`
Make a shortcut for it and put it in an easily accessable place. *(For example your desktop)*
Go into its properties (right click) and change the target:
```
ForgedAlliance.exe /init init_coop_beta.lua
or
ForgedAlliance.exe /init init_coop_beta.lua /showlog
```
If you add `/showlog` then the log window will automaticaly appear. There is an ingame keybind to summon the log window aswell. So it depends on your own prefence if you want it from the start or not.

You're finally ready to make changes to the lua code and test them!

#### Working with issues and pull requests
The main way of communication on github is done with issues and pull requests. 
- Whenever you find a problem or have an interesting idea, then you can make an issue for that. If there already is an issue for it, then you should comment on the original one, instead of making a new issue.
- Whenever you have something of value (bugfixes/improvements/etc) to add, you can make a pull request. Other contributors can review your changes and help improve them and/or confirm their validity. Afterwards your pull request will get merged into the master branch and will be a part of the future releases. So it is not only for sending your own changes, but also for reviewing others' pull requests. Reviewing can be quite laborous, so we'd like as many people as possible doing these so changes will be of a better quality and merged a lot faster.

##### Making an issue
To make an issue about a bug/possible improvement/new feature/etc, you should go to the original repositories webpage and [create an issue there](https://help.github.com/articles/creating-an-issue/).
Don't make issues in your own forked repository unless you don't want anyone to know about them.

When making an issue, you should follow these guidlines:
- Make a seperate issue for each bug/feature. 
So we avoid cluttered issues and everything is clear. 
- Start your issues message with the mission(s) that it applies too: 
  - **UEF M1 - X is wrong**
  - **All UEF - Y is wrong** 
  - **All - Z is wrong**
- Always add as much information as you can provide about the issue
  - Give a nice description of the issue *(where/when/what/how)*
  - Add the logs of your game
   You can find them here: `C:\ProgramData\FAForever\logs`
  - Provide the replay too. Watch it first (after you copied the logs) to see if the same thing happens as during the game.
     
##### Making a pull request
To make a pull request with your changes for a bugfix/possible improvement/new feature/etc, you should go to the original repositories webpage and [create a pull request there](https://help.github.com/articles/creating-a-pull-request-from-a-fork/).
Most of the time pull request will be related to an issue and merging it will solve the issue. You can close an issue manually but its a lot easier if it would automaticaly close when the pull request is merged. You can achieve this by adding a [keyword and a reference to the issue](https://help.github.com/articles/closing-issues-via-commit-messages/) inside the body of your pull request message.

When making a pull request, you should follow these guidelines:
- Start your issues message with the mission(s) that it applies too: 
  - **UEF M1 - X is fixed**
  - **All UEF - Y is fixed** 
  - **All - Z is fixed**
- Give a nice description of the changes *(where/when/what/how)*


Contributing conventions
---------------------------------

#### git convention
Use the normal git conventions for commit messages, with the following rules:
 - Subject line shorter than 80 characters
 - No trailing period
 - For non-trivial commits, always include a commit message body, describing the change in detail
 - If there are related issues, reference them in the commit message footer

We use [git flow](http://nvie.com/posts/a-successful-git-branching-model/) for our branch conventions.

When making _backwards incompatible API changes_, do so with a stub function and put in a logging statement including traceback. This gives time for mod authors to change their code, as well as for us to catch any incompatibilities introduced by the change.

#### Code convention

Please follow the [Lua Style Guide](http://lua-users.org/wiki/LuaStyleGuide) as
much as possible.

For file encoding, use UTF-8 and unix-style file endings in the repo (Set core.autocrlf).
