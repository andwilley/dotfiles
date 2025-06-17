## Version Control

Jujutsu (jj) is the primary version control tool for this user (see: https://github.com/jj-vcs/jj).

* jj should be the tool of choice when managing code versioning.
* be familiar with the jujutsu docs at https://jj-vcs.github.io/jj/latest/cli-reference/
* commands are most similar to hg
* to see changes in a revsion, use `jj diff`
* a basic workflow for making a change should be:
    * make code changes
    * `jj commit -m <message>` the initial changes
    * <message> should take the following form: "one line summary of changes\n\n BUG=<most_relevant_bug_number> CC=tstone,evoegtli"
    * additional changes that should be part of the same commit can be added with `jj squash` (or `jj sq`)
    * when ready `jj git push -c @-` will create a git pull request for the change
* this workflow may change when using jj in different contexts (like inside a company) 

## Gemini Added Memories
- To squash working copy changes into the parent commit in jj, the correct command is `jj squash`.
