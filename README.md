Works:
Use "assumeUnchanged" scripts. This turns Tortoise Git green tick icons to grey tick icons and git runs as normal (fast and smooth). Underscore at start of name so that .gitignore and the assumeUnchanged files are grouped together.


No use:
Using "worktreeSkip" scripts results in very large .git/ folder and get malloc errors while using git (on 32 bit 4GB RAM DVR). Tortoise Git green tick icons remain green.


No use:
Using Git LFS solves the Large File issue but it runs very slowly on Windows, so much so that it is unusable.


No use:
.git/info/exclude is the local version of .gitignore; files in exclude are ignored only locally (.gitignore should be committed to the repo and thus files in it should be ignored in all cloned repos). However, like .gitignore, the exclude file will not ignore files that are part of the repo already (ie: add files to git on laptop (contains .dll files), clone to DVR with exclude already set up to ignore .dlls will NOT ignore the .dll files that were added to the repo on the laptop). 
