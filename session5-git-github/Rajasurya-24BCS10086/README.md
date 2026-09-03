# Git and GitHub - Homework

**Name:** Rajasurya J
**Roll number:** 24BCS10086

## Where I did this

I did both tasks inside this same repository, but on a separate branch called
**`git-hw-main`** so that I did not clutter the real `main` branch with practice
commits. For the cherry-pick task `git-hw-main` plays the role of "main" and
`feature-pages` is the new branch.

Both branches are pushed, so all the commits and hashes below can actually be
checked:

- `git-hw-main` -> https://github.com/rajasurya-rjs/devops-heros/commits/git-hw-main
- `feature-pages` -> https://github.com/rajasurya-rjs/devops-heros/commits/feature-pages

```bash
git clone https://github.com/rajasurya-rjs/devops-heros.git
cd devops-heros
git log --oneline --graph --all
```

The practice files live in `homework/git/practice/` on those branches.

---

# Task 1 - `git commit -a -m` vs `git commit -m`

## Setup

```
$ git switch -c git-hw-main
Switched to a new branch 'git-hw-main'

$ mkdir -p homework/git/practice && cd homework/git/practice
$ echo "line 1 - my first note" > notes.txt
$ git add notes.txt
$ git commit -m "add notes.txt for the commit -a practice"
```

Now the tree is clean. Then I made **two different kinds of change**:

```
$ echo "line 2 - added after the first commit" >> notes.txt   # modify a TRACKED file
$ echo "this file has never been committed" > extra.txt       # create an UNTRACKED file
```

```
$ git status
On branch git-hw-main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   notes.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	extra.txt

no changes added to commit (use "git add" and/or "git commit -a")
```

Two separate sections: `notes.txt` is **modified but not staged**, `extra.txt` is
**untracked**. This is the setup that makes the difference visible.

## Test 1 - plain `git commit -m`

```
$ git commit -m "try to commit without staging anything"
On branch git-hw-main
Changes not staged for commit:
	modified:   notes.txt

Untracked files:
	extra.txt

no changes added to commit (use "git add" and/or "git commit -a")
exit code: 1
```

**It refused to commit** and exited with code 1. `git commit -m` only commits
what is already in the **staging area (index)**, and I had not run `git add`, so
there was nothing to commit. Git even tells you the two ways out: `git add` or
`git commit -a`.

## Test 2 - `git commit -a -m`

```
$ git commit -a -m "add line 2 to notes.txt"
[git-hw-main b7cb29e] add line 2 to notes.txt
 1 file changed, 1 insertion(+)
exit code: 0
```

This time it worked - **1 file changed**. Note: *one* file, not two.

## The important bit - what happened to `extra.txt`?

```
$ git status
On branch git-hw-main
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	extra.txt

nothing added to commit but untracked files present (use "git add" to track)
```

```
$ git show --stat --oneline HEAD
b7cb29e add line 2 to notes.txt
 homework/git/practice/notes.txt | 1 +
 1 file changed, 1 insertion(+)
```

**`extra.txt` is still untracked.** The commit only contains `notes.txt`. This is
the whole point of the task: `-a` auto-stages **tracked** files, and a brand new
file is not tracked yet, so `-a` ignores it completely.

To actually commit it I had to add it by hand:

```
$ git add extra.txt
$ git commit -m "add extra.txt (needed git add first)"
[git-hw-main 55680d8] add extra.txt (needed git add first)
 1 file changed, 1 insertion(+)
 create mode 100644 homework/git/practice/extra.txt

$ git status
On branch git-hw-main
nothing to commit, working tree clean
```

## Bonus test - `-a` also stages deletions

Modifications are not the only thing `-a` catches. Deleting a tracked file counts
as a change to a tracked file:

```
$ rm extra.txt
$ git status --short
 D extra.txt

$ git commit -a -m "remove extra.txt - -a picks up deletions too"
[git-hw-main b6e0921] remove extra.txt - -a picks up deletions too
 1 file changed, 1 deletion(-)
 delete mode 100644 homework/git/practice/extra.txt

$ git status --short
(clean)
```

I never ran `git rm` or `git add` - `-a` staged the deletion by itself.

## Summary

| | `git commit -m` | `git commit -a -m` |
|---|---|---|
| Modified tracked file | ignored unless you `git add` | **staged automatically** |
| Deleted tracked file | ignored unless you `git add`/`git rm` | **staged automatically** |
| **New untracked file** | ignored | **still ignored** |
| Needs `git add` first? | yes | only for new files |
| Empty index | fails with exit code 1 | commits the tracked changes |

**In one line:** `-a` means "stage every change to files git already knows about,
then commit". It is a shortcut for `git add -u && git commit`, **not** for
`git add . && git commit`.

**What I learned / interview point:** `-a` is convenient but it is also a blunt
instrument - it sweeps up *every* modified tracked file, so it is easy to commit
a debug print or a stray config change you did not mean to include. `git status`
before committing, and `git add` for specific files, is the safer habit. And you
can never rely on `-a` when you have added new files.

---

# Task 2 - Git Cherry-Pick

## Step 1 - 3 commits on the main branch

```
$ mkdir -p cherry-pick-practice && cd cherry-pick-practice

$ echo '<h1>My Site</h1>' > index.html
$ git add index.html && git commit -m "add index.html homepage"

$ echo 'body { font-family: sans-serif; }' > style.css
$ git add style.css && git commit -m "add basic stylesheet"

$ echo '<p>Welcome to my site</p>' >> index.html
$ git add index.html && git commit -m "add welcome text to homepage"
```

