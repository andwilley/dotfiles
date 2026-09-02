Tool Use
--------

When a tool is available that doesn't require approval and can do the job, prefer that. Tool calls with high cardinality like bespoke python scripts will always require approval and block progress. Avoid them unless they're the only reasonable tool for the job.

Version Control
---------------

Jujutsu (jj) is the primary version control tool for this user (see: https://github.com/jj-vcs/jj).

-	jj should be the tool of choice when managing code versioning.
-	be familiar with the jujutsu docs at https://jj-vcs.github.io/jj/latest/cli-reference/
-	commands are most similar to hg
-	to see changes in a revision, use `jj diff`
-	Agents should almost always work in the current (working) commit (`@`) and must NOT commit or squash changes unless explicitly asked to do so.