```
$ git log --oneline -3
9fb12f1 add welcome text to homepage
15ee298 add basic stylesheet
ef399ee add index.html homepage

$ git branch --show-current
git-hw-main
```

## Step 2 - create a new branch and make 3 commits on it

```
$ git switch -c feature-pages
Switched to a new branch 'feature-pages'

$ echo '<h2>About</h2>' > about.html
$ git add about.html && git commit -m "add about page"

$ echo '<h2>Contact</h2><p>mail me</p>' > contact.html
$ git add contact.html && git commit -m "add contact page"

$ echo '<footer>copyright 2026</footer>' >> index.html
$ git add index.html && git commit -m "add footer to homepage"
```

```
$ git log --oneline -6
2154497 add footer to homepage
1e45e53 add contact page
b0910b0 add about page
9fb12f1 add welcome text to homepage
15ee298 add basic stylesheet
ef399ee add index.html homepage

$ ls
about.html
contact.html
index.html
style.css
```

## Step 3 - identify the one commit I want

I decided I only want the **contact page** on main - not the about page, not the
footer. That is commit **`1e45e53`**.

```
$ git show --stat --oneline 1e45e53
1e45e53 add contact page
 homework/git/practice/cherry-pick-practice/contact.html | 1 +
 1 file changed, 1 insertion(+)
```

## Step 4 - go back to main and cherry-pick it

```
$ git switch git-hw-main
Switched to branch 'git-hw-main'

$ ls
index.html
style.css
```

Only the two original files - as expected, none of the branch work is here yet.

```
$ git cherry-pick 1e45e53
[git-hw-main 74c7ba6] add contact page
 Date: Thu Sep 3 18:10:48 2026 +0530
 1 file changed, 1 insertion(+)
 create mode 100644 homework/git/practice/cherry-pick-practice/contact.html
exit code: 0
```

## Step 5 - verify

```
$ ls
contact.html
index.html
style.css

$ cat contact.html
<h2>Contact</h2><p>mail me</p>
```

`contact.html` is now on main.

```
$ git log --oneline -5
74c7ba6 add contact page
9fb12f1 add welcome text to homepage
15ee298 add basic stylesheet
ef399ee add index.html homepage
b6e0921 remove extra.txt - -a picks up deletions too
```

And the whole picture:

```
$ git log --oneline --graph --all -9
* 74c7ba6 add contact page
| * 2154497 add footer to homepage
| * 1e45e53 add contact page
| * b0910b0 add about page
|/
* 9fb12f1 add welcome text to homepage
* 15ee298 add basic stylesheet
* ef399ee add index.html homepage
* b6e0921 remove extra.txt - -a picks up deletions too
* 55680d8 add extra.txt (needed git add first)
```

```
$ git branch -v
  feature-pages 2154497 add footer to homepage
* git-hw-main   74c7ba6 add contact page
  main          76f3591 [ahead 3] shell scripting homework: system-info.sh
```

## What the output actually proves

1. **Only one commit came across.** `ls` on main shows `contact.html` but **not**
   `about.html`, and:

   ```
   $ cat index.html
   <h1>My Site</h1>
   <p>Welcome to my site</p>
   ```

   No `<footer>` line. So commits `b0910b0` and `2154497` were left behind - I
   copied exactly the one change I asked for.

2. **The hash changed: `1e45e53` -> `74c7ba6`.** The message and the diff are
   identical, but it is a **different commit object**. That is because a commit
   hash is computed from its content *and its parent*, and the new copy has a
   different parent (`9fb12f1` instead of `b0910b0`). Cherry-pick does not move a
   commit - it **replays the diff** as a brand new commit.

3. The graph shows the two lines of history diverging at `9fb12f1`, with
   `add contact page` appearing on **both** sides - once as the original and once
   as the replayed copy.

## What I learned

- `git cherry-pick <hash>` = "take the change this one commit made and apply it
  here". Very useful for pulling a single bugfix from a feature branch into a
  release branch without merging the half-finished features with it.
- The commit hash **always changes**, so the same change now exists twice in the
  repo. If the feature branch is merged later, git usually notices the identical
  patch and does not duplicate it, but it can also cause a conflict - which is
  why cherry-pick is for exceptions, not a substitute for merging.
- `git log --oneline --graph --all` is the command that makes any of this make
  sense. Without `--graph` I could not see that the branches diverged.
- If the patch does not apply cleanly you get a conflict and have to fix it, then
  `git cherry-pick --continue` (or `--abort` to back out). Mine applied cleanly
  because `contact.html` was a brand new file that nothing else touched.

## Command reference from this homework

| Command | What it does |
|---|---|
| `git status` | what is modified / staged / untracked |
| `git status --short` | the compact two-column version |
| `git add <file>` | stage a specific file (only way to add a new file) |
| `git commit -m "msg"` | commit **only what is staged** |
| `git commit -a -m "msg"` | auto-stage tracked modifications + deletions, then commit |
| `git log --oneline` | compact history |
| `git log --oneline --graph --all` | history of all branches with the branch structure |
| `git show --stat <hash>` | what one commit changed |
| `git switch -c <branch>` | create a branch and move to it |
| `git switch <branch>` | move to an existing branch |
| `git branch -v` | list branches with their latest commit |
| `git cherry-pick <hash>` | replay one commit onto the current branch |
| `git cherry-pick --abort` | undo a cherry-pick that hit a conflict |
